from collections import defaultdict
from app.models.schemas import PatternAnalysisRequest, PatternAnalysisResponse
from app.core.supabase import get_supabase
from app.core.logger import setup_logger

logger = setup_logger("pattern_recognizer")


class PatternRecognizer:
    async def analyze(self, request: PatternAnalysisRequest) -> PatternAnalysisResponse:
        supabase = get_supabase()

        result = supabase.table("transactions") \
            .select("*") \
            .eq("user_id", request.user_id) \
            .order("date", desc=True) \
            .limit(500) \
            .execute()

        transactions = result.data or []
        patterns = []

        if len(transactions) < 10:
            return PatternAnalysisResponse(
                patterns_detected=0,
                patterns=[],
            )

        day_patterns = self._detect_day_of_week_patterns(transactions)
        merchant_patterns = self._detect_merchant_patterns(transactions)
        category_patterns = self._detect_category_trends(transactions)

        patterns.extend(day_patterns)
        patterns.extend(merchant_patterns)
        patterns.extend(category_patterns)

        for p in patterns:
            supabase.table("behavior_patterns").upsert({
                "user_id": request.user_id,
                "pattern_type": p["type"],
                "pattern_name": p["name"],
                "description": p["description"],
                "category": p.get("category", "general"),
                "frequency": p.get("frequency", "monthly"),
                "confidence_score": p.get("confidence", 50),
                "last_observed_at": p.get("last_observed", ""),
                "metadata": p.get("metadata", {}),
            }, on_conflict="user_id,pattern_type,pattern_name").execute()

        return PatternAnalysisResponse(
            patterns_detected=len(patterns),
            patterns=patterns,
        )

    def _detect_day_of_week_patterns(self, transactions: list) -> list:
        patterns = []
        day_names = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        day_data = {d: {"count": 0, "total": 0.0, "categories": set()} for d in day_names}

        from datetime import datetime

        for tx in transactions:
            dt = datetime.fromisoformat(tx["date"].replace("Z", "+00:00"))
            day_name = day_names[dt.weekday()]
            day_data[day_name]["count"] += 1
            day_data[day_name]["total"] += float(tx.get("amount", 0))
            if tx.get("category"):
                day_data[day_name]["categories"].add(tx["category"])

        total = len(transactions)
        expected = total / 7

        for day, data in day_data.items():
            if data["count"] > expected * 1.5 and data["count"] >= 3:
                cats = list(data["categories"])[:3]
                patterns.append({
                    "type": "recurring-spend",
                    "name": f"{day} Spending Pattern",
                    "description": (
                        f"You tend to spend more on {day}s. "
                        f"Average: ${data['total'] / data['count']:.2f}. "
                        f"Categories: {', '.join(cats)}"
                    ),
                    "category": cats[0] if cats else "general",
                    "frequency": "weekly",
                    "confidence": min(95, int((data["count"] / expected) * 50)),
                    "last_observed": transactions[0].get("date", ""),
                    "metadata": {
                        "day": day,
                        "avg_amount": round(data["total"] / data["count"], 2),
                        "transaction_count": data["count"],
                    },
                })

        return patterns

    def _detect_merchant_patterns(self, transactions: list) -> list:
        patterns = []
        merchant_data: dict[str, dict] = {}

        for tx in transactions:
            merchant = tx.get("merchant")
            if not merchant:
                continue
            if merchant not in merchant_data:
                merchant_data[merchant] = {"count": 0, "total": 0.0, "categories": set()}
            merchant_data[merchant]["count"] += 1
            merchant_data[merchant]["total"] += float(tx.get("amount", 0))
            if tx.get("category"):
                merchant_data[merchant]["categories"].add(tx["category"])

        for merchant, data in merchant_data.items():
            if data["count"] >= 5:
                cats = list(data["categories"])
                patterns.append({
                    "type": "recurring-spend",
                    "name": f"Regular {merchant} Visits",
                    "description": (
                        f"You've visited {merchant} {data['count']} times. "
                        f"Total spent: ${data['total']:,.2f}."
                    ),
                    "category": cats[0] if cats else "general",
                    "frequency": "weekly" if data["count"] > 20 else "monthly",
                    "confidence": min(90, int((data["count"] / 50) * 80)),
                    "last_observed": transactions[0].get("date", ""),
                    "metadata": {
                        "merchant": merchant,
                        "avg_amount": round(data["total"] / data["count"], 2),
                        "visit_count": data["count"],
                    },
                })

        return patterns

    def _detect_category_trends(self, transactions: list) -> list:
        patterns = []
        monthly: dict[str, dict[str, float]] = defaultdict(lambda: defaultdict(float))

        from datetime import datetime

        for tx in transactions:
            category = tx.get("category")
            if not category:
                continue
            dt = datetime.fromisoformat(tx["date"].replace("Z", "+00:00"))
            month_key = dt.strftime("%Y-%m")
            monthly[category][month_key] += float(tx.get("amount", 0))

        for category, months in monthly.items():
            sorted_months = sorted(months.items())
            if len(sorted_months) >= 3:
                first_amount = sorted_months[0][1]
                last_amount = sorted_months[-1][1]
                change = ((last_amount - first_amount) / first_amount * 100) if first_amount > 0 else 0

                if abs(change) > 30:
                    direction = "increased" if change > 0 else "decreased"
                    patterns.append({
                        "type": "seasonal-spend",
                        "name": f"{category.title()} Spending Trend",
                        "description": (
                            f"Your {category} spending has {direction} by "
                            f"{abs(round(change))}% over {len(sorted_months)} months."
                        ),
                        "category": category,
                        "frequency": "monthly",
                        "confidence": min(85, int(abs(change))),
                        "last_observed": sorted_months[-1][0],
                        "metadata": {
                            "trend": "up" if change > 0 else "down",
                            "change_percent": round(change),
                            "months_tracked": len(sorted_months),
                        },
                    })

        return patterns
