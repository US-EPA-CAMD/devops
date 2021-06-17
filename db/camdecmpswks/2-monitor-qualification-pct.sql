-- Table: camdecmpswks.monitor_qualification_pct

-- DROP TABLE camdecmpswks.monitor_qualification_pct;

CREATE TABLE camdecmpswks.monitor_qualification_pct
(
    mon_pct_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_qual_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    qual_year numeric(4,0) NOT NULL,
    yr1_qual_data_type_cd character varying(7) COLLATE pg_catalog."default",
    yr1_qual_data_year numeric(4,0),
    yr1_pct_value numeric(5,1),
    yr2_qual_data_type_cd character varying(7) COLLATE pg_catalog."default",
    yr2_qual_data_year numeric(4,0),
    yr2_pct_value numeric(5,1),
    yr3_qual_data_type_cd character varying(7) COLLATE pg_catalog."default",
    yr3_qual_data_year numeric(4,0),
    yr3_pct_value numeric(5,1),
    avg_pct_value numeric(5,1),
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date DEFAULT aws_oracle_ext.sysdate(),
    update_date date,
    CONSTRAINT pk_monitor_qualification_pct PRIMARY KEY (mon_pct_id),
    CONSTRAINT fk_monitor_qualification_pct_monitor_qualification FOREIGN KEY (mon_qual_id)
        REFERENCES camdecmpswks.monitor_qualification (mon_qual_id) MATCH SIMPLE,
    CONSTRAINT fk_monitor_qualification_pct_qual_data_type_code_yr1 FOREIGN KEY (yr1_qual_data_type_cd)
        REFERENCES camdecmpsmd.qual_data_type_code (qual_data_type_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_qualification_pct_qual_data_type_code_yr2 FOREIGN KEY (yr2_qual_data_type_cd)
        REFERENCES camdecmpsmd.qual_data_type_code (qual_data_type_cd) MATCH SIMPLE,
    CONSTRAINT fk_monitor_qualification_pct_qual_data_type_code_yr3 FOREIGN KEY (yr3_qual_data_type_cd)
        REFERENCES camdecmpsmd.qual_data_type_code (qual_data_type_cd) MATCH SIMPLE
);

-- Index: idx_monitor_qualification_pct_mon_qual_id

-- DROP INDEX camdecmpswks.idx_monitor_qualification_pct_mon_qual_id;

CREATE INDEX idx_monitor_qualification_pct_mon_qual_id
    ON camdecmpswks.monitor_qualification_pct USING btree
    (mon_qual_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_monitor_qualification_pct_yr1_qual_data_type_cd

-- DROP INDEX camdecmpswks.idx_monitor_qualification_pct_yr1_qual_data_type_cd;

CREATE INDEX idx_monitor_qualification_pct_yr1_qual_data_type_cd
    ON camdecmpswks.monitor_qualification_pct USING btree
    (yr1_qual_data_type_cd COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_monitor_qualification_pct_yr2_qual_data_type_cd

-- DROP INDEX camdecmpswks.idx_monitor_qualification_pct_yr2_qual_data_type_cd;

CREATE INDEX idx_monitor_qualification_pct_yr2_qual_data_type_cd
    ON camdecmpswks.monitor_qualification_pct USING btree
    (yr2_qual_data_type_cd COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_monitor_qualification_pct_yr3_qual_data_type_cd

-- DROP INDEX camdecmpswks.idx_monitor_qualification_pct_yr3_qual_data_type_cd;

CREATE INDEX idx_monitor_qualification_pct_yr3_qual_data_type_cd
    ON camdecmpswks.monitor_qualification_pct USING btree
    (yr3_qual_data_type_cd COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;