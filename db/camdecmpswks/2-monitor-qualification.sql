-- Table: camdecmpswks.monitor_qualification

-- DROP TABLE camdecmpswks.monitor_qualification;

CREATE TABLE camdecmpswks.monitor_qualification
(
    mon_qual_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_loc_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    qual_type_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    begin_date date NOT NULL,
    end_date date,
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date DEFAULT aws_oracle_ext.sysdate(),
    update_date date,
    CONSTRAINT pk_monitor_qualification PRIMARY KEY (mon_qual_id),
    CONSTRAINT fk_monitor_qualification_monitor_location FOREIGN KEY (mon_loc_id)
        REFERENCES camdecmpswks.monitor_location (mon_loc_id) MATCH SIMPLE,
    CONSTRAINT fk_monitor_qualification_qual_type_code FOREIGN KEY (qual_type_cd)
        REFERENCES camdecmpsmd.qual_type_code (qual_type_cd) MATCH SIMPLE
);

-- Index: idx_monitor_qualification_mon_loc_id

-- DROP INDEX camdecmpswks.idx_monitor_qualification_mon_loc_id;

CREATE INDEX idx_monitor_qualification_mon_loc_id
    ON camdecmpswks.monitor_qualification USING btree
    (mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_monitor_qualification_qual_type_cd

-- DROP INDEX camdecmpswks.idx_monitor_qualification_qual_type_cd;

CREATE INDEX idx_monitor_qualification_qual_type_cd
    ON camdecmpswks.monitor_qualification USING btree
    (qual_type_cd COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;