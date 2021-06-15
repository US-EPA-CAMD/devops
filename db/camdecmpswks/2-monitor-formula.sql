-- Table: camdecmpswks.monitor_formula

-- DROP TABLE camdecmpswks.monitor_formula;

CREATE TABLE camdecmpswks.monitor_formula
(
    mon_form_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_loc_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    parameter_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    equation_cd character varying(7) COLLATE pg_catalog."default",
    formula_identifier character varying(3) COLLATE pg_catalog."default" NOT NULL,
    begin_date date,
    begin_hour numeric(2,0),
    end_date date,
    end_hour numeric(2,0),
    formula_equation character varying(200) COLLATE pg_catalog."default",
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    CONSTRAINT pk_monitor_formula PRIMARY KEY (mon_form_id),
    CONSTRAINT fk_monitor_formula_equation_code FOREIGN KEY (equation_cd)
        REFERENCES camdecmpsmd.equation_code (equation_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_formula_monitor_location FOREIGN KEY (mon_loc_id)
        REFERENCES camdecmpswks.monitor_location (mon_loc_id) MATCH SIMPLE,
    CONSTRAINT fk_monitor_formula_parameter_code FOREIGN KEY (parameter_cd)
        REFERENCES camdecmpsmd.parameter_code (parameter_cd) MATCH SIMPLE
);

-- -- Index: idx_monitor_formula_equation_c

-- -- DROP INDEX camdecmpswks.idx_monitor_formula_equation_c;

-- CREATE INDEX idx_monitor_formula_equation_c
--     ON camdecmpswks.monitor_formula USING btree
--     (equation_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_formula_mon_loc_id

-- -- DROP INDEX camdecmpswks.idx_monitor_formula_mon_loc_id;

-- CREATE INDEX idx_monitor_formula_mon_loc_id
--     ON camdecmpswks.monitor_formula USING btree
--     (mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: monitor_formula_idx$$_15b00008

-- -- DROP INDEX camdecmpswks."monitor_formula_idx$$_15b00008";

-- CREATE INDEX "monitor_formula_idx$$_15b00008"
--     ON camdecmpswks.monitor_formula USING btree
--     (formula_identifier COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: monitor_formula_idx001

-- -- DROP INDEX camdecmpswks.monitor_formula_idx001;

-- CREATE INDEX monitor_formula_idx001
--     ON camdecmpswks.monitor_formula USING btree
--     (parameter_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;