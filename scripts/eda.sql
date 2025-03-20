-- Use the layoffs database
USE layoffs_db;

-- Step 1: Get basic statistics on layoffs
-- Maximum number of employees laid off in a single event
SELECT MAX(total_laid_off) AS max_layoffs FROM layoffs_staging;

-- Identify companies that had 100% layoffs (completely shut down)
SELECT company, location, industry, total_laid_off, percentage_laid_off
FROM layoffs_staging
WHERE percentage_laid_off = 1;

-- Step 2: Analyze layoffs by year
-- Get total layoffs per year
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY YEAR(date)
ORDER BY year ASC;

-- Step 3: Rolling total of layoffs over time
-- This helps visualize how layoffs accumulated over time
WITH rolling_totals AS (
    SELECT 
        DATE_FORMAT(date, '%Y-%m') AS month, 
        SUM(total_laid_off) AS monthly_layoffs
    FROM layoffs_staging
    GROUP BY DATE_FORMAT(date, '%Y-%m')
)
SELECT 
    month,
    SUM(monthly_layoffs) OVER (ORDER BY month ASC) AS rolling_total_layoffs
FROM rolling_totals;

-- Step 4: Industry analysis
-- Identify which industries had the most layoffs
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY industry
ORDER BY total_layoffs DESC;

-- Step 5: Country-based layoffs
-- Determine the countries with the highest layoffs
SELECT country, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY country
ORDER BY total_layoffs DESC;

-- Step 6: Company-level insights
-- Rank companies by total layoffs
WITH company_rank AS (
    SELECT 
        company, 
        SUM(total_laid_off) AS total_layoffs,
        RANK() OVER (ORDER BY SUM(total_laid_off) DESC) AS ranking
    FROM layoffs_staging
    GROUP BY company
)
SELECT * FROM company_rank
WHERE ranking <= 10; -- Get top 10 companies by layoffs

-- Step 7: Analyzing layoffs by funding level
-- Identify if high-funded companies had more layoffs
SELECT 
    CASE 
        WHEN funds_raised_millions < 50 THEN 'Low Funding (<$50M)'
        WHEN funds_raised_millions BETWEEN 50 AND 500 THEN 'Mid Funding ($50M-$500M)'
        ELSE 'High Funding (>$500M)'
    END AS funding_category,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY funding_category
ORDER BY total_layoffs DESC;

-- Step 8: Ranking layoffs per year
-- Rank companies by total layoffs per year
WITH company_year_rank AS (
    SELECT 
        company, YEAR(date) AS year, SUM(total_laid_off) AS total_layoffs,
        RANK() OVER (PARTITION BY YEAR(date) ORDER BY SUM(total_laid_off) DESC) AS ranking
    FROM layoffs_staging
    GROUP BY company, YEAR(date)
)
SELECT * FROM company_year_rank
WHERE ranking <= 5; -- Get top 5 companies per year by layoffs
