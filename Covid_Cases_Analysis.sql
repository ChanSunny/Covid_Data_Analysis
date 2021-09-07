SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Total Cases vs Total Deaths
-- Shows the likeihood of dying when contracted Covid in the United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%' and continent is not null
ORDER BY 1, 2

-- Total Cases vs Population
-- Shows the percentage of population that were infected by Covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 as InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1, 2

-- Countries with the Highest Infection Rate to their population
SELECT location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY InfectedPercentage desc

-- Locations with the Highest Deaths to their population
SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Continents with the Highest Deaths to their population
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%' 
WHERE continent is not null
Group by date
ORDER BY 1, 2

-- Total numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%' 
WHERE continent is not null
--Group by date
ORDER BY 1, 2

-- Total Population vs Vaccinations with CTE
WITH PopVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(CONVERT(int, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths death JOIN PortfolioProject.dbo.CovidVaccinations vaccine
ON death.location = vaccine.location and death.date = vaccine.date
WHERE death.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

--TEMP Table
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(CONVERT(int, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths death JOIN PortfolioProject.dbo.CovidVaccinations vaccine
ON death.location = vaccine.location and death.date = vaccine.date
WHERE death.continent is not null and new_vaccinations is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for Visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(CONVERT(int, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths death JOIN PortfolioProject.dbo.CovidVaccinations vaccine
ON death.location = vaccine.location and death.date = vaccine.date
WHERE death.continent is not null and new_vaccinations is not null
--ORDER BY 2,3

select *
From PercentPopulationVaccinated