-- Table: camdecmpswks.mats_method_data

-- DROP TABLE camdecmpswks.mats_method_data;

CREATE TABLE camdecmpswks.mats_method_data
(
    mats_method_data_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_loc_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mats_method_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    mats_method_parameter_cd character varying(7) COLLATE pg_catalog."default" NOT NULL,
    begin_date date NOT NULL,
    begin_hour numeric(2,0) NOT NULL,
    end_date date,
    end_hour numeric(2,0),
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date,
    update_date date,
    CONSTRAINT pk_mats_method_data PRIMARY KEY (mats_method_data_id),
    CONSTRAINT fk_mats_method_data_mats_method_code FOREIGN KEY (mats_method_cd)
        REFERENCES camdecmpsmd.mats_method_code (mats_method_cd) MATCH SIMPLE,
    CONSTRAINT fk_mats_method_data_monitor_location FOREIGN KEY (mon_loc_id)
        REFERENCES camdecmpswks.monitor_location (mon_loc_id) MATCH SIMPLE,
    CONSTRAINT fk_mats_method_data_mats_method_parameter_code FOREIGN KEY (mats_method_parameter_cd)
        REFERENCES camdecmpsmd.mats_method_parameter_code (mats_method_parameter_cd) MATCH SIMPLE
);

-- -- Index: mats_method_data_method_cd

-- -- DROP INDEX camdecmpswks.mats_method_data_method_cd;

-- CREATE INDEX mats_method_data_method_cd
--     ON camdecmpswks.mats_method_data USING btree
--     (mats_method_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: mats_method_data_mon_loc_id

-- -- DROP INDEX camdecmpswks.mats_method_data_mon_loc_id;

-- CREATE INDEX mats_method_data_mon_loc_id
--     ON camdecmpswks.mats_method_data USING btree
--     (mon_loc_id COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;
-- -- Index: mats_method_data_param_cd

-- -- DROP INDEX camdecmpswks.mats_method_data_param_cd;

-- CREATE INDEX mats_method_data_param_cd
--     ON camdecmpswks.mats_method_data USING btree
--     (mats_method_parameter_cd COLLATE pg_catalog."default" ASC NULLS LAST)
--     TABLESPACE pg_default;