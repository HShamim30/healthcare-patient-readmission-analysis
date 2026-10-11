-- A. Executive readmission KPIs

SELECT
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT patient_nbr) AS unique_patients,

    COUNT(*) FILTER (
        WHERE readmission_eligible IS TRUE
    ) AS eligible_encounters,

    COUNT(*) FILTER (
        WHERE readmission_eligible IS TRUE
          AND readmitted_within_30_days = 1
    ) AS readmissions_within_30_days,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE readmission_eligible IS TRUE
              AND readmitted_within_30_days = 1
        ) / NULLIF(
            COUNT(*) FILTER (
                WHERE readmission_eligible IS TRUE
            ), 0
        ),
        2
    ) AS readmission_rate_pct

FROM encounters_clean;


-- B. Readmission rate by age group

SELECT
    age_group,
    COUNT(*) AS eligible_encounters,

    COUNT(*) FILTER (
        WHERE readmitted_within_30_days = 1
    ) AS readmitted_30d,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE readmitted_within_30_days = 1
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS readmission_rate_pct

FROM encounters_clean
WHERE readmission_eligible IS TRUE
GROUP BY age_group
ORDER BY age_group;


-- C. Previous hospitalization patterns

SELECT
    CASE
        WHEN number_inpatient = 0 THEN '0 prior inpatient visits'
        WHEN number_inpatient = 1 THEN '1 prior inpatient visit'
        WHEN number_inpatient BETWEEN 2 AND 3 THEN '2-3 prior visits'
        WHEN number_inpatient BETWEEN 4 AND 5 THEN '4-5 prior visits'
        WHEN number_inpatient >= 6 THEN '6+ prior visits'
        ELSE 'Unknown'
    END AS prior_inpatient_group,

    COUNT(*) AS eligible_encounters,

    COUNT(*) FILTER (
        WHERE readmitted_within_30_days = 1
    ) AS readmitted_30d,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE readmitted_within_30_days = 1
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS readmission_rate_pct

FROM encounters_clean
WHERE readmission_eligible IS TRUE
GROUP BY 1
ORDER BY MIN(number_inpatient) NULLS LAST;


-- D. Length of stay analysis

SELECT
    CASE
        WHEN time_in_hospital BETWEEN 1 AND 2 THEN '1-2 days'
        WHEN time_in_hospital BETWEEN 3 AND 5 THEN '3-5 days'
        WHEN time_in_hospital BETWEEN 6 AND 9 THEN '6-9 days'
        WHEN time_in_hospital BETWEEN 10 AND 14 THEN '10-14 days'
        ELSE 'Unknown'
    END AS stay_group,

    COUNT(*) AS eligible_encounters,

    ROUND(AVG(time_in_hospital), 2) AS avg_stay_days,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE readmitted_within_30_days = 1
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS readmission_rate_pct

FROM encounters_clean
WHERE readmission_eligible IS TRUE
GROUP BY 1
ORDER BY MIN(time_in_hospital) NULLS LAST;


-- E. Readmission by medication-change status

SELECT
    medication_change,
    diabetes_medication,
    COUNT(*) AS eligible_encounters,

    COUNT(*) FILTER (
        WHERE readmitted_within_30_days = 1
    ) AS readmitted_30d,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE readmitted_within_30_days = 1
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS readmission_rate_pct

FROM encounters_clean
WHERE readmission_eligible IS TRUE
GROUP BY medication_change, diabetes_medication
ORDER BY eligible_encounters DESC;


-- F. Most frequent primary diagnosis codes

SELECT
    diag_1 AS primary_diagnosis_code,
    COUNT(*) AS eligible_encounters,

    COUNT(*) FILTER (
        WHERE readmitted_within_30_days = 1
    ) AS readmitted_30d,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE readmitted_within_30_days = 1
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS readmission_rate_pct

FROM encounters_clean
WHERE readmission_eligible IS TRUE
  AND diag_1 IS NOT NULL
GROUP BY diag_1
HAVING COUNT(*) >= 100
ORDER BY eligible_encounters DESC
LIMIT 15;


-- G. Compare all three readmission outcomes

SELECT
    readmission_category,
    COUNT(*) AS encounters,

    ROUND(
        100.0 * COUNT(*) / NULLIF(
            SUM(COUNT(*)) OVER (), 0
        ),
        2
    ) AS percentage_of_encounters

FROM encounters_clean
GROUP BY readmission_category
ORDER BY encounters DESC;