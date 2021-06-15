-- Table: camdecmpsaux.check_process

-- DROP TABLE camdecmpsaux.check_process;

CREATE TABLE camdecmpsaux.check_process
(
    check_process_cd character varying NOT NULL,
    check_process_description character varying NOT NULL,
    CONSTRAINT pk_check_process PRIMARY KEY (check_process_cd)
);

COMMENT ON TABLE camdecmpsaux.check_process
    IS 'Lookup table of check engine processes.';

COMMENT ON COLUMN camdecmpsaux.check_process.check_process_cd
    IS 'Code used to identify check engine process.';

COMMENT ON COLUMN camdecmpsaux.check_process.check_process_description
    IS 'Description of check engine process.';


insert into camdecmpsaux.check_process(check_process_cd, check_process_description) values('EM', 'Emissions Data Evaluation');
insert into camdecmpsaux.check_process(check_process_cd, check_process_description) values('MP', 'Monitoring Plan Evaluation');
insert into camdecmpsaux.check_process(check_process_cd, check_process_description) values('QA', 'QA & Certification Evaluation');
