--Selecting all the data
SELECT *
FROM CovidDeaths$
ORDER BY 3,4

--Selecting the data we will use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2

--Total Cases vs Total Deaths (last date that dataset goes to is 30/4/21 there were a total of 2613 cases with 26 dead - resulting in a 0.995% death rate in NZ if you contracted COVID 19)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percent
FROM CovidDeaths$
WHERE location = 'New Zealand'
ORDER BY 1,2

--Total Cases vs Population - shows how much of the population contracted COVID 19
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS Population_contracted
FROM CovidDeaths$
WHERE location = 'New Zealand'

--Country that has the highest infection rate - First = Andorra with 17.1% ,  New Zealand  = 179 with 5.4%
SELECT location, population, MAX(total_cases) as Highest_Infections_Count, MAX((total_cases/population)) * 100 AS Population_contracted
FROM CovidDeaths$
GROUP BY location, population
ORDER BY Population_contracted desc

--Seeing which continents have the highest death count
SELECT continent, MAX(CAST(total_deaths as INT)) as Highest_Deaths
FROM CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY Highest_Deaths desc

--Countries with Highest Death Count per population. We used "CAST" as the date type needed to be changed (was nvarchar255 - need it to be int). Adding NULL statement removes the continents.
SELECT location, MAX(CAST(total_deaths as INT)) as Highest_Deaths
FROM CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY Highest_Deaths desc

--Continents with the highest death count
SELECT continent, MAX(CAST(total_deaths as INT)) as Contient_Deaths
FROM CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY Contient_Deaths desc

--GLOBAL numbers
SELECT date, SUM(new_cases) as New_Cases_Per_Day , SUM(CAST(new_deaths as INT)) as Death_Count_Per_Day, SUM(CAST(new_deaths as INT))/SUM(new_cases) * 100 as Death_Percent_Per_Day
FROM CovidDeaths$
WHERE continent is not null
GROUP BY date 
ORDER BY 1,2

--Total Population vs Vaccincations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projects..CovidDeaths dea
Join Projects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
AND vac.new_vaccinations is not null
order by 2,3


--Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projects..CovidDeaths dea
Join Projects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as Percent_Rolling_Vaccinated
From PopvsVac

--Creating View for Visualisation (was getting error so went on stackoverflow for fix)
USE [Projects]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create View Test_View as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projects..CovidDeaths dea
Join Projects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
AND vac.new_vaccinations is not null
--order by 2,3



