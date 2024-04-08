/*
In order to see which 10 starting stations were most popluar I ran a query to find the most common NOT NULL "casual" user station...
*/

SELECT TOP 10 user_type, start_station_name, COUNT(start_station_name) AS station_count
FROM TripData_2023
WHERE start_station_name IS NOT NULL
	AND user_type = 'casual'
GROUP BY start_station_name, user_type
ORDER BY station_count DESC
/*
...then the 10 most common NOT NULL "member" user station.  
*/
 
SELECT TOP 10 user_type, start_station_name, COUNT(start_station_name) AS station_count
FROM TripData_2023
WHERE start_station_name IS NOT NULL
	AND user_type = 'member'
GROUP BY start_station_name, user_type
ORDER BY station_count DESC


