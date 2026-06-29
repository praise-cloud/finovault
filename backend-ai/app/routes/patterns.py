from fastapi import APIRouter, HTTPException
from app.models.schemas import PatternAnalysisRequest, PatternAnalysisResponse
from app.services.pattern_recognizer import PatternRecognizer
from app.core.logger import setup_logger

router = APIRouter()
logger = setup_logger("patterns_route")


@router.post("/analyze", response_model=PatternAnalysisResponse)
async def analyze_patterns(request: PatternAnalysisRequest):
    try:
        recognizer = PatternRecognizer()
        result = await recognizer.analyze(request)
        return result
    except Exception as e:
        logger.error(f"Pattern analysis failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))
