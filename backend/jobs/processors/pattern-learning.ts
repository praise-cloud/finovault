import { Job } from 'bull';
import { analyzeUserPatterns } from '../../src/services/pattern-recognition.service';
import { createContextLogger } from '../../src/utils/logger';

const log = createContextLogger('PatternLearningProcessor');

export async function processPatternLearning(job: Job) {
  const { userId } = job.data;

  log.info(`Learning patterns for user ${userId}`);

  await analyzeUserPatterns(userId);

  return { completed: true };
}
