-- Forecast misses next to the change in marketing share
-- Data: data/hf_quarterly.csv (HelloFresh group figures from public reports)

WITH yearly AS (
    SELECT
        year, q, quarter, orders_m,
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
),

marketing AS (
    SELECT
        year, q,
        marketing_pct,
        LAG(marketing_pct) OVER (
            PARTITION BY q
            ORDER BY year
        ) AS last_year_marketing
    FROM hf_quarterly
)

SELECT
    a.quarter,
    ROUND(
        100.0 * (a.forecast2 - a.orders_m)
        / NULLIF(a.orders_m, 0),
        1
    ) AS pct_error,
    m.marketing_pct,
    ROUND(
        m.marketing_pct - last_year_marketing,
        1
    ) AS marketing_change
FROM adjusted a
LEFT JOIN marketing m
    ON a.year = m.year
    AND a.q = m.q
WHERE a.forecast2 IS NOT NULL
ORDER BY a.year, a.q;
