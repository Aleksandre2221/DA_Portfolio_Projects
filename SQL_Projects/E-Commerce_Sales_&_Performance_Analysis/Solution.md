## Solutions 
> Note: Only the top 5 rows of each result set are shown for readability purposes

### 1. General KPI's: What is the overall performance of the business in terms of orders, sales, customers, and operational efficiency?

```sql
WITH qty_per_order AS (
	SELECT order_id, 
		SUM(quantity) AS qty_per_order 
	FROM order_items 
	GROUP BY order_id
) 
	
SELECT 
	CONCAT(MIN(o.order_date), ' - ', MAX(o.order_date))			AS reporting_period, 
	ROUND(SUM(o.total_price), 0) 								AS total_sales,
	SUM(q.qty_per_order) 										AS total_qty_sold,
	COUNT(o.order_id) 											AS total_orders, 
	COUNT(DISTINCT o.customer_id)								AS total_unique_customers,
	ROUND(
		SUM(o.total_price) * 1.0 
		/ COUNT(o.order_id)
	, 0) 														AS aov,
	ROUND(
		SUM(o.total_price) * 1.0 
		/ COUNT(DISTINCT o.customer_id)
	, 0) 														AS arpu, 
	ROUND(
		AVG(s.delivery_date - s.shipment_date)
	, 1) 														AS avg_shipping_days,
	ROUND(
		SUM(q.qty_per_order) * 1.0 
		/ COUNT(o.order_id)
	, 1) 														AS avg_qty_per_order,
	ROUND(	
		AVG(
			CASE 
				WHEN s.shipment_status = 'Cancelled' 
				THEN 100.0 
				ELSE 0 
			END
		)
	, 1) 														AS cancelled_orders_ratio,
	ROUND(
		AVG(
			CASE 
				WHEN p.transaction_status = 'Failed' 
				THEN 100.0 
				ELSE 0 
			END
		)
	, 1) 														AS failed_trans_ratio
FROM 	  orders 		 o
LEFT JOIN qty_per_order  q USING (order_id) 
LEFT JOIN shipments 	 s USING (order_id)
LEFT JOIN payments 		 p USING (order_id);
```

**Result Set:**

| reporting_period           | total_sales | total_qty_sold | total_orders | total_unique_customers | aov  | arpu | avg_shipping_days | avg_qty_per_order | cancelled_orders_ratio | failed_trans_ratio |
|----------------------------|------------|----------------|-------------|-----------------------|------|------|-----------------|-----------------|----------------------|------------------|
| 2023-11-05 - 2024-11-04   | 42495705   | 93875          | 15000       | 10000                 | 2833 | 4250 | 4.5             | 6.3             | 4.9                  | 10.0             |
---

### 2. State Analysis: How do sales, top products, and customer value vary across different states?

```sql
WITH
	base_orders AS (
	    SELECT 
	        o.order_id,
	        o.customer_id,
	        o.total_price,
	        RIGHT(c.address, 2) 						AS purchase_state
	    FROM customers c
	    JOIN orders    o USING (customer_id)
	),
	
	orders_per_state AS (
	    SELECT 
	        purchase_state,
	        ROUND(
				SUM(total_price)
			, 0) 										AS total_sales,
			ROUND(
				SUM(total_price) * 100.0 
				/ SUM(SUM(total_price)) OVER()
			, 2) 										AS revenue_share_pct,
	        ROUND(
				SUM(total_price) * 1.0 
				/ COUNT(DISTINCT order_id)
			, 0) 	 									AS aov,
	        ROUND(
				SUM(total_price) * 1.0 
				/ COUNT(DISTINCT customer_id)
			, 0) 										AS arpu
	    FROM base_orders
	    GROUP BY purchase_state
	),
	
	product_stats_per_state AS (
	    SELECT 
	        bo.purchase_state,
	        p.product_name,
	        SUM(oi.quantity) 									AS total_qty,
	        ROW_NUMBER() OVER (
							PARTITION BY bo.purchase_state 
							ORDER BY SUM(oi.quantity) DESC)		AS rnk
	    FROM base_orders bo
	    JOIN order_items oi USING (order_id)
	    JOIN products 	  p USING (product_id)
	    GROUP BY bo.purchase_state, p.product_name
	),
	
	category_stats_per_state AS (
	    SELECT 
	        bo.purchase_state,
	        p.category,
	        SUM(oi.quantity) 									AS total_qty,
	        ROW_NUMBER() OVER (
							PARTITION BY bo.purchase_state 
							ORDER BY SUM(oi.quantity) DESC) 	AS rnk
	    FROM base_orders bo
	    JOIN order_items oi USING (order_id)
	    JOIN products 	  p USING (product_id)
	    GROUP BY bo.purchase_state, p.category
	),
	
	supplier_stats_per_state AS (
	    SELECT 
	        bo.purchase_state,
	        s.supplier_name,
	        SUM(oi.quantity) 									AS total_qty,
	        ROW_NUMBER() OVER (
							PARTITION BY bo.purchase_state 
							ORDER BY SUM(oi.quantity) DESC) 	AS rnk
	    FROM base_orders bo
	    JOIN order_items oi USING (order_id)
	    JOIN products 	  p USING (product_id)
	    JOIN suppliers 	  s USING (supplier_id)
	    GROUP BY bo.purchase_state, s.supplier_name
)

SELECT 
    o.purchase_state 			AS state,
	o.revenue_share_pct,
    o.total_sales,
    o.aov,
    o.arpu,
    p.product_name 				AS top_product,
    p.total_qty 				AS top_product_qty_sold,
    c.category 					AS top_category,
    c.total_qty 				AS top_category_qty_sold,
    s.supplier_name 			AS top_supplier,
    s.total_qty 				AS top_supplier_qty_supplied
FROM orders_per_state 		  o
JOIN product_stats_per_state  p ON p.purchase_state = o.purchase_state AND p.rnk = 1
JOIN category_stats_per_state c ON c.purchase_state = o.purchase_state AND c.rnk = 1
JOIN supplier_stats_per_state s ON s.purchase_state = o.purchase_state AND s.rnk = 1
ORDER BY o.revenue_share_pct DESC
LIMIT 5;
```

**Result Set:**

| state | revenue_share_pct | total_sales | aov | arpu | top_product | top_product_qty_sold | top_category | top_category_qty_sold | top_supplier | top_supplier_qty_supplied |
|-------|-------------------|------------|------|------|-------------|----------------------|--------------|-----------------------|--------------|---------------------------|
| NY | 2.23 | 947079 | 3055 | 4510 | Laptop Sleeve | 97 | Electronics | 600 | Strategic Partners Co. | 153 |
| CA | 2.23 | 947761 | 2990 | 4513 | Bookshelf | 81 | Electronics | 734 | Next Level Systems | 175 |
| CT | 2.23 | 946791 | 2968 | 4509 | Power Strip | 90 | Electronics | 803 | Ultimate Services | 167 |
| VA | 2.21 | 937712 | 2885 | 4465 | Monitor Stand | 90 | Electronics | 666 | Next Level Systems | 164 |
| WI | 2.21 | 938222 | 2896 | 4468 | Smart Watch | 102 | Electronics | 849 | Next Level Systems | 162 |
---

### 3. Carrier Analysis: How efficient are the carriers in terms of order fulfillment, cancellations, and shipping times?

```sql
SELECT 
	carrier,
	COUNT(shipment_id)									AS total_shipments,
	ROUND(
		AVG(delivery_date - shipment_date)
	, 2)												AS avg_shipping_days,
	ROUND(
		STDDEV(delivery_date - shipment_date)
	, 2)												AS delivery_variance,
	SUM(
		CASE 
			WHEN shipment_status = 'Delivered' 
			THEN 1 
			ELSE 0 
		END
	) 													AS delivered_shipments,
	SUM(
		CASE 
			WHEN shipment_status = 'Cancelled' 
			THEN 1 
			ELSE 0 
		END
	) 													AS cancelled_shipments_qty,
	ROUND(
		SUM(
			CASE 
				WHEN shipment_status = 'Cancelled' 
				THEN 1 
				ELSE 0 
			END
		) * 100.0 / COUNT(shipment_id)
	, 2) 												AS cancelled_pct
FROM     shipments
GROUP BY carrier
ORDER BY cancelled_pct;

```

**Result Set:**

| carrier | total_shipments | avg_shipping_days | delivery_variance | delivered_shipments | cancelled_shipments_qty | cancelled_pct |
|---------|----------------|------------------|-------------------|---------------------|--------------------------|---------------|
| DHL | 5000 | 4.50 | 2.07 | 1810 | 219 | 4.38 |
| FedEx | 5000 | 4.48 | 2.04 | 1760 | 254 | 5.08 |
| UPS | 5000 | 4.51 | 2.06 | 1804 | 257 | 5.14 |
---

### 4. Product / Category Analysis: Which products and categories perform best in terms of sales, quantity sold and top suppliers?
• **Product Analysis**

```sql
SELECT 
	p.product_id,
	p.product_name, 
	COALESCE(
			ROUND(SUM(oi.quantity * oi.price_at_purchase)
			, 0)
		, 0) 															AS total_sales, 
	COALESCE(
			ROUND(SUM(oi.quantity)
			, 0)
		, 0) 															AS total_qty_sold, 
	ROUND(SUM(oi.quantity * oi.price_at_purchase) * 100.0 
			/ SUM(SUM(oi.quantity * oi.price_at_purchase)) OVER()
		, 3)															AS revenue_share_pct
FROM      products 	   p 
LEFT JOIN order_items oi USING (product_id)
GROUP BY  p.product_id, p.product_name
ORDER BY  revenue_share_pct DESC NULLS LAST
LIMIT 5;
```

**Result Set:**

| product_id | product_name | total_sales | total_qty_sold | revenue_share_pct |
|------------|-------------|------------|---------------|-------------------|
| 697 | Water Bottle | 63823 | 92 | 0.150 |
| 1186 | Standing Desk | 61073 | 117 | 0.144 |
| 1012 | Rice Cooker | 59234 | 98 | 0.139 |
| 1181 | Wall Clock | 57196 | 107 | 0.135 |
| 1844 | Screen Protector | 56873 | 104 | 0.134 |
---

• **Category Analysis**

```sql
WITH 
	top_supplier_per_category AS (
		SELECT 
			p.category, 
			s.supplier_name, 
			SUM(oi.quantity) 							AS total_supplied,
			ROW_NUMBER() OVER(
					  PARTITION BY p.category 
					  ORDER BY SUM(oi.quantity) DESC) 	AS rn 
		FROM order_items oi
		JOIN products  	  p USING (product_id)
		JOIN suppliers 	  s USING (supplier_id)
		GROUP BY p.category, s.supplier_name
	),
	
	category_sales_stats AS (
		SELECT 
			p.category, 														
			ROUND(
				SUM(oi.quantity * oi.price_at_purchase)
			, 0) 														AS total_sales, 
			ROUND(
				SUM(oi.quantity)
			, 0) 														AS total_qty_sold, 
			ROUND(
				SUM(oi.quantity * oi.price_at_purchase) * 100.0 
				/ SUM(SUM(oi.quantity * oi.price_at_purchase)) OVER()
			, 1) 														AS revenue_share_pct
		FROM 	  products     p 
		LEFT JOIN order_items oi USING (product_id)
		GROUP BY  p.category
)

SELECT 
	c.category 					 AS product_category, 
	c.total_sales, 
	c.total_qty_sold, 
	c.revenue_share_pct, 
	t.supplier_name 			 AS top_supplier_name, 
	t.total_supplied 			 AS top_supplier_supplied_qty
FROM category_sales_stats c
JOIN top_supplier_per_category t ON c.category = t.category AND t.rn = 1
ORDER BY c.revenue_share_pct DESC;
```

**Result Set:**

| product_category | total_sales | total_qty_sold | revenue_share_pct | top_supplier_name | top_supplier_supplied_qty |
|------------------|------------|---------------|-------------------|-------------------|----------------------------|
| Electronics | 15247167 | 33704 | 35.9 | Unified Trading Co. | 3902 |
| Home & Kitchen | 11182786 | 24799 | 26.3 | Precision Suppliers LLC | 3052 |
| Accessories | 9833969 | 21763 | 23.1 | Modern Tech Enterprises | 2606 |
| Furniture | 6231783 | 13609 | 14.7 | Premier Logistics Inc. | 1993 |
---

### 5. Customer Analysis: Who are the most valuable and active customers based on purchases, reviews, and RFM Metrics?

```sql
WITH 
	rfm_metrics AS (
		SELECT 
			c.customer_id,
			(SELECT MAX(order_date) FROM orders) - MAX(o.order_date) 	AS recency,
			COUNT(o.order_id) 								 			AS frequency,
			SUM(o.total_price) 								 			AS monetary
		FROM 	 customers  c 
		LEFT JOIN orders 	o USING (customer_id)
		GROUP BY  c.customer_id 
	),
	
	rfm_scores AS (
	    SELECT 
	        customer_id,
	        NTILE(5) OVER (ORDER BY recency DESC)	 		  			AS recency_score, 
	        NTILE(5) OVER (ORDER BY frequency) 		 		  			AS frequency_score,
	        NTILE(5) OVER (ORDER BY monetary )		 		 			AS monetary_score
	    FROM rfm_metrics
	),
	
	sales_stats_per_customer AS (
		SELECT 
			c.customer_id, 
			CONCAT(c.first_name, ' ', c.last_name) 						AS customer_name, 
			ROUND(SUM(oi.quantity * oi.price_at_purchase), 0)			AS total_spent, 
			SUM(oi.quantity) 											AS total_qty_purchased, 
			COUNT(DISTINCT o.order_id) 									AS total_orders 
		FROM      customers     c
		LEFT JOIN orders 	    o USING (customer_id)
		LEFT JOIN order_items  oi USING (order_id)
		GROUP BY  c.customer_id
	),
	
	avg_rating_per_customer AS (
		SELECT 
			c.customer_id, 
			ROUND(AVG(r.rating), 1) 							AS avg_rating
		FROM 	  customers c 
		LEFT JOIN reviews   r USING (customer_id)
		GROUP BY  c.customer_id 
	),
	
	fav_product_category_per_customer AS (
		SELECT 
			c.customer_id, 
			p.category, 
			SUM(oi.quantity) 									AS total_qty_purchased, 
			ROW_NUMBER() OVER(
							PARTITION BY c.customer_id 
							ORDER BY SUM(oi.quantity) DESC) 	AS rnk
		FROM      customers 	c 
		LEFT JOIN orders 		o   USING (customer_id)
		LEFT JOIN order_items   oi  USING (order_id)
		LEFT JOIN products      p   USING (product_id)
		GROUP BY  c.customer_id, p.category
)

SELECT 
	      c.customer_id,
	      s.customer_name, 
	      s.total_spent, 
	      s.total_qty_purchased,
	      s.total_orders,
	      f.category 						  AS fav_product_category, 
	      f.total_qty_purchased 			  AS purchased_qty_from_fav_category, 
	      a.avg_rating,
	      r.recency_score,
	      r.frequency_score, 
	      r.monetary_score
FROM 	  customers 						c	
LEFT JOIN sales_stats_per_customer 			s USING (customer_id) 
LEFT JOIN avg_rating_per_customer 			a USING (customer_id) 
LEFT JOIN rfm_scores 						r USING (customer_id)
LEFT JOIN fav_product_category_per_customer f ON f.customer_id = c.customer_id AND f.rnk = 1
ORDER BY  s.total_spent DESC
LIMIT 5;
```

**Result Set:**

| customer_id | customer_name | total_spent | total_qty_purchased | total_orders | fav_product_category | purchased_qty_from_fav_category | recency_score | frequency_score | monetary_score |
|-------------|--------------|------------|--------------------|-------------|----------------------|---------------------------------|--------------|----------------|----------------|
| 9803 | John Williams | 19652 | 20 | 2 | Electronics | 10 | 5 | 3 | 5 |
| 4114 | James Natalie | 17567 | 18 | 2 | Electronics | 10 | 4 | 5 | 5 |
| 8941 | John Philip | 17124 | 19 | 2 | Home & Kitchen | 10 | 3 | 5 | 5 |
| 9953 | John Gonzalez | 16956 | 24 | 2 | Electronics | 13 | 3 | 5 | 5 |
| 7387 | Mary Douglas | 16952 | 20 | 2 | Home & Kitchen | 20 | 5 | 5 | 5 |
---

### 6. Supplier Analysis: Which suppliers contribute most to revenue, product quality, and order fulfillment reliability?

```sql
SELECT 
	s.supplier_id, 
	s.supplier_name,
	COUNT(DISTINCT p.product_id)									AS total_products, 
	COUNT(DISTINCT o.customer_id)									AS total_unique_customers,
	COUNT(DISTINCT o.order_id)										AS total_orders,
	SUM(oi.quantity) 												AS total_qty_sold, 
	ROUND(
		SUM(oi.quantity * oi.price_at_purchase)
	, 0) 															AS total_sales, 
	ROUND(
		SUM(oi.quantity * oi.price_at_purchase) 
		/ NULLIF(SUM(oi.quantity), 0)
	, 2)															AS avg_selling_price, 
	ROUND(
		SUM(oi.quantity * oi.price_at_purchase) * 100.0
		/ SUM(SUM(oi.quantity * oi.price_at_purchase)) OVER()
	, 2)															AS revenue_share_pct
FROM 	  suppliers     s 
LEFT JOIN products 		p  USING (supplier_id)
LEFT JOIN order_items 	oi USING (product_id)
LEFT JOIN orders 		o  USING (order_id)
GROUP BY  s.supplier_id, s.supplier_name 
ORDER BY  total_sales DESC
LIMIT 5; 
```

**Result Set:**

| supplier_id | supplier_name | total_products | total_unique_customers | total_orders | total_qty_sold | total_sales | avg_selling_price | revenue_share_pct |
|-------------|--------------|---------------|------------------------|-------------|---------------|------------|------------------|-------------------|
| 572 | Next Level Systems | 20 | 169 | 169 | 1079 | 550550 | 510.24 | 1.30 |
| 597 | Precision Suppliers LLC | 20 | 166 | 168 | 1107 | 529584 | 478.40 | 1.25 |
| 546 | Ultimate Services | 20 | 167 | 168 | 1135 | 515871 | 454.51 | 1.21 |
| 596 | Unified Trading Co. | 20 | 187 | 187 | 1145 | 512795 | 447.86 | 1.21 |
| 586 | Excel Distribution Group | 20 | 158 | 158 | 1066 | 512761 | 481.01 | 1.21 |
---
