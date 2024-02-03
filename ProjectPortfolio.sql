--SELECT *
--FROM CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageDeath
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--looking at the total cases vs population
--shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentageCases
FROM CovidDeaths
--WHERE LOCATION LIKE '%canada%'
ORDER BY 1,2

--looking at countries with the highest infection rates compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS HighestInfectionRate
FROM CovidDeaths
--WHERE LOCATION LIKE '%canada%'
GROUP BY continent, population
ORDER BY HighestInfectionRate DESC

--showing countires with the highest death count per population
SELECT location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM CovidDeaths
--WHERE LOCATION LIKE '%canada%'
WHERE Continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Lets break things down by continent 

SELECT location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM CovidDeaths
--WHERE LOCATION LIKE '%canada%'
WHERE Continent IS NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC

--showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM CovidDeaths
--WHERE LOCATION LIKE '%canada%'
WHERE Continent IS  NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC

--Global numbers
--sum of new_cases per day across the world

SELECT date, SUM(new_cases) AS DailyNewCases
FROM CovidDeaths
--WHERE location LIKE '%canada%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 

SELECT date, SUM(new_cases) AS DailyNewCases, SUM(CAST(new_deaths AS INT)) AS DailyNewDeaths 
FROM CovidDeaths
--WHERE location LIKE '%canada%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Daily new death percentage across the world

SELECT date, SUM(new_cases) AS DailyNewCases, SUM(CAST(new_deaths AS INT)) AS DailyNewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) AS DailyNewDeathPercentage 
FROM CovidDeaths
--WHERE location LIKE '%canada%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Overall Daily New's Across the World

SELECT SUM(new_cases) AS DailyNewCases, SUM(CAST(new_deaths AS INT)) AS DailyNewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) AS DailyNewDeathPercentage 
FROM CovidDeaths
--WHERE location LIKE '%canada%'
WHERE continent IS NOT NULL
ORDER BY 1,2


SELECT date, SUM(new_cases) AS DailyNewCases, SUM(CAST(new_deaths AS INT)) AS DailyNewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) AS DailyNewDeathPercentage 
FROM CovidDeaths
--WHERE location LIKE '%canada%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--looking at total population vs vaccinations

--JOINS
SELECT *
FROM CovidDeaths
JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date

--Total population vs New vaccinations

SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
FROM CovidDeaths
JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
	WHERE CovidDeaths.continent IS NOT NULL
	ORDER BY 1,2,3

--Daily Vaccinations

SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) OVER(PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS DailyVaccinations
FROM CovidDeaths
JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
	WHERE CovidDeaths.continent IS NOT NULL
	ORDER BY 1,2,3

--Number of people vaccinated in a country
--USE CTE

--With PopVacc (continent, location, date, population, new_vaccinations, DailyVaccinations)

--AS
--(
--SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
--SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) OVER(PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS DailyVaccinations
--FROM CovidDeaths
--JOIN CovidVaccinations
--	ON CovidDeaths.location = CovidVaccinations.location
--	AND CovidDeaths.date = CovidVaccinations.date
--	WHERE CovidDeaths.continent IS NOT NULL
--)
--SELECT *
--FROM PopVacc

--Percentage of the total population vaccinated


With PopVacc (continent, location, date, population, new_vaccinations, DailyVaccinations)

AS
(
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) OVER(PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS DailyVaccinations
FROM CovidDeaths
JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
	WHERE CovidDeaths.continent IS NOT NULL
)
SELECT *, (DailyVaccinations/population)*100
FROM PopVacc


--TEMP TABLE
Drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
DailyVaccinations numeric
)
INSERT INTO #PercentagePopulationVaccinated
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) OVER(PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS DailyVaccinations
FROM CovidDeaths
JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
	WHERE CovidDeaths.continent IS NOT NULL

SELECT *, (DailyVaccinations/population)*100
FROM #PercentagePopulationVaccinated


--Creating view to store data for later visualization

Create view TotalDeathCountPerContinent as

SELECT continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE Continent IS  NOT NULL
GROUP BY continent 


Create view PercentagePopulationVaccinated AS
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) OVER(PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS DailyVaccinations
FROM CovidDeaths
JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
	WHERE CovidDeaths.continent IS NOT NULL

SELECT *
FROM PercentagePopulationVaccinated


