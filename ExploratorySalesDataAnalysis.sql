select count(*) from incubyte.assessment_dataset
-- # count(*)
-- '450000'
-- This count check is a data load validation, The total count of row matches the given assesment_dataset.csv

select count(*), extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Year
from incubyte.assessment_dataset
group by 2

-- There is valid data only for the year 2022
-- There are about 10%(45038) of transaction witn no date

-- Total Dimensions: There are 8 Dimensions. TransactionID,CustomerID,TransactionDate,TransactionAmount,PaymentMethod,Quantity,DiscountPercent,City,StoreType,CustomerAge,CustomerGender,LoyaltyPoints,ProductName,Region,Returned, FeedbackScore, ShippingCost, DeliveryTimeDays, IsPromotional
-- Total Measures: There are 7 Measures. TransactionAmount,PaymentMethod,Quantity,DiscountPercent,City,StoreType,CustomerAge,CustomerGender,LoyaltyPoints,ProductName, Region, Returned,FeedbackScore,ShippingCost, DeliveryTimeDays
-- Granularity: The granularity of the data is at tranasction level.
-- A simple drill down in the dataset would be as shown: Region > City > CustomerID > TransactionID


select 
extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Month,
extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Year,
count(TransactionID) as 'Number Of Transaction',
sum(TransactionAmount) as 'Total Transaction'
from incubyte.assessment_dataset
group by 1,2
order by 1

-- Month of december have low number of transactions, with less than 50% when compared to the other months.

select Month, year, PreviousMonthTotalTransaction , TotalTransaction,
cast(((PreviousMonthTotalTransaction - TotalTransaction)/PreviousMonthTotalTransaction) *100 as decimal (5,2)) as PercentMonthlyChange
From (
select
extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Month,
extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Year,
count(TransactionID) as 'Number Of Transaction',
sum(TransactionAmount) as TotalTransaction,
lag(sum(TransactionAmount)) over (order by extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y'))) as PreviousMonthTotalTransaction
from incubyte.assessment_dataset
where extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y'))= 2022
group by 1,2
order by 1) a

-- Month over month transaction by city
select Month, year, City,PreviousMonthTotalTransaction , TotalTransaction,
coalesce(cast(((PreviousMonthTotalTransaction - TotalTransaction)/PreviousMonthTotalTransaction) *100 as decimal (5,2)),0)as PercentMonthlyChange
From (
select
extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Month,
extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Year,
City,
count(TransactionID) as 'Number Of Transaction',
sum(TransactionAmount) as TotalTransaction,
coalesce(lag(sum(TransactionAmount)) over (partition by City order by extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y'))),0) as PreviousMonthTotalTransaction
from incubyte.assessment_dataset
where extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y'))= 2022
group by 1,2, 3
order by 1,3,4) a

-- Top 10 Cities by Transaction
select City, sum(TransactionAmount) as TotalTransaction
from incubyte.assessment_dataset
group by 1
order by 2 desc
limit 10
-- Kolkata has the Highest number of TotalTransaction

-- Month over month transaction by Region
select Month, year, Region,  TotalTransaction, PreviousMonthTotalTransaction,
coalesce(cast(((PreviousMonthTotalTransaction - TotalTransaction)/PreviousMonthTotalTransaction) *100 as decimal (5,2)),0)as PercentMonthlyChange
From (
select
extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Month,
extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Year,
Region,
count(TransactionID) as 'Number Of Transaction',
sum(TransactionAmount) as TotalTransaction,
coalesce(lag(sum(TransactionAmount)) over (partition by Region order by extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y'))),0) as PreviousMonthTotalTransaction
from incubyte.assessment_dataset
where extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y'))= 2022
group by 1,2, 3
order by 1,3,4) a


-- Top Region by Transaction
select Region, sum(TransactionAmount) as TotalTransaction
from incubyte.assessment_dataset
group by 1
order by 2 desc

-- South region has the Highest number of TotalTransaction


-- Top 10 most returned products based on transaction count  
-- This helps identify products with high return rates
select extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Month,
extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Year, ProductName, count(TransactionID) as  TotalReturns
from incubyte.assessment_dataset
where Returned = 'Yes'
group by 1,2,3
order by 4 desc
limit 10

-- Average shipping days took for each product and store type
select 
avg(DeliveryTimeDays) as AvgerageShiptmentDays, ProductName, StoreType
from incubyte.assessment_dataset
group by 2,3

-- Average shipping days across months and year
select 
extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Month,
extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Year,
avg(DeliveryTimeDays) as AvgerageShiptmentDays
from incubyte.assessment_dataset
group by 1,2
order by 2,1


-- Top 3 products based on transaction count 
select
extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Month,
extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Year,
count(TransactionID) as TransactionCount, 
ProductName
from incubyte.assessment_dataset
where extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) is not null
group by 1,2,4
order by 3 desc
limit 3
-- This shows that top products based on transaction count are  Notebook, T-Shirt and Sofa 

-- Top 3 products based on sum of total transaction
select
ProductName,
sum(TransactionAmount) as TotalTransaction
from incubyte.assessment_dataset
where extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) is not null
group by 1
order by 2 desc
limit 3
-- This shows that top products based on sum of transaction amounts are Laptop,  Sofa  and T-Shirt


-- Month over month transaction For top products
select Month, year, ProductName,  TotalTransaction, PreviousMonthTotalTransaction,
coalesce(cast(((PreviousMonthTotalTransaction - TotalTransaction)/PreviousMonthTotalTransaction) *100 as decimal (5,2)),0)as PercentMonthlyChange
From (
select
extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Month,
extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Year,
ProductName,
count(TransactionID) as 'Number Of Transaction',
sum(TransactionAmount) as TotalTransaction,
coalesce(lag(sum(TransactionAmount)) over (partition by ProductName order by extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y'))),0) as PreviousMonthTotalTransaction
from incubyte.assessment_dataset
where extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y'))= 2022
group by 1,2, 3
order by 1,3,4) a



-- return rate by shipping cost
select
ProductName,
avg(ShippingCost) as AvgerageShiptmentCost, 
count(case when Returned ='yes' then 1 end) as ReturnCount
from incubyte.assessment_dataset
group by 1

-- products with higher shipping costs, like sofa and laptop, do not necessarily have higher return rates, 
-- but, notebook has a moderate shipping cost but the highest return count.


-- The total number of times the product was returned based on the Avgerage Shiptment Days
select
ProductName,
avg(DeliveryTimeDays) as AvgerageShiptmentDays, 
count(case when Returned ='yes' then 1 end) as ReturnCount
from incubyte.assessment_dataset
group by 1
-- with longer shipment times, like Sofa, do not necessarily have higher return rates,
-- while Notebook stands out with the highest returns despite moderate delivery times.


-- Compare Total Transaction Amount based on store type
select 
StoreType,
sum(TransactionAmount) as TotalTransactionAmount
from incubyte.assessment_dataset
group by 1
-- The difference is quite minimal: In-Store transaction very slightly exceeds the online transactions



-- Online vs in store . Which has most returns
select
StoreType, count(case when Returned = 'yes' then 1 end) as ReturnCount
from incubyte.assessment_dataset
group by 1
-- The difference again is minimal in this case. Online returns are slightly higher than In-store returns.


-- Product returns based on storetype
select
ProductName, StoreType, count(case when Returned = 'yes' then 1 end) as ReturnCount
from incubyte.assessment_dataset
group by 1,2
order by 2