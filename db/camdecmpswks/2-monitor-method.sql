-- Table: camdecmpswks.monitor_method

-- DROP TABLE camdecmpswks.monitor_method;

CREATE TABLE camdecmpswks.monitor_method
(
    mon_method_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_loc_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    parameter_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    sub_data_cd character varying(7) COLLATE pg_catalog."default",
    bypass_approach_cd character varying(7) COLLATE pg_catalog."default",
    method_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    begin_date date NOT NULL,
    begin_hour numeric(2,0) NOT NULL,
    end_date date,
    end_hour numeric(2,0),
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    CONSTRAINT pk_monitor_method PRIMARY KEY (mon_method_id),
    CONSTRAINT fk_monitor_method_bypass_approach_code FOREIGN KEY (bypass_approach_cd)
        REFERENCES camdecmpsmd.bypass_approach_code (bypass_approach_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_method_method_code FOREIGN KEY (method_cd)
        REFERENCES camdecmpsmd.method_code (method_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_method_monitor_location FOREIGN KEY (mon_loc_id)
        REFERENCES camdecmpswks.monitor_location (mon_loc_id) MATCH SIMPLE,
    CONSTRAINT fk_monitor_method_parameter_code FOREIGN KEY (parameter_cd)
        REFERENCES camdecmpsmd.parameter_code (parameter_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_method_substitute_data_code FOREIGN KEY (sub_data_cd)
        REFERENCES camdecmpsmd.substitute_data_code (sub_data_cd) MATCH SIMPLE
);

-- -- Index: idx_mm_monlocid

-- -- DROP INDEX camdecmpswks.idx_mm_monlocid;

-- CREATE INDEX idx_mm_monlocid
--     ON camdecmpswks.monitor_method USING btree
--     (mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_mm_paramcd

-- -- DROP INDEX camdecmpswks.idx_mm_paramcd;

-- CREATE INDEX idx_mm_paramcd
--     ON camdecmpswks.monitor_method USING btree
--     (parameter_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_method_bypass_app

-- -- DROP INDEX camdecmpswks.idx_monitor_method_bypass_app;

-- CREATE INDEX idx_monitor_method_bypass_app
--     ON camdecmpswks.monitor_method USING btree
--     (bypass_approach_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_method_method_cd

-- -- DROP INDEX camdecmpswks.idx_monitor_method_method_cd;

-- CREATE INDEX idx_monitor_method_method_cd
--     ON camdecmpswks.monitor_method USING btree
--     (method_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_method_sub_data_c

-- -- DROP INDEX camdecmpswks.idx_monitor_method_sub_data_c;

-- CREATE INDEX idx_monitor_method_sub_data_c
--     ON camdecmpswks.monitor_method USING btree
--     (sub_data_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: monitor_method_idx$$_15f60005

-- -- DROP INDEX camdecmpswks."monitor_method_idx$$_15f60005";

-- CREATE INDEX "monitor_method_idx$$_15f60005"
--     ON camdecmpswks.monitor_method USING btree
--     (begin_date ASC NULLS LAST, begin_hour ASC NULLS LAST, parameter_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;