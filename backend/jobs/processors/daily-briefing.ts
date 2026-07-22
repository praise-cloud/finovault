import { Job } from 'bull';
import { generateDailyBriefing } from '../../src/services/scheduler.service';
import { createContextLogger } from '../../src/utils/logger';

const log = createContextLogger('DailyBriefingProcessor');

export async function processDailyBriefing(job: Job) {
  const { userId } = job.data;

  log.info(`Generating daily briefing for user ${userId}`);

  try {
    const briefing = await generateDailyBriefing(userId);

    return {
      generated: !!briefing,
      briefing,
    };
  } catch (error: any) {
    log.error(`Daily briefing failed for user ${userId}`, { error: error.message });
    throw error;
  }
}
