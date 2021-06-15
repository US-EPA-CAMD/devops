-- Table: camdecmpswks.monitor_system

-- DROP TABLE camdecmpswks.monitor_system;

CREATE TABLE camdecmpswks.monitor_system
(
    mon_sys_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_loc_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    system_identifier character varying(3) COLLATE pg_catalog."default" NOT NULL,
    sys_type_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    begin_date date,
    begin_hour numeric(2,0),
    end_date date,
    end_hour numeric(2,0),
    sys_designation_cd character varying(7) COLLATE pg_catalog."default",
    fuel_cd character varying(7) COLLATE pg_catalog."default",
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    CONSTRAINT pk_monitor_system PRIMARY KEY (mon_sys_id),
    CONSTRAINT fk_monitor_system_fuel_code FOREIGN KEY (fuel_cd)
        REFERENCES camdecmpsmd.fuel_code (fuel_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_system_monitor_location FOREIGN KEY (mon_loc_id)
        REFERENCES camdecmpswks.monitor_location (mon_loc_id) MATCH SIMPLE,
    CONSTRAINT fk_monitor_system_system_designation_code FOREIGN KEY (sys_designation_cd)
        REFERENCES camdecmpsmd.system_designation_code (sys_designation_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_system_system_type_code FOREIGN KEY (sys_type_cd)
        REFERENCES camdecmpsmd.system_type_code (sys_type_cd) MATCH SIMPLE
);

-- -- Index: idx_monitor_system_fuel_cd

-- -- DROP INDEX camdecmpswks.idx_monitor_system_fuel_cd;

-- CREATE INDEX idx_monitor_system_fuel_cd
--     ON camdecmpswks.monitor_system USING btree
--     (fuel_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_system_mon_loc_id

-- -- DROP INDEX camdecmpswks.idx_monitor_system_mon_loc_id;

-- CREATE INDEX idx_monitor_system_mon_loc_id
--     ON camdecmpswks.monitor_system USING btree
--     (mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_system_sys_design

-- -- DROP INDEX camdecmpswks.idx_monitor_system_sys_design;

-- CREATE INDEX idx_monitor_system_sys_design
--     ON camdecmpswks.monitor_system USING btree
--     (sys_designation_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_system_sys_type_c

-- -- DROP INDEX camdecmpswks.idx_monitor_system_sys_type_c;

-- CREATE INDEX idx_monitor_system_sys_type_c
--     ON camdecmpswks.monitor_system USING btree
--     (sys_type_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_system_uq

-- -- DROP INDEX camdecmpswks.idx_monitor_system_uq;

-- CREATE UNIQUE INDEX idx_monitor_system_uq
--     ON camdecmpswks.monitor_system USING btree
--     (mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST, mon_sys_id COLLATE pg_catalog."default" ASC NULLS LAST, system_identifier COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;