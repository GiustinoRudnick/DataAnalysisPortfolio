/* 
Data provided by https://ourworldindata.org/covid-deaths date updated as of  1/8/2024
*/

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--WHERE continent is not null
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidDeaths
--WHERE continent is not null
--ORDER BY 3,4

SELECT
location
, date
, total_cases
, new_cases
, total_deaths
, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Explore Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

SELECT 
location
, date
, total_cases
, total_deaths
, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like	'United States' AND total_cases IS NOT NULL AND continent is not null
ORDER BY 1,2

-- Explore Total Cases vs Population
--Shows what percentage of population contracted Covid

SELECT 
location
, date
, total_cases
, population
, (CONVERT(float, total_cases / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentagePopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like	'United States' AND total_cases IS NOT NULL AND continent IS NOT NULL
ORDER BY 1,2

-- Explore Countries with the highest infection percent

SELECT 
location
, population
, MAX(total_cases) AS HighestInfectionCount
, MAX((CONVERT(float, total_cases) / (CONVERT(float, population)))) * 100 AS PercentagePopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
Order BY PercentagePopulationInfected DESC

-- Explore Continents with the highest infection percent
SELECT
continent
, MAX(total_cases) AS HighestInfectionCount
, MAX((CONVERT(float, total_cases) / (CONVERT(float, population)))) * 100 AS PercentagePopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
Order BY PercentagePopulationInfected DESC

-- Explore Countries with highest death count per population

SELECT 
location
, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
Order BY TotalDeathCount DESC

-- Explore continents with highest death count per population

SELECT 
continent
, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
Order BY TotalDeathCount DESC

-- Global Numbers

SELECT
date
, SUM(CAST(new_cases AS float)) AS TotalCases
, SUM(CAST(new_deaths AS float)) AS TotalDeaths
, ( SUM(CAST(new_deaths AS float)) / SUM(CAST(new_cases AS float)) ) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs New Vaccinations


SELECT
dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS VaccinationRollingCount
-- (VaccinationRollingCount / dea.population )* 100 AS RollingPercentVaccinated
FROM PortfolioProject.dbo.CovidVaccinations as Vac
JOIN PortfolioProject.dbo.CovidDeaths as dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255)
, Location nvarchar(255)
, Date datetime
, population numeric
, New_vaccinations numeric
, VaccinationRollingCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS VaccinationRollingCount
-- (VaccinationRollingCount / dea.population )* 100 AS RollingPercentVaccinated
FROM PortfolioProject.dbo.CovidVaccinations as Vac
JOIN PortfolioProject.dbo.CovidDeaths as dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
, (VaccinationRollingCount / population )* 100 AS RollingPercentVaccinated
FROM #PercentPopulationVaccinated

-- Create view to store data for visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT
dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS VaccinationRollingCount
-- (VaccinationRollingCount / dea.population )* 100 AS RollingPercentVaccinated
FROM PortfolioProject.dbo.CovidVaccinations as Vac
JOIN PortfolioProject.dbo.CovidDeaths as dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated