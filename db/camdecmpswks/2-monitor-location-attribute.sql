-- Table: camdecmpswks.monitor_location_attribute

-- DROP TABLE camdecmpswks.monitor_location_attribute;

CREATE TABLE camdecmpswks.monitor_location_attribute
(
    mon_loc_attrib_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_loc_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    grd_elevation numeric(5,0),
    duct_ind numeric(38,0),
    bypass_ind numeric(38,0),
    cross_area_flow numeric(4,0),
    cross_area_exit numeric(4,0),
    begin_date date NOT NULL,
    end_date date,
    stack_height numeric(4,0),
    shape_cd character varying(7) COLLATE pg_catalog."default",
    material_cd character varying(7) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    userid character varying(8) COLLATE pg_catalog."default",
    CONSTRAINT pk_monitor_location_attribute PRIMARY KEY (mon_loc_attrib_id),
    CONSTRAINT fk_monitor_location_attribute_material_code FOREIGN KEY (material_cd)
        REFERENCES camdecmpsmd.material_code (material_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_location_attribute_monitor_location FOREIGN KEY (mon_loc_id)
        REFERENCES camdecmpswks.monitor_location (mon_loc_id) MATCH SIMPLE,
    CONSTRAINT fk_monitor_location_attribute_shape_code FOREIGN KEY (shape_cd)
        REFERENCES camdecmpsmd.shape_code (shape_cd) MATCH SIMPLE
);

-- -- Index: idx_monitor_locatio_material_c

-- -- DROP INDEX camdecmpswks.idx_monitor_locatio_material_c;

-- CREATE INDEX idx_monitor_locatio_material_c
--     ON camdecmpswks.monitor_location_attribute USING btree
--     (material_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_locatio_mon_loc_id

-- -- DROP INDEX camdecmpswks.idx_monitor_locatio_mon_loc_id;

-- CREATE INDEX idx_monitor_locatio_mon_loc_id
--     ON camdecmpswks.monitor_location_attribute USING btree
--     (mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_monitor_locatio_shape_cd

-- -- DROP INDEX camdecmpswks.idx_monitor_locatio_shape_cd;

-- CREATE INDEX idx_monitor_locatio_shape_cd
--     ON camdecmpswks.monitor_location_attribute USING btree
--     (shape_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: monitor_locatio_idx$$_15b0000b

-- -- DROP INDEX camdecmpswks."monitor_locatio_idx$$_15b0000b";

-- CREATE INDEX "monitor_locatio_idx$$_15b0000b"
--     ON camdecmpswks.monitor_location_attribute USING btree
--     (begin_date ASC NULLS LAST)
--     TABLESPACE pg_default;