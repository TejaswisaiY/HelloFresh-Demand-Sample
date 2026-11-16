-- Error of the simple forecast
-- Data: data/hf_quarterly.csv (HelloFresh group figures from public reports)

WITH forecasts AS (
    SELECT
        year,
        q,
        quarter,
        orders_m,
        LAG(orders_m) OVER (
            PARTITION BY q
            ORDER BY year
        ) AS forecast
    FROM hf_quarterly
)

SELECT
    quarter,
    orders_m,
    forecast,
    ROUND(forecast - orders_m, 2) AS error_m,
    ROUND(
        100.0 * (forecast - orders_m)
        / NULLIF(orders_m, 0),
        1
    ) AS pct_error
FROM forecasts
WHERE forecast IS NOT NULL
ORDER BY year, q;
