from fastapi import APIRouter, HTTPException
from app.models.schemas import BusinessAdviceRequest, BusinessAdviceResponse
from app.services.business_advisor import BusinessAdvisor
from app.core.logger import setup_logger

router = APIRouter()
logger = setup_logger("business_route")


@router.post("/advise", response_model=BusinessAdviceResponse)
async def get_business_advice(request: BusinessAdviceRequest):
    try:
        advisor = BusinessAdvisor()
        result = await advisor.advise(request)
        return result
    except Exception as e:
        logger.error(f"Business advice failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))
