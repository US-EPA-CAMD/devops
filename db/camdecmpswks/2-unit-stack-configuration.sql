-- Table: camdecmpswks.unit_stack_configuration

-- DROP TABLE camdecmpswks.unit_stack_configuration;

CREATE TABLE camdecmpswks.unit_stack_configuration
(
    config_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    unit_id numeric(38,0) NOT NULL,
    stack_pipe_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    begin_date date NOT NULL,
    end_date date,
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    CONSTRAINT pk_unit_stack_configuration PRIMARY KEY (config_id),
    CONSTRAINT fk_unit_stack_configuration_stack_pipe FOREIGN KEY (stack_pipe_id)
        REFERENCES camdecmpswks.stack_pipe (stack_pipe_id) MATCH SIMPLE,
    CONSTRAINT fk_unit_stack_configuration_unit FOREIGN KEY (unit_id)
        REFERENCES camd.unit (unit_id) MATCH SIMPLE
);

-- -- Index: idx_unit_stack_configuration_b

-- -- DROP INDEX camdecmpswks.idx_unit_stack_configuration_b;

-- CREATE INDEX idx_unit_stack_configuration_b
--     ON camdecmpswks.unit_stack_configuration USING btree
--     (stack_pipe_id COLLATE pg_catalog."default" ASC NULLS LAST, unit_id ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_unit_stack_configuration_s

-- -- DROP INDEX camdecmpswks.idx_unit_stack_configuration_s;

-- CREATE INDEX idx_unit_stack_configuration_s
--     ON camdecmpswks.unit_stack_configuration USING btree
--     (stack_pipe_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_unit_stack_configuration_u

-- -- DROP INDEX camdecmpswks.idx_unit_stack_configuration_u;

-- CREATE INDEX idx_unit_stack_configuration_u
--     ON camdecmpswks.unit_stack_configuration USING btree
--     (unit_id ASC NULLS LAST)
--     TABLESPACE pg_default;