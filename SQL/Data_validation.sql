
-- 1. Total rows
SELECT COUNT(*) AS total_rows
FROM diabetic_data_raw;

-- 2. Duplicate encounter IDs
SELECT
    encounter_id,
    COUNT(*) AS record_count
FROM diabetic_data_raw
GROUP BY encounter_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

-- 3. Missing-value markers in important columns
SELECT
    COUNT(*) FILTER (
        WHERE encounter_id IS NULL
    ) AS missing_encounter_id,
    COUNT(*) FILTER (
        WHERE patient_nbr IS NULL
    ) AS missing_patient_id,
    COUNT(*) FILTER (
        WHERE race IS NULL OR TRIM(race) IN ('', '?')
    ) AS missing_race,
    COUNT(*) FILTER (
        WHERE weight IS NULL OR TRIM(weight) IN ('', '?')
    ) AS missing_weight,
    COUNT(*) FILTER (
        WHERE medical_specialty IS NULL
           OR TRIM(medical_specialty) IN ('', '?')
    ) AS missing_specialty
FROM diabetic_data_raw;

-- 4. Readmission categories
SELECT readmitted, COUNT(*) AS encounters
FROM diabetic_data_raw
GROUP BY readmitted
ORDER BY encounters DESC;

-- 5. Check invalid numeric values before casting
SELECT encounter_id, time_in_hospital
FROM diabetic_data_raw
WHERE time_in_hospital IS NOT NULL
  AND time_in_hospital::TEXT !~ '^[0-9]+$';

-- 6. Unexpected category values
SELECT DISTINCT gender
FROM diabetic_data_raw
ORDER BY gender;

SELECT DISTINCT age
FROM diabetic_data_raw
ORDER BY age;

SELECT DISTINCT diabetes_med
FROM diabetic_data_raw
ORDER BY diabetes_med;

SELECT DISTINCT change
FROM diabetic_data_raw
ORDER BY change;

-- 7. Check numeric ranges
SELECT
    MIN(time_in_hospital) AS min_stay_text,
    MAX(time_in_hospital) AS max_stay_text
FROM diabetic_data_raw;
