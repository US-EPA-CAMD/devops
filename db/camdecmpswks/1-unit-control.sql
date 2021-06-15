-- Table: camdecmpswks.unit_control

-- DROP TABLE camdecmpswks.unit_control;

CREATE TABLE camdecmpswks.unit_control
(
    ctl_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    unit_id numeric(38,0) NOT NULL,
    control_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    ce_param character varying(7) COLLATE pg_catalog."default" NOT NULL,
    install_date date,
    opt_date date,
    orig_cd character varying(1) COLLATE pg_catalog."default",
    seas_cd character varying(1) COLLATE pg_catalog."default",
    retire_date date,
    indicator_cd character varying(7) COLLATE pg_catalog."default",
    userid character varying(8) COLLATE pg_catalog."default" NOT NULL,
    add_date date NOT NULL,
    update_date date,
    CONSTRAINT pk_unit_control PRIMARY KEY (ctl_id),
    CONSTRAINT fk_unit_control_control_equip_param_code FOREIGN KEY (ce_param)
        REFERENCES camdecmpsmd.control_equip_param_code (control_equip_param_cd) MATCH SIMPLE,
    CONSTRAINT fk_unit_control_fuel_indicator_code FOREIGN KEY (indicator_cd)
        REFERENCES camdecmpsmd.fuel_indicator_code (fuel_indicator_cd) MATCH SIMPLE,
    CONSTRAINT fk_unit_control_unit FOREIGN KEY (unit_id)
        REFERENCES camd.unit (unit_id) MATCH SIMPLE
);

-- -- Index: idx_unit_control_ce_param

-- -- DROP INDEX camdecmpswks.idx_unit_control_ce_param;

-- CREATE INDEX idx_unit_control_ce_param
--     ON camdecmpswks.unit_control USING btree
--     (ce_param COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_unit_control_indicator_cd

-- -- DROP INDEX camdecmpswks.idx_unit_control_indicator_cd;

-- CREATE INDEX idx_unit_control_indicator_cd
--     ON camdecmpswks.unit_control USING btree
--     (indicator_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: idx_unit_control_unit

-- -- DROP INDEX camdecmpswks.idx_unit_control_unit;

-- CREATE INDEX idx_unit_control_unit
--     ON camdecmpswks.unit_control USING btree
--     (unit_id ASC NULLS LAST)
--     TABLESPACE pg_default;