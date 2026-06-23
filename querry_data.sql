select *from customer limit 20

--total revenue generate by male vs female customer

select gender, sum(purchase_amount) as revenue
from customer
group by gender

--customers used a discount but still spent more than the average purchase amount
SELECT customer_id, purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
AND purchase_amount >= (
    SELECT AVG(purchase_amount)
    FROM customer
);

--top 5 product with the higest average review rating
select item_purchased, ROUND(AVG(review_rating::numeric),2) as "Average Product Rating"
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5;

--compare the average purchased Amount between standard and expensive shipping
select shipping_type,
ROUND(AVG(purchase_amount),2)
from customer
where shipping_type in ('Standard','Express')
group by shipping_type

--Do subscribed customer spend more? Compare average spend and total revenue between subscriber and non-subsscriber?
select subscription_status,
count(customer_id) as total_customer,
ROUND(AVG(purchase_amount),2) as avg_spend,
ROUND(SUM(purchase_amount),2) as total_revenue
from customer
group by subscription_status
order by total_revenue, avg_spend desc;

-- 5 products have the higest percentage of purchases with discounts applied
SELECT item_purchased,
       ROUND(
           SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
           2
       ) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

--segment customer into New, returning, and Loyal based on their total number of previous purchase, 
--amd shoe the count of each segment

WITH customer_type AS (
    SELECT 
        customer_id,
        previous_purchases,
        CASE 
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer
)
SELECT 
    customer_segment,
    COUNT(*) AS "Number of Customers"
FROM customer_type
GROUP BY customer_segment;


--what are the top 3 most purchase product within each category?
with item_counts as(
select category,
item_purchased,
COUNT(customer_id) as total_orders,
ROW_NUMBER() over(partition by category order by count(customer_id) DESC ) as item_rank
from customer
group by category, item_purchased)

select item_rank, category, item_purchased, total_orders
from item_counts
where item_rank <=3;
)

-- are customers who are pepeat buyers (more then 5 previous purchases) also likely to subscribe?
select subscription_status,
count(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status


--what is revenue contribution of each age group?
select age_group,
SUM(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc;
