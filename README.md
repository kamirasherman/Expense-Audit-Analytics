# Expense Audit Analytics

## The engagement

Eight detection tests run against eight months of accounts-payable data (230 transactions, Jan–Aug 2025) for a fictional mid-size services company: duplicate-charge detection, outlier analysis, approval-threshold monitoring, and master-data integrity checks. The same tests an audit data analyst runs when the external auditors ask, "show me your analytics."

*The dataset is fully synthetic — a seeded generator, so every result is reproducible. Built to mirror real AP patterns without any real company or personal data.*

## Key findings

| # | Finding | Severity |
|---|---------|----------|
| 1 | **Duplicate charges** — 3 vendor/date/amount pairs billed twice ($2,508.49 at risk) | High |
| 2 | **Outliers** — $48,500 "Office Supplies" and $32,000 "Travel" transactions need validation | High |
| 3 | **Threshold gaming** — 4 transactions cluster just under the $5,000 approval limit | Medium |
| 4 | **Phantom vendor** — QuickSupply LLC transacted ($4,730) *before* it was created | High |
| 5 | **Pre-hire activity** — 15 transactions predate the submitting employee's hire date | Medium |
| 6 | **Weekend postings & uncategorized items** — 3 Saturday posts, 2 pending without category | Low |

Full write-ups (evidence → risk → recommendation) in [`findings.md`](findings.md).

## How the tests work

- **Duplicate detection** — `GROUP BY vendor_id, txn_date, amount HAVING COUNT(*) > 1`
- **Outlier flagging** — fixed thresholds and banding with `CASE WHEN`
- **Master-data integrity** — joining transactions to vendor/employee tables and testing date logic (`txn_date < created_date`)
- **Temporal analysis** — `strftime('%w', ...)` for weekend posts, `substr(txn_date,1,7)` for monthly trends

## Reproduce it

```bash
sqlite3 audit_practice.db < analysis.sql   # runs all eight detection queries
```

Or open `audit_practice.db` in [DB Browser for SQLite](https://sqlitebrowser.org/) (free) and run the queries from `analysis.sql` one at a time. The CSVs in `data/` open in Excel.

## Files

- `analysis.sql` — the eight detection queries
- `findings.md` — written findings: evidence → risk → recommendation
- `audit_practice.db` — the SQLite database (230 synthetic transactions)
- `data/` — the same data as CSVs (transactions, vendors, employees)

## Next steps

- Run the duplicate and threshold queries as **continuous monitoring** (weekly, not quarterly sampling).
- Join to the HR termination feed so pre-hire/post-termination checks run automatically.
- Track each finding to remediation with an owner and due date, then re-test the following quarter to confirm the control actually worked.

## Tech

SQL · SQLite
