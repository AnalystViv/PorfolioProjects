Select *
From CovidDeaths
where continent is  not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
where continent is  not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelhood of dying if you contract covid in your country

--- Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentge
--- From PortfolioProject..CovidDeaths
--- order by 1,2 
--- this query did not work because i have data stored as a string 
---in either the "total_cases" or "total_deaths" column. To resolve this error, you need to ensure that the data in these columns 
---is stored as a numerical data type, such as INT or FLOAT. 
--- the CAST function is used to convert the "total_cases" and "total_deaths" columns to the FLOAT data type, 
-- which allows the divide operator to work correctly. The DeathPercentage column is also calculated using the converted values.

SELECT location, date, CAST(total_cases AS FLOAT) AS total_cases, CAST(total_deaths AS FLOAT) AS total_deaths, 
(CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS DeathPercentage
FROM CovidDeaths
Where location like '%states%'
and continent is  not null
ORDER BY 1, 2


-- Looking at the Total cases vs the Population
SELECT location, date,  CAST(population AS FLOAT) AS population, CAST(total_cases AS FLOAT) AS total_cases,
(CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100 AS PercentagePopulation
FROM CovidDeaths
--Where location like '%states%'
where continent is  not null
ORDER BY 1, 2


-- Countries with highest infection rate compared to population

SELECT location,population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
--WHERE location LIKE '%states%'
ORDER BY PercentPopulationInfected desc;


-- Countries with highest death count with population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE '%states%'
where continent is  not null
GROUP BY location
ORDER BY TotalDeathCount desc;


-- Lets break things down by continent
--- showing the continent with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE '%states%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
FROM CovidDeaths
--WHERE location LIKE '%states%'
where continent is not null
group by date
ORDER BY 1,2;

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPercent
FROM CovidDeaths
WHERE continent is not null
group by date
ORDER BY 1,2;


SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPercent
FROM CovidDeaths
WHERE continent is not null
--group by date
ORDER BY 1,2;

-- Join CovidDeaths and CovidVaccinations Table together 


Select *
From CovidDeaths cd
Join CovidVaccinations cv
On cd.location = cv.location
and cd.date = cv.date

-- Looking at Total Population vs Vaccination

--casting the SUM function to a larger data type such as BIGINT or DECIMAL, which can accommodate larger values. 

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location order by cd.location,
cd.date) as RollingpeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations cv
On cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (continent, location, date, Population, new_vaccination, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location order by cd.location,
cd.date) as RollingpeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations cv
On cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE 

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingpeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location order by cd.location,
cd.date) as RollingpeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations cv
On cd.location = cv.location
and cd.date = cv.date
--where cd.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated






-- Creating view to store data for visualisation

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location order by cd.location,
cd.date) as RollingpeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations cv
On cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated