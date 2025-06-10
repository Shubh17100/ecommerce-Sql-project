Select * from df_customers;
Select * from df_orderitems;
Select * from df_orders;
Select * from df_payments;
Select * from df_products;


--1. Get the number of orders placed by each customer.
		Select c.customer_id , count(o.order_id) 
		from df_customers c 
		join df_orders o 
		on c.customer_id = o.customer_id 
		group by 1;

--2. Get the total number of orders placed. 
		select count(order_id) Total_orders from df_orders;

--3. Find the total revenue generated (price + shipping) per order.
		Select sum(price + shipping_charges) total_revenue from df_orderitems;

--4. Calculate the total payment value.
		Select sum(payment_value) total_payment_value from df_payments;

--5. Calculate the average payment value. 
		Select round(avg(payment_value),2) avg_value from df_payments;

--6. What is the min, max, and avg shipping charges?
		Select Min(shipping_charges) min_charge,
		max(shipping_charges) max_charge,
		round(avg(shipping_charges),2) avg_charge
		from df_orderitems;

--7. Get the top 5 product categories by total sales value.
		Select p.product_category_name, sum(oi.price) total_sales
		from df_orderitems oi
		join df_products p
		on oi.product_id = p.product_id
		group by 1 
		order by 2 desc
		limit 5;

--8. List the payment methods and their total transaction amounts.
		Select Payment_type, 
		sum(payment_value) total_transaction_amounts
		from df_payments
		group by 1 
		order by 2 desc;

--9. Find all customers who placed more than 5 orders
		Select c.customer_id, count(o.order_id) total_orders
		from df_customers c
		join df_orders o 
		on o.customer_id = c.customer_id
		group by 1 
		having count(o.order_id) > 5;

--10.  Get the average shipping charges by product category
		Select p.product_category_name, round(avg(oi.shipping_charges),2) avg_charges
		from df_products p
		join df_orderitems oi 
		on oi.product_id = p.product_id
		group by 1
		order by 2 desc;

--11. Find the total number of orders per state.
		Select c.customer_state, count(o.order_id) total_orders
		from df_customers c 
		join df_orders o 
		on c.customer_id = o.customer_id 
		group by 1 
		order by 2 desc;

--12. Get the total number of orders and total revenue for each month.
		Select 
		TO_CHAR( order_purchase_timestamp, 'YYYY-MM') as month, 
		sum(oi.price + oi.shipping_charges) total_revenue,
		round(avg(oi.price + oi.shipping_charges),2) avg_sales,
		count(o.order_id) total_orders
		from df_orders o
		join df_orderitems oi
		on o.order_id = oi.order_id
		group by 1
		order by 1;

--13. List all products with dimensions greater than 50 cm in any dimension.
		Select * from df_products 
		where product_length_cm > 50 or
		product_height_cm > 50 or 
		product_width_cm > 50;

--14. Get the average number of installments per payment type.
		Select payment_type, round(avg(payment_installments),2) avg_no_installments from df_payments
		group by 1 
		order by 2 desc;

--15. What is the average delivery time (approved to purchase) for each state?
		SELECT 
 		 c.customer_state, 
		 ROUND(AVG(EXTRACT(EPOCH FROM (order_approved_at - order_purchase_timestamp)) / 3600), 2) AS avg_delivery_hours
		FROM df_customers c 
		JOIN df_orders o ON c.customer_id = o.customer_id
		WHERE order_approved_at IS NOT NULL
		GROUP BY c.customer_state
		ORDER BY avg_delivery_hours DESC;

--16. Identify the top 5 cities with the highest number of distinct customers.
		Select c.customer_city, count(distinct o.customer_id) unique_customers 
		from df_customers c
		join df_orders o 
		on c.customer_id = o.customer_id
		group by 1 
		order by 2 desc 
		limit 5;

--17. Calculate the total revenue and number of orders per product category.
		Select p.product_category_name, 
		sum(oi.price + oi.shipping_charges) total_revenue,
		count(o.order_id) Number_orders
		from df_orders o
		join df_orderitems oi 
		on o.order_id = oi.order_id
		join df_products p
		on oi.product_id = p.product_id
		group by 1 
		order by 2 desc;

--18. Find the top 3 most frequently purchased products.
		Select oi.product_id,
		p.product_category_name, 
		count(*) purchase_count
		FROM 
    	df_orderitems oi
		JOIN 
		    df_products p ON oi.product_id = p.product_id
		GROUP BY 
		    oi.product_id, p.product_category_name
		ORDER BY 
		    purchase_count DESC
		LIMIT 3;

--19. What is the total shipping cost incurred by each seller?
		Select oi.seller_id, sum(oi.shipping_charges) total_shipping_cost
		from df_orderitems oi
		group by 1
		order by 2 desc;

--20. What is the monthly trend of orders over time?
		Select 
		Date_Trunc('Month', order_purchase_timestamp) order_time,
		count(o.order_id) total_orders 
		from df_orders o
		group by 1

--21.  Which product categories are most commonly paid for in installments?
			Select p.product_category_name, 
			round(avg(pt.payment_installments),2) as avg_installments
			from df_products p
			join df_orderitems oi
			on oi.product_id = p.product_id
			join df_payments pt
			on oi.order_id = pt.order_id
			group by 1
			having round(avg(pt.payment_installments),2) > 1
			order by 2 desc;

--22. List the top 5 customers who spent the most (total payment_value).
		select c.customer_id, sum(p.payment_value) total_payment_value 
		from df_customers c 
		join df_orders o
		on c.customer_id = o.customer_id
		join df_payments p
		on p.order_id = o.order_id
		group by 1
		order by 2 desc
		limit 5;

--23. Rank top-selling products by total price across all orders.
		Select product_id, 
		sum(price) total_sales, 
		rank() over (order by sum(price) desc) as product_rank
		from df_orderitems
		group by product_id;

--24. For each customer get their first order  date.
		SELECT 
    customer_id,
    order_id,
    order_purchase_timestamp,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_purchase_timestamp) AS rn
FROM 
    df_orders;

--25. Calculate running total of revenue by month.
		WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
        SUM(oi.price + oi.shipping_charges) AS revenue
    FROM 
        df_orders o
    JOIN 
        df_orderitems oi ON o.order_id = oi.order_id
    GROUP BY 
        order_month
)
SELECT 
    order_month,
    revenue,
    SUM(revenue) OVER (ORDER BY order_month) AS running_total
FROM 
    monthly_revenue;

--26. Compare each customer’s payment to their average payment.
		SELECT 
    order_id,
    customer_id,
    payment_value,
    AVG(payment_value) OVER (PARTITION BY customer_id) AS avg_payment
FROM (
    SELECT 
        o.order_id,
        o.customer_id,
        p.payment_value
    FROM 
        df_orders o
    JOIN 
        df_payments p ON o.order_id = p.order_id
) sub;

--27. Find the customers who made their last order in 2016.
		With last_orders as (Select 
			customer_id,
			max(order_purchase_timestamp) as last_order_date
		from df_orders
		group by 1)
		Select lo.customer_id, lo.last_order_date
		from last_orders lo
		where extract(year from lo.last_order_date) = 2016;

--28. What is the customer retention rate by month?
		WITH first_orders AS (
    SELECT customer_id, MIN(order_purchase_timestamp) AS first_order_date
    FROM df_orders
    GROUP BY customer_id
),
monthly_orders AS (
    SELECT DATE_TRUNC('month', order_purchase_timestamp) AS order_month, customer_id
    FROM df_orders
    GROUP BY 1, customer_id
)
SELECT 
    mo.order_month,
    COUNT(DISTINCT CASE WHEN fo.first_order_date < mo.order_month THEN mo.customer_id END) AS returning_customers,
    COUNT(DISTINCT mo.customer_id) AS total_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN fo.first_order_date < mo.order_month THEN mo.customer_id END) * 100.0 / 
        COUNT(DISTINCT mo.customer_id), 2
    ) AS retention_rate
FROM monthly_orders mo
JOIN first_orders fo ON mo.customer_id = fo.customer_id
GROUP BY 1
ORDER BY 1;

--29. Identify customers who haven’t ordered in the last 6 months.
		SELECT 
    c.customer_id,
    MAX(o.order_purchase_timestamp) AS last_order_date
FROM 
    df_customers c
LEFT JOIN 
    df_orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id
HAVING 
    MAX(o.order_purchase_timestamp) < CURRENT_DATE - INTERVAL '6 months'
    OR MAX(o.order_purchase_timestamp) IS NULL
ORDER BY 
    last_order_date;


