/*
I then calculated the average ride time by "user_type"
*/

SELECT user_type, AVG(ride_time) AS avg_ride_time
FROM TripData_2023
GROUP BY user_type



