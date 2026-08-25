# feature/overflow-fixes

This branch contains the **layout‑overflow fixes** for the Finovault Flutter app.

## What it is
Five screens previously overflowed horizontally at a phone viewport (393×852).
This branch makes them fit.

## What was achieved
- `VaultTab`: the two action buttons are stacked vertically (`Column` +
  `expanded`) so each gets full width; `FvButton` is also made ellipsis‑safe
  when narrow.
- `BudgetsScreen`: the "spent / amount" cluster is now `Flexible` with ellipsis
  so long MUR amounts can't overflow the card row.
- `InvoicesScreen`: the amount is stacked above the status badge + check button
  (two‑line right column) instead of cramming one row.
- `PensionScreen`: `_Row` label/value use `Flexible` + ellipsis.
- `TransferScreen`: the `DropdownButtonFormField` uses `isExpanded` plus an
  ellipsis `selectedItemBuilder` so the account name + balance shrink.

The complete app source is also present on this branch; this README focuses on
the overflow‑fix work.
