CREATE TABLE camdmd.account_type_group_code
(
    account_type_group_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    account_type_group_description character varying(1000) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT pk_account_type_group_code PRIMARY KEY (account_type_group_cd)
)

TABLESPACE pg_default;

COMMENT ON TABLE camdmd.account_type_group_code
    IS 'Lookup table containing the groups of account types to which account type codes correspond.';

COMMENT ON COLUMN camdmd.account_type_group_code.account_type_group_cd
    IS 'Identifies the group in which the account type is cataloged.';

COMMENT ON COLUMN camdmd.account_type_group_code.account_type_group_description
    IS 'Full description of the account type group.';


-- LOAD ACCOUNT TYPE GROUPS
INSERT INTO camdmd.account_type_group_code(
	account_type_group_cd, account_type_group_description)
	VALUES ('FACLTY', 'Facility');

INSERT INTO camdmd.account_type_group_code(
	account_type_group_cd, account_type_group_description)
	VALUES ('GENERAL', 'General');

INSERT INTO camdmd.account_type_group_code(
	account_type_group_cd, account_type_group_description)
	VALUES ('OVERDF', 'Overdraft');

INSERT INTO camdmd.account_type_group_code(
	account_type_group_cd, account_type_group_description)
	VALUES ('RESERVE', 'Reserve');

INSERT INTO camdmd.account_type_group_code(
	account_type_group_cd, account_type_group_description)
	VALUES ('RETIRE', 'Surrender');

INSERT INTO camdmd.account_type_group_code(
	account_type_group_cd, account_type_group_description)
	VALUES ('SHOLD', 'State Holding');

INSERT INTO camdmd.account_type_group_code(
	account_type_group_cd, account_type_group_description)
	VALUES ('UNIT', 'Unit');


-- ADD CONSTRAINT
ALTER TABLE camdmd.account_type_code
    ADD CONSTRAINT fk_account_type_account_type_group FOREIGN KEY (account_type_group_cd)
    REFERENCES camdmd.account_type_group_code (account_type_group_cd) MATCH SIMPLE