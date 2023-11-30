
Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3, 4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3, 4

-- Select data using for project

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1, 2



-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in the country

Select Location, date, total_cases, total_deaths,
	CONVERT(decimal(18,8),(CONVERT(decimal(18,8),total_deaths)/ CONVERT(decimal(18,8),total_cases)))*100 as [DeathsPercentage]
From PortfolioProject..CovidDeaths
Where location like 'Myanmar'
and continent is not null
order by 1, 2



-- Looking at Total Cases vs Population
-- Shows what percentage of population infected by covid19

Select Location, date,population,total_cases,
	CONVERT(decimal(18,8),(CONVERT(decimal(18,8),total_cases)/ CONVERT(decimal(18,8),population)))*100 as [InfectedPercentage]
From PortfolioProject..CovidDeaths
Where Location like 'Myanmar'
and continent is not null
order by 1, 2



--Looking at Countries with Highest Infection Rate Compared to Population


--Select Location,population, MAX(cast(total_cases as int)) as [HighestInfection]
--	 ,cast (total_cases as int)/ cast(population as int)*100 as [InfectedPercentage]
--From PortfolioProject..CovidDeaths
--Where Location like 'Myanmar'
--Group by Location, population
--order by InfectedPercentage



-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as [TotalDeathCount]
from PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc



-- Break things down by continent

-- Showing continent with highest death count

Select continent, MAX(cast(total_deaths as int)) as [TotalDeathCount]
from PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select date, SUM(new_cases) as [total_cases], SUM(cast(total_deaths as int)) as [new_deaths], SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0) * 100 as [DeathPercentage]
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2



Select SUM(new_cases) as [total_cases], SUM(CONVERT(decimal(18,8),total_deaths)) as [total_deaths], SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0) * 100 as [DeathPercentage]
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2



---- Covid Vaccination ----


Select * 
From PortfolioProject..CovidVaccinations
Where continent is not null
order by 3, 4


select * 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	and dea.date = vac.date



-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(decimal(18,8),vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3



--USE CTE

With PopVsVac(continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(decimal(18,8),vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)


Select *, (RollingPeopleVaccinated/Population) * 100
From PopVsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(decimal(18,8),vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as [dea]
Join PortfolioProject..CovidVaccinations as [vac]
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3


Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(decimal(18,8),vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as [dea]
Join PortfolioProject..CovidVaccinations as [vac]
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3



Select * 
From PercentPopulationVaccinated