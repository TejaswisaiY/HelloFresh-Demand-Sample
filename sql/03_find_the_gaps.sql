-- Quarters with missing revenue or marketing share
-- Data: data/hf_quarterly.csv (HelloFresh group figures from public reports)

SELECT
    quarter,
    revenue_eur_m,
    marketing_pct
FROM hf_quarterly
WHERE revenue_eur_m IS NULL
   OR marketing_pct IS NULL
ORDER BY year, q;
