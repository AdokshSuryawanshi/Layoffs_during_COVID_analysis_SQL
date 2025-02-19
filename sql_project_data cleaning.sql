-- Data Cleaning

SELECT *
FROM layoffs;

# WE are going to do multople steps here.
-- Step 1. Remove duplicates
-- Step 2. Standarise the data
-- Step 3. Look at the NULL/ Blank Values
-- Step 4. Remove Any Column

CREATE TABLE layoffs_staging
LIKE layoffs ; 

SELECT *
FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

# now to check duplicates we are doing the below process

SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;
#in the row_num column we can see that each row 

#doing cte

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging
)
SELECT*
FROM duplicate_cte
WHERE row_num > 1;
# now where there is 2 in row_num it means they are duplicates given row num is 2 meaning it is repeated again.alter

SELECT *
FROM layoffs_staging
WHERE company  = 'Oda';
#now we saw that we didnt take all the columns and found out the above wasn't really a duplicate so changing the condition.

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT*
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company  = 'Casper';

#now lets delete the exact duplicate rows

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE 
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging4` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT*
FROM layoffs_staging4;

INSERT INTO layoffs_staging4
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT*
FROM layoffs_staging4
WHERE row_num > 1;

DELETE 
FROM layoffs_staging4
WHERE row_num > 1;

SELECT*
FROM layoffs_staging4;

-- Standardising Data

SELECT company, TRIM(company)
FROM layoffs_staging4;


UPDATE layoffs_staging4
SET company = TRIM(company);

SELECT DISTINCT industry, TRIM(industry)
FROM layoffs_staging4
ORDER BY 1;

SELECT *
FROM layoffs_staging4
WHERE industry LIKE 'Crypto%';

#there are 3 version of crypto- crypto, cryptocurrency, crypto currency so making them one.

UPDATE layoffs_staging4
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_staging4;

SELECT DISTINCT location
FROM layoffs_staging4
Order by 1;

SELECT DISTINCT country
FROM layoffs_staging4
Order by 1;

SELECT *
FROM layoffs_staging4
WHERE country LIKE 'United States%'
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging4
ORDER BY 1;

UPDATE layoffs_staging4
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT*
FROM layoffs_staging4;
#since the date is in text format, for timeseries analysis it is required to be in INT so we will convert it now

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') 
FROM layoffs_staging4;

UPDATE layoffs_staging4
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging4;

#it was still text and so to change the data type we are doing below step.
ALTER TABLE layoffs_staging4
MODIFY COLUMN `date` DATE;

#checking the changes
SELECT *
FROM layoffs_staging4;

-- working with NULL/blank values
SELECT *
FROM layoffs_staging4
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- removing rows & columns

SELECT *
FROM layoffs_staging4
WHERE industry IS NULL 
OR industry = ''; 

UPDATE layoffs_staging4
SET industry = NULL 
WHERE industry = ''; # there are null and blacnk values so converting them into one. 

SELECT *
FROM layoffs_staging4
WHERE company LIKE 'Bally%';

SELECT *
FROM layoffs_staging4 t1
JOIN layoffs_staging4 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL ;

SELECT t1.industry, t2.industry
FROM layoffs_staging4 t1
JOIN layoffs_staging4 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging4 t1
JOIN layoffs_staging4 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

#above we have populated the NULL values in industry since we knew some had values, for eg. Airbnb was repeated
#twice with only one industry mentioned 'Travel' and the other was blank so we populated it.

SELECT *
FROM layoffs_staging4
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


#to check the total NULL values in each of them
SELECT 
       SUM(total_laid_off IS NULL) AS count_total_laid_off_null,
       SUM(percentage_laid_off IS NULL) AS count_percentage_laid_off_null,
       COUNT(*) AS total_rows
FROM layoffs_staging4;

DELETE 
FROM layoffs_staging4
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging4;

#we use alter table to drop a column from a table
ALTER TABLE layoffs_staging4
DROP COLUMN row_num;

#DONE WITH CLEANING DATA ABOVE

-- Now we will do exploratory analysis with the cleaned data EDA (exploratory data analysis)

SELECT *
FROM layoffs_staging4;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging4;

SELECT *
FROM layoffs_staging4
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT *
FROM layoffs_staging4
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging4
GROUP BY company
ORDER BY sum_total_laid_off DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging4;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY YEAR(`date`)
ORDER BY 1 DESC; 

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY stage
ORDER BY 1 DESC; 

SELECT * 
FROM layoffs_staging4;

SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging4
GROUP BY company
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`, 6, 2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY SUBSTRING(`date`, 6, 2);
#above 6 means from sixth position of date i.e. 2022-01-21, here from sixth position is 0 from month. 

#or

SELECT SUBSTRING(`date`, 6, 2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY `MONTH`
ORDER BY 1 ;

#for year
SELECT SUBSTRING(`date`, 1, 4) AS `year`, SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY `year`;

# we can do more refined as month are all combined across years i.e. 2020. 2021, 2022, etc... so we'll take year along with month

SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY `MONTH`
ORDER BY 1; 

# now there is a null column above so we'll remove it

SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging4
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1; 

# now we will do rolling sum
#rolling sum:- Each row in the result reflects the sum of its value and all preceding rows' values in the specified order) 

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging4
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER (ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

# now that we have done the rolling total by date, we will look into yearly which companies have laid how many.

SELECT company, YEAR (`date`),SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY company, YEAR (`date`)
ORDER BY 3 DESC;

WITH Company_year (company, years, total_laid_off) AS
(SELECT company, YEAR (`date`),SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY company, YEAR (`date`)
), Company_Year_Rank AS 
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_year
WHERE years IS NOT NULL
ORDER BY Ranking ASC
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
ORDER by years ;



SELECT industry, YEAR (`date`),SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY industry, YEAR (`date`)
ORDER BY 2 ASC;

WITH Industry_year (industry, years, total_laid_off) AS
(SELECT industry, YEAR (`date`),SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY industry, YEAR (`date`)
), Industry_Year_Rank AS 
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Industry_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC
)
SELECT *
FROM Industry_Year_Rank
WHERE Ranking <= 5
ORDER by years ;

