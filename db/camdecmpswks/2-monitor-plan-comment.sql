-- Table: camdecmpswks.monitor_plan_comment

-- DROP TABLE camdecmpswks.monitor_plan_comment;

CREATE TABLE camdecmpswks.monitor_plan_comment
(
    mon_plan_comment_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_plan_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    mon_plan_comment character varying(4000) COLLATE pg_catalog."default" NOT NULL,
    begin_date date NOT NULL,
    end_date date,
    userid character varying(8) COLLATE pg_catalog."default",
    add_date date DEFAULT aws_oracle_ext.sysdate(),
    submission_availability_cd character varying(7) COLLATE pg_catalog."default",
    update_date date,
    CONSTRAINT pk_monitor_plan_comment PRIMARY KEY (mon_plan_comment_id),
    CONSTRAINT fk_monitor_plan_comment_monitor_plan FOREIGN KEY (mon_plan_id)
        REFERENCES camdecmpswks.monitor_plan (mon_plan_id) MATCH SIMPLE,
    CONSTRAINT fk_monitor_plan_comment_submission_availability_code FOREIGN KEY (submission_availability_cd)
        REFERENCES camdecmpsmd.submission_availability_code (submission_availability_cd) MATCH SIMPLE
);

-- Index: idx_monitor_plan_comment_mon_plan_id

-- DROP INDEX camdecmpswks.idx_monitor_plan_comment_mon_plan_id;

CREATE INDEX idx_monitor_plan_comment_mon_plan_id
    ON camdecmpswks.monitor_plan_comment USING btree
    (mon_plan_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;