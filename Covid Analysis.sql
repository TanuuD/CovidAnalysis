

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--SELECT Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2



-- Looking at total_cases vs total_deaths
-- Shows likelihood of dying if you contract covid in your country 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2


--Looking at Total cases vs population
--Shows what percent of population got covid

SELECT Location, date, total_cases, population, (total_cases/population)* 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2


--Looking at countrie with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like '%India%'
GROUP BY location, Population
ORDER BY PercentPopulationInfected desc



-- Showing countries with highest death count per population 

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like '%India%'
GROUP BY location
ORDER BY TotalDeathCount desc


--Lets break things down by continents


--Showing the continents with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like '%India%'
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%' 
 WHERE continent is not null
 --GROUP BY date
ORDER BY 1,2


--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/ population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null
order by 2,3



-- USE CTE


With PopVsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac



--TEMP TABLE


DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
--WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/ population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null
--order by 2,3


SELECT *
FROM PercentPopulationVaccinated
