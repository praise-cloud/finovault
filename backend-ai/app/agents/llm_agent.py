import json
from openai import OpenAI
from app.core.config import settings
from app.core.logger import setup_logger

logger = setup_logger("llm_agent")

OPENROUTER_BASE_URL = "https://openrouter.ai/api/v1"
DEFAULT_MODEL = "openai/gpt-4o-mini"
BUSINESS_MODEL = "anthropic/claude-3.5-sonnet"

_client: OpenAI | None = None


def get_client() -> OpenAI | None:
    global _client
    if _client is not None:
        return _client
    if not settings.OPENROUTER_API_KEY:
        logger.warning("OPENROUTER_API_KEY not configured — LLM disabled")
        return None
    _client = OpenAI(
        base_url=OPENROUTER_BASE_URL,
        api_key=settings.OPENROUTER_API_KEY,
        default_headers={
            "HTTP-Referer": "https://finovault.ai",
            "X-Title": "Finovault AI Engine",
        },
    )
    return _client


def build_system_prompt(role: str, context: dict) -> str:
    base = (
        "You are Finovault AI, a financial intelligence assistant for a premium "
        "Mauritian fintech platform. Respond in a professional, trustworthy tone "
        "— aspirational but not playful. "
        "Provide specific, actionable advice. If exact numbers aren't available, "
        "use the context provided or say so rather than inventing data.\n\n"
    )
    parts = [base]
    if context.get("user_name"):
        parts.append(f"User: {context['user_name']}")
    if context.get("transactions"):
        txs = context["transactions"]
        if isinstance(txs, list) and len(txs) > 0:
            total_spent = sum(
                float(t.get("amount", 0)) for t in txs if t.get("type") == "expense"
            )
            total_income = sum(
                float(t.get("amount", 0)) for t in txs if t.get("type") == "income"
            )
            parts.append(
                f"Recent activity — spent: ${total_spent:,.2f}, "
                f"income: ${total_income:,.2f} ({len(txs)} transactions)"
            )
    if context.get("savings_goals"):
        goals = context["savings_goals"]
        if isinstance(goals, list) and len(goals) > 0:
            saved = sum(float(g.get("current_amount", 0)) for g in goals)
            parts.append(f"Savings goals total: ${saved:,.2f} across {len(goals)} goals")
    if context.get("revenue") is not None:
        parts.append(f"Business revenue: ${context['revenue']:,.2f}")
    if context.get("expenses") is not None:
        parts.append(f"Business expenses: ${context['expenses']:,.2f}")
    if context.get("vendor_count") is not None:
        parts.append(f"Active vendors: {context['vendor_count']}")
    if context.get("profile"):
        profile = context["profile"]
        if isinstance(profile, dict):
            if profile.get("financial_goals"):
                parts.append(f"Financial goals: {profile['financial_goals']}")
            if profile.get("risk_tolerance"):
                parts.append(f"Risk tolerance: {profile['risk_tolerance']}")
    return "\n".join(parts)


async def ask(
    question: str,
    context: dict,
    role: str = "coach",
    model: str | None = None,
) -> dict:
    client = get_client()
    if client is None:
        logger.warning(f"LLM unavailable for {role}, returning empty")
        return {"answer": "", "suggestions": [], "used_llm": False}

    system = build_system_prompt(role, context)
    selected_model = model or (BUSINESS_MODEL if role == "business" else DEFAULT_MODEL)

    try:
        response = client.chat.completions.create(
            model=selected_model,
            messages=[
                {"role": "system", "content": system},
                {
                    "role": "user",
                    "content": (
                        f"{question}\n\n"
                        "Respond with JSON: {\"answer\": \"...\", \"suggestions\": [\"...\"]}"
                    ),
                },
            ],
            temperature=0.7,
            max_tokens=800,
            response_format={"type": "json_object"},
        )
        content = response.choices[0].message.content
        if not content:
            raise ValueError("Empty LLM response")
        parsed = json.loads(content)
        tokens = response.usage
        logger.info(
            f"[LLM] {role} — model={selected_model}, "
            f"tokens={tokens.total_tokens if tokens else 'unknown'}"
        )
        return {
            "answer": parsed.get("answer", ""),
            "suggestions": parsed.get("suggestions", []),
            "used_llm": True,
        }
    except Exception as e:
        logger.warning(f"[LLM] {role} call failed: {e}")
        return {"answer": "", "suggestions": [], "used_llm": False}
