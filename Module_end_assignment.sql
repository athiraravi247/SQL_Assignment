use ecomm;
	
-- Q1. Impute mean for WarehouseToHome, HourSpendOnApp,
-- OrderAmountHikeFromlastYear and DaySinceLastOrder. Calculate rounded mean value
SELECT
    ROUND(AVG(WarehouseToHome)) AS Avg_WarehouseToHome,
    ROUND(AVG(HourSpendOnApp)) AS Avg_HourSpendOnApp,
    ROUND(AVG(OrderAmountHikeFromlastYear)) AS Avg_OrderAmountHike,
    ROUND(AVG(DaySinceLastOrder)) AS Avg_DaySinceLastOrder
FROM customer_churn;

SET SQL_SAFE_UPDATES = 0;

-- Impute the missing values using the calculated means
UPDATE customer_churn
SET WarehouseToHome = 16
WHERE WarehouseToHome IS NULL;	

UPDATE customer_churn
SET HourSpendOnApp = 3
WHERE HourSpendOnApp IS NULL;

UPDATE customer_churn
SET OrderAmountHikeFromlastYear = 16
WHERE OrderAmountHikeFromlastYear IS NULL;

UPDATE customer_churn
SET DaySinceLastOrder = 5
WHERE DaySinceLastOrder IS NULL;

-- Verify that the NULL values have been removed
SELECT
    SUM(WarehouseToHome IS NULL) AS WarehouseToHome_NULL,
    SUM(HourSpendOnApp IS NULL) AS HourSpendOnApp_NULL,
    SUM(OrderAmountHikeFromlastYear IS NULL) AS OrderAmountHike_NULL,
    SUM(DaySinceLastOrder IS NULL) AS DaySinceLastOrder_NULL
FROM customer_churn;

-- Q2. Impute mode for Tenure, CouponUsed and OrderCount
SELECT Tenure, COUNT(*) AS Frequency
FROM customer_churn
WHERE Tenure IS NOT NULL
GROUP BY Tenure
ORDER BY Frequency DESC
LIMIT 1;

SELECT CouponUsed, COUNT(*) AS Frequency
FROM customer_churn
WHERE CouponUsed IS NOT NULL
GROUP BY CouponUsed
ORDER BY Frequency DESC
LIMIT 1;

SELECT OrderCount, COUNT(*) AS Frequency
FROM customer_churn
WHERE OrderCount IS NOT NULL
GROUP BY OrderCount
ORDER BY Frequency DESC
LIMIT 1;

-- Impute mode for Tenure, CouponUsed and Ordercount
UPDATE customer_churn
SET Tenure = 1
WHERE Tenure IS NULL;

UPDATE customer_churn
SET CouponUsed = 1
WHERE CouponUsed IS NULL;

UPDATE customer_churn
SET OrderCount = 2
WHERE OrderCount IS NULL;

-- Verify Null values have been removed
SELECT
    SUM(Tenure IS NULL) AS Tenure_NULL,
    SUM(CouponUsed IS NULL) AS CouponUsed_NULL,
    SUM(OrderCount IS NULL) AS OrderCount_NULL
FROM customer_churn;

-- Handle outliers in WarehouseToHome
-- Find the number of outlier rows
SELECT COUNT(*) AS Outlier_Rows
FROM customer_churn
WHERE WarehouseToHome > 100;

-- Q3. Delete outliers where WarehouseToHome is greater than 100
DELETE FROM customer_churn
WHERE WarehouseToHome > 100;

-- Verify that no WarehouseToHome values greater than 100 remain
SELECT COUNT(*) AS Remaining_Outliers
FROM customer_churn
WHERE WarehouseToHome > 100;

-- Q4. Standardize PreferredLoginDevice and PreferedOrderCat
SELECT COUNT(*) AS Phone_Count
FROM customer_churn
WHERE PreferredLoginDevice = 'Phone';

SELECT COUNT(*) AS Mobile_Count
FROM customer_churn
WHERE PreferedOrderCat = 'Mobile';

-- Replace Phone with Mobile Phone
UPDATE customer_churn
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone';

-- Replace Mobile with Mobile Phone
UPDATE customer_churn
SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile';

-- Verify Q4
SELECT COUNT(*) AS Remaining_Phone
FROM customer_churn
WHERE PreferredLoginDevice = 'Phone';

SELECT COUNT(*) AS Remaining_Mobile
FROM customer_churn
WHERE PreferedOrderCat = 'Mobile';

-- Q5. Standardize PreferredPaymentMode
SELECT PreferredPaymentMode, COUNT(*) AS Frequency
FROM customer_churn
WHERE PreferredPaymentMode IN ('COD', 'CC')
GROUP BY PreferredPaymentMode;

-- Replace COD with Cash on Delivery
UPDATE customer_churn
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD';

-- Replace CC with Credit Card
UPDATE customer_churn
SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC';

-- Verify Q5
SELECT COUNT(*) AS Remaining_COD
FROM customer_churn
WHERE PreferredPaymentMode = 'COD';

SELECT COUNT(*) AS Remaining_CC
FROM customer_churn
WHERE PreferredPaymentMode = 'CC';

-- Data Transformation
-- Q1. Rename PreferedOrderCat to PreferredOrderCat
ALTER TABLE customer_churn
RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;

DESCRIBE customer_churn;

-- Q2. Rename HourSpendOnApp to HoursSpentOnApp
ALTER TABLE customer_churn
RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp;

-- Q3. Create ComplaintReceived column
ALTER TABLE customer_churn
ADD COLUMN ComplaintReceived VARCHAR(3);	

UPDATE customer_churn
SET ComplaintReceived =
    CASE
        WHEN Complain = 1 THEN 'Yes'
        ELSE 'No'
    END;
    
-- Q4. Create ChurnStatus column
ALTER TABLE customer_churn
ADD COLUMN ChurnStatus VARCHAR(10);    

UPDATE customer_churn
SET ChurnStatus =
    CASE
        WHEN Churn = 1 THEN 'Churned'
        ELSE 'Active'
    END;
    
SELECT Churn, ChurnStatus, COUNT(*) AS Frequency
FROM customer_churn
GROUP BY Churn, ChurnStatus;

-- Q5. Drop Churn and Complain columns
ALTER TABLE customer_churn
DROP COLUMN Churn,
DROP COLUMN Complain;

-- Data Exploration and Analysis
-- Q1. Count of churned and active customers
SELECT ChurnStatus,
       COUNT(CustomerID) AS NumberOfCustomers
FROM customer_churn
GROUP BY ChurnStatus;

-- Q2. Average tenure and total cashback of churned customers
SELECT
    ROUND(AVG(Tenure), 2) AS Average_Tenure,
    SUM(CashbackAmount) AS Total_Cashback
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- Q3. Determine the percentage of churned customers who complained.
SELECT 
    COUNT(CASE WHEN ComplaintReceived = 'Yes' THEN 1 END) * 100.0 
    / COUNT(*) AS Percentage_Churned_Complained
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- Q4. Identify the city tier with the highest number of churned customers
-- whose preferred order category is Laptop & Accessory.
SELECT 
    CityTier,
    COUNT(CustomerID) AS Churned_Customers
FROM customer_churn
WHERE ChurnStatus = 'Churned'
  AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY Churned_Customers DESC
LIMIT 1;

-- Q5. Identify the most preferred payment mode among active customers
SELECT
    PreferredPaymentMode,
    COUNT(CustomerID) AS NumberOfCustomers
FROM customer_churn
WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode
ORDER BY NumberOfCustomers DESC
LIMIT 1;

-- Q6. Total order amount hike for Single customers preferring Mobile Phone
SELECT
    SUM(OrderAmountHikeFromlastYear) AS Total_OrderAmount_Hike
FROM customer_churn
WHERE MaritalStatus = 'Single'
  AND PreferredOrderCat = 'Mobile Phone';

-- Q7. Average devices registered among UPI users
SELECT
    AVG(NumberOfDeviceRegistered) AS Average_Devices_Registered
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';

-- Q8. City tier with the highest number of customers
SELECT
    CityTier,
    COUNT(CustomerID) AS NumberOfCustomers
FROM customer_churn
GROUP BY CityTier
ORDER BY NumberOfCustomers DESC
LIMIT 1;

-- Q9. Gender that utilized the highest number of coupons
SELECT
    Gender,
    SUM(CouponUsed) AS Total_Coupons_Used
FROM customer_churn
GROUP BY Gender
ORDER BY Total_Coupons_Used DESC
LIMIT 1;

-- Q10. Customers and maximum hours spent by preferred order category
SELECT
    PreferredOrderCat,
    COUNT(CustomerID) AS NumberOfCustomers,
    MAX(HoursSpentOnApp) AS Max_Hours_Spent
FROM customer_churn
GROUP BY PreferredOrderCat;

-- Q11. Total order count for Credit Card users with maximum satisfaction score
SELECT
    SUM(OrderCount) AS Total_Order_Count
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
  AND SatisfactionScore = (
      SELECT MAX(SatisfactionScore)
      FROM customer_churn
  );

-- Find the Max Score
SELECT MAX(SatisfactionScore)
FROM customer_churn;

-- Q12. Average satisfaction score of customers who complained
SELECT
    AVG(SatisfactionScore) AS Average_Satisfaction_Score
FROM customer_churn
WHERE ComplaintReceived = 'Yes';

-- Q13. Preferred order category among customers who used more than 5 coupons
SELECT
    PreferredOrderCat,
    COUNT(CustomerID) AS NumberOfCustomers
FROM customer_churn
WHERE CouponUsed > 5
GROUP BY PreferredOrderCat;

-- Q14. Top 3 preferred order categories by average cashback
SELECT
    PreferredOrderCat,
    AVG(CashbackAmount) AS Average_Cashback
FROM customer_churn
GROUP BY PreferredOrderCat
ORDER BY Average_Cashback DESC
LIMIT 3;

-- Q15. Preferred payment modes with average tenure 10 months and over 500 orders
-- The result is 0 rows
SELECT
    PreferredPaymentMode,
    ROUND(AVG(Tenure), 2) AS Average_Tenure,
    SUM(OrderCount) AS Total_Order_Count
FROM customer_churn
GROUP BY PreferredPaymentMode
HAVING ROUND(AVG(Tenure), 2) = 10
   AND SUM(OrderCount) > 500;
   
-- Q15. Average tenure and total orders by payment mode
-- as the actual result is 0, Average tenure and total orders by payment found
SELECT
    PreferredPaymentMode,
    ROUND(AVG(Tenure), 2) AS Average_Tenure,
    SUM(OrderCount) AS Total_Order_Count
FROM customer_churn
GROUP BY PreferredPaymentMode;   

-- Q16. Churn status breakdown by warehouse-to-home distance
SELECT
    CASE
        WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
        WHEN WarehouseToHome <= 10 THEN 'Close Distance'
        WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
        ELSE 'Far Distance'
    END AS Distance_Category,
    ChurnStatus,
    COUNT(CustomerID) AS NumberOfCustomers
FROM customer_churn
GROUP BY Distance_Category, ChurnStatus
ORDER BY Distance_Category, ChurnStatus;

-- Q17. Order details of married, City Tier-1 customers above average order count
SELECT
    CustomerID,
    OrderCount,
    MaritalStatus,
    CityTier
FROM customer_churn
WHERE MaritalStatus = 'Married'
  AND CityTier = 1
  AND OrderCount > (
      SELECT AVG(OrderCount)
      FROM customer_churn
  );
  
-- Q18(a). Create customer_returns table
USE ecomm;

CREATE TABLE customer_returns (
    ReturnID INT,
    CustomerID INT,
    ReturnDate DATE,
    RefundAmount DECIMAL(10,2)
);  

-- Q18(a). Insert customer return data
INSERT INTO customer_returns
(ReturnID, CustomerID, ReturnDate, RefundAmount)
VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);

-- Verify customer_returns table
SELECT * FROM customer_returns;

-- Q18(b). Return details of churned customers who complained
SELECT
    r.ReturnID,
    r.CustomerID,
    r.ReturnDate,
    r.RefundAmount,
    c.ChurnStatus,
    c.ComplaintReceived
FROM customer_returns r
JOIN customer_churn c
    ON r.CustomerID = c.CustomerID
WHERE c.ChurnStatus = 'Churned'
  AND c.ComplaintReceived = 'Yes';



	