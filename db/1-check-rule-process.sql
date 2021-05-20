-- Table: camdecmpsaux.check_rule_process

-- DROP TABLE camdecmpsaux.check_rule_process;

CREATE TABLE camdecmpsaux.check_rule_process
(
    check_rule_process_cd character varying NOT NULL,
    check_rule_process_description character varying NOT NULL,
    CONSTRAINT pk_check_rule_process PRIMARY KEY (check_rule_process_cd)
);

COMMENT ON TABLE camdecmpsaux.check_rule_process
    IS 'Lookup table of check rule processes.';

COMMENT ON COLUMN camdecmpsaux.check_rule_process.check_rule_process_cd
    IS 'Code used to identify check rule process.';

COMMENT ON COLUMN camdecmpsaux.check_rule_process.check_rule_process_description
    IS 'Description of check rule process.';


insert into camdecmpsaux.check_rule_process(check_rule_process_cd, check_rule_process_description) values('EM', 'Emissions Data Evaluation');
insert into camdecmpsaux.check_rule_process(check_rule_process_cd, check_rule_process_description) values('MP', 'Monitoring Plan Evaluation');
insert into camdecmpsaux.check_rule_process(check_rule_process_cd, check_rule_process_description) values('QA', 'Quality Assurance Evaluation');
