-- Table: camdecmpswks.monitor_load

-- DROP TABLE camdecmpswks.monitor_load;

CREATE TABLE camdecmpswks.monitor_load
(
    load_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_loc_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    load_analysis_date date,
    begin_date date NOT NULL,
    begin_hour numeric(2,0) NOT NULL,
    end_date date,
    end_hour numeric(2,0),
    max_load_value numeric(6,0),
    second_normal_ind numeric(38,0),
    up_op_boundary numeric(6,0),
    low_op_boundary numeric(6,0),
    normal_level_cd character varying(7) COLLATE pg_catalog."default",
    second_level_cd character varying(7) COLLATE pg_catalog."default",
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    max_load_uom_cd character varying(7) COLLATE pg_catalog."default",
    CONSTRAINT pk_monitor_load PRIMARY KEY (load_id),
    CONSTRAINT fk_monitor_load_monitor_location FOREIGN KEY (mon_loc_id)
        REFERENCES camdecmpswks.monitor_location (mon_loc_id) MATCH SIMPLE
);

-- -- Index: idx_monitor_load_mon_loc_id

-- -- DROP INDEX camdecmpswks.idx_monitor_load_mon_loc_id;

-- CREATE INDEX idx_monitor_load_mon_loc_id
--     ON camdecmpswks.monitor_load USING btree
--     (mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;