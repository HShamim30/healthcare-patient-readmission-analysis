
-- Compare raw and clean row counts
SELECT
    (SELECT COUNT(*) FROM diabetic_data_raw) AS raw_rows,
    (SELECT COUNT(*) FROM encounters_clean) AS clean_rows;

-- Check encounter key quality
SELECT
    COUNT(*) AS total_rows,
    COUNT(encounter_id) AS nonnull_encounter_ids,
    COUNT(DISTINCT encounter_id) AS unique_encounter_ids
FROM encounters_clean;

-- Check invalid readmission categories
SELECT readmitted_raw, COUNT(*) AS rows
FROM encounters_clean
WHERE readmission_category = 'Unknown'
GROUP BY readmitted_raw;

-- Check stay-duration range
SELECT
    MIN(time_in_hospital) AS min_days,
    MAX(time_in_hospital) AS max_days,
    COUNT(*) FILTER (
        WHERE time_in_hospital < 1 OR time_in_hospital > 14
    ) AS out_of_expected_range
FROM encounters_clean;

-- Check impossible or suspicious count values
SELECT *
FROM encounters_clean
WHERE num_lab_procedures < 0
   OR num_procedures < 0
   OR num_medications < 0
   OR number_outpatient < 0
   OR number_emergency < 0
   OR number_inpatient < 0
   OR number_diagnoses < 0;

-- Review missingness in analytical fields
SELECT
    COUNT(*) FILTER (WHERE age_group IS NULL) AS missing_age,
    COUNT(*) FILTER (WHERE race IS NULL) AS missing_race,
    COUNT(*) FILTER (WHERE medical_specialty IS NULL) AS missing_specialty,
    COUNT(*) FILTER (WHERE number_inpatient IS NULL) AS missing_prior_inpatient,
    COUNT(*) FILTER (WHERE readmitted_within_30_days IS NULL)
        AS missing_target
FROM encounters_clean;
