SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Combine first and last names for easier identification
    -- Calculate account tenure in months, adding 1 to avoid division by zero when customer just signed up
    TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()) + 1 AS tenure_months,
    -- Total number of transactions per customer (excluding zero or negative amounts)
    COALESCE(tx.total_transactions, 0) AS total_transactions,
    -- Calculate estimated CLV using the simplified formula:
    -- CLV = (average transactions per month * 12 months) * average profit per transaction
    -- Assumes average profit is 0.1% of confirmed transaction amount
    ROUND(
        (COALESCE(tx.total_transactions, 0) / (TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()) + 1))
        * 12
        * COALESCE(tx.avg_profit_per_transaction, 0),
    2) AS estimated_clv
FROM
    users_customuser u
LEFT JOIN (
    SELECT
        owner_id,
        COUNT(*) AS total_transactions,  -- Count all positive transactions for each customer
        AVG(confirmed_amount) * 0.001 AS avg_profit_per_transaction  -- Scale average transaction amount to profit estimate
    FROM
        adashi_staging.savings_savingsaccount
    WHERE
        confirmed_amount > 0  -- Exclude non-positive transactions to avoid skewing averages
    GROUP BY
        owner_id
) tx ON u.id = tx.owner_id
ORDER BY
    estimated_clv DESC;  -- Rank customers by highest potential lifetime value to prioritize marketing efforts
