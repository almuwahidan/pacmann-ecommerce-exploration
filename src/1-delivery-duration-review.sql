-- Dataset 1
-- We're calculating whether there's any correlation between delivery duration and reviews
-- In this query, we're getting completed order data in 2018, and the reviews of such orders

-- by almuwahidan@gmail.com


-- stripping down order table
WITH orders AS (

	SELECT
		o.order_id
		, DATE(o.order_purchase_timestamp) AS purchase_date
		, DATE(o.order_approved_at) AS approved_date
		, DATE(o.order_delivered_customer_date) AS delivered_date
	FROM olist_order_dataset o
	WHERE TRIM(o.order_status) = "delivered"
		AND STRFTIME('%Y', o.order_purchase_timestamp) = "2018" 

),


-- stripping down order review table
reviews AS (

	SELECT order_id, review_score
	FROM olist_order_reviews_dataset

)

SELECT r.review_score, o.purchase_date, o.approved_date, o.delivered_date
FROM orders o
INNER JOIN reviews r
	ON o.order_id = r.order_id