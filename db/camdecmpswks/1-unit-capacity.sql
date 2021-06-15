-- Table: camdecmpswks.unit_capacity

-- DROP TABLE camdecmpswks.unit_capacity;

CREATE TABLE camdecmpswks.unit_capacity
(
    unit_cap_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    unit_id numeric(38,0) NOT NULL,
    begin_date date,
    end_date date,
    max_hi_capacity numeric(7,1),
    userid character varying(8) COLLATE pg_catalog."default" NOT NULL,
    add_date date NOT NULL,
    update_date date,
    CONSTRAINT pk_unit_capacity PRIMARY KEY (unit_cap_id),
    CONSTRAINT fk_unit_capacity_unit FOREIGN KEY (unit_id)
        REFERENCES camd.unit (unit_id) MATCH SIMPLE
);

-- -- Index: idx_unit_capacity_unit

-- -- DROP INDEX camdecmpswks.idx_unit_capacity_unit;

-- CREATE INDEX idx_unit_capacity_unit
--     ON camdecmpswks.unit_capacity USING btree
--     (unit_id ASC NULLS LAST)
--     TABLESPACE pg_default;