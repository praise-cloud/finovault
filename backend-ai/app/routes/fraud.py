from fastapi import APIRouter, Depends, HTTPException
from app.models.schemas import FraudCheckRequest, FraudCheckResponse
from app.services.fraud_detector import FraudDetector
from app.core.auth import get_current_user
from app.core.logger import setup_logger

router = APIRouter()
logger = setup_logger("fraud_route")


@router.post("/check", response_model=FraudCheckResponse)
async def check_fraud(request: FraudCheckRequest, user_id: str = Depends(get_current_user)):
    try:
        detector = FraudDetector()
        result = await detector.analyze(request, user_id)
        return result
    except Exception as e:
        logger.error(f"Fraud check failed for user {user_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
