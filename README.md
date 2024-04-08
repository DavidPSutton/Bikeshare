# Introduction

This was a suggested capstone project for the Google Data Analytics Professional Certificate.  All of the data is from a public dataset provided by Coursera/Google ( https://divvy-tripdata.s3.amazonaws.com/index.html ) and is assumed to be accurate.

The defined scenario for the couse is as follows:

*You are a junior data analyst working on the marketing analyst team at Cyclistic, a bike-share
company in Chicago. The director of marketing believes the company’s future success
depends on maximizing the number of annual memberships. Therefore, your team wants to
understand how casual riders and annual members use Cyclistic bikes differently. From these
insights, your team will design a new marketing strategy to convert casual riders into annual
members. But first, Cyclistic executives must approve your recommendations, so they must be
backed up with compelling data insights and professional data visualizations...*

*...[The director of marketing] has assigned you the first question to answer: How do annual members and casual
riders use Cyclistic bikes differently?*

# Tools Used
- **SQL:** Language used for queries in the Project
- **MS SQL Server:** For storing the database
- **VS Code:** For writing and organizing queries
- **Tableau:** For data visualization
- **GitHub:** For storing the [data repository](/Queries/)

# Analysis 
### **Cleaning the data**

In order to look at the data for the entire year, I had to combine all of the data from individual months (csv files) into one dataset.

```sql
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
```
I then confirmed that there where no repeated 'ride_id' values...

```sql
SELECT ride_id, COUNT(ride_id) as 'repeat_id_count'
FROM TripData_2023
GROUP BY ride_id
HAVING COUNT(ride_id) >1
```
...and the query showed no result which confirmed that each 'ride_id' was unique.
 
### **Exploring the Data**

The first thing to figure out is the breakdown of 'member' vs. 'casual' users.

```sql
SELECT user_type, COUNT (user_type) as "number_of_users", ROUND(COUNT(*)* 100.0/ SUM(COUNT(*)) OVER() ,2) AS "%_of_users"
FROM TripData_2023
GROUP BY user_type
```
|user_type|number_of_users|%_of_users|
|---------|---------------|----------|
|casual   |2020783        |35.95     |
|member   |3600780        |64.05     |
  
-  **Question 1:** 
*What is difference in ride times for casual riders and members?*

To answer the question, first, I had to calculate the time of each ride based on the the 'started_at' and 'ended_at' values in minutes and add it as a new column.

```sql
ALTER TABLE TripData_2023 
    ADD ride_time AS DATEDIFF(MINUTE, started_at, ended_at)
```
Looking at the data, some of the 'ride_time' values were negative, which I assume are data errors, and some were over 12 hours suggesting that people were holding bikes longer than they were using them.  So I removed these from the dataset so that they wouldn't skew the averages.

```sql
DELETE FROM TripData_2023
WHERE ride_time <= 0
OR ride_time > 12*60
```

```sql
SELECT user_type, AVG(ride_time) AS avg_ride_time
FROM TripData_2023
GROUP BY user_type
```

|user_type|avg_ride_time|
|---------|-------------|
|   member|           12|
|   casual|           19|


This query shows that the average ride time for casual riders is ~58% greater than members, so an advertisment campain
focusing on cost vs. time for each ride may help increase membership.

- **Question 2:** 
*What are the most common stations started from by members and casual riders?*

I start by checking to see what the top 10 start stations used by casual riders...

```sql
SELECT TOP 10 user_type, start_station_name, COUNT(start_station_name) AS station_count
FROM TripData_2023
WHERE start_station_name IS NOT NULL
	AND user_type = 'casual'
GROUP BY start_station_name, user_type
ORDER BY station_count DESC
```

user_type|	start_station_name|	station_count
-|-|-|
casual|	Streeter Dr & Grand Ave|	45270
casual|	DuSable Lake Shore Dr & Monroe St|	30010
casual|	Michigan Ave & Oak St|	22331
casual|	DuSable Lake Shore Dr & North Blvd|	20051
casual|	Millennium Park|	19843
casual|	Shedd Aquarium|	17508
casual|	Theater on the Lake|	16118
casual|	Dusable Harbor|	15248
casual|	Wells St & Concord Ln|	12043
casual|	Montrose Harbor|	11729

... and then the top 10 stations used by members.

```sql
SELECT TOP 10 user_type, start_station_name, COUNT(start_station_name) AS station_count
FROM TripData_2023
WHERE start_station_name IS NOT NULL
	AND user_type = 'member'
GROUP BY start_station_name, user_type
ORDER BY station_count DESC
```
user_type|	start_station_name|	station_count|
-|-|-
member|	Clinton St & Washington Blvd|	25821
member|	Kingsbury St & Kinzie St|	25793
member|	Clark St & Elm St|	24681
member|	Wells St & Concord Ln|	21131
member|	Clinton St & Madison| St	20298
member|	Wells St & Elm St|	20162
member|	University Ave & 57th St|	19727
member|	Broadway & Barry Ave|	18718
member|	Loomis St & Lexington St|	18564
member|	State St & Chicago Ave|	18075

These queries show that the top 10 stations for casual riders and members don't align.  I would suggest that advertising for memberships should be focused on the most used starting stations for casual riders.

- **Question 3:** 
*When do members and casual riders most often use Cyclistic?*

To answer this question I had to write a query using a CTE to breakdown starting by extracting the month for the different user types from each ride, then counting how many times each month occurs in the data.

```sql
WITH cte as (

	SELECT ride_id, user_type, DATENAME(MONTH, started_at) as 'month'
	FROM TripData_2023
	Where user_type = 'casual'
	GROUP BY user_type, started_at, ride_id
)

	SELECT user_type, month, COUNT(ride_id) as rides_per_month
	FROM cte
	GROUP BY user_type, [month]
	ORDER BY [rides_per_month] desc
```
user_type|	month|	rides_per_month
-|-|-
casual|	July|	325120
casual|	August|	305612
casual|	June|	295450
casual|	September|	257299
casual|	May|	229506
casual|	October|	174109
casual|	April|	143902
casual|	November|	96835
casual|	March|	60823
casual|	December|	50816
casual|	February|	42135
casual|	January|	39176

```sql
WITH cte as (

	SELECT ride_id, user_type, DATENAME(MONTH, started_at) as 'month'
	FROM TripData_2023
	Where user_type = 'member'
	GROUP BY user_type, started_at, ride_id
)

	SELECT user_type, month, COUNT(ride_id) as rides_per_month
	FROM cte
	GROUP BY user_type, [month]
	ORDER BY [rides_per_month] desc
```
user_type|	month|	rides_per_month
-|-|-
member|	August|	453712
member|	July|	429331
member|	June|	411872
member|	September|	399486
member|	May|	363653
member|	October|	355422
member|	April|	272850
member|	November|	260877
member|	March|	191843
member|	December|	170266
member|	January|	147131
member|	February|	144337



![alt text](<Assets/Monthly Ride Trends.png>)



Looking at the results for each rider type, it seems that they both have very similar month to month use trends.

Next, I wrote a multi-leveled CTE for each rider type to find the average rides per day.

```sql
WITH
CTE AS (

    SELECT ride_id, user_type, CAST(started_at as date) as 'date', DATENAME(dw,started_at) AS 'day'
    FROM TripData_2023
    WHERE user_type = 'casual'
    GROUP BY started_at, ride_id, user_type
),

CTE2 AS (

    Select user_type, [date], day, COUNT([ride_id]) as 'ride_count'
    FROM CTE
    GROUP BY [day], [date], user_type
)

    SELECT user_type, day, avg(ride_count) as 'avg_rides_day'
    FROM CTE2
    GROUP BY [day], user_type
    ORDER BY [avg_rides_day] DESC
```

user_type|	day|	avg_rides_day
-|-|-
casual|	Saturday|	7748
casual|	Sunday|	6211
casual|	Friday|	5887
casual|	Thursday|	5108
casual|	Wednesday|	4703
casual|	Tuesday|	4649
casual|	Monday|	4434

```sql
WITH
CTE AS (

    SELECT ride_id, user_type, CAST(started_at as date) as 'date', DATENAME(dw,started_at) AS 'day'
    FROM TripData_2023
    WHERE user_type = 'member'
    GROUP BY started_at, ride_id, user_type
),

CTE2 AS (

    Select user_type, [date], day, COUNT([ride_id]) as 'ride_count'
    FROM CTE
    GROUP BY [day], [date], user_type
    --ORDER BY [date]
)

    SELECT user_type, day, avg(ride_count) as 'avg_rides_day'
    FROM CTE2
    GROUP BY [day], user_type
    ORDER BY [avg_rides_day] DESC
```

user_type|	day|	avg_rides_day
-|-|-
member|	Thursday|	11151
member|	Wednesday|	11100
member|	Tuesday|	10914
member|	Friday|	10048
member|	Monday|	9358
member|	Saturday|	8937
member|	Sunday|	7588

![alt text](<Assets/Avg Daily Ride by User Type.png>)

Here we see that casual users tend to use Cyclistic on the weekends while members are more likely to ride during the work week.  This shows that casual riders are most likely using the service recreationally, while members are more often riding to commute.

- **Question 4:** 
*Are casual riders more likely to choose one type of bike (classic, electric, or docked)over another?*

I wrote a query to see how casual riders and members used the different bike types.

```sql
    SELECT user_type, rideable_type, COUNT(user_type) AS 'ride_count'
    FROM TripData_2023
    GROUP BY rideable_type, user_type
    ORDER BY user_type, ride_count DESC
```
user_type|	rideable_type|	ride_count
-|-|-
casual|	electric_bike|	1080286
casual|	classic_bike|	864885
casual|	docked_bike|	75612
member|	electric_bike|	1800987
member|	classic_bike|	1799793

Looking at the results, it seems that Members use 'classic' and 'electric' bikes nearly equally, but don't use 'docked' bikes at all.  Casual users, however, show a preference for 'electric' bikes over the other two options.  

This made me wonder if these trends were consistent throughout the year, so I wrote queries for how each user type used the different bike types each month.

```sql
WITH CTE AS (
    SELECT ride_id, user_type, DATENAME(month, started_at) as 'month', rideable_type, count(rideable_type) as 'rides' 
    FROM TripData_2023
    WHERE user_type = 'casual'
    GROUP BY started_at, user_type, rideable_type, ride_id
)

SELECT user_type, month, rideable_type, count(ride_id) as 'ride_count'
FROM CTE
GROUP BY rideable_type, month, rides, user_type
ORDER BY ride_count DESC, rideable_type --, month
```

user_type|	month|	rideable_type|	ride_count
-|-|-|-
casual|	July|	electric_bike|	166379
casual|	June|	electric_bike|	165984
casual|	August|	classic_bike|	146696
casual|	August|	electric_bike|	143566
casual|	July|	classic_bike|	140977
casual|	September|	classic_bike|	130355
casual|	September|	electric_bike|	126944
casual|	May|	electric_bike|	125435
casual|	June|	classic_bike|	115029
casual|	October|	electric_bike|	92182
casual|	May|	classic_bike|	91349
casual|	April|	electric_bike|	87080
casual|	October|	classic_bike|	81927
casual|	November|	electric_bike|	54915
casual|	April|	classic_bike|	48217
casual|	November|	classic_bike|	41920
casual|	March|	electric_bike|	38693
casual|	December|	electric_bike|	30699
casual|	February|	electric_bike|	24652
casual|	January|	electric_bike|	23757
casual|	December|	classic_bike|	20117
casual|	March|	classic_bike|	19199
casual|	July|	docked_bike|	17764
casual|	February|	classic_bike|	15352
casual|	August|	docked_bike|	15350
casual|	June|	docked_bike|	14437
casual|	January|	classic_bike|	13747
casual|	May|	docked_bike|	12722
casual|	April|	docked_bike|	8605
casual|	March|	docked_bike|	2931
casual|	February|	docked_bike|	2131
casual|	January|	docked_bike|	1672

```sql
WITH CTE AS (
    SELECT ride_id, user_type, DATENAME(month, started_at) as 'month', rideable_type, count(rideable_type) as 'rides' 
    FROM TripData_2023
    WHERE user_type = 'member'
    GROUP BY started_at, user_type, rideable_type, ride_id
)

SELECT user_type, month, rideable_type, count(ride_id) as 'ride_count'
FROM CTE
GROUP BY rideable_type, month, rides, user_type
ORDER BY ride_count DESC, rideable_type --, month
```

user_type|	month|	rideable_type|	ride_count
-|-|-|-
member|	August|	classic_bike|	245651
member|	June|	electric_bike|	217204
member|	July|	classic_bike|	216729
member|	September|	classic_bike|	212872
member|	July|	electric_bike|	212602
member|	August|	electric_bike|	208061
member|	June|	classic_bike|	194668
member|	May|	electric_bike|	188280
member|	September|	electric_bike|	186614
member|	October|	classic_bike|	183284
member|	May|	classic_bike|	175373
member|	October|	electric_bike|	172138
member|	April|	electric_bike|	153272
member|	November|	classic_bike|	132252
member|	November|	electric_bike|	128625
member|	April|	classic_bike|	119578
member|	March|	electric_bike|	105032
member|	December|	electric_bike|	86940
member|	March|	classic_bike|	86811
member|	December|	classic_bike|	83326
member|	January|	classic_bike|	75621
member|	February|	classic_bike|	73628
member|	January|	electric_bike|	71510
member|	February|	electric_bike|	70709

This gave me all of the information needed, but was difficult to parse the results, so I created graphs to better visualize the information.

![alt text](<Assets/Monthly Bike Type by User Type.png>)

Now we can easily see when each bike type is most often used by which rider type.

It looks like 'electric' bikes trend up in the spring for both rider types, and 'classic' bikes trend highest in the summer with Member usage spiking in August.  This would indicate that the spring and summer months would be the best times to market to casual riders.

# Conclusion

After digging through the data I found many ways that Members and Casual Riders differ in their uses of Cyclistic, as well as a few ways that were consistent to both.  This should help the team devise multiple marketing stratagies by showing when and where to focus their budgets and efforts.