import asyncio
from collections import defaultdict
from app.models.schemas import CoachRequest, CoachResponse
from app.core.supabase import async_execute, get_supabase
from app.core.logger import setup_logger
from app.agents.llm_agent import ask as llm_ask

logger = setup_logger("financial_coach")


def _aggregate_by_category(transactions: list, tx_type: str) -> list[dict]:
    cats: dict[str, dict] = defaultdict(
        lambda: {"total": 0.0, "count": 0, "merchants": set()}
    )
    for t in transactions:
        if t.get("type") != tx_type:
            continue
        cat = t.get("category") or "General"
        cats[cat]["total"] += float(t.get("amount", 0))
        cats[cat]["count"] += 1
        if t.get("merchant"):
            cats[cat]["merchants"].add(t["merchant"])
    result = []
    for cat, data in sorted(cats.items(), key=lambda x: -x[1]["total"]):
        result.append({
            "category": cat,
            "total": round(data["total"], 2),
            "count": data["count"],
            "avg": round(data["total"] / data["count"], 2) if data["count"] else 0,
            "merchants": list(data["merchants"]),
        })
    return result


class FinancialCoach:
    async def answer(self, request: CoachRequest, user_id: str) -> CoachResponse:
        supabase = get_supabase()

        profile, transactions, goals, patterns, accounts = await _fetch_user_data(
            supabase, user_id
        )

        user_name = profile.data[0]["full_name"] if profile.data else "User"
        tx_data = transactions.data or []
        goals_data = goals.data or []
        patterns_data = patterns.data or []
        accounts_data = accounts.data or []

        total_spent = sum(
            float(t["amount"]) for t in tx_data if t.get("type") == "expense"
        )
        total_income = sum(
            float(t["amount"]) for t in tx_data if t.get("type") == "income"
        )
        total_saved = sum(
            float(g["current_amount"]) for g in goals_data
        )

        expense_by_cat = _aggregate_by_category(tx_data, "expense")
        income_by_cat = _aggregate_by_category(tx_data, "income")

        context = {
            "user_name": user_name,
            "spending_summary": expense_by_cat,
            "income_summary": income_by_cat,
            "total_spent": round(total_spent, 2),
            "total_income": round(total_income, 2),
            "total_saved": round(total_saved, 2),
            "savings_goals": [
                {
                    "name": g["name"],
                    "current": float(g.get("current_amount", 0)),
                    "target": float(g.get("target_amount", 0)),
                    "progress_pct": round(
                        float(g.get("current_amount", 0))
                        / max(float(g.get("target_amount", 1)), 1)
                        * 100,
                        1,
                    ),
                    "status": g.get("status", "active"),
                }
                for g in goals_data
            ],
            "behavior_patterns": [
                {
                    "name": p.get("pattern_name", ""),
                    "type": p.get("pattern_type", ""),
                    "description": p.get("description", ""),
                    "confidence": p.get("confidence_score", 50),
                }
                for p in patterns_data
            ],
            "accounts": [
                {
                    "bank": a.get("bank_name", ""),
                    "type": a.get("account_type", ""),
                    "balance": float(a.get("balance", 0)),
                }
                for a in accounts_data
            ],
            "profile": profile.data[0] if profile.data else None,
        }

        llm_result = await llm_ask(
            question=request.question,
            context=context,
            role="coach",
        )

        answer: str
        suggestions: list[str] = []

        if llm_result["used_llm"]:
            logger.info(f"[LLM] Coach answered via OpenRouter for user {user_id}")
            answer = llm_result["answer"]
            suggestions = llm_result["suggestions"]
        else:
            logger.info(f"[FALLBACK] Coach used keyword rules for user {user_id}")
            answer, suggestions = _fallback_response(
                request.question, user_name,
                total_spent, total_income, total_saved, goals_data,
            )

        try:
            await async_execute(
                supabase.table("ai_conversations").insert({
                    "user_id": user_id,
                    "session_id": user_id,
                    "role": "assistant",
                    "content": answer,
                    "context": {
                        "user_name": user_name,
                        "total_spent": total_spent,
                        "total_income": total_income,
                        "total_saved": total_saved,
                        "question_asked": request.question,
                        "llm_used": llm_result["used_llm"],
                    },
                })
            )
        except Exception as db_err:
            logger.warning(f"Failed to persist conversation for user {user_id}: {db_err}")

        await _persist_suggestions(supabase, user_id, suggestions, user_name)

        return CoachResponse(answer=answer, suggestions=suggestions)


async def _fetch_user_data(supabase, user_id: str):
    profile_fut = async_execute(
        supabase.table("profiles").select("*").eq("id", user_id)
    )
    tx_fut = async_execute(
        supabase.table("transactions")
        .select("type, amount, category, merchant, date")
        .eq("user_id", user_id)
        .order("date", desc=True)
        .limit(30)
    )
    goals_fut = async_execute(
        supabase.table("savings_goals").select("*").eq("user_id", user_id)
    )
    patterns_fut = async_execute(
        supabase.table("behavior_patterns")
        .select("pattern_name, pattern_type, description, confidence_score")
        .eq("user_id", user_id)
        .order("last_observed_at", desc=True)
        .limit(10)
    )
    accounts_fut = async_execute(
        supabase.table("linked_accounts")
        .select("bank_name, account_type, balance")
        .eq("user_id", user_id)
    )

    results = await asyncio.gather(
        profile_fut, tx_fut, goals_fut, patterns_fut, accounts_fut,
        return_exceptions=True,
    )

    def _safe(idx):
        return results[idx] if not isinstance(results[idx], Exception) else type("R", (), {"data": None})()

    return tuple(_safe(i) for i in range(5))


def _fallback_response(
    question: str, user_name: str,
    total_spent: float, total_income: float,
    total_saved: float, goals_data: list,
) -> tuple[str, list[str]]:
    q = question.lower()
    suggestions: list[str] = []

    if "save" in q or "saving" in q:
        answer = (
            f"Great question, {user_name}! Based on your activity, "
            f"you've saved ${total_saved:,.2f} so far. "
            f"I recommend setting aside 20% of your income each month. "
            f"Would you like me to suggest a personalized savings plan?"
        )
        suggestions.append("Set up automatic savings transfer")
        suggestions.append("Review subscription services")
    elif "spend" in q or "spending" in q:
        pct = (total_spent / total_income * 100) if total_income > 0 else 0
        answer = (
            f"Your recent spending totals ${total_spent:,.2f}, "
            f"which is {pct:.0f}% of your income. "
            f"Would you like a detailed breakdown by category?"
        )
        suggestions.append("Get category breakdown")
        suggestions.append("Set spending limits")
    elif "invest" in q:
        answer = (
            f"Investing is powerful for building wealth, {user_name}. "
            f"A diversified portfolio with equities (60%), fixed income (25%), "
            f"and alternatives (15%) could work well for you. "
            f"Would you like help setting up an investment plan?"
        )
        suggestions.append("Learn about index funds")
        suggestions.append("Calculate risk tolerance")
    elif "budget" in q:
        answer = (
            f"Budgeting is key to financial health! Try the 50/30/20 rule: "
            f"50% needs, 30% wants, 20% savings. "
            f"Would you like me to create a custom budget?"
        )
        suggestions.append("Create a custom budget")
        suggestions.append("Track expenses automatically")
    elif "debt" in q or "loan" in q:
        answer = (
            f"Managing debt wisely is important. Consider the avalanche method "
            f"(highest interest first) or snowball method (smallest first). "
            f"Would you like a debt repayment strategy?"
        )
        suggestions.append("Calculate debt payoff timeline")
        suggestions.append("Explore consolidation options")
    else:
        answer = (
            f"That's a thoughtful question, {user_name}! "
            f"Based on your profile, I'd recommend tracking expenses regularly "
            f"and setting clear financial goals. "
            f"What specific area would you like to focus on?"
        )

    return answer, suggestions


async def _persist_suggestions(supabase, user_id: str, suggestions: list[str], user_name: str) -> None:
    for sug in suggestions:
        try:
            await async_execute(
                supabase.table("ai_suggestions").insert({
                    "user_id": user_id,
                    "title": sug,
                    "description": f"Suggested during chat with AI Coach for {user_name}",
                    "type": "coach_chat",
                    "status": "active",
                })
            )
        except Exception as e:
            logger.warning(f"Failed to persist suggestion: {e}")
