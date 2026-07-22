from app.models.schemas import BusinessAdviceRequest, BusinessAdviceResponse
from app.core.supabase import get_supabase
from app.core.logger import setup_logger

logger = setup_logger("business_advisor")


class BusinessAdvisor:
    async def advise(self, request: BusinessAdviceRequest, user_id: str) -> BusinessAdviceResponse:
        supabase = get_supabase()

        tx_result = supabase.table("transactions") \
            .select("type, amount") \
            .eq("user_id", user_id) \
            .limit(100) \
            .execute()

        vendor_result = supabase.table("vendors") \
            .select("*") \
            .eq("user_id", user_id) \
            .execute()

        transactions = tx_result.data or []
        vendors = vendor_result.data or []

        revenue = sum(
            float(t["amount"]) for t in transactions if t.get("type") == "income"
        )
        expenses = sum(
            float(t["amount"]) for t in transactions if t.get("type") == "expense"
        )
        profit = revenue - expenses
        margin = ((profit / revenue) * 100) if revenue > 0 else 0

        q = request.question.lower()
        answer = ""

        if "profit" in q or "revenue" in q or "growth" in q:
            answer = (
                f"Your revenue is ${revenue:,.2f} with expenses of ${expenses:,.2f}. "
                f"Profit margin: {margin:.1f}%. "
                + ("Consider optimizing costs." if margin < 20
                   else "Your margins look healthy!")
            )

        elif "vendor" in q or "supplier" in q:
            answer = f"You have {len(vendors)} vendors. "
            if vendors:
                top = vendors[0]
                answer += (
                    f"Top vendor: {top['name']} "
                    f"(${float(top.get('monthly_spend', 0)):,.2f}/mo). "
                    f"Health score: {top.get('health_score', 'N/A')}/100."
                )
            else:
                answer += "Consider diversifying your supplier base."

        elif "cash" in q or "runway" in q:
            monthly_avg = expenses / 3 if expenses > 0 else 0
            runway = int(100000 / monthly_avg) if monthly_avg > 0 else 12
            answer = f"Estimated cash runway: ~{runway} months based on current spending."

        else:
            ratio = (expenses / revenue * 100) if revenue > 0 else 0
            answer = (
                f"Revenue: ${revenue:,.2f} | Expenses: ${expenses:,.2f} | "
                f"Vendors: {len(vendors)} | Expense ratio: {ratio:.1f}%"
            )

        return BusinessAdviceResponse(
            answer=answer,
            metrics={
                "revenue": round(revenue, 2),
                "expenses": round(expenses, 2),
                "profit": round(profit, 2),
                "margin": round(margin, 1),
                "vendor_count": len(vendors),
            },
        )
