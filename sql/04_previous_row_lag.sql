-- Previous row with LAG, and why a gap breaks it
-- Data: data/hf_quarterly.csv (HelloFresh group figures from public reports)

SELECT
    quarter,
    orders_m,
    LAG(orders_m) OVER (
        ORDER BY year, q
    ) AS previous_orders_m
FROM hf_quarterly
ORDER BY year, q;
