-- Table: camdecmpswks.monitor_span

-- DROP TABLE camdecmpswks.monitor_span;

CREATE TABLE camdecmpswks.monitor_span
(
    span_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_loc_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mpc_value numeric(6,1),
    mec_value numeric(6,1),
    mpf_value numeric(10,0),
    max_low_range numeric(6,1),
    span_value numeric(13,3),
    full_scale_range numeric(13,3),
    begin_date date NOT NULL,
    begin_hour numeric(2,0) NOT NULL,
    end_date date,
    end_hour numeric(2,0),
    default_high_range numeric(5,0),
    flow_span_value numeric(10,0),
    flow_full_scale_range numeric(10,0),
    component_type_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    span_scale_cd character varying(7) COLLATE pg_catalog."default",
    span_method_cd character varying(7) COLLATE pg_catalog."default",
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    span_uom_cd character varying(7) COLLATE pg_catalog."default",
    CONSTRAINT pk_monitor_span PRIMARY KEY (span_id),
    CONSTRAINT fk_monitor_span_component_type_code FOREIGN KEY (component_type_cd)
        REFERENCES camdecmpsmd.component_type_code (component_type_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_span_monitor_location FOREIGN KEY (mon_loc_id)
        REFERENCES camdecmpswks.monitor_location (mon_loc_id) MATCH SIMPLE,
    CONSTRAINT fk_monitor_span_span_method_code FOREIGN KEY (span_method_cd)
        REFERENCES camdecmpsmd.span_method_code (span_method_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_span_span_scale_code FOREIGN KEY (span_scale_cd)
        REFERENCES camdecmpsmd.span_scale_code (span_scale_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_span_units_of_measure_code FOREIGN KEY (span_uom_cd)
        REFERENCES camdecmpsmd.units_of_measure_code (uom_cd) MATCH SIMPLE
);

-- -- Index: idx_monitor_span_component

-- -- DROP INDEX camdecmpswks.idx_monitor_span_component;

-- CREATE INDEX idx_monitor_span_component
--     ON camdecmpswks.monitor_span USING btree
--     (component_type_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_span_mon_loc_id

-- -- DROP INDEX camdecmpswks.idx_monitor_span_mon_loc_id;

-- CREATE INDEX idx_monitor_span_mon_loc_id
--     ON camdecmpswks.monitor_span USING btree
--     (mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_span_span_metho

-- -- DROP INDEX camdecmpswks.idx_monitor_span_span_metho;

-- CREATE INDEX idx_monitor_span_span_metho
--     ON camdecmpswks.monitor_span USING btree
--     (span_method_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_span_span_scale

-- -- DROP INDEX camdecmpswks.idx_monitor_span_span_scale;

-- CREATE INDEX idx_monitor_span_span_scale
--     ON camdecmpswks.monitor_span USING btree
--     (span_scale_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_span_span_uom_c

-- -- DROP INDEX camdecmpswks.idx_monitor_span_span_uom_c;

-- CREATE INDEX idx_monitor_span_span_uom_c
--     ON camdecmpswks.monitor_span USING btree
--     (span_uom_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;