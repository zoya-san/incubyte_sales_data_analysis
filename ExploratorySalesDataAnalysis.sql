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

-- Month of december have low number of trnasactions, with only 
select * from(
select 
extract(month from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Month,
extract(year from STR_TO_DATE(TransactionDate,'%m/%d/%Y')) as Year,
count(TransactionID) as 'Number Of Transaction',
sum(TransactionAmount) as 'Total Transaction'
from incubyte.assessment_dataset
group by 1,2
order by 1) a