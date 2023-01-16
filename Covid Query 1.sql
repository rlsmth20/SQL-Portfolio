
SELECT *
FROM CovidProject..CovidDeaths
ORDER BY 3,4;

-- Select *
-- From CovidProject..CovidVaccinations
-- Order By 3,4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
ORDER BY location, date;

-- Looking at total cases vs total deaths
-- Shows covid death rate in the US
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS death_rate
FROM CovidProject..CovidDeaths
WHERE location LIKE '%states'
ORDER BY location, date DESC;

-- Looking at total cases vs population in US
-- Shows percentage of US population who have been infected over time
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,2) AS population_infection_rate
FROM CovidProject..CovidDeaths
WHERE location LIKE '%states'
ORDER BY location, date DESC;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS total_cases_count, ROUND(MAX((total_cases/population))*100,2) AS population_infection_rate
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY population_infection_rate DESC;

SELECT location, population,date, MAX(total_cases) AS total_cases_count, ROUND(MAX((total_cases/population))*100,2) AS population_infection_rate
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY population_infection_rate DESC;

-- Showing countries with highest death rate compared to population
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS total_death_count, ROUND(MAX((total_deaths/population))*100,2) AS population_death_rate
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY population_death_rate DESC;

-- Showing countries with the most deaths
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Showing continents with the most deaths and world deaths
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM CovidProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('High income','Upper middle income', 'Lower middle income', 'European Union', 'Low income', 'International')
GROUP BY location
ORDER BY total_death_count DESC;

-- Total cases, deaths, and death percentage worldwide
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY total_cases, total_deaths

-- Worldwide Vaccination rate
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS  RollingVaccinations
	--(RollingVaccinations/population)*100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND new_vaccinations IS NOT NULL
ORDER BY 2,3


--CTE
WITH PopVaccinated (continent, location, date, population, new_vaccinations, RollingVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location
	,dea.date) AS  RollingVaccinations
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND new_vaccinations IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingVaccinations/population)*100 AS PercentVaccinated
FROM PopVaccinated


--Temp Table 
DROP TABLE IF EXISTS #PercentVaccinated
CREATE TABLE #PercentVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric,
)

INSERT INTO #PercentVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location
	,dea.date) AS  RollingVaccinations
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND new_vaccinations IS NOT NULL

SELECT *, (RollingVaccinations/population)*100 AS PercentVaccinated
FROM #PercentVaccinated
ORDER BY location, date

--View
USE CovidProject
GO
CREATE VIEW PercentVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location
	,dea.date) AS  RollingVaccinations
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND new_vaccinations IS NOT NULL
