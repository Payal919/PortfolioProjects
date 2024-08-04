select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases,new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

select location, date, population, total_cases, (total_cases/population)*100 as CasesPercent
from PortfolioProject..CovidDeaths
order by 1,2

select location, MAX(total_cases) as total_cases, population, MAX(total_cases)/MAX(population) *100 as percentt
from PortfolioProject..CovidDeaths
group by location, population
order by percentt desc

select location, MAX(cast(total_deaths as int)) as total_Deaths
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by total_Deaths desc

select continent, MAX(cast(total_deaths as int)) as total_Deaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by total_Deaths desc

select sum(cast(new_deaths as int)) as total_deaths, sum(new_cases) as total_cases, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by vac.location order by dea.location, dea.date) as TotalVacc
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

with PopVsTotVacc(continent, location, date, population, new_vaccinations, Totalvacc)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by vac.location order by dea.location, dea.date) as TotalVacc
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Totalvacc/population)*100
from PopVsTotVacc

drop table if exists #newvaccVsPopp
create table #newvaccVsPopp
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
Nnew_vaccinations numeric,
ttotalvacc numeric
)

insert into #newvaccVsPopp
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by vac.location order by dea.location, dea.date) as TotalVacc
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date					
where dea.continent is not null
--order by 2,3
	
select *, (ttotalvacc/Population)*100
from #newvaccVsPopp

create view newvaccVsPopp as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by vac.location order by dea.location, dea.date) as TotalVacc
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date					
where dea.continent is not null
--order by 2,3