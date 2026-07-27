import pytest
from unittest.mock import AsyncMock
from app.services.fraud_detector import FraudDetector
from app.models.schemas import FraudCheckRequest


@pytest.fixture
def mock_execute(monkeypatch):
    async def fake_execute(_query):
        class FakeResult:
            data = []
        return FakeResult()
    monkeypatch.setattr("app.services.fraud_detector.async_execute", fake_execute)
    return fake_execute


@pytest.fixture
def detector(mock_execute):
    return FraudDetector()


@pytest.mark.asyncio
async def test_low_risk_small_amount(detector):
    req = FraudCheckRequest(amount=50.0, merchant="Shop", category="food")
    result = await detector.analyze(req, "test-user-id")
    assert result.risk_level == "low"
    assert result.decision == "allow"
    assert result.risk_score < 25


@pytest.mark.asyncio
async def test_high_value_above_10k(detector):
    req = FraudCheckRequest(amount=15000.0, merchant="Luxury")
    result = await detector.analyze(req, "test-user-id")
    assert result.risk_score >= 20
    assert "High value transaction" in result.signals[0]


@pytest.mark.asyncio
async def test_very_high_value_above_50k(detector):
    req = FraudCheckRequest(amount=75000.0, merchant="Car Dealer")
    result = await detector.analyze(req, "test-user-id")
    assert result.risk_score >= 40
    assert result.risk_level == "medium"


@pytest.mark.asyncio
async def test_high_risk_with_receiver_and_anomaly(monkeypatch):
        async def fake_execute(_query):
            class FakeResult:
                data = [{"amount": 50}, {"amount": 75}, {"amount": 60}, {"amount": 55},
                        {"amount": 80}, {"amount": 45}, {"amount": 70}, {"amount": 65},
                        {"amount": 90}, {"amount": 85}, {"amount": 40}, {"amount": 95}]
            return FakeResult()
        monkeypatch.setattr("app.services.fraud_detector.async_execute", fake_execute)

        detector = FraudDetector()
        req = FraudCheckRequest(amount=75000.0, receiver="new@vendor.com")
        result = await detector.analyze(req, "test-user-id")
        assert result.risk_score > 65
        assert result.risk_level in ("high", "critical")


@pytest.mark.asyncio
async def test_new_receiver_adds_risk(detector):
    req = FraudCheckRequest(amount=500.0, receiver="new-vendor@example.com")
    result = await detector.analyze(req, "test-user-id")
    assert result.risk_score >= 10
    assert any("receiver" in s.lower() for s in result.signals)


@pytest.mark.asyncio
async def test_risk_score_capped_at_100(detector):
    req = FraudCheckRequest(amount=200000.0, receiver="new@vendor.com")
    result = await detector.analyze(req, "test-user-id")
    assert result.risk_score <= 100


@pytest.mark.asyncio
async def test_z_score_detects_anomaly(monkeypatch):
    async def fake_execute(_query):
        class FakeResult:
            data = [{"amount": 50}, {"amount": 75}, {"amount": 60}, {"amount": 55},
                    {"amount": 80}, {"amount": 45}, {"amount": 70}, {"amount": 65},
                    {"amount": 90}, {"amount": 85}, {"amount": 40}, {"amount": 95}]
        return FakeResult()
    monkeypatch.setattr("app.services.fraud_detector.async_execute", fake_execute)

    detector = FraudDetector()
    req = FraudCheckRequest(amount=5000.0)
    result = await detector.analyze(req, "test-user-id")
    assert any("anomalous" in s.lower() for s in result.signals)
