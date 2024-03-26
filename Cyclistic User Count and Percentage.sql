/*
I found the number of each user type and their percentage of the whole.
*/

SELECT user_type, COUNT (user_type) as "number_of_users", ROUND(COUNT(*)* 100.0/ SUM(COUNT(*)) OVER() ,2) AS "%_of_users"
FROM TripData_2023
GROUP BY user_type
