## Solutions

#### 1. Who is the senior most employee based on job title?

```sql
SELECT   title, last_name, first_name 
FROM     employee
ORDER BY levels DESC
LIMIT    1
```

**Result Set:**

billing_country	 |invoice_count |
--|--|
USA |	131 |
Canada |	76 |
Brazil |	61 |
France |	50 |
Germany |	41 |
Czech Republic |	30 |
Portugal |	29 |
United Kingdom |	28 |
India |	21 |
Chile |	13 |

---

#### 2. Which countries have the most Invoices?

```sql
SELECT   billing_country, COUNT(*) as invoice_count
FROM     invoice
GROUP BY 1
ORDER BY 2 DESC
LIMIT    10
```

**Result Set:**

billing_country	 |invoice_count |
--|--|
USA |	131 |
Canada |	76 |
Brazil |	61 |
France |	50 |
Germany |	41 |
Czech Republic |	30 |
Portugal |	29 |
United Kingdom |	28 |
India |	21 |
Chile |	13 |
