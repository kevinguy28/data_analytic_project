SELECT *
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT * 
--FROM Portfolio_Project..CovidVaccinations
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths
order by 1,2

-- Looking at Total Cases VS Total Deaths
-- Shows the likelihood of dying if you contract COVIDi in Canada
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE Location like 'Canada'
order by 1,2

-- Looking at total cases VS Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentageGotCovid
FROM Portfolio_Project..CovidDeaths
WHERE Location like 'Canada'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location,Population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
FROM Portfolio_Project..CovidDeaths
Group by Location, Population
order by PercentagePopulationInfected desc

-- Looking at Counties with Highest Death Rate compared to Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
Group by Location, Population
order by TotalDeathCount desc

-- Looking at Highest Death Count by Continent

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
WHERE continent is not null
Group by continent
order by TotalDeathCount desc

-- GLobal Numbers

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Using CTE

With PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into  #PercentPopulationVaccinated 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated 

-- Creating View to store datra for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * From PercentPopulationVaccinated