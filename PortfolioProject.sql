Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVacinations
--Order by 3,4

--select data i am going to using

Select Location, date, total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null

Order by 1,2

--Looking > Total Cases vs Total Deaths

	Select Location, date, total_cases,total_deaths, CAST(total_deaths as float)/(total_cases) *100 AS DeathProcentage
	From PortfolioProject..CovidDeaths
	Where location like '%croatia%'
	and continent is not null

	Order by 1,2

--Looking > Total cases vs population
--Shows what precentage of population got covid


	Select Location, date, population, total_cases, (total_cases / population) *100 AS InfectedPopulationProcentage
	From PortfolioProject..CovidDeaths
	--Where location like '%serbia%'
	Where continent is not null
	Order by 1,2 


--Looking > Population with highest infection rate compared to population
		Select Location, population, MAX(cast(total_cases as int)) as HighestInfectionCount,MAX(cast(total_cases as int) / population) *100 AS InfectedpopulationProcentage
		From PortfolioProject..CovidDeaths
		--Where location like '%serbia%'
		--Column 'PortfolioProject..CovidDeaths.location' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
		Group by Location,population 
		Order by InfectedpopulationProcentage desc

	 
--Showing > Countries with highest death rate/count per population

	Select Location, MAX(cast(total_deaths_per_million as decimal)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group by Location
	Order by TotalDeathCount desc

--LETS BREAK THINGS DOWN TO CONTINENT

--showing continents with highest death count per population


	Select location, MAX(cast(total_deaths_per_million as decimal)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group by location
	Order by TotalDeathCount desc


-- Global numbers



	Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathsPercentage 
	From PortfolioProject..CovidDeaths
	--Where location like '%croatia%'
	where continent is not null
	--group by date
	Order by 1,2

-- Looking at total Population vs Vaccinations
			Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as decimal)) 
			OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeoplesVaccinated
		
			From PortfolioProject..CovidDeaths dea
			Join PortfolioProject..CovidVaccinations vac	
				On dea.location = vac.location
				and dea.date = vac.date
			Where dea.continent is not null 
			Order by 2,3

-- Use CTE

		With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVAccinated)
		as
		(
		Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as decimal)) 
					OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeoplesVaccinated
		
					From PortfolioProject..CovidDeaths dea
					Join PortfolioProject..CovidVaccinations vac	
						On dea.location = vac.location
						and dea.date = vac.date
					Where dea.continent is not null 
					--Order by 2,3
		)
		Select * , (RollingPeopleVaccinated/Population)*100
		From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinater
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as decimal)) 
					OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeoplesVaccinated
		
					From PortfolioProject..CovidDeaths dea
					Join PortfolioProject..CovidVaccinations vac	
						On dea.location = vac.location
						and dea.date = vac.date
					--Where dea.continent is not null 
					--Order by 2,3
		
		Select * , (RollingPeopleVaccinated/Population)*100
		From #PercentPopulationVaccinated
		
Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating very first View to store data for latest VISUALISATIONS
USE PortfolioProject --use to be shown in the project
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as decimal)) 
OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeoplesVaccinated
		
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac	
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--Order by 2,3
		
