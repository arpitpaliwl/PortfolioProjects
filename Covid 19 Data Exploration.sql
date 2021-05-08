#Covid 19 Data Exploration-Portfolio Project 1


--Querying the data from the two tables which we are going to use

Select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

Select * from PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4


--Selecting  the data from Covid Deaths table

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total Cases VS Total Deaths 
--It shows the likelihood of dying if you contract COVID in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'India' --Using Location as India
and continent is not null
order by 1,2


--Total Cases vs Population
--It will show what percentage of population got infected with COVID

Select location, date, population, total_cases,  (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location ='India'
where continent is not null
order by 1,2


--Countries  with Highest Infection Rates compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PopulationPercentageInfected
From PortfolioProject..CovidDeaths
--Where location ='India'
where continent is not null
Group by location, population
order by PopulationPercentageInfected desc

--Countries with the Highest Death count per Population

Select location, MAX(CAST(total_deaths as int))as TotalDeathCOunt
--We can use CONVERT(int,total_deaths) in replacement of CAST
From PortfolioProject..CovidDeaths
--Where location ='India'
where continent is not null
Group by location
order by TotalDeathCOunt desc



--Continent with the Highest Death count per Population

Select continent, MAX(CAST(total_deaths as int))as TotalDeathCOunt
From PortfolioProject..CovidDeaths
--Where location ='India'
where continent is not null
Group by continent
order by TotalDeathCOunt desc



---Quick check for Continent Data 
Select location, MAX(CAST(total_deaths as int))as TotalDeathCOunt
From PortfolioProject..CovidDeaths
--Where location ='India'
where continent is null
Group by location
order by TotalDeathCOunt desc



--Viweing GLOBAL NUMBERS for COVID 19

Select date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeath, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location ='India'
where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeath, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location ='India'
where continent is not null
--Group by date
order by 1,2



--Joining both Tables CovidDeaths and CovidVaccinations


Select * 
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vacc
	ON vacc.date=dea.date
	and vacc.location=dea.location

--Looking at TotalPopulations VS Vaccination
--Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent,dea.location,dea.date,dea.population, vacc.new_vaccinations, 
	SUM(CAST(vacc.new_vaccinations AS INT)) OVER (Partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vacc
	ON vacc.date=dea.date
	and vacc.location=dea.location
where dea.continent is not null
--and dea.location= 'India'
order by 2,3



--Using CTE to perform Calculation on Partition By in previous query

With PopVsVacc(Continent,Location,Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population, vacc.new_vaccinations, 
	SUM(CAST(vacc.new_vaccinations AS INT)) OVER (Partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vacc
	ON vacc.date=dea.date
	and vacc.location=dea.location
where dea.continent is not null
--and dea.location= 'India'
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingVaccPercentage 
from PopVsVacc


-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population, vacc.new_vaccinations, 
	SUM(CAST(vacc.new_vaccinations AS INT)) OVER (Partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vacc
	ON vacc.date=dea.date
	and vacc.location=dea.location
where dea.continent is not null
--and dea.location= 'India'
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated


-- Creating View to store data for later use

Create View PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations AS INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null 
