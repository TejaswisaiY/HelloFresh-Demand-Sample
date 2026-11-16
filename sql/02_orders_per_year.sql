-- Orders per year, with a count of quarters
-- Data: data/hf_quarterly.csv (HelloFresh group figures from public reports)

SELECT
    year,
    COUNT(*) AS quarters,
    ROUND(SUM(orders_m), 2) AS total_orders_m
FROM hf_quarterly
GROUP BY year
ORDER BY year;
