-- EDA

-- Here we are just going to explore the data and find trends or patterns or anything interesting like outliers

-- normally when you start the EDA process you have some idea of what you're looking for

-- with this info we are just going to look around and see what we find!

Select *
From world_layoffs.Temp_layoffs_2;

-- Looking at Percentage to see how big these layoffs were
Select MAX(total_laid_off) , MAX(percentage_laid_off)
From world_layoffs.Temp_layoffs_2;

-- Which companies had 1 which is basically 100 percent of they company laid off
Select *
From world_layoffs.Temp_layoffs_2
where percentage_laid_off = 1 ;

-- these are mostly startups it looks like who all went out of business during this time
-- if we order by funcs_raised_millions we can see how big some of these companies were

Select *
From world_layoffs.Temp_layoffs_2
where percentage_laid_off = 1 
ORDER BY funds_raised_millions DESC ;

-- Companies with the most Total Layoffs
Select company , SUM(total_laid_off)
From world_layoffs.Temp_layoffs_2
GROUP BY company
ORDER BY 2 DESC;

Select min(`date`) , max(`date`)
From world_layoffs.Temp_layoffs_2;

-- by industry
Select industry , SUM(total_laid_off)
From world_layoffs.Temp_layoffs_2
GROUP BY industry
ORDER BY 2 DESC;

Select *
From world_layoffs.Temp_layoffs_2;


-- by country
Select country , SUM(total_laid_off)
From world_layoffs.Temp_layoffs_2
GROUP BY country
ORDER BY 2 DESC;

Select year(`date`) , SUM(total_laid_off)
From world_layoffs.Temp_layoffs_2
GROUP BY year(`date`)
ORDER BY 1 DESC;

Select stage , SUM(total_laid_off)
From world_layoffs.Temp_layoffs_2
GROUP BY stage
ORDER BY 2 DESC;

Select country , AVG(percentage_laid_off)
From world_layoffs.Temp_layoffs_2
GROUP BY country
ORDER BY 2 DESC;


-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per month and year.
-- Rolling Total of Layoffs Per Month

Select SUBSTRING(`date` ,1,7) AS `MONTH` , SUM(total_laid_off)
From world_layoffs.Temp_layoffs_2
WHERE SUBSTRING(`date` ,1,7) IS NOT NULL
GROUP BY `MONTH` 
ORDER BY 1 ASC
;

-- now use it in a CTE so we can query off of it
WITH rolling_total AS 
(
Select SUBSTRING(`date` ,1,7) AS `MONTH` , SUM(total_laid_off) as total_off
From world_layoffs.Temp_layoffs_2
WHERE SUBSTRING(`date` ,1,7) IS NOT NULL
GROUP BY `MONTH` 
ORDER BY 1 ASC
)
SELECT `MONTH` , total_off ,
SUM(total_off) OVER(ORDER BY `MONTH` ) AS rolling_total
FROM rolling_total;

Select company , year(`date`) , SUM(total_laid_off)
From world_layoffs.Temp_layoffs_2
GROUP BY company , year(`date`)
ORDER BY 3 DESC;

WITH Company_Year ( company , years , total_laid_off )AS
(
Select company , year(`date`) , SUM(total_laid_off)
From world_layoffs.Temp_layoffs_2
GROUP BY company , year(`date`)
ORDER BY 3 DESC
)
Select *
from Company_Year;

WITH Company_Year ( company , years , total_laid_off )AS
(
Select company , year(`date`) , SUM(total_laid_off)
From world_layoffs.Temp_layoffs_2
GROUP BY company , year(`date`)
), Company_Year_Rank AS
(Select *, dense_rank() over (PARTITION BY years order by total_laid_off DESC)
AS Ranking from Company_Year
WHERE years IS NOT NULL )
Select *
FROM Company_Year_Rank
WHERE Ranking <=5 ;








