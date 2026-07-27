import pytest
from datetime import datetime, timedelta, timezone
from app.services.pattern_recognizer import PatternRecognizer


@pytest.fixture
def recognizer():
    return PatternRecognizer()


def _make_tx(amount: float, category: str, merchant: str, day_offset: int = 0, tx_type: str = "expense"):
    d = (datetime.now(timezone.utc) - timedelta(days=day_offset)).isoformat()
    return {
        "amount": amount,
        "category": category,
        "merchant": merchant,
        "date": d,
        "type": tx_type,
    }


class TestDayOfWeekPatterns:
    def test_detects_frequent_day(self, recognizer):
        """Multiple transactions on the same day should be detected."""
        txs = [_make_tx(100, "food", "Shop1", 0) for _ in range(10)]
        txs.extend(_make_tx(100, "food", "Shop2", i) for i in range(1, 5))
        patterns = recognizer._detect_day_of_week_patterns(txs)
        assert len(patterns) > 0

    def test_no_pattern_with_few_transactions(self, recognizer):
        """Few transactions should not trigger any day pattern."""
        txs = [_make_tx(50, "food", "Shop", i) for i in range(3)]
        patterns = recognizer._detect_day_of_week_patterns(txs)
        assert len(patterns) == 0


class TestMerchantPatterns:
    def test_detects_frequent_merchant(self, recognizer):
        """Many visits to same merchant should be detected."""
        txs = [_make_tx(25, "food", "CoffeeShop", i) for i in range(10)]
        patterns = recognizer._detect_merchant_patterns(txs)
        merchant_patterns = [p for p in patterns if p["name"].startswith("Regular")]
        assert len(merchant_patterns) >= 1

    def test_skip_merchant_with_few_visits(self, recognizer):
        """Few visits should not trigger merchant pattern."""
        txs = [_make_tx(25, "food", "RareShop", i) for i in range(3)]
        patterns = recognizer._detect_merchant_patterns(txs)
        assert len(patterns) == 0


class TestCategoryTrends:
    def test_detects_spending_trend(self, recognizer):
        """Significant change in category spending over months."""
        txs = [_make_tx(100, "shopping", "Store", day * 35) for day in range(6)]
        txs.extend(_make_tx(500, "shopping", "Store", day * 35 + 200) for day in range(3))
        patterns = recognizer._detect_category_trends(txs)
        assert len(patterns) > 0
