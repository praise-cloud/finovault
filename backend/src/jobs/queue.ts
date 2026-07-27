import Queue from 'bull';
import { env } from '../config/env';
import { createContextLogger } from '../utils/logger';
import { processDailyBriefing } from './processors/daily-briefing';
import { processPatternLearning } from './processors/pattern-learning';
import { processTransactionAnalysis } from './processors/transaction-analysis';
import { processIncomeDetected } from './processors/income-detected';

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

export const incomeDetectedQueue = new Queue('income-detected', env.REDIS_URL, {
  defaultJobOptions: {
    attempts: 2,
    backoff: { type: 'fixed', delay: 5000 },
    removeOnComplete: 50,
  },
});

// Register processors
dailyBriefingQueue.process(processDailyBriefing);
patternLearningQueue.process(processPatternLearning);
transactionAnalysisQueue.process(processTransactionAnalysis);
incomeDetectedQueue.process(processIncomeDetected);

function addListeners(queue: Queue.Queue, name: string) {
  queue.on('completed', (job) => {
    log.info(`${name} job ${job.id} completed`);
  });
  queue.on('failed', (job, err) => {
    log.error(`${name} job ${job.id} failed`, { error: err.message });
  });
}

addListeners(transactionAnalysisQueue, 'Transaction analysis');
addListeners(dailyBriefingQueue, 'Daily briefing');
addListeners(patternLearningQueue, 'Pattern learning');
addListeners(incomeDetectedQueue, 'Income detected');
