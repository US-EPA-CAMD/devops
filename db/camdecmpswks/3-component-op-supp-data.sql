-- Table: camdecmpswks.component_op_supp_data

-- DROP TABLE camdecmpswks.component_op_supp_data;

CREATE TABLE camdecmpswks.component_op_supp_data
(
    comp_op_supp_data_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    component_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    rpt_period_id numeric(38,0) NOT NULL,
    op_supp_data_type_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    days numeric(38,0) NOT NULL,
    hours numeric(38,0) NOT NULL,
    mon_loc_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    delete_ind numeric(1,0) NOT NULL DEFAULT 0,
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    CONSTRAINT pk_component_op_supp_data PRIMARY KEY (comp_op_supp_data_id),
    CONSTRAINT fk_component_op_supp_data_component FOREIGN KEY (component_id)
        REFERENCES camdecmpswks.component (component_id) MATCH SIMPLE,
    CONSTRAINT fk_component_op_supp_data_op_supp_data_type_code FOREIGN KEY (op_supp_data_type_cd)
        REFERENCES camdecmpsmd.op_supp_data_type_code (op_supp_data_type_cd) MATCH SIMPLE,
    CONSTRAINT fk_component_op_supp_data_monitor_location FOREIGN KEY (mon_loc_id)
        REFERENCES camdecmpswks.monitor_location (mon_loc_id) MATCH SIMPLE,
    CONSTRAINT fk_component_op_supp_data_reporting_period FOREIGN KEY (rpt_period_id)
        REFERENCES camdecmpsmd.reporting_period (rpt_period_id) MATCH SIMPLE
);

-- -- Index: idx_component_op_supp_data_cmp

-- -- DROP INDEX camdecmpswks.idx_component_op_supp_data_cmp;

-- CREATE INDEX idx_component_op_supp_data_cmp
--     ON camdecmpswks.component_op_supp_data USING btree
--     (component_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_component_op_supp_data_cod

-- -- DROP INDEX camdecmpswks.idx_component_op_supp_data_cod;

-- CREATE INDEX idx_component_op_supp_data_cod
--     ON camdecmpswks.component_op_supp_data USING btree
--     (op_supp_data_type_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_component_op_supp_data_emr

-- -- DROP INDEX camdecmpswks.idx_component_op_supp_data_emr;

-- CREATE INDEX idx_component_op_supp_data_emr
--     ON camdecmpswks.component_op_supp_data USING btree
--     (rpt_period_id ASC NULLS LAST, mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_component_op_supp_data_loc

-- -- DROP INDEX camdecmpswks.idx_component_op_supp_data_loc;

-- CREATE INDEX idx_component_op_supp_data_loc
--     ON camdecmpswks.component_op_supp_data USING btree
--     (mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_component_op_supp_data_prd

-- -- DROP INDEX camdecmpswks.idx_component_op_supp_data_prd;

-- CREATE INDEX idx_component_op_supp_data_prd
--     ON camdecmpswks.component_op_supp_data USING btree
--     (rpt_period_id ASC NULLS LAST)
--     TABLESPACE pg_default;