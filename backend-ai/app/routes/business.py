from fastapi import APIRouter, Depends, HTTPException, Request
from app.models.schemas import BusinessAdviceRequest, BusinessAdviceResponse
from app.services.business_advisor import BusinessAdvisor
from app.core.auth import get_current_user
from app.core.limiter import limiter
from app.core.logger import setup_logger

router = APIRouter()
logger = setup_logger("business_route")


@router.post("/advise", response_model=BusinessAdviceResponse)
@limiter.limit("30/minute")
async def get_business_advice(request: Request, body: BusinessAdviceRequest, user_id: str = Depends(get_current_user)):
    try:
        advisor = BusinessAdvisor()
        result = await advisor.advise(body, user_id)
        return result
    except Exception as e:
        logger.error(f"Business advice failed for user {user_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
