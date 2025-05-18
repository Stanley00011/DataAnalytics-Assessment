-- Objective: Identify customers inactive in savings for over 365 days

SELECT
    p.id AS plan_id,                           -- Unique identifier for each plan
    u.id AS owner_id,                          -- Customer's user ID
    -- CONCAT(u.first_name, ' ', u.last_name) AS full_name,  -- Optional for verification/debugging
    CASE WHEN p.is_a_fund = 1 THEN 'Investment' ELSE 'Savings' END AS plan_type,
        -- Categorise plan as Investment or Savings for clarity
    t.last_transaction_date,                   -- Date of the most recent confirmed transaction
    DATEDIFF(CURDATE(), t.last_transaction_date) AS days_inactive
        -- Calculate days since last transaction to identify inactivity duration
FROM (
    -- Subquery: Get last transaction date per plan with positive confirmed amount
    SELECT
        s.plan_id,
        MAX(s.transaction_date) AS last_transaction_date
    FROM adashi_staging.savings_savingsaccount s
    WHERE s.confirmed_amount > 0               -- Consider only confirmed deposits
    GROUP BY s.plan_id
) AS t
JOIN adashi_staging.plans_plan p ON p.id = t.plan_id   -- Join to get plan details
JOIN users_customuser u ON u.id = p.owner_id           -- Join to get customer info
WHERE DATEDIFF(CURDATE(), t.last_transaction_date) > 365
    -- Filter plans inactive for more than 1 year
ORDER BY days_inactive DESC;   -- Order by longest inactivity first
