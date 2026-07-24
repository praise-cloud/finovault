import dotenv from 'dotenv';
dotenv.config();

function required(key: string): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
}

export const env = {
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: parseInt(process.env.PORT || '4000', 10),

  SUPABASE_URL: required('SUPABASE_URL'),
  SUPABASE_SERVICE_KEY: required('SUPABASE_SERVICE_KEY'),
  SUPABASE_JWT_SECRET: required('SUPABASE_JWT_SECRET'),

  AI_SERVICE_KEY: process.env.AI_SERVICE_KEY || '',
  PYTHON_AI_URL: process.env.PYTHON_AI_URL || 'https://finovault-ai.onrender.com',

  REDIS_URL: process.env.REDIS_URL || 'redis://localhost:6379',

  CORS_ORIGIN: process.env.CORS_ORIGIN || 'http://localhost:8081,http://localhost:8082,http://localhost:19006',

  LOG_LEVEL: process.env.LOG_LEVEL || 'debug',

  get isProduction() {
    return this.NODE_ENV === 'production';
  },

  get corsOrigins(): string[] {
    return this.CORS_ORIGIN.split(',').map(s => s.trim());
  },
};
