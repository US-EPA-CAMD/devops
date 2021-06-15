-- Table: camdecmpswks.monitor_location

-- DROP TABLE camdecmpswks.monitor_location;

CREATE TABLE camdecmpswks.monitor_location
(
    mon_loc_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    stack_pipe_id character varying(45) COLLATE pg_catalog."default",
    unit_id numeric(38,0),
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    CONSTRAINT pk_monitor_location PRIMARY KEY (mon_loc_id),
    CONSTRAINT fk_monitor_location_stack_pipe FOREIGN KEY (stack_pipe_id)
        REFERENCES camdecmpswks.stack_pipe (stack_pipe_id) MATCH SIMPLE,
    CONSTRAINT fk_monitor_location_unit FOREIGN KEY (unit_id)
        REFERENCES camd.unit (unit_id) MATCH SIMPLE
);

-- -- Index: idx_monitor_location_stp

-- -- DROP INDEX camdecmpswks.idx_monitor_location_stp;

-- CREATE INDEX idx_monitor_location_stp
--     ON camdecmpswks.monitor_location USING btree
--     (stack_pipe_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_location_unt

-- -- DROP INDEX camdecmpswks.idx_monitor_location_unt;

-- CREATE INDEX idx_monitor_location_unt
--     ON camdecmpswks.monitor_location USING btree
--     (unit_id ASC NULLS LAST)
--     TABLESPACE pg_default;