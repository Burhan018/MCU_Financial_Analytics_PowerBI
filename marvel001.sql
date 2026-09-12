CREATE DATABASE marvel_db;
USE marvel_db;

CREATE TABLE mcu_movies (
    movie_id VARCHAR(20) PRIMARY KEY,
    movie_title VARCHAR(255) NOT NULL,
    release_date DATE,
    release_year INT,
    mcu_timeline_order INT,
    phase VARCHAR(20),
    phase_number INT,
    director VARCHAR(255),
    lead_actor VARCHAR(255),
    runtime_minutes INT,
    production_budget_millions DECIMAL(10,2),
    worldwide_box_office_millions DECIMAL(10,2),
    domestic_box_office_millions DECIMAL(10,2),
    profit_millions DECIMAL(10,2),
    roi_percentage DECIMAL(10,2),
    domestic_percentage DECIMAL(10,2),
    imdb_rating DECIMAL(3,1),
    rotten_tomatoes INT,
    metacritic_score INT,
    storyline TEXT
);

   ---#Phase-Level Financial Breakdown
   
   CREATE VIEW vw_phase_financials AS
SELECT 
    phase,
    COUNT(movie_id) AS total_movies,
    SUM(production_budget_millions) AS total_budget_millions,
    SUM(worldwide_box_office_millions) AS total_worldwide_gross_millions,
    SUM(profit_millions) AS total_profit_millions,
    ROUND(AVG(roi_percentage), 2) AS avg_roi_percentage,
    ROUND(AVG(imdb_rating), 2) AS avg_imdb_rating
FROM mcu_movies
GROUP BY phase, phase_number
ORDER BY phase_number;

   ---#Director Box Office Performance
   
   CREATE VIEW vw_director_performance AS
SELECT 
    director,
    COUNT(movie_id) AS movies_directed,
    SUM(production_budget_millions) AS total_budget_millions,
    SUM(worldwide_box_office_millions) AS total_box_office_millions,
    SUM(profit_millions) AS total_profit_millions,
    ROUND((SUM(profit_millions) / SUM(production_budget_millions)) * 100, 2) AS overall_director_roi
FROM mcu_movies
GROUP BY director
ORDER BY total_profit_millions DESC;

   ---#CREATE VIEW vw_director_performance AS
SELECT 
    director,
    COUNT(movie_id) AS movies_directed,
    SUM(production_budget_millions) AS total_budget_millions,
    SUM(worldwide_box_office_millions) AS total_box_office_millions,
    SUM(profit_millions) AS total_profit_millions,
    ROUND((SUM(profit_millions) / SUM(production_budget_millions)) * 100, 2) AS overall_director_roi
FROM mcu_movies
GROUP BY director
ORDER BY total_profit_millions DESC;

   ---#Year-over-Year (YoY) Revenue Growth & Margin Analysis
   
   SELECT 
    curr.movie_title,
    curr.release_year,
    curr.worldwide_box_office_millions,
    prev.worldwide_box_office_millions AS prev_movie_revenue,
    ROUND(
        (curr.worldwide_box_office_millions - prev.worldwide_box_office_millions) 
        / prev.worldwide_box_office_millions * 100, 2
    ) AS revenue_growth_pct,
    ROUND((curr.profit_millions / curr.worldwide_box_office_millions) * 100, 2) AS net_profit_margin_pct
FROM mcu_movies curr
LEFT JOIN mcu_movies prev 
    ON curr.mcu_timeline_order = prev.mcu_timeline_order + 1;
    
	---#Director Risk vs. Return Matrix
    
    SELECT 
    director,
    COUNT(movie_id) AS total_films,
    ROUND(AVG(production_budget_millions), 2) AS avg_budget_millions,
    ROUND(AVG(profit_millions), 2) AS avg_profit_millions,
    ROUND(AVG(roi_percentage), 2) AS avg_roi_pct,
    ROUND(AVG(imdb_rating), 2) AS avg_imdb_score
FROM mcu_movies
GROUP BY director
HAVING COUNT(movie_id) >= 2
ORDER BY avg_profit_millions DESC;


  ---#Domestic vs. International Market Reliance
  
  SELECT 
    movie_title,
    phase,
    worldwide_box_office_millions,
    domestic_percentage,
    ROUND(100 - domestic_percentage, 2) AS international_percentage,
    CASE 
        WHEN domestic_percentage > 50 THEN 'Domestic Heavy'
        ELSE 'International Heavy'
    END AS market_dominance
FROM mcu_movies
ORDER BY worldwide_box_office_millions DESC;


SELECT * FROM marvel_db.vw_phase_financials;

SELECT * FROM marvel_db.vw_director_performance;

SELECT * FROM marvel_db.vw_financial_vs_critics;