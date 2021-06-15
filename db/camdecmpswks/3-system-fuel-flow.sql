-- Table: camdecmpswks.system_fuel_flow

-- DROP TABLE camdecmpswks.system_fuel_flow;

CREATE TABLE camdecmpswks.system_fuel_flow
(
    sys_fuel_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_sys_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    max_rate numeric(9,1) NOT NULL,
    begin_date date,
    begin_hour numeric(2,0),
    end_date date,
    end_hour numeric(2,0),
    max_rate_source_cd character varying(7) COLLATE pg_catalog."default",
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    sys_fuel_uom_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT pk_system_fuel_flow PRIMARY KEY (sys_fuel_id),
    CONSTRAINT fk_system_fuel_flow_max_rate_source_code FOREIGN KEY (max_rate_source_cd)
        REFERENCES camdecmpsmd.max_rate_source_code (max_rate_source_cd) MATCH SIMPLE,
    CONSTRAINT fk_system_fuel_flow_monitor_system FOREIGN KEY (mon_sys_id)
        REFERENCES camdecmpswks.monitor_system (mon_sys_id) MATCH SIMPLE,
    CONSTRAINT fk_system_fuel_flow_units_of_measure_code FOREIGN KEY (sys_fuel_uom_cd)
        REFERENCES camdecmpsmd.units_of_measure_code (uom_cd) MATCH SIMPLE
);

-- -- Index: idx_system_fuel_flo_max_rate_s

-- -- DROP INDEX camdecmpswks.idx_system_fuel_flo_max_rate_s;

-- CREATE INDEX idx_system_fuel_flo_max_rate_s
--     ON camdecmpswks.system_fuel_flow USING btree
--     (max_rate_source_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_system_fuel_flo_mon_sys_id

-- -- DROP INDEX camdecmpswks.idx_system_fuel_flo_mon_sys_id;

-- CREATE INDEX idx_system_fuel_flo_mon_sys_id
--     ON camdecmpswks.system_fuel_flow USING btree
--     (mon_sys_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_system_fuel_flo_sys_fuel_u

-- -- DROP INDEX camdecmpswks.idx_system_fuel_flo_sys_fuel_u;

-- CREATE INDEX idx_system_fuel_flo_sys_fuel_u
--     ON camdecmpswks.system_fuel_flow USING btree
--     (sys_fuel_uom_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;