# Exploratory Data Analysis in MySQL

## Table of Contents
- [Overview](#overview)
- [Goals and Key Questions](#goals-and-key-questions)
- [Dataset](#dataset)
- [Key Insights from EDA](#key-insights-from-eda)
  - [1. Layoff Trends Over Time](#1-layoff-trends-over-time)
  - [2. Industry and Country Analysis](#2-industry-and-country-analysis)
  - [3. Company-Level Insights](#3-company-level-insights)
  - [4. Advanced Queries and Ranking](#4-advanced-queries-and-ranking)
- [SQL Scripts Used](#sql-scripts-used)
- [Future Recommendations](#future-recommendations)
- [Usage Instructions](#usage-instructions)


## **Overview**

This project conducts **Exploratory Data Analysis (EDA)** on a global layoffs dataset using **MySQL**. With the dataset already cleaned, we now dive into analyzing trends, industries, and company-level layoffs to extract meaningful insights. The EDA process helps identify patterns in layoffs across different time periods, locations, and company sizes.

## **Goals and Key Questions**

- What is the total number of layoffs reported in the dataset?
- Which companies and industries experienced the most layoffs?
- How have layoffs fluctuated over time (yearly and monthly trends)?
- Which countries had the highest number of layoffs?
- How does a company's funding level relate to layoffs?

## **Dataset**

The dataset covers layoffs in the **tech industry** from **March 11, 2020, to July 20, 2024**, based on reports from sources like **Bloomberg, TechCrunch, and The New York Times**. It includes:

- **Company Name:** The organization that issued the layoffs.
- **Location:** The city or country where layoffs occurred.
- **Industry:** The affected business sector.
- **Total Laid Off:** The number of employees affected.
- **Percentage Laid Off:** The proportion of the company’s workforce impacted.
- **Layoff Date:** The date layoffs were announced.
- **Funding Raised (Millions):** The total financial backing of the company.

## **Key Insights from EDA**

### **1. Layoff Trends Over Time**

- The **highest number of layoffs** occurred in **2022**, with another surge in **early 2023**.
- A **rolling total analysis** showed a sharp rise in layoffs from late 2022 into 2023.
- Layoffs spiked during **economic downturns** and **post-pandemic market adjustments**.

**SQL Query:**

```sql
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY YEAR(date)
ORDER BY year ASC;
```

### **2. Industry and Country Analysis**

- **Retail, Consumer Tech, and Transportation** were among the hardest-hit industries.
- **The United States** recorded the highest number of layoffs, followed by **India and the Netherlands**.
- Some industries, like **manufacturing, aerospace, and legal**, experienced **fewer layoffs**.

**SQL Query:**

```sql
-- Layoffs by Industry
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY industry
ORDER BY total_layoffs DESC;

-- Layoffs by Country
SELECT country, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY country
ORDER BY total_layoffs DESC;
```

### **3. Company-Level Insights**

- **Amazon, Google, Meta, and Microsoft** had some of the largest layoffs.
- Companies with **high funding levels (over $2 billion)** also faced **significant layoffs**.
- Several companies experienced **100% layoffs**, leading to complete shutdowns.

**SQL Query:**

```sql
-- Top Companies by Layoffs
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;

-- Companies with 100% Layoffs
SELECT company, location, industry, total_laid_off
FROM layoffs_staging
WHERE percentage_laid_off = 1;
```

### **4. Advanced Queries and Ranking**

- **Used window functions** to rank companies by **total layoffs per year**.
- **Grouped layoffs** by **industry, country, and funding level**.
- **Created rolling totals** to visualize layoffs accumulating over time.

**SQL Query:**

```sql
-- Ranking Companies by Layoffs Per Year
WITH company_year_rank AS (
    SELECT 
        company, YEAR(date) AS year, SUM(total_laid_off) AS total_layoffs,
        RANK() OVER (PARTITION BY YEAR(date) ORDER BY SUM(total_laid_off) DESC) AS ranking
    FROM layoffs_staging
    GROUP BY company, YEAR(date)
)
SELECT * FROM company_year_rank
WHERE ranking <= 5;

-- Rolling Total of Layoffs Over Time
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
```

## **SQL Scripts Used**

All analysis queries are available in `eda.sql`, which includes:

- **Summary statistics** (maximum layoffs, percentage laid off).
- **Yearly, monthly, and daily layoff trends**.
- **Industry and country-based analysis**.
- **Company-level layoffs**, including rankings.
- **Rolling total calculations** for layoffs over time.

## **Future Recommendations**

- **Visualization Dashboards:** Use **Tableau or Power BI** to create interactive visualizations.
- **Predictive Analysis:** Apply **machine learning models** to forecast future layoffs based on past trends.
- **Sector-Specific Insights:** Further **segment layoffs** by sub-industries or funding levels.

## **Usage Instructions**

1. Run the `eda.sql` ****script in **MySQL Workbench** or any compatible database tool.
2. Verify the cleaned dataset using:
    
    ```sql
    SELECT * FROM layoffs_staging;
    ```
    
3. Modify and expand queries to discover additional insights based on **industry trends, company size, and funding levels**.

This project highlights how **SQL-based EDA** can uncover **meaningful insights** from structured datasets, helping businesses and stakeholders better understand **market shifts and economic trends**.
