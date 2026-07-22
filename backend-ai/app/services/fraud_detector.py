import numpy as np
from sklearn.ensemble import IsolationForest
from app.models.schemas import FraudCheckRequest, FraudCheckResponse
from app.core.supabase import get_supabase
from app.core.logger import setup_logger

logger = setup_logger("fraud_detector")


class FraudDetector:
    def __init__(self):
        self.model = IsolationForest(
            contamination=0.1,
            random_state=42,
            n_estimators=100,
        )

    async def analyze(self, request: FraudCheckRequest, user_id: str) -> FraudCheckResponse:
        signals = []
        risk_score = 0.0

        supabase = get_supabase()

        result = supabase.table("transactions") \
            .select("amount") \
            .eq("user_id", user_id) \
            .order("date", desc=True) \
            .limit(100) \
            .execute()

        amounts = [float(t["amount"]) for t in result.data] if result.data else []

        if len(amounts) >= 10:
            amounts.append(request.amount)
            X = np.array(amounts).reshape(-1, 1)
            preds = self.model.fit_predict(X)

            if preds[-1] == -1:
                risk_score += 35
                signals.append("Amount is anomalous compared to transaction history")

        if request.amount > 10000:
            risk_score += 20
            signals.append(f"High value transaction: ${request.amount:,.2f}")

        if request.amount > 50000:
            risk_score += 20
            signals.append("Very high value transaction")

        if request.receiver:
            risk_score += 10
            signals.append(f"Transaction to new receiver: {request.receiver}")

        if request.device_id:
            metrics = supabase.table("security_metrics") \
                .select("active_devices") \
                .eq("user_id", user_id) \
                .execute()

            if metrics.data:
                pass

        risk_score = min(100, risk_score)

        if risk_score > 70:
            risk_level = "critical"
            decision = "block"
            message = "This transaction has been blocked due to high risk factors."
        elif risk_score > 50:
            risk_level = "high"
            decision = "freeze"
            message = "This transaction requires verification."
        elif risk_score > 25:
            risk_level = "medium"
            decision = "freeze"
            message = "We recommend verifying this transaction."
        else:
            risk_level = "low"
            decision = "allow"
            message = "Transaction looks normal."

        return FraudCheckResponse(
            risk_score=round(risk_score, 1),
            risk_level=risk_level,
            signals=signals,
            decision=decision,
            message=message,
        )
