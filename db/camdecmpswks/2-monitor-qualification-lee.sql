-- Table: camdecmpswks.monitor_qualification_lee

-- DROP TABLE camdecmpswks.monitor_qualification_lee;

CREATE TABLE camdecmpswks.monitor_qualification_lee
(
    mon_qual_lee_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_qual_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    qual_test_date date NOT NULL,
    parameter_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    qual_lee_test_type_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    potential_annual_emissions numeric(6,1),
    applicable_emission_standard numeric(9,4),
    emission_standard_uom character varying(7) COLLATE pg_catalog."default",
    emission_standard_pct numeric(5,1),
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date DEFAULT aws_oracle_ext.sysdate(),
    update_date date,
    CONSTRAINT pk_monitor_qualification_lee PRIMARY KEY (mon_qual_lee_id),
    CONSTRAINT fk_monitor_qualification_lee_monitor_qualification FOREIGN KEY (mon_qual_id)
        REFERENCES camdecmpswks.monitor_qualification (mon_qual_id) MATCH SIMPLE,
    CONSTRAINT fk_monitor_qualification_lee_parameter_code FOREIGN KEY (parameter_cd)
        REFERENCES camdecmpsmd.parameter_code (parameter_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_qualification_lee_qual_test_type_code FOREIGN KEY (qual_lee_test_type_cd)
        REFERENCES camdecmpsmd.qual_lee_test_type_code (qual_lee_test_type_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_qualification_lee_units_of_measure_code FOREIGN KEY (emission_standard_uom)
        REFERENCES camdecmpsmd.units_of_measure_code (uom_cd) MATCH SIMPLE
);

-- Index: idx_monitor_qualification_lee_emission_standard_uom

-- DROP INDEX camdecmpswks.idx_monitor_qualification_lee_emission_standard_uom;

CREATE INDEX idx_monitor_qualification_lee_emission_standard_uom
    ON camdecmpswks.monitor_qualification_lee USING btree
    (emission_standard_uom COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_monitor_qualification_lee_mon_qual_id

-- DROP INDEX camdecmpswks.idx_monitor_qualification_lee_mon_qual_id;

CREATE INDEX idx_monitor_qualification_lee_mon_qual_id
    ON camdecmpswks.monitor_qualification_lee USING btree
    (mon_qual_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_monitor_qualification_lee_parameter_cd

-- DROP INDEX camdecmpswks.idx_monitor_qualification_lee_parameter_cd;

CREATE INDEX idx_monitor_qualification_lee_parameter_cd
    ON camdecmpswks.monitor_qualification_lee USING btree
    (parameter_cd COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_monitor_qualification_lee_qaul_lee_test_type_cd

-- DROP INDEX camdecmpswks.idx_monitor_qualification_lee_qaul_lee_test_type_cd;

CREATE INDEX idx_monitor_qualification_lee_qaul_lee_test_type_cd
    ON camdecmpswks.monitor_qualification_lee USING btree
    (qual_lee_test_type_cd COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;