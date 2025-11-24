## DAX Measures used in Project

### 1. Year over Year Growth Rate 
```DAX
Total Sales = SUM(Orders[Sales])
YOY Growth = 
VAR CurrentYear = [Total Sales]
VAR LastYear = CALCULATE([Total Sales], DATEADD('Date'[Date], -1, YEAR))
RETURN DIVIDE(CurrentYear - LastYear, LastYear)
```

### 2. Year over Year Growth Rate 
```DAX
Total Sales = SUM(Orders[Sales])
YOY Growth = 
VAR CurrentYear = [Total Sales]
VAR LastYear = CALCULATE([Total Sales], DATEADD('Date'[Date], -1, YEAR))
RETURN DIVIDE(CurrentYear - LastYear, LastYear)
```
