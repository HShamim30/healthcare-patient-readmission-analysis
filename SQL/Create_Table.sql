--Creating table so i can import csv file data in my table
CREATE TABLE diabetic_data_raw (
    encounter_id BIGINT,
    patient_nbr BIGINT,
    race VARCHAR(50),
    gender VARCHAR(30),
    age VARCHAR(20),
    weight VARCHAR(20),
    admission_type_id INTEGER,
    discharge_disposition_id INTEGER,
    admission_source_id INTEGER,
    time_in_hospital INTEGER,
    payer_code VARCHAR(20),
    medical_specialty VARCHAR(100),
    num_lab_procedures INTEGER,
    num_procedures INTEGER,
    num_medications INTEGER,
    number_outpatient INTEGER,
    number_emergency INTEGER,
    number_inpatient INTEGER,
    diag_1 VARCHAR(20),
    diag_2 VARCHAR(20),
    diag_3 VARCHAR(20),
    number_diagnoses INTEGER,
    max_glu_serum VARCHAR(20),
    A1Cresult VARCHAR(20),
    metformin VARCHAR(20),
    repaglinide VARCHAR(20),
    nateglinide VARCHAR(20),
    chlorpropamide VARCHAR(20),
    glimepiride VARCHAR(20),
    acetohexamide VARCHAR(20),
    glipizide VARCHAR(20),
    glyburide VARCHAR(20),
    tolbutamide VARCHAR(20),
    pioglitazone VARCHAR(20),
    rosiglitazone VARCHAR(20),
    acarbose VARCHAR(20),
    miglitol VARCHAR(20),
    troglitazone VARCHAR(20),
    tolazamide VARCHAR(20),
    examide VARCHAR(20),
    citoglipton VARCHAR(20),
    insulin VARCHAR(20),
    glyburide_metformin VARCHAR(20),
    glipizide_metformin VARCHAR(20),
    glimepiride_pioglitazone VARCHAR(20),
    metformin_rosiglitazone VARCHAR(20),
    metformin_pioglitazone VARCHAR(20),
    change VARCHAR(20),
    diabetes_Med VARCHAR(20),
    readmitted VARCHAR(20)
);

--Viewing If it successfully imported in my data or not
SELECT * FROM diabetic_data_raw;
SELECT COUNT(*) FROM diabetic_data_raw;

--Viewing only 10 data 
SELECT * FROM diabetic_data_raw
LIMIT 10;

-- Check readmission distribution
SELECT readmitted, COUNT(*) AS total_patients
FROM public.diabetic_data_raw
GROUP BY readmitted
ORDER BY total_patients DESC;