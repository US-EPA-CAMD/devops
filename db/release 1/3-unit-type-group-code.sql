CREATE TABLE camdmd.unit_type_group_code
(
    unit_type_group_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    unit_type_group_description character varying(1000) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT pk_unit_type_group_code PRIMARY KEY (unit_type_group_cd)
);

COMMENT ON TABLE camdmd.unit_type_group_code
    IS 'Lookup table containing the groups of unit types to which unit type codes correspond.';

COMMENT ON COLUMN camdmd.unit_type_group_code.unit_type_group_cd
    IS 'Identifies the group in which the unit type is cataloged.';

COMMENT ON COLUMN camdmd.unit_type_group_code.unit_type_group_description
    IS 'Full description of the unit type group.';


-- LOAD UNIT TYPE GROUPS
INSERT INTO camdmd.unit_type_group_code(
	unit_type_group_cd, unit_type_group_description)
	VALUES ('B', 'Boilers');

INSERT INTO camdmd.unit_type_group_code(
	unit_type_group_cd, unit_type_group_description)
	VALUES ('F', 'Furnaces');

INSERT INTO camdmd.unit_type_group_code(
	unit_type_group_cd, unit_type_group_description)
	VALUES ('T', 'Turbines');

-- MODIFY UNIT_TYPE_CODE TO INCLUDE GROUP
ALTER TABLE camdmd.unit_type_code
    ADD COLUMN unit_type_group_cd character varying;

COMMENT ON COLUMN camdmd.unit_type_code.unit_type_group_cd
    IS 'Identifies the category of unit types (e.g., boiler, turbine).';


-- MODIFY UNIT_TYPE_CODE DATA TO INCLUDE GROUP
update camdmd.unit_type_code
set unit_type_group_cd = 'T'
where unit_type_cd in ('CC','CT','ICE','OT','IGC');

update camdmd.unit_type_code
set unit_type_group_cd = 'B'
where unit_type_cd not in ('CC','CT','ICE','OT','IGC');

update camdmd.unit_type_code
set unit_type_group_cd = 'F'
where unit_type_cd in ('PRH','KLN');


-- MODIFY UNIT_TYPE_CODE TO MAKE GROUP NOT NULL
ALTER TABLE camdmd.unit_type_code
    ALTER COLUMN unit_type_group_cd SET NOT NULL;


-- ADD CONSTRAINT
ALTER TABLE camdmd.unit_type_code
    ADD CONSTRAINT fk_unit_type_unit_type_group FOREIGN KEY (unit_type_group_cd)
    REFERENCES camdmd.unit_type_group_code (unit_type_group_cd) MATCH SIMPLE
