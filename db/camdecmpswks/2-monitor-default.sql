-- Table: camdecmpswks.monitor_default

-- DROP TABLE camdecmpswks.monitor_default;

CREATE TABLE camdecmpswks.monitor_default
(
    mondef_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_loc_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    parameter_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    begin_date date NOT NULL,
    begin_hour numeric(2,0) NOT NULL,
    end_date date,
    end_hour numeric(2,0),
    operating_condition_cd character varying(7) COLLATE pg_catalog."default",
    default_value numeric(15,4) NOT NULL,
    default_purpose_cd character varying(7) COLLATE pg_catalog."default",
    default_source_cd character varying(7) COLLATE pg_catalog."default",
    fuel_cd character varying(7) COLLATE pg_catalog."default",
    group_id character varying(10) COLLATE pg_catalog."default",
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    default_uom_cd character varying(7) COLLATE pg_catalog."default",
    CONSTRAINT pk_monitor_default PRIMARY KEY (mondef_id),
    CONSTRAINT fk_monitor_default_default_purpose_code FOREIGN KEY (default_purpose_cd)
        REFERENCES camdecmpsmd.default_purpose_code (default_purpose_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_default_default_source_code FOREIGN KEY (default_source_cd)
        REFERENCES camdecmpsmd.default_source_code (default_source_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_default_fuel_code FOREIGN KEY (fuel_cd)
        REFERENCES camdecmpsmd.fuel_code (fuel_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_default_monitor_location FOREIGN KEY (mon_loc_id)
        REFERENCES camdecmpswks.monitor_location (mon_loc_id) MATCH SIMPLE,
    CONSTRAINT fk_monitor_default_operating_condition_code FOREIGN KEY (operating_condition_cd)
        REFERENCES camdecmpsmd.operating_condition_code (operating_condition_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_default_parameter_code FOREIGN KEY (parameter_cd)
        REFERENCES camdecmpsmd.parameter_code (parameter_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_default_units_of_measure_code FOREIGN KEY (default_uom_cd)
        REFERENCES camdecmpsmd.units_of_measure_code (uom_cd) MATCH SIMPLE
);

-- -- Index: idx_monitor_default_default_pu

-- -- DROP INDEX camdecmpswks.idx_monitor_default_default_pu;

-- CREATE INDEX idx_monitor_default_default_pu
--     ON camdecmpswks.monitor_default USING btree
--     (default_purpose_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_default_default_so

-- -- DROP INDEX camdecmpswks.idx_monitor_default_default_so;

-- CREATE INDEX idx_monitor_default_default_so
--     ON camdecmpswks.monitor_default USING btree
--     (default_source_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_default_default_uo

-- -- DROP INDEX camdecmpswks.idx_monitor_default_default_uo;

-- CREATE INDEX idx_monitor_default_default_uo
--     ON camdecmpswks.monitor_default USING btree
--     (default_uom_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_default_fuel_cd

-- -- DROP INDEX camdecmpswks.idx_monitor_default_fuel_cd;

-- CREATE INDEX idx_monitor_default_fuel_cd
--     ON camdecmpswks.monitor_default USING btree
--     (fuel_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_default_loc_prp

-- -- DROP INDEX camdecmpswks.idx_monitor_default_loc_prp;

-- CREATE INDEX idx_monitor_default_loc_prp
--     ON camdecmpswks.monitor_default USING btree
--     (mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST, default_purpose_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_default_operating

-- -- DROP INDEX camdecmpswks.idx_monitor_default_operating;

-- CREATE INDEX idx_monitor_default_operating
--     ON camdecmpswks.monitor_default USING btree
--     (operating_condition_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: monitor_default_idx$$_15b00006

-- -- DROP INDEX camdecmpswks."monitor_default_idx$$_15b00006";

-- CREATE INDEX "monitor_default_idx$$_15b00006"
--     ON camdecmpswks.monitor_default USING btree
--     (begin_date ASC NULLS LAST, begin_hour ASC NULLS LAST, parameter_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: monitor_default_idx001

-- -- DROP INDEX camdecmpswks.monitor_default_idx001;

-- CREATE INDEX monitor_default_idx001
--     ON camdecmpswks.monitor_default USING btree
--     (parameter_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;