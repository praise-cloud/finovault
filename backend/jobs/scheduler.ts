import { dailyBriefingQueue, patternLearningQueue } from './queue';
import { createContextLogger } from '../src/utils/logger';
import { getSupabase } from '../src/config/supabase';

const log = createContextLogger('Scheduler');

export async function scheduleDailyBriefings(): Promise<void> {
  const supabase = getSupabase();
  const today = new Date().toISOString().split('T')[0];

  const { data: users } = await supabase
    .from('profiles')
    .select('id');

  if (!users || users.length === 0) {
    log.info('No users found for daily briefing');
    return;
  }

  for (const user of users) {
    const { data: existing } = await supabase
      .from('morning_briefings')
      .select('id')
      .eq('user_id', user.id)
      .eq('briefing_date', today)
      .single();

    if (existing) continue;

    await dailyBriefingQueue.add(
      { userId: user.id },
      { delay: Math.random() * 3600000 }
    );
  }

  log.info(`Scheduled daily briefings for ${users.length} users`);
}

export async function schedulePatternLearning(): Promise<void> {
  const supabase = getSupabase();

  const { data: users } = await supabase
    .from('profiles')
    .select('id');

  if (!users || users.length === 0) return;

  for (const user of users) {
    await patternLearningQueue.add(
      { userId: user.id },
      { delay: Math.random() * 7200000 }
    );
  }

  log.info(`Scheduled pattern learning for ${users.length} users`);
}
