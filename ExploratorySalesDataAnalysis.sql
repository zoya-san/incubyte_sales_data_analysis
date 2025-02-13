select count(*) from incubyte.assessment_dataset
-- # count(*)
-- '450000'
-- This count check is a data load validation, The total count of row matches the given assesment_dataset.csv

select COUNT(*), extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Year
from incubyte.assessment_dataset
group by 2

-- There is valid data only for the year 2022
-- There are about 10%(45038) of transaction witn no date

-- Total Dimensions: There are 8 Dimensions. TransactionID,CustomerID,TransactionDate,TransactionAmount,PaymentMethod,Quantity,DiscountPercent,City,StoreType,CustomerAge,CustomerGender,LoyaltyPoints,ProductName,Region,Returned, FeedbackScore, ShippingCost, DeliveryTimeDays, IsPromotional
-- Total Measures: There are 7 Measures. TransactionAmount,PaymentMethod,Quantity,DiscountPercent,City,StoreType,CustomerAge,CustomerGender,LoyaltyPoints,ProductName, Region, Returned,FeedbackScore,ShippingCost, DeliveryTimeDays
-- Granularity: The granularity of the data is at tranasction level.
-- A simple drill down in the dataset would be as shown below : Region > City > CustomerID > TransactionID


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
-- lag(sum(TransactionAmount)) over (order by extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y'))) - sum(TransactionAmount)) as 'Monthly Difference'
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
-- lag(sum(TransactionAmount)) over (order by extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y'))) - sum(TransactionAmount)) as 'Monthly Difference'
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

-- Month over month transaction by Region
select Month, year, Region,  TotalTransaction, PreviousMonthTotalTransaction,
coalesce(cast(((PreviousMonthTotalTransaction - TotalTransaction)/PreviousMonthTotalTransaction) *100 as decimal (5,2)),0)as PercentMonthlyChange
From (
select
extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Month,
extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Year,
REgion,
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