-- Expense Audit Analytics: key detection queries
-- Run against audit_practice.db (sqlite3 audit_practice.db < analysis.sql)

-- 1. Duplicate charges: same vendor, date, and amount more than once
SELECT vendor_id, txn_date, amount, COUNT(*) AS occurrences
FROM transactions
GROUP BY vendor_id, txn_date, amount
HAVING COUNT(*) > 1;

-- 2. Outlier transactions above $10,000
SELECT txn_id, vendor_id, amount, category, txn_date
FROM transactions
WHERE amount > 10000
ORDER BY amount DESC;

-- 3. Approval-threshold gaming: amounts just under the $5,000 limit
SELECT txn_id, vendor_id, amount, category, txn_date
FROM transactions
WHERE amount BETWEEN 4900 AND 4999.99
ORDER BY amount DESC;

-- 4. Vendors transacted with before they existed
SELECT t.txn_id, v.vendor_name, t.txn_date, v.created_date
FROM transactions t
JOIN vendors v ON t.vendor_id = v.vendor_id
WHERE t.txn_date < v.created_date;

-- 5. Transactions posted before the employee's hire date
SELECT t.txn_id, e.full_name, t.txn_date, e.hire_date
FROM transactions t
JOIN employees e ON t.employee_id = e.employee_id
WHERE t.txn_date < e.hire_date;

-- 6. Weekend postings (higher fraud/error risk)
SELECT txn_id, vendor_id, amount, txn_date
FROM transactions
WHERE strftime('%w', txn_date) IN ('0', '6');

-- 7. Spend banding with CASE WHEN
SELECT CASE
         WHEN amount > 10000 THEN 'Over 10k'
         WHEN amount BETWEEN 4900 AND 4999.99 THEN 'Near 5k threshold'
         ELSE 'Normal'
       END AS band,
       COUNT(*) AS n
FROM transactions
GROUP BY band;

-- 8. Monthly spend trend
SELECT substr(txn_date, 1, 7) AS month, ROUND(SUM(amount), 2) AS total
FROM transactions
GROUP BY month
ORDER BY month;
