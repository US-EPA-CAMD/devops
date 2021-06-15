-- Table: camdecmpswks.component

-- DROP TABLE camdecmpswks.component;

CREATE TABLE camdecmpswks.component
(
    component_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_loc_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    component_identifier character varying(3) COLLATE pg_catalog."default" NOT NULL,
    model_version character varying(15) COLLATE pg_catalog."default",
    serial_number character varying(20) COLLATE pg_catalog."default",
    manufacturer character varying(25) COLLATE pg_catalog."default",
    component_type_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    acq_cd character varying(7) COLLATE pg_catalog."default",
    basis_cd character varying(7) COLLATE pg_catalog."default",
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    hg_converter_ind numeric(1,0),
    CONSTRAINT pk_component PRIMARY KEY (component_id),
    CONSTRAINT fk_component_acquisition_method_code FOREIGN KEY (acq_cd)
        REFERENCES camdecmpsmd.acquisition_method_code (acq_cd) MATCH SIMPLE,
    CONSTRAINT fk_component_basis_code FOREIGN KEY (basis_cd)
        REFERENCES camdecmpsmd.basis_code (basis_cd) MATCH SIMPLE,
    CONSTRAINT fk_component_component_type_code FOREIGN KEY (component_type_cd)
        REFERENCES camdecmpsmd.component_type_code (component_type_cd) MATCH SIMPLE,
    CONSTRAINT fk_component_monitor_location FOREIGN KEY (mon_loc_id)
        REFERENCES camdecmpswks.monitor_location (mon_loc_id) MATCH SIMPLE
);

-- -- Index: component_idx$$_15b00009

-- -- DROP INDEX camdecmpswks."component_idx$$_15b00009";

-- CREATE INDEX "component_idx$$_15b00009"
--     ON camdecmpswks.component USING btree
--     (mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST, component_identifier COLLATE pg_catalog."default" ASC NULLS LAST, component_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_component_acq_cd

-- -- DROP INDEX camdecmpswks.idx_component_acq_cd;

-- CREATE INDEX idx_component_acq_cd
--     ON camdecmpswks.component USING btree
--     (acq_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_component_basis_cd

-- -- DROP INDEX camdecmpswks.idx_component_basis_cd;

-- CREATE INDEX idx_component_basis_cd
--     ON camdecmpswks.component USING btree
--     (basis_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_component_component

-- -- DROP INDEX camdecmpswks.idx_component_component;

-- CREATE INDEX idx_component_component
--     ON camdecmpswks.component USING btree
--     (component_type_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_component_monlocid

-- -- DROP INDEX camdecmpswks.idx_component_monlocid;

-- CREATE INDEX idx_component_monlocid
--     ON camdecmpswks.component USING btree
--     (mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;