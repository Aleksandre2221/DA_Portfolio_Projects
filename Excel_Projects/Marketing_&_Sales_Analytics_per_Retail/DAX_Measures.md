## DAX Measures used in Project

### 1. Total Sales
```DAX
Sales 
=SUM('FactOrders'[Total_Amount])
```

### 2. Total Orders
```DAX
Orders 
=DISTINCTCOUNT('FactOrders'[Order_ID])
```

### 3. Total Customers
```DAX
Customers 
=DISTINCTCOUNT('DimCustomers'[Customer_ID])
```

### 4. Total Quantity Sold
```DAX
Qty Sold 
=SUM('FactOrders'[Total_Purchases])
```

### 5. Average Quantity Sold
```DAX
AVG Qty Sold 
=AVERAGE('FactOrders'[Total_Purchases])
```

### 6. Average Rating
```DAX
AVG Rating 
=AVERAGE('FactOrders'[Ratings])
```

### 7. Average Revenue per User
```DAX
ARPU 
=DIVIDE([Sales], [Customers])
```

### 8. Average Order Value
```DAX
AOV 
=DIVIDE([Sales], [Orders])
```

### 8. Purchase Frequency
```DAX
PF
=DIVIDE([Orders], [Customers])
```

### 9. Repurchase Rate
```DAX
Repurchase Rate % 
=DIVIDE(
    COUNTROWS(
        FILTER(
            VALUES('FactOrders'[Customer_ID]), 
            CALCULATE(COUNTROWS('FactOrders')) > 1
        )
    ), 
    [Customers]
)
```

### 10. New Customers
```DAX
New Customers 
=CALCULATE(
    DISTINCTCOUNT(FactOrders[Customer_ID]),
    FILTER(
        ADDCOLUMNS(
            VALUES(FactOrders[Customer_ID]),
            "FirstPurchaseDate", CALCULATE(MIN(DimDate[Date]))
        ),
        [FirstPurchaseDate] >= MIN(DimDate[Date]) &&
        [FirstPurchaseDate] <= MAX(DimDate[Date])
    )
)
```
