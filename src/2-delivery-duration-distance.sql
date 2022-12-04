-- Dataset 2
-- We're calculating whether there's any correlation between distance and delivery duration
-- In this query, we're getting completed order data in 2018, and location of both customer and seller

-- by almuwahidan@gmail.com


-- stripping down order table
WITH orders AS (

	SELECT
		o.order_id
		, DATE(o.order_purchase_timestamp) AS purchase_date
		, DATE(o.order_delivered_customer_date) AS delivered_date
		, o.customer_id AS customer_id
	FROM olist_order_dataset o
	WHERE TRIM(o.order_status) = "delivered"
		AND STRFTIME('%Y', o.order_purchase_timestamp) = "2018" 

),

-- stripping down items table
order_items AS (

	SELECT order_id, seller_id
	FROM olist_order_items_dataset
	GROUP BY 1

),

-- stripping down seller table
sellers AS (

	SELECT seller_id, seller_zip_code_prefix 
	FROM olist_sellers_dataset

),


-- stripping down customer table
customers AS (

	SELECT customer_id, customer_zip_code_prefix 
	FROM olist_order_customer_dataset
	
),


-- stripping down geolocation table + join with seller table
geolocation_sellers AS (

	SELECT
		s.seller_id
		, gl.geolocation_zip_code_prefix
		, TRIM(gl.geolocation_city) AS seller_city
		, AVG(gl.geolocation_lat) AS seller_lat
		, AVG(gl.geolocation_lng) AS seller_lng
	FROM olist_geolocation_dataset gl
	INNER JOIN sellers s
		ON gl.geolocation_zip_code_prefix = s.seller_zip_code_prefix
	GROUP BY 1, 2

),


-- stripping down geolocation table + join with customer table
geolocation_customers AS (

	SELECT
		c.customer_id
		, gl.geolocation_zip_code_prefix
		, TRIM(gl.geolocation_city) AS customer_city
		, AVG(gl.geolocation_lat) AS customer_lat
		, AVG(gl.geolocation_lng) AS customer_lng
	FROM olist_geolocation_dataset gl
	INNER JOIN customers c
		ON gl.geolocation_zip_code_prefix = c.customer_zip_code_prefix
	GROUP BY 1, 2

),


-- Step 1: get data of delivery dates and seller + customer IDs
delivered_orders AS (

	SELECT
		o.purchase_date
		, o.delivered_date
		, o.customer_id
		, oi.seller_id AS seller_id
	FROM orders o
	INNER JOIN order_items oi
		ON o.order_id = oi.order_id

),


-- Step 2: add seller location data (lat, lng)
delivered_order_sellers AS (
	
	SELECT
		do.purchase_date
		, do.delivered_date
		, do.customer_id
		, gls.seller_lat
		, gls.seller_lng
		, gls.seller_city
	FROM delivered_orders do
	INNER JOIN geolocation_sellers gls
		ON do.seller_id = gls.seller_id

),


-- Step 3: add customer location data (lat, lng)
delivered_order_complete AS (

	SELECT
		dos.purchase_date
		, dos.delivered_date
		, dos.seller_lat
		, dos.seller_lng
		, dos.seller_city
		, glc.customer_lat
		, glc.customer_lng
		, glc.customer_city
	FROM delivered_order_sellers dos
	INNER JOIN geolocation_customers glc
		ON dos.customer_id = glc.customer_id

)

SELECT *
FROM delivered_order_complete
