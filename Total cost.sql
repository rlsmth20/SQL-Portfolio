-- Calculate the total cost of all missions over all time
SELECT SUM("cost_MUSD") AS total_cost_MUSD
FROM mission_budgets;
