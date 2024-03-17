Select * 
From PortfolioProject..CovidDeaths
order by 3,4 

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4 

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at the total cases vs total deaths in a country 
-- Shows the likelihood of death if someone contracts Covid in a certain country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%Pakistan%'
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

 -- Looking at the total cases vs the population
 -- Shows percentage of population that has gotten covid. Looking at Pakistan vs the US (low for Pakistan in percentage terms as well as absolute)
 
 Select location, date, population, total_cases, (total_cases/population)*100 as CasebyPopulation
From PortfolioProject..CovidDeaths
where location like '%Pakistan%'
order by 1,2

Select location, date, population, total_cases, (total_cases/population)*100 as CasesbyPopulation
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2
 

 -- Looking at Countries with highest infection rate compared to populations

 
 Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as CasesbyPopulation
From PortfolioProject..CovidDeaths
-- where location like '%states%'
Group by location, population
order by CasesbyPopulation desc

-- Showing countries with highest death count per population

 Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%states%'
Where Continent is not null
Group by location
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT

 Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%states%'
Where Continent is null
Group by location
order by TotalDeathCount desc

-- The query above is what I did and it gave the correct result but since I am following a video and he made the query below which he says he has to continue with so hence I will use the query below
-- He is using the below query because he wants to drill down based on continents
-- Showing continents with the highest deathcounts

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%states%'
Where Continent is not null
Group by continent
order by TotalDeathCount desc


-- Look at this with the idea that we want to have a drill down effects like from continents to countries and so on so if you want to change the above queries just change location to continents

-- LET'S NOW LOOK AT THINGS GLOBALLY

-- GLOBAL NUMMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
group by date
order by 1,2

-- Now lets remove the date so we get a total number just one

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
-- group by date
order by 1,2


-- Now looking at the other table that we have

Select *
From PortfolioProject..CovidVaccinations


--Join  the two tables 

Select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

-- Adding rolling number so that we can see total vaccinations as well side by side to date 
-- try it out and see what does not work when you change stuff in this

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

	-- adding column name to it and also using the convert function instead of cast since it does the same thing

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccincated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

	-- The following query is when we want to see the vaccinations percentage against the popuulation number but it wont work 
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccincated
, (RollingPeopleVaccincated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

-- Now we have some options on how to move forward we can do 1 or both. Lets first use CTE 
-- Note that the number of columns in the CTE which is the WITH clause, it should be the same as the number of columns in the SELECT query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccincated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccincated
--, (RollingPeopleVaccincated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	-- order by 2,3
)
Select *, (RollingPeopleVaccincated/Population)*100
from PopvsVac

-- Now we will do Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccincated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccincated
--, (RollingPeopleVaccincated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	-- order by 2,3
	Select *, (RollingPeopleVaccincated/Population)*100
from #PercentPopulationVaccinated

-- The above works but its better to add in 1 line in the beginning and removve where continent is not null because what if we want to alter it later so the following is better

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccincated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccincated
--, (RollingPeopleVaccincated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	-- order by 2,3
	Select *, (RollingPeopleVaccincated/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccincated
--, (RollingPeopleVaccincated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

-- Now it permanently creates that view its not a temp table and we can query it like below:
-- We can use it later for visualization. Create a few more like this. Normally its good to put some of these and set them aside and call it a work table or work view
-- So they can be used consistenly and to connect them with tableau

Select *
From PercentPopulationVaccinated

-- Now save it and put into github