import Queue from 'bull';
import { env } from '../src/config/env';
import { createContextLogger } from '../src/utils/logger';
import { processDailyBriefing } from './processors/daily-briefing';
import { processPatternLearning } from './processors/pattern-learning';
import { processTransactionAnalysis } from './processors/transaction-analysis';

const log = createContextLogger('Queue');

export const transactionAnalysisQueue = new Queue('transaction-analysis', env.REDIS_URL, {
  defaultJobOptions: {
    attempts: 3,
    backoff: { type: 'exponential', delay: 5000 },
    removeOnComplete: 100,
    removeOnFail: 50,
  },
});

export const dailyBriefingQueue = new Queue('daily-briefing', env.REDIS_URL, {
  defaultJobOptions: {
    attempts: 2,
    backoff: { type: 'fixed', delay: 10000 },
    removeOnComplete: 50,
  },
});

export const patternLearningQueue = new Queue('pattern-learning', env.REDIS_URL, {
  defaultJobOptions: {
    attempts: 2,
    backoff: { type: 'fixed', delay: 10000 },
    removeOnComplete: 50,
  },
});

// Register processors
dailyBriefingQueue.process(processDailyBriefing);
patternLearningQueue.process(processPatternLearning);
transactionAnalysisQueue.process(processTransactionAnalysis);

transactionAnalysisQueue.on('completed', (job) => {
  log.info(`Transaction analysis job ${job.id} completed`);
});

transactionAnalysisQueue.on('failed', (job, err) => {
  log.error(`Transaction analysis job ${job.id} failed`, { error: err.message });
});

dailyBriefingQueue.on('completed', (job) => {
  log.info(`Daily briefing job ${job.id} completed`);
});

dailyBriefingQueue.on('failed', (job, err) => {
  log.error(`Daily briefing job ${job.id} failed`, { error: err.message });
});
