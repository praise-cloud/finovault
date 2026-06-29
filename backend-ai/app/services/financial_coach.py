import json
from app.models.schemas import CoachRequest, CoachResponse
from app.core.supabase import get_supabase
from app.core.logger import setup_logger

logger = setup_logger("financial_coach")


class FinancialCoach:
    async def answer(self, request: CoachRequest) -> CoachResponse:
        supabase = get_supabase()

        profile = supabase.table("profiles") \
            .select("*") \
            .eq("id", request.user_id) \
            .execute()

        transactions = supabase.table("transactions") \
            .select("type, amount, category, merchant, date") \
            .eq("user_id", request.user_id) \
            .order("date", desc=True) \
            .limit(30) \
            .execute()

        goals = supabase.table("savings_goals") \
            .select("*") \
            .eq("user_id", request.user_id) \
            .execute()

        user_name = profile.data[0]["full_name"] if profile.data else "User"
        tx_data = transactions.data or []
        goals_data = goals.data or []

        total_spent = sum(
            float(t["amount"]) for t in tx_data if t.get("type") == "expense"
        )
        total_income = sum(
            float(t["amount"]) for t in tx_data if t.get("type") == "income"
        )
        total_saved = sum(
            float(g["current_amount"]) for g in goals_data
        )

        q = request.question.lower()
        suggestions = []

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

        supabase.table("ai_conversations").insert({
            "user_id": request.user_id,
            "session_id": request.user_id,
            "role": "assistant",
            "content": answer,
            "context": {
                "user_name": user_name,
                "total_spent": total_spent,
                "total_income": total_income,
                "total_saved": total_saved,
                "question_asked": request.question,
            },
        }).execute()

        return CoachResponse(answer=answer, suggestions=suggestions)
