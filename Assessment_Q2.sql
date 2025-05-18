-- Step 1: Calculate overall customer activity metrics
WITH customer_activity AS (
    SELECT
        owner_id,
        COUNT(*) AS total_transactions,                    -- Total number of transactions per customer
        MIN(DATE(transaction_date)) AS first_txn_date,     -- Date of first transaction
        MAX(DATE(transaction_date)) AS last_txn_date,      -- Date of most recent transaction
        TIMESTAMPDIFF(MONTH, MIN(transaction_date), MAX(transaction_date)) + 1 AS active_months
        -- Calculate number of active months between first and last transaction, inclusive
    FROM adashi_staging.savings_savingsaccount
    GROUP BY owner_id
),

-- Step 2: Calculate average transactions per active month for each customer
monthly_averages AS (
    SELECT
        owner_id,
        total_transactions,
        active_months,
        total_transactions * 1.0 / active_months AS avg_transactions_per_month
        -- Multiply by 1.0 to ensure floating-point division
    FROM customer_activity
),

-- Step 3: Categorize customers by transaction frequency
frequency_categorized AS (
    SELECT
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_transactions_per_month
    FROM monthly_averages
)

-- Final aggregation: count customers and calculate average transactions per category
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM frequency_categorized
GROUP BY frequency_category
ORDER BY
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency'); 
    -- Custom ordering for clear presentation of categories
