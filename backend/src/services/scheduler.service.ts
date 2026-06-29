import { getSupabase } from '../config/supabase';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('SchedulerService');

interface DailyBriefing {
  title: string;
  content: string;
  action_items: { type: string; label: string; impact: string }[];
}

export async function generateDailyBriefing(userId: string): Promise<DailyBriefing | null> {
  const supabase = getSupabase();

  const today = new Date().toISOString().split('T')[0];

  const { data: existing } = await supabase
    .from('morning_briefings')
    .select('id')
    .eq('user_id', userId)
    .eq('briefing_date', today)
    .single();

  if (existing) {
    return null;
  }

  const [txRes, goalRes, fraudRes] = await Promise.all([
    supabase.from('transactions').select('*').eq('user_id', userId).gte('date', getDaysAgo(30)),
    supabase.from('savings_goals').select('*').eq('user_id', userId).eq('status', 'active'),
    supabase.from('fraud_events').select('*').eq('user_id', userId).gte('timestamp', getDaysAgo(7)),
  ]);

  const transactions = txRes.data || [];
  const goals = goalRes.data || [];
  const fraudEvents = fraudRes.data || [];

  const totalSpent = transactions
    .filter((t: any) => t.type === 'expense')
    .reduce((s: number, t: any) => s + Number(t.amount), 0);

  const totalIncome = transactions
    .filter((t: any) => t.type === 'income')
    .reduce((s: number, t: any) => s + Number(t.amount), 0);

  const recentFraud = fraudEvents.filter((e: any) => e.severity === 'warning' || e.severity === 'critical');

  let content = 'Good morning. ';
  const actionItems: { type: string; label: string; impact: string }[] = [];

  if (recentFraud.length > 0) {
    content += 'There are some security items to review. ';
    actionItems.push({ type: 'review', label: 'Check recent security alerts', impact: 'Prevent potential fraud' });
  }

  if (goals.length > 0) {
    const goalProgress = goals.map((g: any) => {
      const pct = g.target_amount > 0 ? (g.current_amount / g.target_amount) * 100 : 0;
      return `${g.name}: ${pct.toFixed(0)}% complete`;
    });
    content += `Your savings goals progress: ${goalProgress.join(', ')}. `;
  }

  if (totalSpent > 0 && totalIncome > 0) {
    const savingsRate = ((totalIncome - totalSpent) / totalIncome) * 100;
    if (savingsRate < 20) {
      content += 'Your savings rate could be improved. ';
      actionItems.push({ type: 'optimize', label: 'Review your spending categories', impact: 'Potential savings increase' });
    }
  } else {
    content += 'No recent transaction activity found. Link a bank account to start tracking.';
  }

  if (actionItems.length === 0) {
    content += 'Everything is on track. Have a productive day!';
  }

  const briefing: DailyBriefing = {
    title: 'Good morning!',
    content,
    action_items: actionItems,
  };

  await supabase.from('morning_briefings').insert({
    user_id: userId,
    briefing_date: today,
    title: briefing.title,
    content: briefing.content,
    action_items: briefing.action_items,
    read: false,
  });

  log.info(`Daily briefing generated for user ${userId}`);

  return briefing;
}

function getDaysAgo(days: number): string {
  const date = new Date();
  date.setDate(date.getDate() - days);
  return date.toISOString();
}
