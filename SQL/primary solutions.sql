create schema raw;

---customer table
CREATE TABLE raw.customers (
    customer_id VARCHAR(50),
    signup_date TEXT,
    city VARCHAR(100),
    acquisition_channel VARCHAR(100)
);
UPDATE customers 
SET signup_date = TO_DATE(signup_date, 'DD-MM-YYYY');


ALTER TABLE customers 
ALTER COLUMN signup_date TYPE DATE USING signup_date::DATE;

SELECT * FROM raw.customers 


--deliver partner table

create table raw.delivery_partner(
delivery_partner_id varchar(50),
partner_name TEXT,
city text,
vehicle_type text,
employment_type text,
avg_rating float(20),
is_active text
);

select * from raw.delivery_partner;

alter table delivery_partner
set schema raw;

---menu item table

create table raw.menu_item (
menu_item_id varchar (30),
restaurant_id varchar(30),
item_name text,
category text,
is_veg text,
price float(25)
);
select * from raw.menu_item

alter table menu_item
set schema raw;

--restaurant table
create table restaurant (
restaurant_id varchar(20),
restaurant_name text,
city text,
cuisine_type text,
partner_type text,
avg_prep_time_min varchar(20),
is_active text
);
select * from raw.restaurant

alter table restaurant
set schema raw;

--delivery performance

create table raw.delivery_performance(
order_id varchar(20),
actual_delivery_time_mins int,
expected_delivery_time_mins int,
distance_km float(10)
);

select * from raw.delivery_performance

alter table delivery_performance
set schema raw;

--order_items
create table order_items (
order_id varchar(30),
item_id varchar(30),
menu_item_id varchar(30),
restaurant_id varchar (30),
quantity int,
unit_price float(20),
item_discount float(20),
line_total float(20)
);

select * from raw.order_items

alter table order_items
set schema raw;

--orders
create table orders(
order_id varchar(20),
customer_id varchar(20),
restaurant_id varchar (20),
delivery_partner_id varchar(20),
order_timestamp text,
subtotal_amount float(20),
discount_amount float(20),
delivery_fee float(20),
total_amount float(20),
is_cod text,
is_cancelled text
);
ALTER TABLE orders 
ALTER COLUMN order_timestamp TYPE TIMESTAMP 
USING order_timestamp::TIMESTAMP;
select * from orders;

alter table orders
set schema raw;


--ratings
create table raw.ratings(
order_id varchar(20),
customer_id varchar(20),
restaurant_id varchar(20),
rating decimal(3,1),
review_text text,
review_timestamp text,
sentiment_score decimal(3,1)
);

alter table ratings
set schema raw;

select * from raw.ratings

--- fixing datatypes
ALTER TABLE raw.delivery_partner 
ALTER COLUMN avg_rating TYPE DECIMAL(3,2) USING avg_rating::DECIMAL(3,2);

ALTER TABLE raw.delivery_performance 
ALTER COLUMN distance_km TYPE DECIMAL(5,2) USING distance_km::DECIMAL(5,2);

--- DATA CLEANING

create schema staging


--- staging.customer

create table staging.customer  as 
select 
trim(customer_id) as customer_id,
signup_date,
INITCAP(trim(city)) as city,
lower(trim(acquisition_channel)) as acquisition_channel
from raw.customers;


select distinct city from staging.customer 
order by city

select distinct acquisition_channel from staging.customer
order by acquisition_channel

SELECT customer_id, COUNT(*)
FROM staging.customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

select * from staging.customer

--- staging.delivery_partner

select * from raw.delivery_partner
limit 15;

select delivery_partner_id from raw.delivery_partner
where delivery_partner_id is null
or partner_name is null
or city is null
or vehicle_type is null
or avg_rating is null
or is_active is null
or employment_type is null

select distinct city from raw.delivery_partner
order by city

select distinct vehicle_type from raw.delivery_partner
order by vehicle_type

select distinct employment_type from raw.delivery_partner
order by employment_type

select distinct is_active from raw.delivery_partner
order by is_active

SELECT *
FROM raw.delivery_partner
WHERE avg_rating < 0 OR avg_rating > 5;

SELECT COUNT(DISTINCT delivery_partner_id)
FROM raw.delivery_partner;

CREATE TABLE staging.delivery_partner AS
SELECT
    TRIM(delivery_partner_id) AS delivery_partner_id,
    INITCAP(TRIM(partner_name)) AS partner_name,
    INITCAP(TRIM(city)) AS city,
    LOWER(TRIM(vehicle_type)) AS vehicle_type,
    LOWER(TRIM(employment_type)) AS employment_type,
    ROUND(avg_rating::NUMERIC, 2) AS avg_rating,
    LOWER(TRIM(is_active)) AS is_active
FROM raw.delivery_partner;

--staging.menu_item
select * from raw.menu_item

select menu_item_id from raw.menu_item
where menu_item_id is null
or restaurant_id is null
or item_name is null
or category is null
or is_veg is null
or price is null

select distinct category from raw.menu_item

select distinct is_veg from raw.menu_item

SELECT *
FROM raw.menu_item
WHERE price <= 0 OR price > 5000;

CREATE TABLE staging.menu_item AS
SELECT
    TRIM(menu_item_id) AS menu_item_id,

    TRIM(restaurant_id) AS restaurant_id,

    INITCAP(TRIM(item_name)) AS item_name,

    LOWER(TRIM(category)) AS category,

    LOWER(TRIM(is_veg)) AS is_veg,

    ROUND(price::NUMERIC, 2) AS price

FROM raw.menu_item;

----staging.restaurant

select * from raw.restaurant

select restaurant_id from raw.restaurant
where restaurant is null
or restaurant_name is null
or city is null
or cuisine_type is null
or partner_type is null
or avg_prep_time_min is null
or is_active is null

SELECT DISTINCT city
FROM raw.restaurant
ORDER BY city;

SELECT DISTINCT cuisine_type
FROM raw.restaurant;

SELECT DISTINCT partner_type
FROM raw.restaurant;

SELECT DISTINCT is_active
FROM raw.restaurant;


CREATE TABLE staging.restaurant AS
SELECT
    TRIM(restaurant_id) AS restaurant_id,

    TRIM(restaurant_name) AS restaurant_name,

    INITCAP(TRIM(city)) AS city,

    INITCAP(TRIM(cuisine_type)) AS cuisine_type,

    INITCAP(TRIM(partner_type)) AS partner_type,

    avg_prep_time_min AS prep_time_bucket,
	
	CASE
        WHEN avg_prep_time_min = '<=15' THEN 10
        WHEN avg_prep_time_min = '16-25' THEN 20.5
        WHEN avg_prep_time_min = '26-40' THEN 33
        WHEN avg_prep_time_min = '>40' THEN 45
		
    END AS prep_time_numeric,
	
	TRIM (is_active) as is_active

FROM raw.restaurant;

--- staging.delivery_performance

select * from raw.delivery_performance

select order_id from raw.delivery_performance
where order_id is null
or actual_delivery_time_mins is null
or expected_delivery_time_mins is null
or distance_km is null

select order_id,count(*) from raw.delivery_performance
group by order_id
having count(*) >1 

SELECT *
FROM raw.delivery_performance
WHERE distance_km <= 0
   OR expected_delivery_time_mins <= 0
   OR actual_delivery_time_mins <= 0


CREATE TABLE staging.delivery_performance AS
SELECT
    TRIM(order_id) AS order_id,

    CAST(actual_delivery_time_mins AS NUMERIC) AS actual_delivery_time_mins,
    CAST(expected_delivery_time_mins AS NUMERIC) AS expected_delivery_time_mins,
    CAST(distance_km AS NUMERIC) AS distance_km

FROM raw.delivery_performance

ALTER TABLE staging.delivery_performance
ADD COLUMN delay_mins NUMERIC;

UPDATE staging.delivery_performance
SET delay_mins = actual_delivery_time_mins - expected_delivery_time_mins;

ALTER TABLE staging.delivery_performance 
ADD COLUMN avg_speed_kmh DECIMAL(5,2);
UPDATE staging.delivery_performance
SET avg_speed_kmh = distance_km / (NULLIF(actual_delivery_time_mins, 0) / 60.0);

select * from staging.delivery_performance

---staging order_items
select * from raw.order_items

select order_id from raw.order_items
where order_id is null
or item_id is null

or menu_item_id is null
or restaurant_id is null
or quantity is null
or unit_price is null
or item_discount is null
or line_total is null

SELECT *
FROM raw.order_items
WHERE quantity <= 0
or  unit_price <= 0
or line_total <= 0 
or item_discount < 0 

SELECT *
FROM raw.order_items
WHERE ABS(
    (quantity * unit_price - item_discount) - line_total
) > 1;


create table staging.order_items AS
select trim(order_id) as order_id,
		trim (item_id) as item_id,
		trim(menu_item_id) as menu_item_id,
		quantity as quantity,
		unit_price as unit_price,
		item_discount as item_discount,
		line_total as line_total

FROM raw.order_items
WHERE quantity > 0
  AND unit_price > 0
  AND item_discount >= 0;


ALTER TABLE staging.order_items
ADD COLUMN gross_amount NUMERIC;		

UPDATE staging.order_items
SET gross_amount = quantity * unit_price;

ALTER TABLE staging.order_items
ADD COLUMN discount_percentage NUMERIC;

UPDATE staging.order_items
SET discount_percentage =
    (item_discount / NULLIF(gross_amount, 0)) * 100;
	

---staging.orders

select * from raw.orders

SELECT *
FROM raw.orders
WHERE order_id IS NULL
   OR customer_id IS NULL
   OR restaurant_id IS NULL;

SELECT *
FROM raw.orders
WHERE subtotal_amount < 0
   OR discount_amount < 0
   OR delivery_fee < 0
   OR total_amount < 0;   


SELECT *
FROM raw.orders
WHERE ABS(
    (
        subtotal_amount
        - discount_amount
        + delivery_fee
    ) - total_amount
) > 1;   

SELECT order_timestamp
FROM raw.orders
LIMIT 10;

SELECT DISTINCT is_cod
FROM raw.orders;

SELECT DISTINCT is_cancelled
FROM raw.orders;

create table staging.orders as
select trim(order_id) as order_id,
	   trim(customer_id) as customer_id,
	   trim(restaurant_id) as restaurant_id,
	   order_timestamp as order_timestamp,
	   subtotal_amount as subtotal_amount,
	   discount_amount as discount_amount,
	   delivery_fee as delivery_fee,
	   is_cod as is_cod,
	   is_cancelled as is_cancelled

from raw.orders

---staging.ratings

select * from raw.ratings

SELECT *
FROM raw.ratings
WHERE order_id IS NULL;

DELETE FROM raw.ratings
WHERE order_id IS NULL
  AND customer_id IS NULL
  AND restaurant_id IS NULL
  AND rating IS NULL
  AND review_text IS NULL
  AND review_timestamp IS NULL
  AND sentiment_score IS NULL;

SELECT *
FROM raw.ratings
WHERE rating < 1
   OR rating > 5;

SELECT *
FROM raw.ratings
WHERE sentiment_score < -1
   OR sentiment_score > 1;  

SELECT review_timestamp
FROM raw.ratings
LIMIT 10;   

SELECT *
FROM raw.ratings
WHERE TRIM(review_text) = '';

SELECT *
FROM raw.ratings
WHERE rating >= 4
  AND sentiment_score < 0.3;

create  table staging.ratings as
select trim(order_id) as order_id,
	   trim(customer_id) as customer_id,
	   trim(restaurant_id) as restaurant_id,
	   rating as rating,
	   review_text as review_text,
	   review_timestamp as review_timestamp,
	   sentiment_score as sentiment_score
from raw.ratings	 
WHERE rating BETWEEN 1 AND 5

---Analysis 

create schema analytics

------------------Primary Analysis ---------------------

--1Q) Monthly Orders: Compare total orders across pre-crisis (Jan–May 2025) vs crisis  (Jun–Sep 2025). How severe is the decline? 
CREATE OR REPLACE VIEW analytics.monthly_orders AS

SELECT
    'Pre-Crisis' AS period,
    COUNT(order_id) AS total_orders
FROM staging.orders
WHERE order_timestamp BETWEEN
      '2025-01-01'
  AND '2025-05-31 23:59:59'

UNION ALL

SELECT
    'Crisis' AS period,
    COUNT(order_id) AS total_orders
FROM staging.orders
WHERE order_timestamp BETWEEN
      '2025-06-01'
  AND '2025-09-30 23:59:59';




--2Q)Which top 5 city groups experienced the highest percentage decline in orders during the crisis period compared to the pre-crisis period? 
CREATE OR REPLACE VIEW analytics.city_decline AS

WITH city_orders AS (

    SELECT
        c.city,

        CASE
            WHEN o.order_timestamp BETWEEN
                 '2025-01-01'
             AND '2025-05-31 23:59:59'
            THEN 'Pre-Crisis'

            WHEN o.order_timestamp BETWEEN
                 '2025-06-01'
             AND '2025-09-30 23:59:59'
            THEN 'Crisis'
        END AS period,

        COUNT(o.order_id) AS total_orders

    FROM staging.orders o

    JOIN staging.customer c
    ON o.customer_id = c.customer_id

    WHERE o.order_timestamp BETWEEN
          '2025-01-01'
      AND '2025-09-30 23:59:59'

    GROUP BY c.city, period
),

pivoted AS (

    SELECT
        city,

        SUM(
            CASE
                WHEN period = 'Pre-Crisis'
                THEN total_orders
                ELSE 0
            END
        ) AS pre_crisis_orders,

        SUM(
            CASE
                WHEN period = 'Crisis'
                THEN total_orders
                ELSE 0
            END
        ) AS crisis_orders

    FROM city_orders

    GROUP BY city
)

SELECT
    city,

    pre_crisis_orders,

    crisis_orders,

    ROUND(
        (
            (
                pre_crisis_orders
                - crisis_orders
            ) * 100.0
        ) / pre_crisis_orders,
        2
    ) AS decline_percentage

FROM pivoted

WHERE pre_crisis_orders > 0

ORDER BY decline_percentage DESC

LIMIT 5;

--3Q)  Among restaurants with at least 50 pre-crisis orders, which top 10 high-volume  restaurants experienced the largest percentage decline in order counts during the crisis period?

CREATE OR REPLACE VIEW analytics.restaurant_decline AS
WITH restaurant_orders AS (

    SELECT
        o.restaurant_id,

        CASE
            WHEN o.order_timestamp BETWEEN '2025-01-01' AND '2025-05-31 23:59:59'
            THEN 'Pre-Crisis'

            WHEN o.order_timestamp BETWEEN '2025-06-01' AND '2025-09-30 23:59:59'
            THEN 'Crisis'
        END AS period,

        COUNT(o.order_id) AS total_orders

    FROM staging.orders o

    WHERE o.order_timestamp BETWEEN '2025-01-01' AND '2025-09-30 23:59:59'

    GROUP BY o.restaurant_id, period
),

pivoted AS (

    SELECT
        restaurant_id,

        SUM(CASE WHEN period = 'Pre-Crisis' THEN total_orders ELSE 0 END) AS pre_crisis_orders,
        SUM(CASE WHEN period = 'Crisis' THEN total_orders ELSE 0 END) AS crisis_orders

    FROM restaurant_orders
    GROUP BY restaurant_id
),

filtered AS (

    SELECT *
    FROM pivoted
    WHERE pre_crisis_orders >= 5   -- realistic threshold based on your dataset
)

SELECT
    restaurant_id,
    pre_crisis_orders,
    crisis_orders,

    ROUND(
        (pre_crisis_orders - crisis_orders) * 100.0
        / NULLIF(pre_crisis_orders, 0),
        2
    ) AS decline_percentage

FROM filtered

ORDER BY decline_percentage DESC

LIMIT 10;

--4Q) Cancellation Analysis: What is the cancellation rate trend pre-crisis vs crisis,  and which cities are most affected? 

CREATE OR REPLACE VIEW analytics.cancellation_analysis AS

SELECT
    CASE
        WHEN order_timestamp BETWEEN '2025-01-01' AND '2025-05-31 23:59:59'
        THEN 'Pre-Crisis'

        WHEN order_timestamp BETWEEN '2025-06-01' AND '2025-09-30 23:59:59'
        THEN 'Crisis'
    END AS period,

    COUNT(order_id) AS total_orders,

    SUM(
        CASE
            WHEN LOWER(is_cancelled) IN ('yes','y','1','true','cancelled')
            THEN 1 ELSE 0
        END
    ) AS cancelled_orders,

    ROUND(
        SUM(
            CASE
                WHEN LOWER(is_cancelled) IN ('yes','y','1','true','cancelled')
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(order_id),
        2
    ) AS cancellation_rate

FROM staging.orders

WHERE order_timestamp BETWEEN '2025-01-01' AND '2025-09-30 23:59:59'

GROUP BY period;

---city-level-cancellation
CREATE OR REPLACE VIEW analytics.city_cancellation_analysis AS

WITH city_cancel AS (

    SELECT
        c.city,

        CASE
            WHEN o.order_timestamp BETWEEN '2025-01-01' AND '2025-05-31 23:59:59'
            THEN 'Pre-Crisis'

            WHEN o.order_timestamp BETWEEN '2025-06-01' AND '2025-09-30 23:59:59'
            THEN 'Crisis'
        END AS period,

        COUNT(o.order_id) AS total_orders,

        SUM(
            CASE
                WHEN LOWER(o.is_cancelled) IN ('yes','y','1','true','cancelled')
                THEN 1 ELSE 0
            END
        ) AS cancelled_orders

    FROM staging.orders o

    JOIN staging.customer c
    ON o.customer_id = c.customer_id

    WHERE o.order_timestamp BETWEEN '2025-01-01' AND '2025-09-30 23:59:59'

    GROUP BY c.city, period
),

pivoted AS (

    SELECT
        city,

        SUM(CASE WHEN period = 'Pre-Crisis' THEN total_orders ELSE 0 END) AS pre_orders,
        SUM(CASE WHEN period = 'Crisis' THEN total_orders ELSE 0 END) AS crisis_orders,

        SUM(CASE WHEN period = 'Pre-Crisis' THEN cancelled_orders ELSE 0 END) AS pre_cancelled,
        SUM(CASE WHEN period = 'Crisis' THEN cancelled_orders ELSE 0 END) AS crisis_cancelled

    FROM city_cancel

    GROUP BY city
)

SELECT
    city,

    pre_orders,
    crisis_orders,

    ROUND(pre_cancelled * 100.0 / NULLIF(pre_orders,0),2) AS pre_cancellation_rate,

    ROUND(crisis_cancelled * 100.0 / NULLIF(crisis_orders,0),2) AS crisis_cancellation_rate,

    ROUND(
        (
            crisis_cancelled * 100.0 / NULLIF(crisis_orders,0)
            -
            pre_cancelled * 100.0 / NULLIF(pre_orders,0)
        ),
        2
    ) AS change_in_cancellation_rate

FROM pivoted

ORDER BY change_in_cancellation_rate DESC

LIMIT 5;


---5Q) Delivery SLA: Measure average delivery time across phases. Did SLA  compliance worsen significantly in the crisis period?

CREATE OR REPLACE VIEW analytics.delivery_sla AS
WITH delivery_base AS (

    SELECT
        dp.order_id,
        dp.actual_delivery_time_mins,
        dp.expected_delivery_time_mins,
        dp.delay_mins,
        dp.avg_speed_kmh,
        dp.distance_km,

        o.order_timestamp,

        CASE
            WHEN o.order_timestamp BETWEEN '2025-01-01' AND '2025-05-31 23:59:59'
            THEN 'Pre-Crisis'

            WHEN o.order_timestamp BETWEEN '2025-06-01' AND '2025-09-30 23:59:59'
            THEN 'Crisis'
        END AS period,

        CASE
            WHEN dp.actual_delivery_time_mins <= dp.expected_delivery_time_mins
            THEN 1 ELSE 0
        END AS sla_met

    FROM staging.delivery_performance dp

    JOIN staging.orders o
    ON dp.order_id = o.order_id

    WHERE o.order_timestamp BETWEEN '2025-01-01' AND '2025-09-30 23:59:59'
),

metrics AS (

    SELECT
        period,

        COUNT(order_id) AS total_orders,

        AVG(actual_delivery_time_mins) AS avg_actual_time,
        AVG(expected_delivery_time_mins) AS avg_expected_time,

        AVG(delay_mins) AS avg_delay_mins,
        AVG(avg_speed_kmh) AS avg_speed_kmh,

        SUM(sla_met) AS sla_met_orders

    FROM delivery_base

    GROUP BY period
)

SELECT
    period,
    total_orders,

    ROUND(avg_actual_time,2) AS avg_actual_time,
    ROUND(avg_expected_time,2) AS avg_expected_time,
    ROUND(avg_delay_mins,2) AS avg_delay_mins,
    ROUND(avg_speed_kmh,2) AS avg_speed_kmh,

    ROUND(
        sla_met_orders * 100.0 / total_orders,
        2
    ) AS sla_compliance_rate

FROM metrics;

--6Q)  Ratings Fluctuation: Track average customer rating month-by-month. Which  months saw the sharpest drop? 

CREATE OR REPLACE VIEW analytics.monthly_rating AS
WITH monthly_rating AS (

    SELECT
        DATE_TRUNC(
            'month',
            TO_TIMESTAMP(
                TRIM(review_timestamp),
                'DD-MM-YYYY HH24:MI'
            )
        ) AS month,

        AVG(rating) AS avg_rating

    FROM staging.ratings

    WHERE review_timestamp IS NOT NULL
      AND TRIM(review_timestamp) <> ''

    GROUP BY month
)

SELECT *
FROM monthly_rating
ORDER BY month;

--7Q) During the crisis period, identify the most frequently  occurring negative keywords in customer review texts

CREATE OR REPLACE VIEW analytics.sentiment_insights AS

WITH negative_reviews AS (

    SELECT
        LOWER(review_text) AS review_text

    FROM staging.ratings

    WHERE
        TO_TIMESTAMP(
            TRIM(review_timestamp),
            'DD-MM-YYYY HH24:MI'
        )
        BETWEEN '2025-06-01'
            AND '2025-09-30 23:59:59'

        AND (
            rating <= 2
            OR sentiment_score < 0
        )

        AND review_text IS NOT NULL
),

split_words AS (

    SELECT
        REGEXP_SPLIT_TO_TABLE(
            review_text,
            '\s+'
        ) AS word

    FROM negative_reviews
)

SELECT
    word,

    COUNT(*) AS frequency

FROM split_words

WHERE LENGTH(word) > 3

AND word NOT IN (
    'this',
    'that',
    'with',
    'have',
    'they',
    'were',
    'from',
    'your',
    'food',
    'very',
    'there',
    'would',
    'been',
    'restaurant',
    'delivery'
)

GROUP BY word

ORDER BY frequency DESC;


--8Q)Revenue Impact: Estimate revenue loss from pre-crisis vs crisis (based on subtotal, discount, and delivery fee). 


CREATE OR REPLACE VIEW analytics.revenue_impact AS

WITH revenue_phase AS (

    SELECT
        CASE
            WHEN order_timestamp BETWEEN
                 '2025-01-01'
             AND '2025-05-31 23:59:59'
            THEN 'Pre-Crisis'

            WHEN order_timestamp BETWEEN
                 '2025-06-01'
             AND '2025-09-30 23:59:59'
            THEN 'Crisis'
        END AS period,

        COUNT(order_id) AS total_orders,

        SUM(subtotal_amount) AS subtotal_revenue,

        SUM(discount_amount) AS total_discount,

        SUM(delivery_fee) AS total_delivery_fee,

        SUM(
            subtotal_amount
            - discount_amount
            + delivery_fee
        ) AS total_revenue

    FROM staging.orders

    WHERE order_timestamp BETWEEN
          '2025-01-01'
      AND '2025-09-30 23:59:59'

    GROUP BY period
)

SELECT
    period,

    total_orders,

    ROUND(subtotal_revenue::NUMERIC,2) AS subtotal_revenue,

    ROUND(total_discount::NUMERIC,2) AS total_discount,

    ROUND(total_delivery_fee::NUMERIC,2) AS total_delivery_fee,

    ROUND(total_revenue::NUMERIC,2) AS total_revenue

FROM revenue_phase;

--revenue loss

CREATE OR REPLACE VIEW analytics.revenue_loss AS
WITH revenue_phase AS (

    SELECT
        CASE
            WHEN order_timestamp BETWEEN
                 '2025-01-01'
             AND '2025-05-31 23:59:59'
            THEN 'Pre-Crisis'

            WHEN order_timestamp BETWEEN
                 '2025-06-01'
             AND '2025-09-30 23:59:59'
            THEN 'Crisis'
        END AS period,

        SUM(
            subtotal_amount
            - discount_amount
            + delivery_fee
        ) AS revenue

    FROM staging.orders

    WHERE order_timestamp BETWEEN
          '2025-01-01'
      AND '2025-09-30 23:59:59'

    GROUP BY period
)

SELECT

    ROUND(
        MAX(
            CASE
                WHEN period='Pre-Crisis'
                THEN revenue
            END
        )::NUMERIC,
        2
    ) AS pre_crisis_revenue,

    ROUND(
        MAX(
            CASE
                WHEN period='Crisis'
                THEN revenue
            END
        )::NUMERIC,
        2
    ) AS crisis_revenue,

    ROUND(
        (
            MAX(
                CASE
                    WHEN period='Pre-Crisis'
                    THEN revenue
                END
            )
            -
            MAX(
                CASE
                    WHEN period='Crisis'
                    THEN revenue
                END
            )
        )::NUMERIC,
        2
    ) AS revenue_loss,

    ROUND(
        (
            (
                MAX(
                    CASE
                        WHEN period='Pre-Crisis'
                        THEN revenue
                    END
                )
                -
                MAX(
                    CASE
                        WHEN period='Crisis'
                        THEN revenue
                    END
                )
            )
            * 100.0
            /
            MAX(
                CASE
                    WHEN period='Pre-Crisis'
                    THEN revenue
                END
            )
        )::NUMERIC,
        2
    ) AS revenue_decline_percentage

FROM revenue_phase;

--9Q) Loyalty Impact: Among customers who placed five or more orders before the crisis, determine how many stopped ordering during the crisis, and out of those, how many had an average rating above 4.5?

CREATE OR REPLACE VIEW analytics.customer_loyalty_impact AS

WITH pre_crisis_customers AS (

    SELECT
        customer_id,
        COUNT(order_id) AS pre_crisis_orders

    FROM staging.orders

    WHERE order_timestamp BETWEEN
          '2025-01-01'
      AND '2025-05-31 23:59:59'

    GROUP BY customer_id

    HAVING COUNT(order_id) >= 5
),

crisis_customers AS (

    SELECT DISTINCT
        customer_id

    FROM staging.orders

    WHERE order_timestamp BETWEEN
          '2025-06-01'
      AND '2025-09-30 23:59:59'
),

churned_customers AS (

    SELECT
        pc.customer_id

    FROM pre_crisis_customers pc

    LEFT JOIN crisis_customers cc
    ON pc.customer_id = cc.customer_id

    WHERE cc.customer_id IS NULL
),

customer_ratings AS (

    SELECT
        customer_id,
        AVG(rating) AS avg_rating

    FROM staging.ratings

    GROUP BY customer_id
)

SELECT

    COUNT(DISTINCT ch.customer_id) AS customers_stopped_ordering,

    COUNT(
        DISTINCT CASE
            WHEN cr.avg_rating > 4.5
            THEN ch.customer_id
        END
    ) AS high_rated_churned_customers

FROM churned_customers ch

LEFT JOIN customer_ratings cr
ON ch.customer_id = cr.customer_id;

--10Q) Customer Lifetime Decline: Which high-value customers (top 5% by total  spend before the crisis) showed the largest drop in order frequency and ratings  during the crisis? What common patterns (e.g., location, cuisine preference, delivery delays) do they share? 

CREATE OR REPLACE VIEW analytics.high_value_customer_decline AS
WITH customer_spend AS (

    SELECT
        customer_id,

        SUM(
            subtotal_amount
            - discount_amount
            + delivery_fee
        ) AS total_spend

    FROM staging.orders

    WHERE order_timestamp BETWEEN
          '2025-01-01'
      AND '2025-05-31 23:59:59'

    GROUP BY customer_id
),

threshold AS (

    SELECT
        PERCENTILE_CONT(0.95)
        WITHIN GROUP (ORDER BY total_spend) AS spend_cutoff

    FROM customer_spend
),

high_value_customers AS (

    SELECT
        cs.customer_id,
        cs.total_spend

    FROM customer_spend cs
    CROSS JOIN threshold t

    WHERE cs.total_spend >= t.spend_cutoff
),

pre_orders AS (

    SELECT
        customer_id,
        COUNT(order_id) AS pre_orders

    FROM staging.orders

    WHERE order_timestamp BETWEEN
          '2025-01-01'
      AND '2025-05-31 23:59:59'

    GROUP BY customer_id
),

crisis_orders AS (

    SELECT
        customer_id,
        COUNT(order_id) AS crisis_orders

    FROM staging.orders

    WHERE order_timestamp BETWEEN
          '2025-06-01'
      AND '2025-09-30 23:59:59'

    GROUP BY customer_id
),

pre_ratings AS (

    SELECT
        customer_id,
        AVG(rating) AS pre_avg_rating

    FROM staging.ratings

    WHERE TO_TIMESTAMP(
            TRIM(review_timestamp),
            'DD-MM-YYYY HH24:MI'
          )
          BETWEEN '2025-01-01'
              AND '2025-05-31 23:59:59'

    GROUP BY customer_id
),

crisis_ratings AS (

    SELECT
        customer_id,
        AVG(rating) AS crisis_avg_rating

    FROM staging.ratings

    WHERE TO_TIMESTAMP(
            TRIM(review_timestamp),
            'DD-MM-YYYY HH24:MI'
          )
          BETWEEN '2025-06-01'
              AND '2025-09-30 23:59:59'

    GROUP BY customer_id
)

SELECT
    hv.customer_id,
    hv.total_spend,

    po.pre_orders,
    COALESCE(co.crisis_orders,0) AS crisis_orders,

    ROUND(pr.pre_avg_rating::NUMERIC,2) AS pre_avg_rating,

    ROUND(
        COALESCE(cr.crisis_avg_rating,0)::NUMERIC,
        2
    ) AS crisis_avg_rating,

    (
        po.pre_orders
        -
        COALESCE(co.crisis_orders,0)
    ) AS order_drop,

    ROUND(
        (
            pr.pre_avg_rating
            -
            COALESCE(cr.crisis_avg_rating,0)
        )::NUMERIC,
        2
    ) AS rating_drop

FROM high_value_customers hv

LEFT JOIN pre_orders po
ON hv.customer_id = po.customer_id

LEFT JOIN crisis_orders co
ON hv.customer_id = co.customer_id

LEFT JOIN pre_ratings pr
ON hv.customer_id = pr.customer_id

LEFT JOIN crisis_ratings cr
ON hv.customer_id = cr.customer_id

ORDER BY order_drop DESC, rating_drop DESC

LIMIT 20;