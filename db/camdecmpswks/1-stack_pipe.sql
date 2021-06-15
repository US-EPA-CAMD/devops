-- Table: camdecmpswks.stack_pipe

-- DROP TABLE camdecmpswks.stack_pipe;

CREATE TABLE camdecmpswks.stack_pipe
(
    stack_pipe_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    fac_id numeric(38,0) NOT NULL,
    stack_name character varying(6) COLLATE pg_catalog."default" NOT NULL,
    active_date date NOT NULL,
    retire_date date,
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    CONSTRAINT pk_stack_pipe PRIMARY KEY (stack_pipe_id),
    CONSTRAINT fk_stack_pipe_plant FOREIGN KEY (fac_id)
        REFERENCES camd.plant (fac_id) MATCH SIMPLE
);

-- -- Index: idx_stack_pipe_fac

-- -- DROP INDEX camdecmpswks.idx_stack_pipe_fac;

-- CREATE INDEX idx_stack_pipe_fac
--     ON camdecmpswks.stack_pipe USING btree
--     (fac_id ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_stack_pipe_fac_name

-- -- DROP INDEX camdecmpswks.idx_stack_pipe_fac_name;

-- CREATE INDEX idx_stack_pipe_fac_name
--     ON camdecmpswks.stack_pipe USING btree
--     (fac_id ASC NULLS LAST, stack_name COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
