import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    AI_SERVICE_KEY: str = os.getenv("AI_SERVICE_KEY", "")
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_SERVICE_KEY: str = os.getenv("SUPABASE_SERVICE_KEY", "")
    OPENROUTER_API_KEY: str = os.getenv("OPENROUTER_API_KEY", "")
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379")
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")

    @property
    def cors_origins(self) -> list[str]:
        return os.getenv("CORS_ORIGINS", "http://localhost:4000,http://localhost:8081,http://localhost:8082").split(",")


settings = Settings()
