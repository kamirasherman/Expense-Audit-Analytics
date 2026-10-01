# Findings Report — Expense Audit Analytics

All findings below were produced by the queries in `analysis.sql` against the
synthetic dataset (`audit_practice.db`: 230 transactions, Jan–Aug 2025).
Each finding follows the format auditors use: **finding → evidence → risk → recommendation**.

---

## Finding 1 — Duplicate charges: $2,508.49 at risk of double payment (High)

**Evidence:** 3 vendor/date/amount pairs appear twice with different transaction IDs —
V001/Staples Direct on 2025-03-12 ($842.50), V002/Delta Travel on 2025-05-21 ($1,290.00),
V003/CloudServe Inc on 2025-07-09 ($375.99).

**Risk:** the organization may have paid these invoices twice; duplicates are a classic
indicator of weak invoice-matching controls.

**Recommendation:** confirm payment status with AP for all six transactions, recover any
double payments, and add a system-level duplicate-invoice check (vendor + date + amount)
before payment release.

## Finding 2 — Two extreme outliers need business-purpose validation (High)

**Evidence:** T0217 ($48,500, Office Supplies) and T0218 ($32,000, Travel) exceed $10,000 —
roughly 20–95x the typical transaction size (~$500 median).

**Risk:** misclassification, data entry error (extra zeros), or unauthorized spend.

**Recommendation:** pull supporting documentation for both; confirm business purpose and
approval trail; consider a hard approval gate above $10,000.

## Finding 3 — Four transactions cluster just under the $5,000 approval limit (Medium)

**Evidence:** 4 approved transactions fall between $4,900 and $4,999.99 —
$4,999.00, $4,995.00, $4,985.50, $4,950.00.

**Risk:** pattern consistent with splitting or shaping spend to avoid the $5,000
secondary-approval threshold.

**Recommendation:** review the business justification for each; run this banding
quarterly as a continuous-monitoring control.

## Finding 4 — Vendor transacted before it existed (High)

**Evidence:** QuickSupply LLC (V013) was created 2025-06-15, but transactions T0228
($2,750, 2025-03-04) and T0229 ($1,980, 2025-04-11) predate it — $4,730 total.

**Risk:** shell-vendor / fictitious-payee fraud indicator; master-data integrity failure.

**Recommendation:** freeze the vendor pending investigation, validate the business
relationship and goods received, and add a system edit blocking transactions against
vendors created after the transaction date.

## Finding 5 — 15 transactions predate the employee's hire date (Medium)

**Evidence:** all 15 were submitted under E007 (Priya Shah), hired 2025-07-01, with
transaction dates as early as May 2025.

**Risk:** shared credentials, backdated entries, or HR/identity-feed timing gaps.

**Recommendation:** confirm with HR whether this reflects a rehire/transfer data issue
or a real control gap; block transaction submission for inactive employee IDs.

## Finding 6 — Weekend postings and uncategorized items (Low)

**Evidence:** 3 transactions posted on Saturdays; 2 pending transactions have no category.

**Risk:** weekend activity bypasses normal supervisory review; uncategorized spend
can't be monitored by category controls.

**Recommendation:** include weekend postings in the quarterly anomaly review; require
a category before a transaction can move out of Pending.
