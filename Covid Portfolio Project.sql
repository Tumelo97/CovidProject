Use PortFolio_Project

SELECT *
FROM PortFolio_Project..CovidDeaths
WHERE continent is not null
ORDER BY 3 , 4

--SELECT *
--FROM PortFolio_Project..CovidVaccinations
--ORDER BY 3 , 4

--SELECT Data that we are going to be using

SELECT Location , date , total_cases , new_cases , total_deaths , population
FROM PortFolio_Project..CovidDeaths
WHERE continent is not null
ORDER BY 1 , 2 

-- Looking at Total Cases vs Total Deaths
SELECT Location , date , total_cases , total_deaths , (total_deaths/total_cases) * 100 As Death_Percentage
FROM PortFolio_Project..CovidDeaths
ORDER BY 1 , 2

--Shows the likehood of dying if you contract a covid in your country
SELECT Location , date , total_cases , total_deaths , (total_deaths/total_cases) * 100 As Death_Percentage
FROM PortFolio_Project..CovidDeaths
WHERE Location like '%South Africa%'
ORDER BY 1 , 2

--Looking at Total Cases vs Population
--Show what percentage of population got Covid
SELECT Location , date , total_cases , population , (total_cases/population) * 100 As Population_Percentage
FROM PortFolio_Project..CovidDeaths
WHERE Location like '%South Africa%'
ORDER BY 1 , 2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location ,  population, Max(total_cases) As HighestInfectionRate, Max((total_cases/population)) * 100 As PercentagePopulationInfected
FROM PortFolio_Project..CovidDeaths
WHERE continent is not null
GROUP BY location , population
ORDER BY HighestInfectionRate desc

-- Showing countries with highest death count per popolution
SELECT Location , Max(cast(total_deaths as INT)) As TotalDeathRate
FROM PortFolio_Project..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathRate desc

---Lets break Things down by Continent




-- Showing continents with the highest death count per population

SELECT continent , Max(cast(total_deaths as INT)) As TotalDeathRate
FROM PortFolio_Project..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathRate desc

-- Global numbers
SELECT date , SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) As Total_Death ,SUM(cast(new_deaths as INT))/SUM(new_cases) * 100 as DeathPercentage
FROM PortFolio_Project..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1 , 2

-- Looking at total Population vs vaccinations

WITH PopvsVac (Continent , Location , Date , Population ,New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location order by dea.location , dea.date) As RollingPeopleVaccinationated
FROM PortFolio_Project..CovidDeaths dea
JOIN PortFolio_Project..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT * , (RollingPeopleVaccinated /Population) * 100
FROM PopvsVac

DROP Table if exists #PercentPopulationVaccinated
-- Temp Table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location order by dea.location , dea.date) As RollingPeopleVaccinationated
FROM PortFolio_Project..CovidDeaths dea
JOIN PortFolio_Project..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3


SELECT * ,(RollingPeopleVaccinated /Population) * 100
FROM #PercentPopulationVaccinated

--Create View to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location order by dea.location , dea.date) As RollingPeopleVaccinationated
FROM PortFolio_Project..CovidDeaths dea
JOIN PortFolio_Project..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated