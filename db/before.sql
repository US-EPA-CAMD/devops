-- ACCOUNT TYPE
ALTER TABLE IF EXISTS camdmd.account_type_code
    DROP CONSTRAINT IF EXISTS fk_account_type_account_type_group;

DROP TABLE IF EXISTS camdmd.account_type_group_code;


-- UNIT TYPE
ALTER TABLE IF EXISTS camdmd.unit_type_code
    DROP CONSTRAINT IF EXISTS fk_unit_type_unit_type_group;

ALTER TABLE IF EXISTS camdmd.unit_type_code
    DROP COLUMN IF EXISTS unit_type_group_cd;

DROP TABLE IF EXISTS camdmd.unit_type_group_code;