-- Table: camdecmpsmd.check_rule_category_code

-- DROP TABLE camdecmpsmd.check_rule_category_code;

CREATE TABLE camdecmpsmd.check_rule_category_code
(
    check_rule_category_cd character varying(10) COLLATE pg_catalog."default" NOT NULL,
    check_rule_category_description character varying(1000) COLLATE pg_catalog."default" NOT NULL,
    check_rule_category_process_cd character varying(2) COLLATE pg_catalog."default" NOT NULL,
    check_rule_category_order NUMERIC NOT NULL,
    CONSTRAINT pk_check_rule_category_code PRIMARY KEY (check_rule_category_cd),
    CONSTRAINT fk_check_rule_category_process_code FOREIGN KEY (check_rule_category_process_cd)
        REFERENCES camdecmpsmd.check_rule_process_code (check_rule_process_cd) MATCH SIMPLE
)

TABLESPACE pg_default;

COMMENT ON TABLE camdecmpsmd.check_rule_category_code
    IS 'Lookup table of check rule categories.';

COMMENT ON COLUMN camdecmpsmd.check_rule_category_code.check_rule_category_cd
    IS 'Code used to identify check rule category.';

COMMENT ON COLUMN camdecmpsmd.check_rule_category_code.check_rule_category_description
    IS 'Description of check rule category.';

COMMENT ON COLUMN camdecmpsmd.check_rule_category_code.check_rule_category_process_cd
    IS 'The check rule process the check rule category is associated with.';

COMMENT ON COLUMN camdecmpsmd.check_rule_category_code.check_rule_category_order
    IS 'The priority order in which check rule categories are processed.';

-- Index: idx_check_rule_category_process_code

-- DROP INDEX camdecmpsmd.idx_check_rule_category_process_code;

CREATE INDEX idx_check_rule_category_process_code
    ON camdecmpsmd.check_rule_category_code USING btree
    (check_rule_category_process_cd COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;


insert into camdecmpsmd.check_rule_category_code(check_rule_category_cd, check_rule_category_description, check_rule_category_process_cd, check_rule_category_order)
values('MONPLAN', 'Monitor Plan', 'MP', 1);
insert into camdecmpsmd.check_rule_category_code(check_rule_category_cd, check_rule_category_description, check_rule_category_process_cd, check_rule_category_order)
values('MONLOC', 'Monitor Location', 'MP', 2);
insert into camdecmpsmd.check_rule_category_code(check_rule_category_cd, check_rule_category_description, check_rule_category_process_cd, check_rule_category_order)
values('LOCCHAR', 'Location Atribute', 'MP', 3);
insert into camdecmpsmd.check_rule_category_code(check_rule_category_cd, check_rule_category_description, check_rule_category_process_cd, check_rule_category_order)
values('UNITSTK', 'Unit Stack Configuraiton', 'MP', 4);
insert into camdecmpsmd.check_rule_category_code(check_rule_category_cd, check_rule_category_description, check_rule_category_process_cd, check_rule_category_order)
values('CAPAC', 'Unit Capacity', 'MP', 25);

insert into camdecmpsmd.check_rule_category_code(check_rule_category_cd, check_rule_category_description, check_rule_category_process_cd, check_rule_category_order)
values('QA1', 'Quality Assurance Category 1', 'QA', 1);
insert into camdecmpsmd.check_rule_category_code(check_rule_category_cd, check_rule_category_description, check_rule_category_process_cd, check_rule_category_order)
values('QA2', 'Quality Assurance Category 2', 'QA', 2);

insert into camdecmpsmd.check_rule_category_code(check_rule_category_cd, check_rule_category_description, check_rule_category_process_cd, check_rule_category_order)
values('EM1', 'Emissions Category 1', 'EM', 1);
insert into camdecmpsmd.check_rule_category_code(check_rule_category_cd, check_rule_category_description, check_rule_category_process_cd, check_rule_category_order)
values('EM2', 'Emissions Category 2', 'EM', 2);