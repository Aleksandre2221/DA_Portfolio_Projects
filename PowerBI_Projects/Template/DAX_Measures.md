## DAX Measures used in Project

```DAX
Total Sales = SUM(Orders[Sales])
YOY Growth = 
VAR CurrentYear = [Total Sales]
VAR LastYear = CALCULATE([Total Sales], DATEADD('Date'[Date], -1, YEAR))
RETURN DIVIDE(CurrentYear - LastYear, LastYear)
