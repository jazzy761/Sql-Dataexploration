Select *
From [Portfolio Project]..[Covid vaccine]
Order By 3,4

Select *
From [Portfolio Project]..[Covid deaths]
order by 3,4

-- Choosing the data we are Using
--percentage of death in covid 
SELECT location,
       date,
       total_cases,
       total_deaths,
       CASE
           WHEN CAST(total_cases AS float) = 0 THEN 0
           ELSE (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100
       END AS deathpercentage
FROM [Portfolio Project]..[Covid deaths]
Where location like '%pakistan'
ORDER BY 1, 2; 


--Looking at total cases with respect to population

SELECT location,
       date,
       population,
       total_deaths,
       CASE
           WHEN CAST(total_cases AS float) = 0 THEN 0
           ELSE (CAST(total_cases AS float) / CAST(population AS float)) * 100
       END AS deathpercentage
FROM [Portfolio Project]..[Covid deaths]
--Where location like '%pakistan'
ORDER BY 1, 2; 

-- Looking at countries with highest infection rate compared to population

Select location, population ,
Max(cast(total_cases as float)) as highestinfectioncount,
max((cast(total_cases as float)/population))*100 as percentageinfected
FROM [Portfolio Project]..[Covid deaths]
group by Location , population
ORDER BY  percentageinfected desc 


--Showing countries with highest death count per population

Select location, population ,
Max(cast(total_deaths as float)) as highestdeathcount,
Max((cast(total_deaths as float)/population))*100 as percentagedeath
FROM [Portfolio Project]..[Covid deaths]
Where continent is not null
group by Location , population
ORDER BY  percentagedeath 

--Breaking By continent
--Continent With the Highest Death Count per population

select continent ,Max(cast(total_deaths as int)) as highestdeathcount
from [Portfolio Project]..[Covid deaths]
group by continent
order by highestdeathcount asc

--Global Numbers
SELECT 
    date, 
    SUM(CAST(new_cases AS INT)) AS total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    CASE
        WHEN SUM(CAST(new_cases AS INT)) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths AS INT)) / SUM(CAST(new_cases AS INT))) * 100
    END AS deathpercentage
FROM [Portfolio Project]..[Covid deaths]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Looking at total population vs vaccination

select dea.continent , dea.location , dea.date , dea.population ,  vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order By dea.location,
dea.Date) as RollingPeopleVaccinated
from [Portfolio Project]..[Covid deaths] dea
join [Portfolio Project]..[Covid vaccine] vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 


-- Use CTE 

with popvsvac(continent , location , Date , Population , new_vaccinations ,RollingPeopleVaccinated)
as 
(
select dea.continent , dea.location , dea.date , dea.population ,  vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order By dea.location,
dea.Date) as RollingPeopleVaccinated
from [Portfolio Project]..[Covid deaths] dea
join [Portfolio Project]..[Covid vaccine] vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
select *
from popvsvac

-- Use temp table 

drop table if exists #PercentagePopulationVaccinated 

Create table #PercentagePopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent , dea.location , dea.date , dea.population ,  vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location,
dea.Date) as RollingPeopleVaccinated
from [Portfolio Project]..[Covid deaths] dea
join [Portfolio Project]..[Covid vaccine] vac
	on dea.location =vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 
select *
from #PercentagePopulationVaccinated



--Creating view to store data for visualization

Create view PercentagePopulationVaccinated as
select dea.continent , dea.location , dea.date , dea.population ,  vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location,
dea.Date) as RollingPeopleVaccinated
from [Portfolio Project]..[Covid deaths] dea
join [Portfolio Project]..[Covid vaccine] vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
 
 Select *
 From  PercentagePopulationVaccinated
