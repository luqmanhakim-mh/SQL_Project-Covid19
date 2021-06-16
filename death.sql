-- Create and import covid_death CSV file to database

create table covid_death (
iso_code varchar,
continent varchar,
location varchar,
date date,
population bigint,
total_cases int,
new_cases int,
new_cases_smoothed float	,
total_deaths	int,
new_deaths	int,
new_deaths_smoothed float	,
total_cases_per_million float	,
new_cases_per_million	float,
new_cases_smoothed_per_million	float,
total_deaths_per_million	float,
new_deaths_per_million	float,
new_deaths_smoothed_per_million float	,
reproduction_rate	float,
icu_patients	int,
icu_patients_per_million float,	
hosp_patients	int,
hosp_patients_per_million float,	
weekly_icu_admissions	float,
weekly_icu_admissions_per_million float,	
weekly_hosp_admissions	float,
weekly_hosp_admissions_per_million float
);

SELECT covid_death FROM 'C:\Program Files\PostgreSQL\13\Dataset\Covid-19\CovidDeath.csv' delimiter ',' csv header;

SELECT * FROM covid_death;

-- Create and Import table covid_vaccine CSV file to database

create table covid_vaccine (
iso_code varchar,
continent varchar,
location varchar,
date date,
new_tests int,	
total_tests	int,
total_tests_per_thousand float,
new_tests_per_thousand	float,
new_tests_smoothed	float,
new_tests_smoothed_per_thousand float,	
positive_rate float,
tests_per_case	float,
tests_units varchar,
total_vaccinations bigint,	
people_vaccinated int,
people_fully_vaccinated int,	
new_vaccinations int,
new_vaccinations_smoothed float,	
total_vaccinations_per_hundred float,
people_vaccinated_per_hundred float,
people_fully_vaccinated_per_hundred	float,
new_vaccinations_smoothed_per_million float,
stringency_index float,
population_density float,
median_age float,
aged_65_older float,
aged_70_older float,	
gdp_per_capita float,
extreme_poverty	float,
cardiovasc_death_rate float,	
diabetes_prevalence	float,
female_smokers float,
male_smokers float,
handwashing_facilities float,	
hospital_beds_per_thousand	float,
life_expectancy	float,
human_development_index float,	
excess_mortality float
)

COPY covid_vaccine FROM 'C:\Program Files\PostgreSQL\13\Dataset\Covid-19\CovidVaccination.csv' delimiter ',' csv header;

SELECT * FROM covid_vaccine;

-- Explore data and look for something useful

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid_death
ORDER BY 1,2;

-- Select total cases vs total death in Malaysia

SELECT Location, date, total_cases, total_deaths, (select cast(total_deaths as numeric) / total_cases)*100 as death_percentage
FROM covid_death
WHERE location = 'Malaysia'
ORDER BY 1,2;

-- Select total cases vs population in Malaysia

SELECT Location, date, population, total_cases, (select cast(total_cases as numeric) / population)*100 as population_percentage
FROM covid_death
WHERE location = 'Malaysia'
ORDER BY 1,2;

-- Top 10 Countries that have highest infection rate by population

SELECT Location, max(population), max(total_cases), max((select cast(total_cases as numeric) / population)*100) as population_percentage
FROM covid_death
GROUP BY Location
HAVING max((select cast(total_cases as numeric) / population)*100) is not null
ORDER BY population_percentage desc
LIMIT 10;

-- Top 10 Countries with highest death count by populaiton

SELECT Location, max(total_deaths) as death_count
FROM covid_death
WHERE continent is not null
GROUP BY Location
HAVING max(total_deaths) is not null
ORDER BY death_count desc
LIMIT 10;

-- Death count by continent

SELECT continent, max(total_deaths) as death_count
FROM covid_death
WHERE continent is not null
GROUP BY continent
ORDER BY death_count desc;

-- Global daily cases and death percentage

SELECT date, sum(new_cases) as new_cases , sum(new_deaths) as new_deaths, (sum(cast(new_deaths as numeric)) / sum(new_cases))*100 as death_percentage
FROM covid_death
WHERE continent is not null
GROUP BY date
ORDER BY date asc;

-- Total vaccination vs population

with cummulative_vaccination (continent, location, date, population, new_vaccinations, cummulative_vaccination)
AS
(
SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as cummulative_vaccination
FROM covid_death as dea
INNER JOIN covid_vaccine as vac
ON dea.location = vac.location and
	dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.location, dea.date
)

SELECT *, (cast(cummulative_vaccination as numeric)/population)*100 as vaccinated_percentage from cummulative_vaccination;

-- create view "cummulative_vaccination" for data visualization purpose

CREATE VIEW cummulative_vaccination AS

with cummulative_vaccination (continent, location, date, population, new_vaccinations, cummulative_vaccination)
AS
(
SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as cummulative_vaccination
FROM covid_death as dea
INNER JOIN covid_vaccine as vac
ON dea.location = vac.location and
	dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.location, dea.date
)

SELECT *, (cast(cummulative_vaccination as numeric)/population)*100 as vaccinated_percentage from cummulative_vaccination;

SELECT * FROM cummulative_vaccination;
