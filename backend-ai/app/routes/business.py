from fastapi import APIRouter, Depends, HTTPException
from app.models.schemas import BusinessAdviceRequest, BusinessAdviceResponse
from app.services.business_advisor import BusinessAdvisor
from app.core.auth import get_current_user
from app.core.logger import setup_logger

router = APIRouter()
logger = setup_logger("business_route")


@router.post("/advise", response_model=BusinessAdviceResponse)
async def get_business_advice(request: BusinessAdviceRequest, user_id: str = Depends(get_current_user)):
    try:
        advisor = BusinessAdvisor()
        result = await advisor.advise(request, user_id)
        return result
    except Exception as e:
        logger.error(f"Business advice failed for user {user_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
