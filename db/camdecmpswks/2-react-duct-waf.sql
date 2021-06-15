-- Table: camdecmpswks.rect_duct_waf

-- DROP TABLE camdecmpswks.rect_duct_waf;

CREATE TABLE camdecmpswks.rect_duct_waf
(
    rect_duct_waf_data_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_loc_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    waf_determined_date date,
    waf_effective_date date NOT NULL,
    waf_effective_hour numeric(2,0) NOT NULL,
    waf_method_cd character varying(7) COLLATE pg_catalog."default",
    waf_value numeric(6,4) NOT NULL,
    num_test_runs numeric(2,0),
    num_traverse_points_waf numeric(2,0),
    num_test_ports numeric(2,0),
    num_traverse_points_ref numeric(2,0),
    duct_width numeric(5,1),
    duct_depth numeric(5,1),
    end_date date,
    end_hour numeric(2,0),
    add_date date,
    update_date date,
    userid character varying(8) COLLATE pg_catalog."default",
    CONSTRAINT pk_rect_duct_waf PRIMARY KEY (rect_duct_waf_data_id),
    CONSTRAINT fk_rect_duct_waf_monitor_location FOREIGN KEY (mon_loc_id)
        REFERENCES camdecmpswks.monitor_location (mon_loc_id) MATCH SIMPLE,
    CONSTRAINT fk_rect_duct_waf_waf_method_code FOREIGN KEY (waf_method_cd)
        REFERENCES camdecmpsmd.waf_method_code (waf_method_cd) MATCH SIMPLE
);

-- -- Index: idx_rect_duct_waf_mon_loc_id

-- -- DROP INDEX camdecmpswks.idx_rect_duct_waf_mon_loc_id;

-- CREATE INDEX idx_rect_duct_waf_mon_loc_id
--     ON camdecmpswks.rect_duct_waf USING btree
--     (mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_rect_duct_waf_waf_method

-- -- DROP INDEX camdecmpswks.idx_rect_duct_waf_waf_method;

-- CREATE INDEX idx_rect_duct_waf_waf_method
--     ON camdecmpswks.rect_duct_waf USING btree
--     (waf_method_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: rect_duct_waf_idx$$_15f60009

-- -- DROP INDEX camdecmpswks."rect_duct_waf_idx$$_15f60009";

-- CREATE INDEX "rect_duct_waf_idx$$_15f60009"
--     ON camdecmpswks.rect_duct_waf USING btree
--     (waf_effective_date ASC NULLS LAST, waf_effective_hour ASC NULLS LAST)
--     TABLESPACE pg_default;