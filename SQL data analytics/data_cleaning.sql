-- Create the Schema aws_products
CREATE SCHEMA aws_products;

USE aws_products;

-- Create the table
CREATE TABLE laptop_amazon (
	Brand VARCHAR(50)
	,Title VARCHAR(255)
	,Intialprice VARCHAR(10)
	,SellingPrice VARCHAR(10)
	,Reviews VARCHAR(10)
	,Rating VARCHAR(50)
	);

-- Alter table columns as I got error while uploading data
ALTER TABLE laptop_amazon MODIFY COLUMN Title LONGTEXT;

ALTER TABLE laptop_amazon MODIFY COLUMN Brand VARCHAR(255);

ALTER TABLE laptop_amazon MODIFY COLUMN Intialprice VARCHAR(255);

ALTER TABLE laptop_amazon MODIFY COLUMN SellingPrice VARCHAR(255);

ALTER TABLE laptop_amazon MODIFY COLUMN Reviews VARCHAR(255);

ALTER TABLE laptop_amazon MODIFY COLUMN Rating VARCHAR(255);

ALTER TABLE laptop_amazon ADD COLUMN item_no SERIAL NOT NULL;

ALTER TABLE laptop_amazon ADD CONSTRAINT pk_item_no PRIMARY KEY (item_no);

SELECT *
FROM laptop_amazon;

-- Cleaning data 
-- Creating a view table using base data

CREATE VIEW laptop_data
AS
SELECT *
FROM laptop_amazon;

-- Removing data if Selling price N/A 

CREATE VIEW laptop_sellingprice
AS
SELECT *
FROM laptop_data
WHERE SellingPrice <> 'N/A'

;


-- Remove $ from price columns and format rating column with just rating / stored as a view 

CREATE VIEW laptop_price_formats AS 
SELECT item_no
	,Brand
	,Title
	,CASE 
		WHEN Intialprice = 'N/A'
			THEN Intialprice
		ELSE SUBSTRING(Intialprice, 2)
		END Intialprice_updated
	,SUBSTRING(SellingPrice, 2) AS SellingPrice_updated
	,Reviews
	,LEFT(Rating, 3) AS Rating_updated
FROM laptop_sellingprice;  

SELECT*FROM
laptop_price_formats;

-- Get the count of datapoints in Reviews starts with $ sign

SELECT COUNT(Reviews)
FROM laptop_price_formats
WHERE Reviews LIKE '$%'; -- Its indicates we have 164 datpoints stars with $ sign ,which nearly 20% of total data points

-- Replacing those datapoints and datapoints with letters in Review column with 'N/A' as wrongly extracted during the web scrapping

CREATE VIEW laptop_reviewsup
AS
SELECT item_no
	,Brand
	,Title
	,Intialprice_updated
	,SellingPrice_updated
	,CASE 
		WHEN Reviews LIKE '$%'
			OR Reviews REGEXP '[A-Za-z]'
			OR TRIM(Reviews) = ''
			THEN 'N/A'
		ELSE Reviews
		END Reviews_updated
	,Rating_updated
FROM laptop_price_formats;

SELECT*FROM laptop_reviewsup;
-- Checking for non null value counts in numeric columns

SELECT
COUNT(COALESCE(Reviews_updated)),
COUNT(COALESCE(Rating_updated)),
COUNT(COALESCE(Intialprice_updated)),
COUNT(COALESCE(SellingPrice_updated))
FROM
laptop_reviewsup; -- Confirmed that there are no null values 


-- Changing  data formats of numeric columns

CREATE VIEW laptop_final
AS
SELECT item_no
	,Brand
	,Title
	,CAST(Intialprice_updated AS DECIMAL(6, 2)) AS Intialprice_updated
	,CAST(SellingPrice_updated AS DECIMAL(6, 2)) AS SellingPrice_updated
	,CAST(Reviews_updated AS SIGNED INT) AS Reviews_updated
	,CAST(Rating_updated AS DECIMAL(6, 2)) AS Rating_updated
FROM laptop_reviewsup;

-- Check for Duplicate items 

SELECT
a.*
FROM laptop_final a
JOIN laptop_final b
ON a.Title = b.Title
AND a.item_no <> b.item_no
; -- This result indicate we have repeating items

-- Removing duplicates from the and store as view for anlaytics

CREATE VIEW laptop_data_fin
AS
SELECT item_no
	,Brand
	,Title
	,Intialprice_updated
	,SellingPrice_updated
	,Reviews_updated
	,Rating_updated
FROM (
	SELECT MIN(item_no) AS item_no
		,Brand
		,Title
		,Intialprice_updated 
		,SellingPrice_updated
		,Reviews_updated
		,Rating_updated
		,COUNT(*) AS duplicate_count
	FROM laptop_final
	GROUP BY Title
	HAVING COUNT(*) >= 1
	) duplicate_table;
    
    

      


