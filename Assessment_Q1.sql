-- Step 1: CTE to aggregate funded savings by user (excluding funds)
WITH funded_savings AS (
    SELECT
        p.owner_id,
        COUNT(DISTINCT p.id) AS savings_count,           -- Count unique saving plans per user
        SUM(s.confirmed_amount) / 100.0 AS savings_total -- Sum confirmed amounts, converted to proper currency unit
    FROM adashi_staging.plans_plan p
    JOIN adashi_staging.savings_savingsaccount s ON s.plan_id = p.id
    WHERE p.is_a_fund = 0 AND s.confirmed_amount > 0      -- Exclude funds, only consider positive deposits
    GROUP BY p.owner_id
),

-- Step 2: CTE to count funded investment plans per user
funded_investments AS (
    SELECT
        p.owner_id,
        COUNT(DISTINCT p.id) AS investment_count          -- Count unique investment plans (funds)
    FROM adashi_staging.plans_plan p
    WHERE p.is_a_fund = 1
    GROUP BY p.owner_id
)

-- Step 3: Combine results with user info
SELECT
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,        -- Full user name for readability
    fs.savings_count,
    fi.investment_count,
    fs.savings_total AS total_deposits
FROM funded_savings fs
JOIN funded_investments fi ON fs.owner_id = fi.owner_id    -- Ensure users have both savings and investments
JOIN adashi_staging.users_customuser u ON u.id = fs.owner_id
ORDER BY fs.savings_total DESC;                            -- Sort by total deposits descending for priority
