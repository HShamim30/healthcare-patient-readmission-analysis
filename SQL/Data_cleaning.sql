CREATE TABLE encounters_clean AS

WITH normalized AS (
    SELECT
        encounter_id::TEXT AS encounter_id_text,
        patient_nbr::TEXT AS patient_nbr_text,

        NULLIF(NULLIF(TRIM(race), '?'), '') AS race,
        NULLIF(NULLIF(TRIM(gender), '?'), '') AS gender,
        NULLIF(NULLIF(TRIM(age), '?'), '') AS age_group,
        NULLIF(NULLIF(TRIM(weight), '?'), '') AS weight,

        admission_type_id::TEXT AS admission_type_text,
        discharge_disposition_id::TEXT AS discharge_text,
        admission_source_id::TEXT AS admission_source_text,

        time_in_hospital::TEXT AS stay_text,
        num_lab_procedures::TEXT AS lab_text,
        num_procedures::TEXT AS procedure_text,
        num_medications::TEXT AS medication_text,
        number_outpatient::TEXT AS outpatient_text,
        number_emergency::TEXT AS emergency_text,
        number_inpatient::TEXT AS inpatient_text,
        number_diagnoses::TEXT AS diagnoses_text,

        NULLIF(NULLIF(TRIM(payer_code), '?'), '') AS payer_code,
        NULLIF(NULLIF(TRIM(medical_specialty), '?'), '') AS medical_specialty,

        NULLIF(NULLIF(TRIM(diag_1), '?'), '') AS diag_1,
        NULLIF(NULLIF(TRIM(diag_2), '?'), '') AS diag_2,
        NULLIF(NULLIF(TRIM(diag_3), '?'), '') AS diag_3,

        NULLIF(NULLIF(TRIM(max_glu_serum), '?'), '') AS max_glu_serum,
        NULLIF(NULLIF(TRIM(a1cresult), '?'), '') AS a1cresult,
        NULLIF(NULLIF(TRIM(change), '?'), '') AS medication_change,
        NULLIF(NULLIF(TRIM(diabetes_med), '?'), '') AS diabetes_medication,

        NULLIF(NULLIF(TRIM(readmitted), '?'), '') AS readmitted_raw,

        NULLIF(NULLIF(TRIM(metformin), '?'), '') AS metformin,
        NULLIF(NULLIF(TRIM(glimepiride), '?'), '') AS glimepiride,
        NULLIF(NULLIF(TRIM(glipizide), '?'), '') AS glipizide,
        NULLIF(NULLIF(TRIM(glyburide), '?'), '') AS glyburide,
        NULLIF(NULLIF(TRIM(pioglitazone), '?'), '') AS pioglitazone,
        NULLIF(NULLIF(TRIM(rosiglitazone), '?'), '') AS rosiglitazone,
        NULLIF(NULLIF(TRIM(insulin), '?'), '') AS insulin

    FROM public.diabetic_data_raw
),

typed AS (
    SELECT
        CASE
            WHEN encounter_id_text ~ '^[0-9]+$'
            THEN encounter_id_text::BIGINT
        END AS encounter_id,

        CASE
            WHEN patient_nbr_text ~ '^[0-9]+$'
            THEN patient_nbr_text::BIGINT
        END AS patient_nbr,

        race,
        gender,
        age_group,
        weight,

        CASE
            WHEN admission_type_text ~ '^[0-9]+$'
            THEN admission_type_text::INTEGER
        END AS admission_type_id,

        CASE
            WHEN discharge_text ~ '^[0-9]+$'
            THEN discharge_text::INTEGER
        END AS discharge_disposition_id,

        CASE
            WHEN admission_source_text ~ '^[0-9]+$'
            THEN admission_source_text::INTEGER
        END AS admission_source_id,

        CASE
            WHEN stay_text ~ '^[0-9]+$'
            THEN stay_text::INTEGER
        END AS time_in_hospital,

        CASE
            WHEN lab_text ~ '^[0-9]+$'
            THEN lab_text::INTEGER
        END AS num_lab_procedures,

        CASE
            WHEN procedure_text ~ '^[0-9]+$'
            THEN procedure_text::INTEGER
        END AS num_procedures,

        CASE
            WHEN medication_text ~ '^[0-9]+$'
            THEN medication_text::INTEGER
        END AS num_medications,

        CASE
            WHEN outpatient_text ~ '^[0-9]+$'
            THEN outpatient_text::INTEGER
        END AS number_outpatient,

        CASE
            WHEN emergency_text ~ '^[0-9]+$'
            THEN emergency_text::INTEGER
        END AS number_emergency,

        CASE
            WHEN inpatient_text ~ '^[0-9]+$'
            THEN inpatient_text::INTEGER
        END AS number_inpatient,

        CASE
            WHEN diagnoses_text ~ '^[0-9]+$'
            THEN diagnoses_text::INTEGER
        END AS number_diagnoses,

        payer_code,
        medical_specialty,
        diag_1,
        diag_2,
        diag_3,
        max_glu_serum,
        a1cresult,
        medication_change,
        diabetes_medication,
        readmitted_raw,
        metformin,
        glimepiride,
        glipizide,
        glyburide,
        pioglitazone,
        rosiglitazone,
        insulin

    FROM normalized
)

SELECT
    *,

    CASE
        WHEN LOWER(TRIM(readmitted_raw)) = '<30'
            THEN 'Within 30 Days'
        WHEN LOWER(TRIM(readmitted_raw)) = '>30'
            THEN 'After 30 Days'
        WHEN LOWER(TRIM(readmitted_raw)) = 'no'
            THEN 'No Recorded Readmission'
        ELSE 'Unknown'
    END AS readmission_category,

    CASE
        WHEN LOWER(TRIM(readmitted_raw)) = '<30'
            THEN 1
        WHEN LOWER(TRIM(readmitted_raw)) IN ('>30', 'no')
            THEN 0
        ELSE NULL
    END AS readmitted_within_30_days,

    CASE
        WHEN discharge_disposition_id IN (11, 13, 14, 19, 20, 21)
            THEN FALSE
        WHEN discharge_disposition_id IS NULL
            THEN NULL
        ELSE TRUE
    END AS readmission_eligible

FROM typed;