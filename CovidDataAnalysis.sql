SELECT *
From [Portfolio Project #1]..CovidDeaths
--Where Location = 'United States'
WHERE continent is not null
ORDER by 3,4

SELECT *
FROM [Portfolio Project #1]..CovidVacc
--Where location = 'united states'
ORDER by 3,4

--Select Data we will be using

SELECT Iso_code, Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project #1]..CovidDeaths
Where iso_code = 'USA'
order by 1, 2


-- Looking at the Total Cases vs Total deaths
-- Convert total_deaths and total-cases to bigint  and float with TRY_CAST
-- Shows the likelihood for dying from contacting Covid-19


SELECT location, date, total_cases, total_deaths,
(CAST(total_deaths as bigint) /CAST(total_cases as float))*100 AS DeathRate
From [Portfolio Project #1]..CovidDeaths
Where location = 'United States'
ORDER by 1,2

--Looking at the Total Cases vs The Population
--Shows what percentage of population was infected

SELECT location, date, total_cases, population,
(CAST(total_cases as bigint) /CAST(population as float))*100 AS PercentPopulationInfected
From [Portfolio Project #1]..CovidDeaths
--Where location = 'United States'
ORDER by 1,2

--Looking at countries having the highest infection rates compared to the population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population,
(CAST(MAX(total_cases) as bigint) /CAST(population as float))*100 AS PercentPopulationInfected
From [Portfolio Project #1]..CovidDeaths
--Where location = 'United States'
GROUP by location, population
ORDER by PercentPopulationInfected desc


--Looking at the countries having the Highest death Count compared to population

SELECT location, MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount, population,
(CAST(MAX(total_deaths) as bigint) /CAST(population as float))*100 AS PercentPopulationDeath
From [Portfolio Project #1]..CovidDeaths
--Where location = 'United States'
Where continent is not null
GROUP by location, population
ORDER by PercentPopulationDeath desc


--Showing continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
--(CAST(MAX(total_deaths) as bigint) /CAST(population as float))*100 AS PercentPopulationDeath
From [Portfolio Project #1]..CovidDeaths
--Where location = 'United States'
Where continent is not null
GROUP by continent
ORDER by TotalDeathCount desc

--Showing Total Death Count by country

SELECT location, MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
--(CAST(MAX(total_deaths) as bigint) /CAST(population as float))*100 AS PercentPopulationDeath
From [Portfolio Project #1]..CovidDeaths
--Where location = 'United States'
Where continent is not null
GROUP by location
ORDER by TotalDeathCount desc

--Showing breakdown of deaths by income level status of countries world wide

SELECT location, MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
--(CAST(MAX(total_deaths) as bigint) /CAST(population as float))*100 AS PercentPopulationDeath
From [Portfolio Project #1]..CovidDeaths
Where location like '%income'
GROUP by location
ORDER by TotalDeathCount desc

-- Breaking down Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, 
Sum(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage  
--total_deaths,
--(CAST(total_deaths as bigint) /CAST(total_cases as float))*100 AS DeathRate
From [Portfolio Project #1]..CovidDeaths
--Where location = 'United States'
Where continent is not null
ORDER by 1,2

--Looking at Total Populations vs Vaccinations

SELECT vac.continent, vac.location, vac.date, vac.population, vac.people_fully_vaccinated
FROM [Portfolio Project #1]..CovidVacc vac
Where location = 'United States'

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project #1]..CovidDeaths dea
Join [Portfolio Project #1]..CovidVacc vac
	ON dea.date = vac.Date
	and dea.location = vac.Location
	Where dea.continent is not null
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by 
dea.location, dea.date) AS RollingPeopleVaccinated
from [Portfolio Project #1]..CovidDeaths dea
Join [Portfolio Project #1]..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
order by 2,3

SELECT dea.Continent, dea.Location, dea.Date, dea.Population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER by dea.Location,
dea.Date) AS RollingPeopleVaccinated
FROM [Portfolio Project #1]..CovidDeaths dea
JOIN [Portfolio Project #1]..CovidVacc vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--USE CTE
WITH PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER by dea.Location,
dea.Date) AS RollingPeopleVaccinated
FROM [Portfolio Project #1]..CovidDeaths dea
JOIN [Portfolio Project #1]..CovidVacc vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT*
FROM PopVsVac
Select *, (RollingPeopleVaccinated/Population)*100 = PercentPopulation
From PopVsVac

--USING TEMP TABLE

DROP Table if exists #PercentPopulationVaccinations
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER by dea.Location,
dea.Date) AS RollingPeopleVaccinated
FROM [Portfolio Project #1]..CovidDeaths dea
JOIN [Portfolio Project #1]..CovidVacc vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visulizations

Create View PercentPopulationVaccinated as
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER by dea.Location,
dea.Date) AS RollingPeopleVaccinated
FROM [Portfolio Project #1]..CovidDeaths dea
JOIN [Portfolio Project #1]..CovidVacc vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3




