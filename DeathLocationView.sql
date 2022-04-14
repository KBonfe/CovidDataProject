CREATE VIEW DeathLocation as
SELECT continent, location, date, population, new_deaths, 
	SUM(CONVERT(bigint, new_deaths)) --note had to use bigint
	OVER (PARTITION BY location ORDER BY location, date) 
	AS RollingDeaths
	
 FROM  [dbo].[CovidDeaths] 
 

 SELECT * FROM DeathLocation