from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.routes import health, fraud, coach, patterns, business

app = FastAPI(
    title="Finovault AI Engine",
    description="AI-powered financial intelligence for Finovault",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router, tags=["health"])
app.include_router(fraud.router, prefix="/fraud", tags=["fraud"])
app.include_router(coach.router, prefix="/coach", tags=["coach"])
app.include_router(patterns.router, prefix="/patterns", tags=["patterns"])
app.include_router(business.router, prefix="/business", tags=["business"])

@app.get("/")
async def root():
    return {"service": "Finovault AI Engine", "status": "running", "version": "1.0.0"}
