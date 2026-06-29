from fastapi import APIRouter, HTTPException
from app.models.schemas import FraudCheckRequest, FraudCheckResponse
from app.services.fraud_detector import FraudDetector
from app.core.logger import setup_logger

router = APIRouter()
logger = setup_logger("fraud_route")


@router.post("/check", response_model=FraudCheckResponse)
async def check_fraud(request: FraudCheckRequest):
    try:
        detector = FraudDetector()
        result = await detector.analyze(request)
        return result
    except Exception as e:
        logger.error(f"Fraud check failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))
