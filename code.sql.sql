SELECT *
	FROM subscriptions
	LIMIT 100; /* step 1 */
 
SELECT min(subscription_start), 
	max(subscription_start), 
	max(subscription_end)
FROM subscriptions; /* step 2 */
 
WITH months AS (
	SELECT '2017-01-01' AS first_day, 
		'2017-01-31' AS last_day 
	UNION SELECT '2017-02-01' AS first_day, 
		'2017-02-28' AS last_day 
	UNION SELECT '2017-03-01' AS first_day,
		'2017-03-31' AS last_day), /* step 3 */
cross_join AS (
	SELECT *
		FROM subscriptions
		CROSS JOIN months), /* step 4 */
status AS (
	SELECT id, first_day AS month, 
		CASE
			WHEN segment = 87
			AND subscription_start < first_day
			THEN 1
			ELSE 0
			END AS is_active_87,
		CASE
			WHEN segment = 30
			AND subscription_start < first_day
			THEN 1
			ELSE 0
			END AS is_active_30, /* step 5 */
		CASE 
			WHEN segment = 87
			AND subscription_end >= first_day			
			AND subscription_end <= last_day
			THEN 1
			ELSE 0
			END AS is_canceled_87,
		CASE 
			WHEN segment = 30
			AND subscription_end >= first_day
			AND subscription_end <= last_day 
			THEN 1
			ELSE 0
			END AS is_canceled_30 /* step 6 */
	FROM cross_join),
status_aggregate AS (
	SELECT month, 
		sum(is_active_87) AS sum_active_87, 
		sum(is_active_30) AS sum_active_30, 
		sum(is_canceled_87) AS sum_canceled_87,
		sum(is_canceled_30) AS sum_canceled_30
	FROM status
	GROUP BY 1) /* step 7 */
SELECT month, 
	sum_canceled_87*1.0 / sum_active_87 AS churn_87, 		
	sum_canceled_30*1.0 / sum_active_30 AS churn_30 
FROM status_aggregate; /* step 8 and 9 */