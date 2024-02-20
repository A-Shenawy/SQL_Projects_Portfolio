/* This is a project which analysis a data about Covid19 pandemic and Vaccination*/

-- Select the data which we will use:-

select location, date, total_cases, total_deaths,population
from PortfolioProject..CovidDeath$
where continent is not null
order by 3,4;

-- Look at total cases v.s total deaths for each country

select location, date, total_cases, total_deaths, (total_deaths/CAST(total_cases AS FLOAT))*100 as DeathPercentage
from PortfolioProject..CovidDeath$
where location like '%states%' and continent is not null
order by 1,2;

-- Look at total cases v.s population to show percentage of population got covid 

select location, date, population, total_cases, (CAST(total_cases AS FLOAT)/population)*100 as CovidPercentage
from PortfolioProject..CovidDeath$
where location like '%states%' and total_cases is not null and continent is not null
order by 1,2;

-- Look at countries with highest infection rate compared to population

SELECT 
    location,
    population, 
    MAX(total_cases) AS HighestInfectionCount, 
    (MAX(total_cases) / population) * 100 AS CovidPercentage
FROM 
    PortfolioProject..CovidDeath$
-- WHERE location LIKE '%states%' AND total_cases IS NOT NULL
where continent is not null
GROUP BY 
    location, 
    population
-- having location like '%egypt%' and continent is not null
ORDER BY
	CovidPercentage desc;

-- look at highest countries in death count v.s population

SELECT 
    location,
    MAX(total_deaths) AS HighestDeathsCount, 
    (MAX(total_deaths) / population) * 100 AS DeathPercentage
FROM 
    PortfolioProject..CovidDeath$
-- WHERE location LIKE '%states%' AND total_cases IS NOT NULL
where continent is not null
GROUP BY 
    location, 
    population
ORDER BY
	DeathPercentage desc;


-- look at things with breaking them by location
SELECT 
    location,
    MAX(cast(total_deaths as int)) AS HighestDeathsCount 
    --(MAX(total_deaths) / population) * 100 AS DeathPercentage
FROM 
    PortfolioProject..CovidDeath$
-- WHERE location LIKE '%states%' AND total_cases IS NOT NULL
where continent is null
GROUP BY 
    location
ORDER BY
	HighestDeathsCount desc;


-- look at things with breaking them by continent

SELECT 
    continent,
    MAX(cast(total_deaths as int)) AS HighestDeathsCount 
    --(MAX(total_deaths) / population) * 100 AS DeathPercentage
FROM 
    PortfolioProject..CovidDeath$
-- WHERE location LIKE '%states%' AND total_cases IS NOT NULL
where continent is not null
GROUP BY 
    continent
ORDER BY
	HighestDeathsCount desc;

-- Global Info

SELECT 
    date, 
    SUM(new_cases) AS TotalNewCases, 
    SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths, 
    CASE 
        WHEN SUM(new_cases) <> 0 THEN (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 
        ELSE 0 
    END AS DeathPercentage
FROM 
    PortfolioProject..CovidDeath$
-- WHERE location LIKE '%states%' 
WHERE continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    date;


------------------------------------------------------------------------------------------
-- Using the Covid vaccination data to get insights
select * from PortfolioProject..CovidVaccination$;

-- Look at total population v.s vaccinations
-- joining the two tables by (locations, date)
-- Creating CTE (common table Expression) Method :-

with PopvsVac (continent, location, date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
-- we want to know how many people got vaccinated over each country
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--order by 2,3;
)

select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac



-- Temp Table Method

drop table if exists PercentPopulationVaccinated

Create table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
RollingPeopleVaccinated numeric
);

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
-- we want to know how many people got vaccinated over each country
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location 
	and dea.date = vac.date 
--WHERE dea.continent IS NOT NULL
--order by 2,3;

select *, (RollingPeopleVaccinated/population)*100 
from PercentPopulationVaccinated


-- Creating View to store data for later visualization
-- Batch 1
DROP VIEW IF EXISTS PercentPopulationVaccinateddd
GO
CREATE VIEW PercentPopulationVaccinateddd AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date,
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
-- We want to know how many people got vaccinated over each country
-- (RollingPeopleVaccinated/population)*100
FROM 
    PortfolioProject..CovidDeath$ dea
JOIN 
    PortfolioProject..CovidVaccination$ vac ON dea.location = vac.location AND dea.date = vac.date 
WHERE 
    dea.continent IS NOT NULL;
