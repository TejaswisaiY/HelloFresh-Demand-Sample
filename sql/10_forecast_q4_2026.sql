-- Forecast for Q4 2026 with a low and a high case
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

errors AS (
    SELECT
        (forecast2 - orders_m) * 1.0
        / NULLIF(orders_m, 0) AS error_frac
    FROM adjusted
    WHERE forecast2 IS NOT NULL
),

future AS (
    SELECT
        (
            SELECT orders_m
            FROM hf_quarterly
            WHERE year = 2025 AND q = 4
        ) * (
            SELECT orders_m
            FROM hf_quarterly
            WHERE year = 2026 AND q = 3
        ) * 1.0 / NULLIF((
            SELECT orders_m
            FROM hf_quarterly
            WHERE year = 2025 AND q = 3
        ), 0) AS forecast
)

SELECT
    ROUND(forecast, 2) AS forecast,
    ROUND(
        forecast / (1 + (
            SELECT MAX(error_frac)
            FROM errors
        )), 2
    ) AS low_case,
    ROUND(
        forecast / (1 + (
            SELECT MIN(error_frac)
            FROM errors
        )), 2
    ) AS high_case
FROM future;
