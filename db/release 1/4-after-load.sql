--------------------------------------------------
-- PROGRAM CODE UPDATES 
--------------------------------------------------
ALTER TABLE camdmd.program_code
    ADD COLUMN emissions_ind numeric(1,0) NOT NULL DEFAULT 0;

ALTER TABLE camdmd.program_code
    ADD COLUMN allowance_ind numeric(1,0) NOT NULL DEFAULT 0;

ALTER TABLE camdmd.program_code
    ADD COLUMN compliance_ind numeric(1,0) NOT NULL DEFAULT 0;

update camdmd.program_code
set emissions_ind = 1
where prg_cd not in ('MATS');

update camdmd.program_code
set allowance_ind = 1
where prg_cd not in ('MATS', 'NHNOX', 'NSPS4T', 'RGGI', 'SIPNOX');

update camdmd.program_code
set compliance_ind = 1
where prg_cd in ('ARP', 'CSNOX', 'CSOSG1', 'CSOSG2', 'CSSO2G1', 'CSSO2G2', 'TXSO2', 'CSNOXOS');

update camdmd.program_code
set trading_end_date = '2003-05-06',
penalty_factor = 3,
first_comp_year = 1999,
comp_parameter_cd = 'NOX'
where prg_cd = 'OTC';

update camdmd.program_code
set trading_end_date = '2009-03-25',
penalty_factor = 3,
first_comp_year = 2003,
comp_parameter_cd = 'NOX'
where prg_cd = 'NBP';

update camdmd.program_code
set first_comp_year = 2009
where prg_cd = 'CAIRNOX';

update camdmd.program_code
set first_comp_year = 2010
where prg_cd = 'CAIRSO2';

--------------------------------------------------
-- FUEL TYPE CODE UPDATES 
--------------------------------------------------
update camdecmpsmd.fuel_type_code
set fuel_group_cd = 'COAL'
where fuel_type_cd in ('C', 'CRF', 'PTC');