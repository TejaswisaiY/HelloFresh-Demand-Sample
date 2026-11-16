-- A forecast that follows the running trend
-- Data: data/hf_quarterly.csv (HelloFresh group figures from public reports)

WITH yearly AS (
    SELECT
        year,
        q,
        quarter,
        orders_m,
        LAG(orders_m) OVER (
            PARTITION BY q
            ORDER BY year
        ) AS last_year
    FROM hf_quarterly
),

trend AS (
    SELECT
        *,
        LAG(orders_m) OVER (
            ORDER BY year, q
        ) AS prev_orders,
        LAG(last_year) OVER (
            ORDER BY year, q
        ) AS prev_last_year
    FROM yearly
),

adjusted AS (
    SELECT
        *,
        last_year * prev_orders * 1.0
        / NULLIF(prev_last_year, 0) AS forecast2
    FROM trend
)

SELECT
    quarter,
    orders_m,
    ROUND(forecast2, 2) AS forecast2,
    ROUND(
        100.0 * (forecast2 - orders_m)
        / NULLIF(orders_m, 0),
        1
    ) AS pct_error
FROM adjusted
WHERE forecast2 IS NOT NULL
ORDER BY year, q;
