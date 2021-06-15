-- Table: camdecmpswks.monitor_plan_location

-- DROP TABLE camdecmpswks.monitor_plan_location;

CREATE TABLE camdecmpswks.monitor_plan_location
(
    monitor_plan_location_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_plan_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_loc_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT pk_monitor_plan_location PRIMARY KEY (monitor_plan_location_id),
    CONSTRAINT uq_monitor_plan_location UNIQUE (mon_plan_id, mon_loc_id)
);

-- -- Index: idx_mon_plan_loc_plan_loc

-- -- DROP INDEX camdecmpswks.idx_mon_plan_loc_plan_loc;

-- CREATE INDEX idx_mon_plan_loc_plan_loc
--     ON camdecmpswks.monitor_plan_location USING btree
--     (mon_plan_id COLLATE pg_catalog."default" ASC NULLS LAST, mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;