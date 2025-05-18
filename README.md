# DataAnalytics-Assessment

## Overview

This repository contains thoughtful and clearly written SQL queries designed to solve realistic business problems using structured relational data. The focus is not just on correctness, but on demonstrating stakeholder-aligned thinking and solid analytical reasoning. Every solution answers a specific business question, framed from the perspectives of marketing, operations, and finance.


## Per-Question Explanations

### Question 1: High-Value Customers with Multiple Products

**Business Goal**: Identify users who hold both a funded savings plan and a funded investment plan, a signal of deep product engagement.

**Approach**:

* Joined the `users_customuser`, `savings_savingsaccount`, and `plans_plan` tables using user IDs.
* Applied filters to ensure only savings and investment plans with `confirmed_amount > 0` were included.
* Used a Common Table Expression (CTE) to organize users who had funded products, improving readability and simplifying the final filtering logic.
* Leveraged conditional aggregation to confirm both plan types (savings and investment) were present.
* Grouped results by user to sum deposits and sorted by the total confirmed amount to highlight high-value customers.

**Value to Stakeholders**:
This insight is important for identifying loyal customers who trust the platform with multiple services. These users can be prioritized for rewards, deeper engagement, or targeted offers.

### Question 2: Transaction Frequency Analysis

**Business Goal**: Segment users based on how frequently they interact financially, to personalize engagement strategies.

**Approach**:

* Aggregated transaction data from the `savings_savingsaccount` table per user.
* Calculated each user’s transaction window by finding the difference between their earliest and most recent transaction dates.
* Used `TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) + 1` to calculate a full month-based span of activity.
* Computed the average monthly transaction rate per customer.
* Applied a `CASE` statement to classify users into frequency tiers:

  * High Frequency (>= 10/month)
  * Medium Frequency (3-9/month)
  * Low Frequency (≤2/month)

**Value to Stakeholders**:
The marketing team can use this to segment communications, while the product team might design features differently for frequent versus occasional users.

### Question 3: Account Inactivity Alert

**Business Goal**: Detect user accounts with no deposits in the past 12 months to support re-engagement or flag potential drop-offs.

**Approach**:

* Extracted the latest transaction date per account from the `plans_plan` and `savings_savingsaccount` tables.
* Calculated the number of days since the last transaction using `DATEDIFF(CURDATE(), last_transaction_date)`.
* Used a `WHERE` clause to flag accounts with inactivity greater than 365 days.
* Ensured the inclusion of only active accounts using account status flags or assumptions based on confirmed deposits.
* Combined results using a `UNION` to include both savings and investment accounts in a single alert system.

**Value to Stakeholders**:
This helps the operations and customer success teams run proactive outreach, re-engagement campaigns, or flag accounts at risk of churn.

### Question 4: Customer Lifetime Value (CLV) Estimation

**Business Goal**: Estimate the long-term financial value a customer brings based on their average transaction behavior and tenure.

**Assumptions**:

* Each transaction brings 0.1% in profit (i.e., profit = 0.001 × confirmed\_amount).
* CLV formula:
  $CLV = \left(\frac{\text{total_transactions}}{\text{tenure_months}}\right) \times 12 \times \text{avg_profit_per_transaction}$

**Approach**:

* Used `TIMESTAMPDIFF(MONTH, created_on, CURDATE()) + 1` to compute tenure in months, avoiding divide-by-zero errors.
* Counted total transactions per user using `COUNT(*)` and computed `AVG(confirmed_amount)` to estimate value per transaction.
* Calculated `avg_profit_per_transaction` by multiplying average transaction value by 0.001.
* Combined all metrics using a subquery to compute the final CLV per customer.
* Implemented `COALESCE` defensively to handle potential nulls.
* Sorted by CLV in descending order to prioritize high-value customers.

**Value to Stakeholders**:
CLV helps with resource planning and marketing budget allocation. It supports identifying who to retain, reward, or re-acquire.

## Challenges & Design Decisions

### 1. Tenure Calculation

To avoid zero-month tenure (which would cause a divide-by-zero error), a `+1` was added when calculating tenure. This is a design choice to protect integrity of calculations for new users.

### 2. Handling Missing or Zero Transactions

Although no nulls were found in the available sample, `COALESCE` was used in some areas (e.g., average profit) to ensure robustness in case of future data changes.

### 3. Readability and Maintainability

Queries were written with readability in mind: indentation, aliasing, and comments highlight logic clearly. Subqueries and CTEs were used where appropriate to break down complex logic.

### 4. Stakeholder Alignment

Each query was written to answer not just the "what" but also the "why." The output of each script supports a specific business decision or team goal (engagement, segmentation, reactivation, or revenue optimisation).

## File Overview

| Filename                    | Purpose                                                   |
| --------------------------- | --------------------------------------------------------- |
| `q1_funded_summary.sql`     | Identify customers with both funded savings + investments |
| `q2_frequency_analysis.sql` | Segment users by monthly transaction frequency            |
| `q3_inactivity_alert.sql`   | Flag inactive accounts for re-engagement                  |
| `q4_clv_estimation.sql`     | Estimate Customer Lifetime Value                          |


## Final Reflection

This project was approached with care to reflect what SQL looks like in a data team setting — balancing query optimization, clarity, and strategic thinking. Every result was designed to support a practical business action, from marketing segmentation to retention strategy.

By writing queries that are robust, easy to iterate on, and grounded in business needs, the goal was to demonstrate not just SQL skill, but analytical empathy.

Thank you for reviewing this submission.

> "A good SQL query tells you what’s happening. A great one helps you decide what to do next."
