-- MAPE and bias of the simple forecast
-- Data: data/hf_quarterly.csv (HelloFresh group figures from public reports)

WITH forecasts AS (
    SELECT
        year,
        q,
        orders_m,
        LAG(orders_m) OVER (
            PARTITION BY q
            ORDER BY year
        ) AS forecast
    FROM hf_quarterly
),
errors AS (
    SELECT
        100.0 * (forecast - orders_m)
        / NULLIF(orders_m, 0) AS pct_error
    FROM forecasts
    WHERE forecast IS NOT NULL
)

SELECT
    COUNT(*) AS quarters,
    ROUND(AVG(ABS(pct_error)), 1) AS mape,
    ROUND(AVG(pct_error), 1) AS bias
FROM errors;
