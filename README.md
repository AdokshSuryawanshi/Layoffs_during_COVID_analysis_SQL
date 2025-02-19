# COVID layoffs Analysis Using SQL

#1. Data Cleaning Process
  Step 1:
  Creating a Staging Table for Cleaning
  A duplicate table (staging table) is created to ensure that the original data remains unchanged. This table serves as the workspace for cleaning and transformations.

  Step 2: 
  Identifying and Removing Duplicate Records
  A method is used to check for duplicate entries by considering key attributes such as company name, industry, location, total layoffs, and date. Duplicates are assigned      unique row numbers, and any records beyond the first occurrence are removed.

Step 3: 
Standardizing the Data
Trimming Extra Spaces: Ensures consistency in text fields such as company and industry names.
Fixing Inconsistent Naming: Industry names with variations (e.g., "Crypto" and "Cryptocurrency") are standardized.
Cleaning Country Names: Ensures country names are correctly formatted, removing unnecessary symbols or extra text.

Step 4: 
Converting Date Format for Analysis
The date column is converted from a text-based format into a proper date format to allow time-based analysis. This ensures consistency and enables functions like sorting and aggregation.

Step 5: Handling NULL and Blank Values
Replacing Blank Values with NULLs: This makes data handling easier in queries.
Filling Missing Industry Data: Missing industry information is filled by cross-referencing records of the same company.
Removing Insufficient Data: Records where both total layoffs and percentage layoffs are missing are deleted to avoid incomplete analysis.
Dropping Unnecessary Columns: After duplicate removal, any temporary columns used for row tracking are dropped.

2. Exploratory Data Analysis (EDA)

1. Overview of Layoffs Data
A general check is performed to verify data integrity and correctness after cleaning.

2. Identifying Maximum Layoffs and Impact
The highest number of layoffs recorded and the maximum percentage of workforce laid off are identified to understand the most extreme cases.

3. Companies with 100% Layoffs
A subset of companies that completely shut down operations by laying off their entire workforce is analyzed.

4. Companies with the Most Layoffs
Layoffs are aggregated at the company level to determine which businesses were affected the most.

5. Time-Based Analysis
The earliest and latest layoffs recorded in the dataset are identified.
Layoffs are analyzed by year to determine trends over time.
A more granular analysis is performed by grouping layoffs at a monthly level to detect seasonal patterns.

6. Industry-Wise Layoff Trends
Layoff figures are aggregated for each industry to determine which sectors experienced the most job cuts.

7. Country-Wise Layoff Analysis
Layoff data is grouped by country to understand which regions were most affected.

8. Startups vs. Established Companies
Layoffs are analyzed based on the business stage (e.g., startups vs. enterprises) to assess whether younger companies suffered more layoffs compared to established firms.

