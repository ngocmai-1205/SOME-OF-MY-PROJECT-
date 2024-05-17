select * 
from [dbo].[CovidDeath]
where continent is not null

-- select the needed data
select location, date, total_cases, new_cases,total_deaths, population
from CovidDeath
order by 1,2 
-- likelihood of dying when contract the covid in VietNam
select location, date, total_cases, total_deaths, ( total_deaths/total_cases)*100 as DeathPercentage
from CovidDeath
where location ='Vietnam'
order by 1,2 
-- total cases vs population
select location, date, total_cases, population, ( total_cases/POPULATION)*100 as CasesPercentage
from CovidDeath
where location ='Vietnam'
order by 1,2 
-- showing the country with highest inflation compare to population
select location,population, max( total_cases) as Highest_Inflation,MAX ( total_cases/POPULATION)*100 as InflationRate 
from CovidDeath
group by location, population
order by InflationRate  desc 
-- showing the countries with the highest death tolls per population
select location,population, max(cast(total_deaths as int)) as Highest_death   -- convert datatype use Cast 
from [dbo].[CovidDeath]
where continent is not null
group by location, population
order by  Highest_death desc 
-- TOTAL DEATH BY CONTINENT 
select continent,SUM(CAST(total_deaths AS INT)) AS TOTAL_DEATH_BY_CONTINENT
from [dbo].[CovidDeath]
where continent is not null
GROUP BY CONTINENT 
-- global number 
select  date ,sum([new_cases]) as total_newcases, sum(cast([new_deaths] as int)) as total_deaths, sum([new_cases])/sum(cast([new_deaths] as int)) as death_percentage
from [dbo].[CovidDeath]
where continent is not null
group by date
order by 1 desc
-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVaccine ( Continent, Location,Date, Population, New_Vaccinated, RollingPeopleVaccinated)
as (select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as
RollingPeopleVaccinated
from [dbo].[CovidDeath] as dea
join [dbo].[CovidVaccinations] as vac
  on dea.date=vac.date
  and dea.location=vac.location
where dea.continent is not null)

select * ,(RollingPeopleVaccinated/Population)*100 
from PopvsVaccine

--Using Temp Table to perform Calculation on Partition By in previous query

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].[CovidDeath] dea
Join [dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
create view PercentpopulationVaccinated  as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].[CovidDeath] dea
Join [dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3)


