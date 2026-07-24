import { Job } from 'bull';
import { analyzeUserPatterns } from '../../src/services/pattern-recognition.service';
import { createContextLogger } from '../../src/utils/logger';

const log = createContextLogger('PatternLearningProcessor');

export async function processPatternLearning(job: Job) {
  const { userId, userToken } = job.data;

  log.info(`Learning patterns for user ${userId}`);

  try {
    await analyzeUserPatterns(userId, userToken);
    return { completed: true };
  } catch (error: any) {
    log.error(`Pattern learning failed for user ${userId}`, { error: error.message });
    throw error;
  }
}
