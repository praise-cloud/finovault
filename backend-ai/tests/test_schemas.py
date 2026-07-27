import pytest
from pydantic import ValidationError
from app.models.schemas import (
    FraudCheckRequest, FraudCheckResponse,
    CoachRequest, CoachResponse,
    PatternAnalysisRequest, PatternAnalysisResponse,
    BusinessAdviceRequest, BusinessAdviceResponse,
)


class TestFraudSchemas:
    def test_fraud_request_valid(self):
        req = FraudCheckRequest(amount=100.0, merchant="Shop")
        assert req.amount == 100.0
        assert req.merchant == "Shop"

    def test_fraud_request_amount_must_be_positive(self):
        with pytest.raises(ValidationError):
            FraudCheckRequest(amount=0)

    def test_fraud_request_negative_amount(self):
        with pytest.raises(ValidationError):
            FraudCheckRequest(amount=-50)

    def test_fraud_response_risk_score_clamped(self):
        with pytest.raises(ValidationError):
            FraudCheckResponse(risk_score=150, risk_level="high", decision="allow")

    def test_fraud_response_valid(self):
        resp = FraudCheckResponse(risk_score=50, risk_level="medium", decision="freeze")
        assert resp.risk_score == 50
        assert resp.risk_level == "medium"
        assert resp.decision == "freeze"


class TestCoachSchemas:
    def test_coach_request_valid(self):
        req = CoachRequest(question="How can I save more?")
        assert req.question == "How can I save more?"

    def test_coach_request_empty_question(self):
        with pytest.raises(ValidationError):
            CoachRequest(question="")

    def test_coach_response_valid(self):
        resp = CoachResponse(answer="Save 20%", suggestions=["Set up auto-transfer"])
        assert resp.answer == "Save 20%"
        assert resp.suggestions == ["Set up auto-transfer"]


class TestPatternSchemas:
    def test_pattern_request_default(self):
        req = PatternAnalysisRequest()
        assert req.force is False

    def test_pattern_request_force_true(self):
        req = PatternAnalysisRequest(force=True)
        assert req.force is True

    def test_pattern_response_valid(self):
        resp = PatternAnalysisResponse(patterns_detected=2, patterns=[{"type": "recurring"}])
        assert resp.patterns_detected == 2
        assert len(resp.patterns) == 1


class TestBusinessSchemas:
    def test_business_request_valid(self):
        req = BusinessAdviceRequest(question="How to increase profit?")
        assert req.question == "How to increase profit?"

    def test_business_request_empty_question(self):
        with pytest.raises(ValidationError):
            BusinessAdviceRequest(question="")

    def test_business_response_valid(self):
        resp = BusinessAdviceResponse(answer="Cut costs", metrics={"profit": 1000})
        assert resp.answer == "Cut costs"
        assert resp.metrics["profit"] == 1000
