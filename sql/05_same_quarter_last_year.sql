-- Same quarter last year: the simple forecast
-- Data: data/hf_quarterly.csv (HelloFresh group figures from public reports)

SELECT
    year,
    q,
    orders_m,
    LAG(orders_m) OVER (
        PARTITION BY q
        ORDER BY year
    ) AS last_year_orders_m
FROM hf_quarterly
ORDER BY year, q;
