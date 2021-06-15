-- Table: camdecmpswks.monitor_system_component

-- DROP TABLE camdecmpswks.monitor_system_component;

CREATE TABLE camdecmpswks.monitor_system_component
(
    mon_sys_comp_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_sys_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    component_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    begin_hour numeric(2,0) NOT NULL,
    begin_date date NOT NULL,
    end_date date,
    end_hour numeric(2,0),
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    CONSTRAINT pk_monitor_system_component PRIMARY KEY (mon_sys_comp_id),
    CONSTRAINT fk_monitor_system_component_component FOREIGN KEY (component_id)
        REFERENCES camdecmpswks.component (component_id) MATCH SIMPLE,
    CONSTRAINT fk_monitor_system_component_monitor_system FOREIGN KEY (mon_sys_id)
        REFERENCES camdecmpswks.monitor_system (mon_sys_id) MATCH SIMPLE
);

-- -- Index: idx_mon_sys_comp_01

-- -- DROP INDEX camdecmpswks.idx_mon_sys_comp_01;

-- CREATE INDEX idx_mon_sys_comp_01
--     ON camdecmpswks.monitor_system_component USING btree
--     (mon_sys_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_system_component_

-- -- DROP INDEX camdecmpswks.idx_monitor_system_component_;

-- CREATE INDEX idx_monitor_system_component_
--     ON camdecmpswks.monitor_system_component USING btree
--     (component_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;