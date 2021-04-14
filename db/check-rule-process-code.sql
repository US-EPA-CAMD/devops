-- Table: camdecmpsmd.check_rule_process_code

-- DROP TABLE camdecmpsmd.check_rule_process_code;

CREATE TABLE camdecmpsmd.check_rule_process_code
(
    check_rule_process_cd character varying(10) COLLATE pg_catalog."default" NOT NULL,
    check_rule_process_description character varying(1000) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT pk_check_rule_process_code PRIMARY KEY (check_rule_process_cd)
)

TABLESPACE pg_default;

COMMENT ON TABLE camdecmpsmd.check_rule_process_code
    IS 'Lookup table of check rule processes.';

COMMENT ON COLUMN camdecmpsmd.check_rule_process_code.check_rule_process_cd
    IS 'Code used to identify check rule process.';

COMMENT ON COLUMN camdecmpsmd.check_rule_process_code.check_rule_process_description
    IS 'Description of check rule process.';


insert into camdecmpsmd.check_rule_process_code(check_rule_process_cd, check_rule_process_description) values('EM', 'Emissions Data Evaluation');
insert into camdecmpsmd.check_rule_process_code(check_rule_process_cd, check_rule_process_description) values('MP', 'Monitoring Plan Evaluation');
insert into camdecmpsmd.check_rule_process_code(check_rule_process_cd, check_rule_process_description) values('QA', 'Quality Assurance Evaluation');
