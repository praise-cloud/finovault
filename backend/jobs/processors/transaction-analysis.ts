import { Job } from 'bull';
import { getSupabase } from '../../src/config/supabase';
import { createContextLogger } from '../../src/utils/logger';

const log = createContextLogger('TransactionAnalysisProcessor');

export async function processTransactionAnalysis(job: Job) {
  const { userId, transactionId, amount, merchant, category } = job.data;

  log.info(`Analyzing transaction ${transactionId} for user ${userId}`, { amount, merchant });

  try {
    const supabase = getSupabase();

    const { data: recentTx } = await supabase
      .from('transactions')
      .select('amount, category, merchant, date')
      .eq('user_id', userId)
      .neq('id', transactionId)
      .order('date', { ascending: false })
      .limit(50);

    if (!recentTx || recentTx.length < 5) {
      log.info('Not enough transaction history for analysis', { userId });
      return { analyzed: false, reason: 'insufficient_data' };
    }

    const amounts = recentTx.map(t => Number(t.amount));
    const mean = amounts.reduce((s, a) => s + a, 0) / amounts.length;
    const stdDev = Math.sqrt(
      amounts.reduce((s, a) => s + Math.pow(a - mean, 2), 0) / amounts.length
    );

    const zScore = stdDev > 0 ? Math.abs(Number(amount) - mean) / stdDev : 0;

    let anomalyScore = 0;
    let analysisResult = 'normal';

    if (zScore > 3) {
      anomalyScore = Math.min(100, (zScore / 5) * 100);
      analysisResult = 'anomaly';

      const sameMerchant = recentTx.filter(t => t.merchant === merchant);
      const isNewMerchant = sameMerchant.length === 0;

      const sameCategory = recentTx.filter(t => t.category === category);
      const categoryAvg = sameCategory.length > 0
        ? sameCategory.reduce((s, t) => s + Number(t.amount), 0) / sameCategory.length
        : 0;

      await supabase.from('fraud_events').insert({
        user_id: userId,
        event_type: 'Unusual Transaction Detected',
        description: `Transaction of $${Number(amount).toFixed(2)} ${isNewMerchant ? 'at new merchant' : ''} ` +
          `is ${zScore.toFixed(1)} standard deviations from your average of $${mean.toFixed(2)}. ` +
          `Score: ${anomalyScore.toFixed(0)}/100`,
        severity: anomalyScore > 70 ? 'warning' : 'info',
      });

      if (anomalyScore > 70) {
        await supabase.from('transactions')
          .update({ status: 'flagged' })
          .eq('id', transactionId);
      }
    }

    return {
      analyzed: true,
      z_score: zScore,
      anomaly_score: anomalyScore,
      result: analysisResult,
      mean_amount: mean,
      std_dev: stdDev,
    };
  } catch (error: any) {
    log.error(`Transaction analysis failed for job ${job.id}`, { error: error.message, transactionId });
    throw error;
  }
}
