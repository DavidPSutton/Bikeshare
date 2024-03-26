/*
First, I rename the original tables to be more readable (i.e. from 012023_tripdata to JAN_tripdata).  
Then I used 'UNION' to combine the individual monthly data tables into a table with all of the data combined as "TripData_2023".
*/

SELECT *
	INTO TripData_2023
FROM (
	SELECT *
	FROM JAN_tripdata
	UNION
	SELECT *
	FROM FEB_tripdata
	UNION
	SELECT *
	FROM MAR_tripdata
	UNION
	SELECT *
	FROM APR_tripdata
	UNION
	SELECT *
	FROM MAY_tripdata
	UNION
	SELECT *
	FROM JUN_tripdata
	UNION
	SELECT *
	FROM JUL_tripdata
	UNION
	SELECT *
	FROM AUG_tripdata
	UNION
	SELECT *
	FROM SEP_tripdata
	UNION
	SELECT *
	FROM OCT_tripdata
	UNION
	SELECT *
	FROM NOV_tripdata
	UNION
	SELECT *
	FROM DEC_tripdata
) a

/*
Then I check check the new table to make sure each of the monthly tables were combined by sorting by "started_at"
*/

Select top 10*
FROM TripData_2023
ORDER BY started_at

/*
Now I check to make sure all of the "ride_id" values are distinct
*/

SELECT ride_id, COUNT(ride_id)
FROM TripData_2023
GROUP BY ride_id
HAVING COUNT(ride_id) >1

/*
I created a new column in the "TripData_2023" table to calculate the ride time of each ride
*/

ALTER TABLE TripData_2023 
    ADD ride_time AS DATEDIFF(MINUTE, started_at, ended_at)


/*
Then I removed any trips that were less than or equal to 0 minutes (data errors), as well as any that were over 12 hours (outliers)
*/

DELETE FROM TripData_2023
WHERE ride_time <= 0
OR ride_time > 12*60

/*
I changed the "member_casual" column to "user_type" for readablity
*/
EXEC sp_rename 'TripData_2023.member_casual', 'user_type', 'COLUMN'

/*
Checking for consisency of lat & long values for station
*/

	SELECT start_station_name, start_lat, start_lng
	FROM TripData_2023
	WHERE start_station_name IS NOT NULL
	ORDER BY start_station_name, start_lat

/*
Getting total count of distinct start stations
*/

	SELECT COUNT(DISTINCT start_station_name)
	FROM TripData_2023
	WHERE start_station_name IS NOT NULL
/*
Testing if rounding lat to 2 decimals makes consistent
*/
	SELECT start_station_name, start_lat, ROUND (start_lat, 2) as start_lat_rnd
	FROM TripData_2023
	WHERE start_station_name IS NOT NULL
	ORDER BY start_station_name

/*
Adding rounded lat and lng columns for start and end stations for BI use
*/

	ALTER TABLE TripData_2023
		ADD start_lat_rnd AS ROUND (start_lat, 2)

	ALTER TABLE TripData_2023
		ADD start_lng_rnd AS ROUND (start_lng, 2)

	ALTER TABLE TripData_2023
		ADD end_lat_rnd AS ROUND (end_lat, 2)

	ALTER TABLE TripData_2023
		ADD end_lng_rnd AS ROUND (end_lng, 2)

	SELECT TOP 10 *
	FROM TripData_2023

	SELECT DISTINCT start_station_name, end_station_name, COUNT(*) as 'count_of_rides', user_type
	FROM TripData_2023
	WHERE start_station_name IS NOT NULL AND end_station_name IS NOT NULL
	GROUP BY start_station_name, end_station_name, ride_time, user_type
	ORDER BY count_of_rides DESC, start_station_name, end_station_name

	SELECT start_station_name, end_station_name, user_type
	FROM TripData_2023
	WHERE start_station_name = 'Ellis Ave & 60th St' AND end_station_name = 'Ellis Ave & 55th St'

/*
Creating new table with start station lat and lng averaged for BI
*/

	SELECT DISTINCT start_station_name AS 'station_name', AVG(start_lat) as 'approx_lat', AVG(start_lng) as 'approx_lng'
	INTO StationLocations
	FROM TripData_2023
	WHERE start_station_name IS NOT NULL 
	GROUP BY start_station_name
	ORDER BY start_station_name

    SELECT TOP 10 *
    FROM StationLocations
