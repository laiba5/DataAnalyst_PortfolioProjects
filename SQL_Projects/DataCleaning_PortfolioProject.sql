-- SQL Project - Data Cleaning
-- This raw dataset was taken by kaggle. It is a real dataset of companies employees layoffs.
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

select *
from world_layoffs.layoffs;


-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
Create Table world_layoffs.Temp_layoffs
Like world_layoffs.layoffs;

select *
from world_layoffs.Temp_layoffs;

INSERT into world_layoffs.Temp_layoffs
Select * 
from world_layoffs.layoffs;

-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways


-- Step 01
-- 1. Remove Duplicates

# First let's check for duplicates

Select * ,
row_number() over(partition by company, location , industry , total_laid_off, percentage_laid_off, `date` , stage , country , funds_raised_millions ) as row_num
from world_layoffs.Temp_layoffs;

with duplicate_cte AS
(
select *,
row_number() over(partition by company, location , industry , total_laid_off, percentage_laid_off, `date` , stage , country , funds_raised_millions ) as row_num
from world_layoffs.Temp_layoffs
)
Select *
from duplicate_cte
where row_num > 1;

-- now we found out the duplicates we need to delete them.

CREATE TABLE `world_layoffs`.`temp_layoffs_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from world_layoffs.Temp_layoffs_2;

INSERT into world_layoffs.Temp_layoffs_2
select *,
row_number() over(partition by company, location , industry , total_laid_off, percentage_laid_off, `date` , stage , country , funds_raised_millions ) as row_num
from world_layoffs.Temp_layoffs;

-- one solution, which I think is a good one. Is to create a new column and add those row numbers in. Then delete where row numbers are over 2, then delete that column
-- so let's do it!!


Select *
from world_layoffs.Temp_layoffs_2
where row_num > 1;

SET SQL_SAFE_UPDATES = 0;

DELETE
from world_layoffs.Temp_layoffs_2
where row_num > 1;

-- now checking it again to see if it is deleted or not
Select *
from world_layoffs.Temp_layoffs_2
where row_num > 1;

-- and its deleted.
Select *
from world_layoffs.Temp_layoffs_2;
 
 
 
 
-- Step 02
-- 2. StandarizeThe Data And Fixing Errors

select *
from world_layoffs.Temp_layoffs_2;

-- if we look at industry it looks like we have some null and empty rows, let's take a look at these

SELECT DISTINCT industry
FROM world_layoffs.Temp_layoffs_2
ORDER BY industry;

SELECT *
FROM world_layoffs.Temp_layoffs_2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- let's take a look at these
SELECT *
FROM world_layoffs.Temp_layoffs_2
WHERE company LIKE 'Bally%';
-- nothing wrong here
SELECT *
FROM world_layoffs.Temp_layoffs_2
WHERE company LIKE 'airbnb%';

-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

-- we should set the blanks to nulls since those are typically easier to work with
UPDATE world_layoffs.Temp_layoffs_2
SET industry = NULL
WHERE industry = '';

-- now if we check those are all null

SELECT *
FROM world_layoffs.Temp_layoffs_2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- now we need to populate those nulls if possible

UPDATE world_layoffs.Temp_layoffs_2 t1
JOIN world_layoffs.Temp_layoffs_2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- and if we check it looks like Bally's was the only one without a populated row to populate this null values

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- ---------------------------------------------------

-- I also noticed the Crypto has multiple different variations. We need to standardize that - let's say all to Crypto but first lets trim it for the spaces.
select company , TRIM(company)
from world_layoffs.Temp_layoffs_2;

UPDATE world_layoffs.Temp_layoffs_2
SET company = TRIM(company);

Select *
from world_layoffs.Temp_layoffs_2
where industry LIKE 'Crypto%';

UPDATE world_layoffs.Temp_layoffs_2
SET industry = 'Crypto'
where industry LIKE 'Crypto%';

-- now that's taken care of:
SELECT DISTINCT industry
FROM world_layoffs.Temp_layoffs_2
ORDER BY industry;
-- -------------------------------------------------


Select distinct location 
From world_layoffs.Temp_layoffs_2
ORDER BY 1;

-- everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize this.

Select distinct country 
From world_layoffs.Temp_layoffs_2
ORDER BY 1;

Select distinct country
From world_layoffs.Temp_layoffs_2
where country LIKE 'United States%';

UPDATE world_layoffs.Temp_layoffs_2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- now if we run this again it is fixed
SELECT DISTINCT country
FROM world_layoffs.Temp_layoffs_2
ORDER BY country;


-- Let's also fix the date columns:
Select `date`,
STR_TO_DATE(`date` , '%m/%d/%Y' )
FROM world_layoffs.Temp_layoffs_2;

UPDATE world_layoffs.Temp_layoffs_2
SET `date` = STR_TO_DATE(`date` , '%m/%d/%Y' );

-- now we can convert the data type properly

ALTER TABLE world_layoffs.Temp_layoffs_2
MODIFY COLUMN `date` date;

Select *
From world_layoffs.Temp_layoffs_2;


-- step 3
-- 3. Look at Null Values

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values

-- 4. remove any columns and rows we need to


Select *
From world_layoffs.Temp_layoffs_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT DISTINCT industry
FROM world_layoffs.Temp_layoffs_2;

Select *
From world_layoffs.Temp_layoffs_2
WHERE industry IS NULL
OR industry = '';

Select *
From world_layoffs.Temp_layoffs_2
WHERE company = 'Airbnb';

UPDATE world_layoffs.Temp_layoffs_2
SET industry = NULL
where industry = '';

SELECT t1.industry , t2.industry
FROM world_layoffs.Temp_layoffs_2 AS t1
join world_layoffs.Temp_layoffs_2 AS t2
	on t1.company = t2.company
	AND t1.location = t2.location
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

UPDATE world_layoffs.Temp_layoffs_2 t1
JOIN world_layoffs.Temp_layoffs_2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

Select *
From world_layoffs.Temp_layoffs_2
WHERE company LIKE 'Bally%';

Select *
From world_layoffs.Temp_layoffs_2;

-- Delete Useless data we can't really use
Select *
From world_layoffs.Temp_layoffs_2
where total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
From world_layoffs.Temp_layoffs_2
where total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE world_layoffs.Temp_layoffs_2
DROP COLUMN row_num;

Select *
From world_layoffs.Temp_layoffs_2;








