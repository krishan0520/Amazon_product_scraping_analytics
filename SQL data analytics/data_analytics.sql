-- start of data analysis
-- Goal - To identify the trends of ratings and reviews of discounted laptops



SELECT * FROM laptop_data_fin;

-- 1. Can we identify the discount percentage and categorize based on Brands ?

DROP TEMPORARY TABLE discout_per;

CREATE TEMPORARY TABLE discout_per (
	SELECT Brand
	,Intialprice_updated
	,SellingPrice_updated,Reviews_updated,Rating_updated
	,Intialprice_updated - SellingPrice_updated AS discount
	,CAST(((Intialprice_updated - SellingPrice_updated) / Intialprice_updated) * 100 AS DECIMAL(4, 2)) AS discount_percentage FROM laptop_data_fin WHERE (Intialprice_updated - SellingPrice_updated) > 0
	);

-- Categorize discount rates as below
-- A category discount rate in between 75% or above
-- B category discount rate in 55% to 75%
-- C category discount rate in 35% to 55%
-- D category discount rate in 15% to 35%
-- E category discount rate below 15% 

SELECT Brand
	,discout_levels
	,COUNT(discout_levels) AS level_count
FROM (
	SELECT Brand
		,CASE 
			WHEN discount_percentage >= 75.00
				THEN 'A'
			WHEN discount_percentage BETWEEN 55.00
					AND 75.00
				THEN 'B'
			WHEN discount_percentage BETWEEN 35.00
					AND 55.00
				THEN 'C'
			WHEN discount_percentage BETWEEN 15.00
					AND 35.00
				THEN 'D'
			WHEN discount_percentage < 15.00
				THEN 'E'
			END discout_levels
	FROM discout_per
	ORDER BY discout_levels
	) discount_cate
GROUP BY Brand
	,discout_levels
ORDER BY 1;

-- 2. What is the most popular dicount level among all brands ?

WITH disount_counts
AS (
	SELECT Brand
		,discout_levels
		,COUNT(discout_levels) AS level_count
	FROM (
		SELECT Brand
			,CASE 
				WHEN discount_percentage >= 75.00
					THEN 'A'
				WHEN discount_percentage BETWEEN 55.00
						AND 75.00
					THEN 'B'
				WHEN discount_percentage BETWEEN 35.00
						AND 55.00
					THEN 'C'
				WHEN discount_percentage BETWEEN 15.00
						AND 35.00
					THEN 'D'
				WHEN discount_percentage < 15.00
					THEN 'E'
				END discout_levels
		FROM discout_per
		ORDER BY discout_levels
		) discount_cate
	GROUP BY Brand
		,discout_levels
	ORDER BY 1
	)
SELECT discout_levels
	,COUNT(*)
FROM disount_counts
GROUP BY 1
 ; -- This results indicate that most of brand encoraged to keep their discount rates below 35%.
   -- Its rare to see more than 75% discount rates 


-- 3.Do laptop with higer discount percentage tend to have higer ratings?


SELECT
discout_levels,
AVG(Rating_updated) OVER (PARTITION BY discout_levels) AS avg_rating_dicount_lelvel
FROM
(SELECT Brand,Rating_updated
			,CASE 
				WHEN discount_percentage >= 75.00
					THEN 'A'
				WHEN discount_percentage BETWEEN 55.00
						AND 75.00
					THEN 'B'
				WHEN discount_percentage BETWEEN 35.00
						AND 55.00
					THEN 'C'
				WHEN discount_percentage BETWEEN 15.00
						AND 35.00
					THEN 'D'
				WHEN discount_percentage < 15.00
					THEN 'E'
				END discout_levels
		FROM discout_per) dicount_rate;
        
-- Lets get average rating 

SELECT
AVG(Rating_updated)
FROM discout_per; -- avg of rating is 4.32

-- as per the result we can see up ward trend of rating when the discount is at higer value
-- Discount levels A,B and D clearly well above the average rating
-- But Discount level C(35%-55%) below the average rating along with discount level E


-- 4.Do laptop with higer discount percentage tend to have higer reviws 

SELECT
discout_levels,
AVG(Reviews_updated) OVER (PARTITION BY discout_levels) AS avg_reviews_dicount_lelvel
FROM
(SELECT Brand,Reviews_updated
			,CASE 
				WHEN discount_percentage >= 75.00
					THEN 'A'
				WHEN discount_percentage BETWEEN 55.00
						AND 75.00
					THEN 'B'
				WHEN discount_percentage BETWEEN 35.00
						AND 55.00
					THEN 'C'
				WHEN discount_percentage BETWEEN 15.00
						AND 35.00
					THEN 'D'
				WHEN discount_percentage < 15.00
					THEN 'E'
				END discout_levels
		FROM discout_per) dicount_rate;
        
-- lets get the average reviews for dicounted laptops

SELECT
AVG(Reviews_updated)
FROM discout_per ; -- Average reviews is 134.45

-- we can disregard the level A as it is well below than the average discount
-- Level B and C above the average reviews and it idicate reviews count have upward trend with the discount level.

		