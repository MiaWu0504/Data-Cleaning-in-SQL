select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4

---------------------------------------------------------------------

--select data that we are going to be using

select location, date, population, total_cases, new_cases, total_deaths
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--------------------------------------------------------------------------

--Death rate (likelihood of dying if affected Covid)

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
from PortfolioProject..CovidDeaths
where continent is not null 
--and location like '%australia%'
order by 1,2 desc

--------------------------------------------------------------------------

--Shows Covid affection rate

select location, date, total_cases, population, (total_cases/population)*100 as affected_rate
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2 

---------------------------------------------------------------------------

--Countries with highest infection rate 

select location, population, max(total_cases) as highest_infection_cases, (max(total_cases)/population)*100 as affected_rate
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by affected_rate desc

---------------------------------------------------------------------------

--Countries with highest death rate 

select location, population, max(cast(total_deaths as int)) as num_death, 
 (max(total_deaths)/population)*100 as death_rate
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by num_death desc

------------------------------------------------------------------------------

--Contintents with the highest death number per population

select location, max(cast(total_deaths as int)) as num_death
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by num_death desc

--------------------------------------------------------------------

--Total Global Numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, 
       sum(cast(new_deaths as int))/sum(new_cases)*100 as death_rate
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1

---------------------------------------------------------------------

-- Total Population vs Vaccinations

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
      sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) as rolling_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

------------------------------------------------------------------------------------------

--Use CTE to calculate vaccination rate

with temp (continent, location, date, population, new_vaccinations, rolling_vaccinated) as 
(select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
      sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) as rolling_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null)

select *, (rolling_vaccinated/population)*100 as vaccination_rate
from temp

--Create temp table

drop table if exists #population_vaccinated

create table #population_vaccinated
( continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  rolling_vaccinated numeric)

insert into #population_vaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
      sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) as rolling_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null

select *, (rolling_vaccinated/population)*100 as vaccination_rate
from #population_vaccinated

----------------------------------------------------------------------------------

--Creating View to store date for visualizations

create view population_vaccinated_1 as 
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
      sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) as rolling_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null

select *
from population_vaccinated_1


