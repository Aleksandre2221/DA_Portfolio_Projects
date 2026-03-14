## DAX Measures used in Project

- [KPI's](#kpi)
- [Orders](#orders)
- [Customers](#customers)
- [Operations](#operations)

----

## KPI

### 1. Total Sales
```DAX
Sales = 
SUM('FactOrders'[total_price_usd])
```

### 2. Total Customers
```DAX
Customers = 
DISTINCTCOUNT('FactOrders'[customer_id])
```

### 3. Total Orders
```DAX
Orders = 
DISTINCTCOUNT('FactOrders'[order_id])
```

### 4. Total Profit
```DAX
Profit = 
SUM('FactOrders'[profit_usd])
```

### 5. Total Production Cost
```DAX
Production Cost = 
SUM('FactOrders'[cost_usd])
```

### 6. Total Quantity Sold
```DAX
Qty Sold = 
SUM('FactOrders'[quantity])
```

### 7. Total Taxes
```DAX
Taxes = 
SUM('FactOrders'[tax_usd])
```

### 8. Profit %
```DAX
Profit % = 
DIVIDE([Profit], [Sales])
```

### 9. ROI %
```DAX
ROI % = 
DIVIDE([Profit], [Production Cost])
```

### 10. Total Sales LY
```DAX
Sales LY = 
CALCULATE(
    [Sales], 
    SAMEPERIODLASTYEAR('DimDate'[Date])
)
```

### 11. Sales YoY Diff 
```DAX
Sales YoY Diff = 
[Sales] - [Sales LY]
```

### 12. YoY %
```DAX
YoY % = 
VAR CY = [Sales]
VAR LY = [Sales LY]
RETURN
DIVIDE(CY-LY, LY)
```


## Orders 

### 1. AOV
```DAX
AOV = 
DIVIDE([Sales], [Orders])
```

### 2. AVG Discount %
```DAX
AVG Discount % = 
DIVIDE(AVERAGE(FactOrders[discount_percent]), 100)
```

### 3. AVG Qty per Order
```DAX
AVG Qty per Order = 
DIVIDE([Qty Sold], [Orders])
```

### 4. AVG Rating
```DAX
AVG Rating = 
AVERAGE('FactOrders'[rating])
```


## Customers

### 1. ARPU
```DAX
ARPU = 
DIVIDE([Sales], [Customers])
```

### 2. CLV
```DAX
CLV = 
[AOV] * [Purchase Frequency Rate] * [Customer Lifetime (Years)]
```

### 3. Customer Lifetime (Years)
```DAX
Customer Lifetime (Years) = 
AVERAGEX(
    VALUES('FactOrders'[customer_id]), 
    DATEDIFF(
        MIN('FactOrders'[order_date]),
        MAX('FactOrders'[order_date]),
        YEAR
    )
)
```

### 4. Loyalty Score 
```DAX
Loyalty Score = 
DIVIDE(AVERAGE('DimCustomers'[customer_loyalty_score]), 100)
```

### 5. New Customers
```DAX
New Customers = 
CALCULATE(
    DISTINCTCOUNT('FactOrders'[customer_id]),
    FILTER(
        VALUES('FactOrders'[customer_id]),
        CALCULATE(MIN('FactOrders'[order_date])) 
            IN VALUES('DimDate'[Date])
    )
)
```

### 6. Purchase Frequency %
```DAX
Purchase Frequency % = 
DIVIDE([Orders], [Customers])
```

### 7. Repurchase % = 
```DAX
Repurchase % = 
VAR LoyalCustomers = 
    COUNTROWS(
        FILTER(
            VALUES('FactOrders'[customer_id]), 
            CALCULATE(DISTINCTCOUNT('FactOrders'[order_id])) > 1
        )
    )
RETURN 
DIVIDE(LoyalCustomers, [Customers])
```


## Operations 

### 1. Cancelled Orders %
```DAX
Cancelled = 
VAR CancelledOrders = 
    CALCULATE(
        DISTINCTCOUNT('DimOrders'[order_id]), 
        'DimOrders'[order_status] = "Cancelled"
    )
RETURN
DIVIDE(CancelledOrders, [Orders])
```

### 2. Failed Transactions %
```DAX
Failed Transactions = 
VAR FailedTransactions = 
    CALCULATE(
        DISTINCTCOUNT('DimOrders'[order_id]),
        'DimOrders'[payment_status] = "Failed"
    )
RETURN
DIVIDE(FailedTransactions, [Orders])
```

### 3. Returned Orders %
```DAX
Returned = 
VAR ReturnedOrders =
    CALCULATE(
        DISTINCTCOUNT('DimOrders'[order_id]),
        'DimOrders'[order_status] = "Returned"
    )
RETURN
DIVIDE(ReturnedOrders, [Orders])
```

### 4. Shipping Days
```DAX
Shipping Days = 
AVERAGE('FactOrders'[delivery_days])
```
