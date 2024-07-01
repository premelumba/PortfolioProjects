-- Statewide Diabetes and Obesity data
SELECT * 
FROM diabetes_obesity_2021
-- Statewide Diabetes data by race
SELECT *
FROM diabetes_by_race

--What are the prevalence rates of diabetes in percent, for adults 18 or older?
  
SELECT state, county, diagnosed_diabetes_percentage 
FROM diabetes_obesity_2021
Order by state, county;
  
-- What is the average prevalence rate in percent of adults 18 or older diagnosed with diabetes per state?
SELECT state, AVG(diagnosed_diabetes_percentage) AS avg_diabetes_percentage
FROM diabetes_obesity_2021
WHERE diagnosed_diabetes_percentage IS NOT NULL
GROUP BY state
ORDER BY avg_diabetes_percentage DESC;

--Limit query above to return only top 10 states

SELECT state, AVG(diagnosed_diabetes_percentage) AS avg_diabetes_percentage
FROM diabetes_obesity_2021
WHERE diagnosed_diabetes_percentage IS NOT NULL
GROUP BY state
ORDER BY avg_diabetes_percentage DESC
Limit 10;

-- What is the average prevalence rate in percent of adults 18 or older diagnosed with obesity per state?
-- Limit to Top 10 states

SELECT state, AVG(obesity_percentage) AS avg_obesity_percentage
FROM diabetes_obesity_2021
WHERE diagnosed_diabetes_percentage IS NOT NULL
GROUP BY state
ORDER BY avg_obesity_percentage DESC
Limit 10;

--What is the national average prevalence rate for diabetes diagnosis for adults 18 or older?

SELECT AVG(diagnosed_diabetes_percentage) AS avg_national_diabetes_percentage
FROM diabetes_obesity_2021

--What is the average prevalence rate of diabetes diagnosis for adults 18 or older in New Jersey?
SELECT state, AVG(diagnosed_diabetes_percentage) AS avg_diabetes_percentage, 
FROM diabetes_obesity_2021
WHERE state = 'New Jersey'
Group by state;

--Compare New Jersey and West Virginia

SELECT state, AVG(diagnosed_diabetes_percentage) AS avg_diabetes_percentage, Avg(obesity_percentage) as obesity_percentage
FROM diabetes_obesity_2021
WHERE state IN ('New Jersey','West Virginia')
Group by state;


--How does diabetes prevalence in county in New Jersey compare to each other?

SELECT county, AVG(diagnosed_diabetes_percentage) AS avg_diabetes_percentage
FROM diabetes_obesity_2021
WHERE state = 'New Jersey'
Group by county

--Which county has highest diabetes rate in NJ?
SELECT county, Max(diagnosed_diabetes_percentage) as highest_diabetes_rate
FROM diabetes_obesity_2021
WHERE state = 'New Jersey'
Group by county
Order by highest_diabetes_rate desc
Limit 1;

--The county with the highest diabetes rate was Cumberland County

--Which county has lowest diabetes rate in NJ?
SELECT county, Min(diagnosed_diabetes_percentage) as lowest_diabetes_rate
FROM diabetes_obesity_2021
WHERE state = 'New Jersey'
Group by county
Order by lowest_diabetes_rate
Limit 1;

--Hunterton county is county with the lowest diabetes rate in 2021

-- Join both table 
SELECT county, do21.state, diagnosed_diabetes_percentage, obesity_percentage, race_ethnicity, dbr.percentage as diabetes_percentage_by_race
FROM diabetes_obesity_2021 as do21
Join diabetes_by_race as dbr 
ON do21.state = dbr.state

--How does diabetes prevalence vary by race nationally?
SELECT do21.county, do21.state, do21.diagnosed_diabetes_percentage, do21.obesity_percentage, dbr.race_ethnicity, dbr.percentage as diabetes_percentage_by_race
FROM diabetes_obesity_2021 as do21
Join diabetes_by_race as dbr 
ON do21.state = dbr.state
	
-- CREATE table that joins both tables
CREATE TABLE aggregated_diabetes_by_race AS
SELECT 
    state,
    race_ethnicity,
    AVG(CASE 
            WHEN percentage = 'Suppressed' THEN NULL
			When percentage = 'No Data' Then NULL
            ELSE CAST(percentage AS FLOAT)
        END) AS avg_diabetes_percentage_by_race
FROM 
    diabetes_by_race
GROUP BY 
    state,
    race_ethnicity;
	
--What is the average prevalence of diagnosed diabetes in percent for each race in each state--	
SELECT 
	jt.state,
    jt.race_ethnicity as race_ethnicity, 
    avg(jt.avg_diabetes_percentage_by_race) as avg_diabetes_percentage
FROM (
    SELECT  
        do21.state,  
        dbr.race_ethnicity, 
        dbr.avg_diabetes_percentage_by_race
    FROM 
        diabetes_obesity_2021 AS do21
    JOIN 
        aggregated_diabetes_by_race AS dbr 
    ON 
        do21.state = dbr.state 
) AS jt
GROUP BY 
    jt.race_ethnicity, jt.state
ORDER BY 
    state,
	avg_diabetes_percentage DESC; 
	
--What are the prevalence rate in percent of diagnosed diabetes by race in New Jersey?

SELECT 
	jt.state,
    jt.race_ethnicity as race_ethnicity, 
    avg(jt.avg_diabetes_percentage_by_race) as avg_diabetes_percentage
FROM (
    SELECT  
        do21.state,  
        dbr.race_ethnicity, 
        dbr.avg_diabetes_percentage_by_race
    FROM 
        diabetes_obesity_2021 AS do21
    JOIN 
        aggregated_diabetes_by_race AS dbr 
    ON 
        do21.state = dbr.state 
) AS jt
Where jt.state = 'New Jersey'
GROUP BY 
    jt.race_ethnicity, jt.state
ORDER BY 
    state,
	avg_diabetes_percentage DESC;


--Create a view

CREATE VIEW state_diabetes_obesity_data AS
SELECT do21.state, do21.diagnosed_diabetes_percentage, do21.obesity_percentage, dbr.race_ethnicity, dbr.percentage as diabetes_percentage_by_race
FROM diabetes_obesity_2021 as do21
Join diabetes_by_race as dbr 
ON do21.state = dbr.state

SELECT *
FROM  state_diabetes_obesity_data

