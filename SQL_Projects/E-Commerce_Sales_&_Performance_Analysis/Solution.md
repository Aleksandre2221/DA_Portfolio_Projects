## Solutions

#### 1. General KPI's: What is the overall performance of the business in terms of orders, sales, customers, and operational efficiency?

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

#### 2. Which countries have the most Invoices?
