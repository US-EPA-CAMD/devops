-- Table: camdecmpsmd.check_rule_type_code

-- DROP TABLE camdecmpsmd.check_rule_type_code;

CREATE TABLE camdecmpsmd.check_rule_type_code
(
    check_rule_type_cd character varying(25) COLLATE pg_catalog."default" NOT NULL,
    check_rule_type_description character varying(1000) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT pk_check_rule_type_code PRIMARY KEY (check_rule_type_cd)
)

TABLESPACE pg_default;

COMMENT ON TABLE camdecmpsmd.check_rule_type_code
    IS 'Lookup table of check rule types.';

COMMENT ON COLUMN camdecmpsmd.check_rule_type_code.check_rule_type_cd
    IS 'Code used to identify check rule type.';

COMMENT ON COLUMN camdecmpsmd.check_rule_type_code.check_rule_type_description
    IS 'Description of check rule type.';


insert into camdecmpsmd.check_rule_type_code(check_rule_type_cd, check_rule_type_description) values('Loop', 'Loop Mode');
insert into camdecmpsmd.check_rule_type_code(check_rule_type_cd, check_rule_type_description) values('Filter', 'Filter Mode');
insert into camdecmpsmd.check_rule_type_code(check_rule_type_cd, check_rule_type_description) values('Ruleset', 'Ruleset Mode');
insert into camdecmpsmd.check_rule_type_code(check_rule_type_cd, check_rule_type_description) values('Execution', 'Execution Mode');
insert into camdecmpsmd.check_rule_type_code(check_rule_type_cd, check_rule_type_description) values('Evaluation', 'Evaluation Mode');
