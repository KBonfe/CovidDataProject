SELECT * FROM [dbo].[CovidDeaths]
ORDER BY 3,4

SELECT * FROM [dbo].[CovidVaccinations]
ORDER BY 3,4

SELECT location,date, total_cases,new_cases, total_deaths, population
FROM [dbo].[CovidDeaths]
ORDER BY 1,2

--Total cases VS Total the Deaths
--Likelihood of Death if contract Covid in the USA
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE location like '%states%'
ORDER BY 1,2

--Total Cases VS Population
--Percentage of Population who contracted Covid in the USA
SELECT location,date,population,total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM [dbo].[CovidDeaths]
WHERE location like '%states%'
ORDER BY 1,2

--Countries with Highest Infection Rate compared to Population
SELECT location,population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [dbo].[CovidDeaths]
GROUP BY Population, Location
ORDER BY PercentPopulationInfected DESC

--Countries with the Highest Death Count per Population

SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Continents with the Highest Death Count per Population
SELECT location,MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM [dbo].[CovidDeaths]
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Global Numbers
	--Percentage of Death by date
SELECT date, SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

	--Percentage of Death Globally
SELECT  SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 1,2


--Join Death and Vaccination tables
SELECT * FROM  
 [dbo].[CovidDeaths] dea
 JOIN [dbo].[CovidVaccinations] vac
 ON dea.location = vac.location
 AND dea.date = vac.date

 --Total Population VS Vaccination
 SELECT dea.continent, dea.location, dea.date, dea.population FROM  
 [dbo].[CovidDeaths] dea
 JOIN [dbo].[CovidVaccinations] vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent is not null
 ORDER BY 2,3 

 --Total Vaccination
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) --note had to use bigint
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVacinated
	--,(RollingPeopleVacinated/population)*100
 FROM  [dbo].[CovidDeaths] dea
 JOIN [dbo].[CovidVaccinations] vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent is not null
 ORDER BY 2,3 




 --CTE
 WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 AS 
 ( 
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) --note had to use bigint
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVacinated
	--,(RollingPeopleVacinated/population)*100
 FROM  [dbo].[CovidDeaths] dea
 JOIN [dbo].[CovidVaccinations] vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent is not null
 )

  SELECT *, (RollingPeopleVacinated/population)*100
FROM PopVsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_baccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) --note had to use bigint
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVacinated
	--,(RollingPeopleVacinated/population)*100
 FROM  [dbo].[CovidDeaths] dea
 JOIN [dbo].[CovidVaccinations] vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent is not null

SELECT * --,(RollingPeopleVacinated/population)*100
FROM #PercentPopulationVaccinated

--View to store data for vizualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) --note had to use bigint
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVacinated
	--,(RollingPeopleVacinated/population)*100
 FROM  [dbo].[CovidDeaths] dea
 JOIN [dbo].[CovidVaccinations] vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent is not null

 SELECT * FROM PercentPopulationVaccinated
