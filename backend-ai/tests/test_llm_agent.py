import pytest
from app.agents.llm_agent import build_system_prompt, get_client


class TestBuildSystemPrompt:
    def test_base_prompt_has_finovault_identity(self):
        prompt = build_system_prompt("coach", {})
        assert "Finovault AI" in prompt

    def test_includes_user_name(self):
        prompt = build_system_prompt("coach", {"user_name": "Alice"})
        assert "Alice" in prompt

    def test_includes_transaction_summary(self):
        prompt = build_system_prompt("coach", {
            "transactions": [
                {"amount": "100", "type": "expense"},
                {"amount": "500", "type": "income"},
            ],
        })
        assert "$100" in prompt or "$500" in prompt

    def test_includes_savings_goals(self):
        prompt = build_system_prompt("coach", {
            "savings_goals": [
                {"current_amount": "500"},
                {"current_amount": "300"},
            ],
        })
        assert "$800" in prompt

    def test_includes_business_context(self):
        prompt = build_system_prompt("business", {
            "revenue": 10000,
            "expenses": 4000,
            "vendor_count": 5,
        })
        assert "$10,000" in prompt or "$4,000" in prompt

    def test_no_context_returns_base(self):
        prompt = build_system_prompt("coach", {})
        assert prompt.startswith("You are Finovault AI")


class TestGetClient:
    def test_returns_none_when_no_api_key(self, monkeypatch):
        monkeypatch.setattr("app.agents.llm_agent.settings.OPENROUTER_API_KEY", "")
        assert get_client() is None

    def test_returns_client_with_api_key(self, monkeypatch):
        monkeypatch.setattr("app.agents.llm_agent.settings.OPENROUTER_API_KEY", "sk-test")
        client = get_client()
        assert client is not None
