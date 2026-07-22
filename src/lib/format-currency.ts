export function formatCurrency(amount: number, currencyCode: string = 'USD'): string {
  try {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: currencyCode,
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(amount);
  } catch {
    return `$${amount.toLocaleString('en-US', { minimumFractionDigits: 2 })}`;
  }
}

export function convertAmount(amountInUsd: number, rate: number): number {
  if (!rate || rate === 0) return 0;
  return amountInUsd * rate;
}
