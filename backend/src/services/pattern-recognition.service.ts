import { getSupabase } from '../config/supabase';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('PatternRecognition');

export async function analyzeUserPatterns(userId: string): Promise<void> {
  const supabase = getSupabase();

  const { data: transactions, error } = await supabase
    .from('transactions')
    .select('*')
    .eq('user_id', userId)
    .order('date', { ascending: false })
    .limit(500);

  if (error || !transactions || transactions.length === 0) {
    log.warn('No transactions to analyze', { userId });
    return;
  }

  const dayOfWeekPatterns = detectDayOfWeekPatterns(transactions);
  const merchantFrequency = detectMerchantFrequency(transactions);
  const categoryTrends = detectCategoryTrends(transactions);

  const patterns = [...dayOfWeekPatterns, ...merchantFrequency, ...categoryTrends];

  for (const pattern of patterns) {
    await supabase.from('behavior_patterns').upsert({
      user_id: userId,
      pattern_type: pattern.type,
      pattern_name: pattern.name,
      description: pattern.description,
      category: pattern.category,
      frequency: pattern.frequency,
      confidence_score: pattern.confidence,
      last_observed_at: new Date().toISOString(),
      metadata: pattern.metadata || {},
    }, { onConflict: 'user_id,pattern_type,pattern_name', ignoreDuplicates: false });
  }

  log.info(`Pattern analysis complete for user ${userId}`, { patternsFound: patterns.length });
}

function detectDayOfWeekPatterns(transactions: any[]): any[] {
  const patterns: any[] = [];
  const dayTotals: Record<string, { count: number; total: number; categories: Set<string> }> = {};

  const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  days.forEach(d => dayTotals[d] = { count: 0, total: 0, categories: new Set() });

  for (const tx of transactions) {
    const date = new Date(tx.date);
    const dayName = days[date.getDay()];
    dayTotals[dayName].count++;
    dayTotals[dayName].total += Number(tx.amount);
    if (tx.category) dayTotals[dayName].categories.add(tx.category);
  }

  for (const [day, data] of Object.entries(dayTotals)) {
    const totalTransactions = transactions.length;
    const expectedPerDay = totalTransactions / 7;

    if (data.count > expectedPerDay * 1.5 && data.count >= 3) {
      const categoryStr = Array.from(data.categories).slice(0, 3).join(', ');
      patterns.push({
        type: 'recurring-spend',
        name: `${day} Spending Pattern`,
        description: `You tend to spend more on ${day}s. Average: $${(data.total / data.count).toFixed(2)}. Categories: ${categoryStr}`,
        category: Array.from(data.categories)[0] || 'general',
        frequency: 'weekly',
        confidence: Math.min(95, Math.round((data.count / expectedPerDay) * 50)),
        metadata: { day, avg_amount: Math.round(data.total / data.count), transaction_count: data.count },
      });
    }
  }

  return patterns;
}

function detectMerchantFrequency(transactions: any[]): any[] {
  const patterns: any[] = [];
  const merchantCounts: Record<string, { count: number; total: number; categories: string[] }> = {};

  for (const tx of transactions) {
    if (!tx.merchant) continue;
    if (!merchantCounts[tx.merchant]) {
      merchantCounts[tx.merchant] = { count: 0, total: 0, categories: [] };
    }
    merchantCounts[tx.merchant].count++;
    merchantCounts[tx.merchant].total += Number(tx.amount);
    if (tx.category && !merchantCounts[tx.merchant].categories.includes(tx.category)) {
      merchantCounts[tx.merchant].categories.push(tx.category);
    }
  }

  for (const [merchant, data] of Object.entries(merchantCounts)) {
    if (data.count >= 5) {
      patterns.push({
        type: 'recurring-spend',
        name: `Regular ${merchant} Visits`,
        description: `You've visited ${merchant} ${data.count} times. Total spent: $${data.total.toFixed(2)}.`,
        category: data.categories[0] || 'general',
        frequency: data.count > 20 ? 'weekly' : 'monthly',
        confidence: Math.min(90, Math.round((data.count / 50) * 80)),
        metadata: { merchant, avg_amount: Math.round(data.total / data.count), visit_count: data.count },
      });
    }
  }

  return patterns;
}

function detectCategoryTrends(transactions: any[]): any[] {
  const patterns: any[] = [];
  const monthlyByCategory: Record<string, { month: string; amount: number }[]> = {};

  for (const tx of transactions) {
    if (!tx.category) continue;
    const date = new Date(tx.date);
    const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;

    if (!monthlyByCategory[tx.category]) monthlyByCategory[tx.category] = [];
    const existing = monthlyByCategory[tx.category].find(m => m.month === monthKey);
    if (existing) {
      existing.amount += Number(tx.amount);
    } else {
      monthlyByCategory[tx.category].push({ month: monthKey, amount: Number(tx.amount) });
    }
  }

  for (const [category, months] of Object.entries(monthlyByCategory)) {
    if (months.length >= 3) {
      months.sort((a, b) => a.month.localeCompare(b.month));
      const first = months[0].amount;
      const last = months[months.length - 1].amount;
      const change = first > 0 ? ((last - first) / first) * 100 : 0;

      if (Math.abs(change) > 30) {
        patterns.push({
          type: 'seasonal-spend',
          name: `${category} Spending Trend`,
          description: `Your ${category} spending has ${change > 0 ? 'increased' : 'decreased'} by ${Math.abs(Math.round(change))}% over the last ${months.length} months.`,
          category,
          frequency: 'monthly',
          confidence: Math.min(85, Math.round(Math.abs(change))),
          metadata: { trend: change > 0 ? 'up' : 'down', change_percent: Math.round(change), months_tracked: months.length },
        });
      }
    }
  }

  return patterns;
}
