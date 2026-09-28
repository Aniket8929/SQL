-- =========================================================
-- OLYMPIC SQL ANALYSIS  (PostgreSQL)
-- Tables : athlete_events, noc_regions
-- Note   : CTEs (WITH) are used only for multi-step queries.
-- =========================================================


-- Q01. Display all athlete event records.
SELECT *
FROM athlete_events;


-- Q02. Display all NOC region records.
SELECT *
FROM noc_regions;


-- Q03. Total number of unique athletes who participated in the Olympics.
SELECT COUNT(DISTINCT id) AS total_unique_athletes
FROM athlete_events;


-- Q04. Unique athletes in Summer and Winter Olympics (GROUP BY).
SELECT
    season,
    COUNT(DISTINCT id) AS athlete_count
FROM athlete_events
GROUP BY season
ORDER BY season;


-- Q05(second way). Unique athletes in Summer and Winter Olympics (FILTER, one row).
SELECT
    COUNT(DISTINCT id) FILTER (WHERE season = 'Summer') AS summer_athletes,
    COUNT(DISTINCT id) FILTER (WHERE season = 'Winter') AS winter_athletes
FROM athlete_events;


-- Q06. Total number of countries/regions that participated.
SELECT COUNT(DISTINCT n.region) AS total_countries
FROM athlete_events AS a
INNER JOIN noc_regions AS n
    ON a.noc = n.noc;


-- Q07. All unique NOC codes.
SELECT DISTINCT noc
FROM athlete_events
ORDER BY noc;


-- Q08. All unique countries/regions.
SELECT DISTINCT n.region AS country
FROM athlete_events AS a
INNER JOIN noc_regions AS n
    ON a.noc = n.noc
ORDER BY country;


-- Q09. Gold, Silver, Bronze and total medals per country
--      (three separate columns; team medal counted once).
WITH unique_medals AS (
    SELECT DISTINCT noc, games, event, medal
    FROM athlete_events
    WHERE medal IN ('Gold', 'Silver', 'Bronze')
)
SELECT
    n.region AS country,
    COUNT(*) FILTER (WHERE u.medal = 'Gold')   AS gold_medals,
    COUNT(*) FILTER (WHERE u.medal = 'Silver') AS silver_medals,
    COUNT(*) FILTER (WHERE u.medal = 'Bronze') AS bronze_medals,
    COUNT(*)                                   AS total_medals
FROM unique_medals AS u
INNER JOIN noc_regions AS n
    ON u.noc = n.noc
GROUP BY n.region
ORDER BY total_medals DESC;


-- Q10. Country and year combination that won the highest number of medals.
WITH unique_medals AS (
    SELECT DISTINCT noc, year, games, event, medal
    FROM athlete_events
    WHERE medal IN ('Gold', 'Silver', 'Bronze')
),
country_year_medals AS (
    SELECT
        u.year,
        n.region AS country,
        COUNT(*) AS medal_count
    FROM unique_medals AS u
    INNER JOIN noc_regions AS n
    ON u.noc = n.noc
    GROUP BY u.year, n.region
)
SELECT
    year,
    country,
    medal_count
FROM country_year_medals
WHERE medal_count = (
    SELECT MAX(medal_count)
    FROM country_year_medals
);


-- Q11. Sport in which India won the highest number of medals.
WITH india_medals AS (
    SELECT DISTINCT ae.games, ae.sport, ae.event, ae.medal
    FROM athlete_events AS ae
    INNER JOIN noc_regions AS nr
        ON ae.noc = nr.noc
    WHERE nr.region = 'India'
      AND ae.medal IN ('Gold', 'Silver', 'Bronze')
),
sport_medals AS (
    SELECT
        sport,
        COUNT(*) FILTER (WHERE medal = 'Gold')   AS gold,
        COUNT(*) FILTER (WHERE medal = 'Silver') AS silver,
        COUNT(*) FILTER (WHERE medal = 'Bronze') AS bronze,
        COUNT(*)                                 AS total_medals
    FROM india_medals
    GROUP BY sport
)
SELECT *
FROM sport_medals
WHERE total_medals = (
    SELECT MAX(total_medals)
    FROM sport_medals
);


-- Q12. Athlete(s) who won the maximum number of medals.
--      (Row count is correct here: 1 row = 1 medal for that athlete.)
WITH athlete_medal_counts AS (
    SELECT
        id,
        name,
        noc,
        COUNT(*) FILTER (WHERE medal = 'Gold')   AS gold,
        COUNT(*) FILTER (WHERE medal = 'Silver') AS silver,
        COUNT(*) FILTER (WHERE medal = 'Bronze') AS bronze,
        COUNT(*)                                 AS total_medals
    FROM athlete_events
    WHERE medal IN ('Gold', 'Silver', 'Bronze')
    GROUP BY id, name, noc
)
SELECT
    name,
    noc,
    gold,
    silver,
    bronze,
    total_medals
FROM athlete_medal_counts
WHERE total_medals = (
    SELECT MAX(total_medals)
    FROM athlete_medal_counts
);


-- Q13. Oldest athlete(s) who won a medal.
SELECT
    name,
    age,
    sport,
    event,
    medal
FROM athlete_events
WHERE medal IN ('Gold', 'Silver', 'Bronze')
  AND age = (
      SELECT MAX(age)
      FROM athlete_events
      WHERE medal IN ('Gold', 'Silver', 'Bronze')
  );


-- Q14. Sports that were played only once in the Olympics.
SELECT
    sport,
    COUNT(DISTINCT games) AS times_played
FROM athlete_events
GROUP BY sport
HAVING COUNT(DISTINCT games) = 1;


-- Q15. Event held in the maximum number of Olympic editions.
WITH event_counts AS (
    SELECT
        event,
        COUNT(DISTINCT games) AS times_held
    FROM athlete_events
    GROUP BY event
)
SELECT
    event,
    times_held
FROM event_counts
WHERE times_held = (
    SELECT MAX(times_held)
    FROM event_counts
);


-- Q16. Events that were played in every Summer Olympics.
SELECT
    event,
    COUNT(DISTINCT games) AS games_played
FROM athlete_events
WHERE season = 'Summer'
GROUP BY event
HAVING COUNT(DISTINCT games) = (
    SELECT COUNT(DISTINCT games)
    FROM athlete_events
    WHERE season = 'Summer'
);


-- Q17. Year(s) with the minimum and maximum number of unique athletes.
WITH year_participation AS (
    SELECT
        year,
        COUNT(DISTINCT id) AS athlete_count
    FROM athlete_events
    GROUP BY year
)
SELECT
    year,
    athlete_count
FROM year_participation
WHERE athlete_count = (SELECT MIN(athlete_count) FROM year_participation)
   OR athlete_count = (SELECT MAX(athlete_count) FROM year_participation)
ORDER BY year;


-- Q18. Overall male-to-female athlete ratio.
SELECT
    COUNT(DISTINCT id) FILTER (WHERE sex = 'M') AS male_count,
    COUNT(DISTINCT id) FILTER (WHERE sex = 'F') AS female_count,
    ROUND(
        COUNT(DISTINCT id) FILTER (WHERE sex = 'M')::numeric
        / NULLIF(COUNT(DISTINCT id) FILTER (WHERE sex = 'F'), 0),
        2
    ) AS male_female_ratio
FROM athlete_events;


-- Q19. Male-to-female athlete ratio for each region.
SELECT
    n.region AS region,
    COUNT(DISTINCT a.id) FILTER (WHERE a.sex = 'M') AS male_count,
    COUNT(DISTINCT a.id) FILTER (WHERE a.sex = 'F') AS female_count,
    ROUND(
        COUNT(DISTINCT a.id) FILTER (WHERE a.sex = 'M')::numeric
        / NULLIF(COUNT(DISTINCT a.id) FILTER (WHERE a.sex = 'F'), 0),
        2
    ) AS male_female_ratio
FROM athlete_events AS a
INNER JOIN noc_regions AS n
    ON a.noc = n.noc
GROUP BY n.region
ORDER BY n.region;


-- Q20. Number of athlete-event records for each year and country.
SELECT
    a.year,
    n.region AS country,
    COUNT(*) AS record_count
FROM athlete_events AS a
INNER JOIN noc_regions AS n
    ON a.noc = n.noc
GROUP BY a.year, n.region
ORDER BY a.year, record_count DESC;