from pydantic import BaseModel, Field
from typing import Any


class FraudCheckRequest(BaseModel):
    user_id: str
    amount: float
    merchant: str | None = None
    category: str | None = None
    location: str | None = None
    device_id: str | None = None
    receiver: str | None = None


class FraudCheckResponse(BaseModel):
    risk_score: float = Field(ge=0, le=100)
    risk_level: str  # low, medium, high, critical
    signals: list[str] = []
    decision: str  # allow, freeze, block
    message: str = ""


class CoachRequest(BaseModel):
    user_id: str
    question: str
    context: dict[str, Any] | None = None


class CoachResponse(BaseModel):
    answer: str
    suggestions: list[str] = []


class PatternAnalysisRequest(BaseModel):
    user_id: str
    force: bool = False


class PatternAnalysisResponse(BaseModel):
    patterns_detected: int
    patterns: list[dict[str, Any]] = []


class BusinessAdviceRequest(BaseModel):
    user_id: str
    question: str
    business_data: dict[str, Any] | None = None


class BusinessAdviceResponse(BaseModel):
    answer: str
    metrics: dict[str, Any] = {}
