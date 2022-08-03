/* 
Covid 19 Data Exploration

Skills used: Joins, CTE, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Convereting Data Types

*/


select *
from ProjectPortfolio.coviddeaths1
-- where length(continent) > 0
order by 3,4;

select * 
from ProjectPortfolio.covidvaccination1
order by 3,4;

-- Selecting data that is going to be used

select location, date, total_cases, new_cases, total_deaths, population
from ProjectPortfolio.coviddeaths1
order by 1,2;

-- Toatal cases vs total deaths
-- likelihood of dying in Germany when contract covid

select location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
from ProjectPortfolio.coviddeaths1
where location like '%germany%'
order by 1,2;

-- Toatal cases vs population
-- percentage of people that got covid

select location, date,  population, total_cases, (total_cases/population)*100 as CovidInfectionPercentage
from ProjectPortfolio.coviddeaths1
-- where location like '%germany%'
order by 1,2;

-- Countries with highest infection rate compared to their population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationInfectionPercentage
from ProjectPortfolio.coviddeaths1
-- where location like '%germany%'
group by location, population
order by PopulationInfectionPercentage desc;

-- countries with the highest death count per population

select location, max(cast( total_deaths as signed))  as TotalDeathCount
from ProjectPortfolio.coviddeaths1
-- where location like '%germany%'
where length(continent) > 0
group by location
order by TotalDeathCount desc;

-- Breaking things down by continents

select location, max(cast( total_deaths as signed))  as TotalDeathCount
from ProjectPortfolio.coviddeaths1
-- where location like '%germany%'
where length(continent) = 0
group by location
order by TotalDeathCount desc;

select continent, max(cast( total_deaths as signed))  as TotalDeathCount
from ProjectPortfolio.coviddeaths1
-- where location like '%germany%'
where length(continent) > 0
group by continent
order by TotalDeathCount desc;

-- showing countries with the highest death count in europe

select location, max(cast( total_deaths as signed))  as TotalDeathCount
from ProjectPortfolio.coviddeaths1
where continent = 'europe'
-- where length(continent) > 0
group by location
order by TotalDeathCount desc;

-- Global Numbers
-- total cases by date globally

select date, sum(new_cases) as total_cases,  sum(cast(new_deaths as signed)) as total_deaths, (sum(cast(new_deaths as signed))/ sum(new_cases))*100 as DeathPercentage
from ProjectPortfolio.coviddeaths1
-- where location like '%germany%'
where length(continent) > 0
group by date
order by 1,2;

-- total cases, total deaths and death percentage accross the world

select  sum(new_cases) as total_cases,  sum(cast(new_deaths as signed)) as total_deaths, (sum(cast(new_deaths as signed))/ sum(new_cases))*100 as DeathPercentage
from ProjectPortfolio.coviddeaths1
-- where location like '%germany%'
where length(continent) > 0
-- group by date
order by 1,2;


-- Looking at total population vs Vaccinations

select * 
from ProjectPortfolio.coviddeaths1 dea
join ProjectPortfolio.covidvaccination1 vac
on dea.location = vac.location
and dea.date = vac.date;

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from ProjectPortfolio.coviddeaths1 dea
join ProjectPortfolio.covidvaccination1 vac
on dea.location = vac.location
and dea.date = vac.date
where length(dea.continent) > 0
order by 2,3;

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(vac.new_vaccinations, signed)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
, (rolling_people_vaccinated/ population)
from ProjectPortfolio.coviddeaths1 dea
join ProjectPortfolio.covidvaccination1 vac
on dea.location = vac.location
and dea.date = vac.date
where length(dea.continent) > 0
order by 2,3;

-- using CTE to perform calculation on Partition By in previuos query

With PopvsVac (Continent, Location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(vac.new_vaccinations, signed)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
-- , (rolling_people_vaccinated/ population)
from ProjectPortfolio.coviddeaths1 dea
join ProjectPortfolio.covidvaccination1 vac
on dea.location = vac.location
and dea.date = vac.date
where length(dea.continent) > 0
-- order by 2,3
)
select *,( rolling_people_vaccinated/ population)*100
from PopvsVac;

-- Using Temp table to perform calculation on Partition By in previuos query

drop table if exists percentPopulationVaccinated;
Create table percentPopulationVaccinated
(
Continent char(225),
Location char(225),
date datetime,
population numeric,
New_vaccinations numeric,
rolling_people_vaccinated numeric
);
insert  ignore into percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(vac.new_vaccinations, signed)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
-- , (rolling_people_vaccinated/ population)
from ProjectPortfolio.coviddeaths1 dea
join ProjectPortfolio.covidvaccination1 vac
on dea.location = vac.location
and dea.date = vac.date
where length(dea.continent) > 0
-- order by 2,3
;
select *, ( rolling_people_vaccinated/ population)*100
from percentPopulationVaccinated;

-- Creating view to store data for later visualization

Create view percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(vac.new_vaccinations, signed)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
-- , (rolling_people_vaccinated/ population)
from ProjectPortfolio.coviddeaths1 dea
join ProjectPortfolio.covidvaccination1 vac
on dea.location = vac.location
and dea.date = vac.date
where length(dea.continent) > 0
-- order by 2,3
;
select * -- , ( rolling_people_vaccinated/ population)*100
from percent_population_vaccinated;
