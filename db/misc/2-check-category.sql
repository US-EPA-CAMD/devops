-- Table: camdecmpsaux.check_category

-- DROP TABLE camdecmpsaux.check_category;

CREATE TABLE camdecmpsaux.check_category
(
    check_category_cd character varying NOT NULL,
    check_category_description character varying NOT NULL,
    check_category_process_cd character varying NOT NULL,
    check_category_order integer NOT NULL,
    flex_source_id uuid NOT NULL,
    CONSTRAINT pk_check_category PRIMARY KEY (check_category_cd),
    CONSTRAINT uq_check_category_flex_source UNIQUE (flex_source_id),
    CONSTRAINT fk_check_category_process FOREIGN KEY (check_category_process_cd)
        REFERENCES camdecmpsaux.check_process (check_rule_process_cd) MATCH SIMPLE
);

COMMENT ON TABLE camdecmpsaux.check_category
    IS 'Lookup table of check rule categories.';

COMMENT ON COLUMN camdecmpsaux.check_category.check_category_cd
    IS 'Code used to identify check rule category.';

COMMENT ON COLUMN camdecmpsaux.check_category.check_category_description
    IS 'Description of check rule category.';

COMMENT ON COLUMN camdecmpsaux.check_category.check_category_process_cd
    IS 'The check rule process the check rule category is associated with.';

COMMENT ON COLUMN camdecmpsaux.check_category.check_category_order
    IS 'The priority order in which check rule categories are processed.';

COMMENT ON COLUMN camdecmpsaux.check_category.flex_source_id
    IS 'Flex Source system type guid required by Code Effects rule editor.';

-- Index: idx_check_category_process

-- DROP INDEX camdecmpsaux.idx_check_category_process;

CREATE INDEX idx_check_category_process
    ON camdecmpsaux.check_category USING btree
    (check_category_process_cd ASC NULLS LAST);

-- https://www.uuidgenerator.net/version4

-- MONITOR PLAN --
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('MONPLAN', 'Monitor Plan', 'MP', 1, 'e5a4dfb0-9645-4388-bf2a-dd5484630363');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('MONLOC', 'Monitor Location', 'MP', 2, '20b79f0f-5726-4364-a64d-2a3708af399e');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('LOCCHAR', 'Location Atribute', 'MP', 3, '4702dd1f-4f87-4049-b9c2-5f5e7c92e6a0');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('UNITSTK', 'Unit Stack Configuration', 'MP', 4, '8f1cd53d-af49-450e-b7b5-c3f624102a9a');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('PROGRAM', 'Unit Program', 'MP', 5, '5b66f97d-bad3-4bf7-b212-fab985d385e1');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('PRGPRAM', 'Unit Program Parameter', 'MP', 6, '3e6204f7-c284-4106-b6ec-6a9bec51d16f');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('METHOD', 'Method', 'MP', 7, '1ca543db-4502-4149-bffd-3e76a2c2f6a8');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('MATSMTH', 'MATS Supplemental Method', 'MP', 8, '9e9cbb58-994a-4b46-87ea-34277ff84d7a');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('COMP', 'Component', 'MP', 9, 'f7251034-f4dd-4542-8a3b-dc9c86655bb3');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('ANRANGE', 'Component Analyzer Range', 'MP', 10, 'd40f2516-33e7-40e1-afb0-0dd80ade3710');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('SYSTEM', 'System', 'MP', 11, '8f08aa4b-3ac2-44c3-9ab9-60c83353a92b');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('SYSCOMP', 'System Component', 'MP', 12, 'ca63a1f9-f4da-4385-b9bc-b74e89317144');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('FUELFLW', 'System Fuel Flow', 'MP', 13, '0d234d5b-ef96-4acf-9e14-81f67b233e82');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('FORMULA', 'Formula', 'MP', 14, 'df5c7d78-cafc-403f-af0f-33f9dd29055b');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('SPAN', 'Span', 'MP', 15, 'f8732e27-089d-48b5-adc8-d7eeb044600d');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('Default', 'Default', 'MP', 16, 'b9893ad4-4ebf-4e91-bdc5-48e2e2d43e66');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('WAF', 'Duct WAF', 'MP', 17, '4bd21e41-34fd-484e-bb3c-2d2126b7a246');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('LOAD', 'Load', 'MP', 18, 'a7c4767e-bbfe-4075-b2af-348f31a7aa08');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('QUAL', 'Qualification', 'MP', 19, 'dae3a5db-49d0-41f1-aea7-414cfc0640f5');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('QUALPCT', 'Qualification PCT', 'MP', 20, '1c2efb7e-ec58-495c-96e9-04ab4c9741c2');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('QUALLME', 'Qualification LME', 'MP', 21, 'eb588046-1ab1-4dfe-bcae-a8b7dc3b0441');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('QUALLEE', 'Qualification LEE', 'MP', 22, '37d914b6-2003-4169-8b7e-cd3a67b994f9');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('FUEL', 'Unit Fuel', 'MP', 23, '379c422e-76bd-476c-be3f-92a64e7e937b');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('CONTROL', 'Unit Control', 'MP', 24, '73861436-6245-4298-81e2-a3ea7634719d');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('CAPAC', 'Unit Capacity', 'MP', 25, 'd5f907e5-07c0-4290-873a-16836f9fd168');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('MPCOMM', 'Monitor Plan Comment', 'MP', 26, '8772686b-85e4-4791-8c95-2fc35d61ac7a');


-- QA TEST DATA --
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('QA1', 'Quality Assurance Category 1', 'QA', 1, 'a27e3049-de5a-44a7-9655-47eade9a4392');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('QA2', 'Quality Assurance Category 2', 'QA', 2, '699cdaa3-431e-45c2-8d01-d2f298844e09');

-- EMISSIONS --
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('EM1', 'Emissions Category 1', 'EM', 1, 'bc5bdc69-7f7c-4ba2-a997-b2ab0b4963b8');
insert into camdecmpsaux.check_category(check_category_cd, check_category_desc, check_category_process_cd, check_category_order, flex_source_id)
values('EM2', 'Emissions Category 2', 'EM', 2, '40692ff4-391b-48f2-8135-73fe0646e6bc');
