-- Table: camdecmpsaux.check_rule_type

-- DROP TABLE camdecmpsaux.check_rule_type;

CREATE TABLE camdecmpsaux.check_rule_type
(
    check_rule_type_cd character varying NOT NULL,
    check_rule_type_description character varying NOT NULL,
    CONSTRAINT pk_check_rule_type PRIMARY KEY (check_rule_type_cd)
);

COMMENT ON TABLE camdecmpsaux.check_rule_type
    IS 'Lookup table for Code Effects BRE rule editor modes.';

COMMENT ON COLUMN camdecmpsaux.check_rule_type.check_rule_type_cd
    IS 'Code used to identify Code Effects BRE rule editor mode.';

COMMENT ON COLUMN camdecmpsaux.check_rule_type.check_rule_type_description
    IS 'Description of Code Effects BRE rule editor mode.';


insert into camdecmpsaux.check_rule_type(check_rule_type_cd, check_rule_type_description) values('Loop', 'Loop Mode');
insert into camdecmpsaux.check_rule_type(check_rule_type_cd, check_rule_type_description) values('Filter', 'Filter Mode');
insert into camdecmpsaux.check_rule_type(check_rule_type_cd, check_rule_type_description) values('Ruleset', 'Ruleset Mode');
insert into camdecmpsaux.check_rule_type(check_rule_type_cd, check_rule_type_description) values('Execution', 'Execution Mode');
insert into camdecmpsaux.check_rule_type(check_rule_type_cd, check_rule_type_description) values('Evaluation', 'Evaluation Mode');
