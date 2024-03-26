/*
In order to see which 10 starting stations were most popluar I ran a query to find the most common NOT NULL "casual" user station...
*/

	WITH StartingStations AS (
		SELECT start_station_name, COUNT(start_station_name) AS station_count, user_type
		FROM TripData_2023
		WHERE start_station_name IS NOT NULL
		GROUP BY start_station_name, user_type
			)
	SELECT TOP 10 MAX(station_count) as count_times_used, start_station_name, user_type
	FROM StartingStations
	WHERE user_type = 'casual'
	GROUP BY user_type, start_station_name
	ORDER BY count_times_used DESC
/*
...then the 10 most common NOT NULL "member" user station.  
*/
    WITH StartingStations AS (
		SELECT start_station_name, COUNT(start_station_name) AS station_count, user_type
		FROM TripData_2023
		WHERE start_station_name IS NOT NULL
		GROUP BY start_station_name, user_type
			)
	SELECT TOP 10 MAX(station_count) as count_times_used, start_station_name, user_type
	FROM StartingStations
	WHERE user_type = 'member'
	GROUP BY user_type, start_station_name
	ORDER BY count_times_used DESC;