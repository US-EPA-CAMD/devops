-- Table: camdecmpsaux.check_queue

-- DROP TABLE camdecmpsaux.check_queue;

CREATE TABLE camdecmpsaux.check_queue
(
    check_queue_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 ),
    check_queue_status_cd text NOT NULL,
    check_queue_process_cd text NOT NULL,
    facility_id integer NOT NULL,
    monitor_plan_id text,
    scheduler_id uuid,
    submitted_date date NOT NULL,
    CONSTRAINT pk_check_queue PRIMARY KEY (check_queue_id),
    CONSTRAINT fk_check_queue_process FOREIGN KEY (check_queue_process_cd)
        REFERENCES camdecmpsaux.check_rule_process (check_rule_process_cd) MATCH SIMPLE
);

COMMENT ON TABLE camdecmpsaux.check_queue
    IS 'Submissions to be processed by the Check Engine evaluation processes.';

COMMENT ON COLUMN camdecmpsaux.check_queue.check_queue_id
    IS 'Identifies the check engine evaluation submission.';

COMMENT ON COLUMN camdecmpsaux.check_queue.check_queue_status_cd
    IS 'Status of the submission [Submitted, Processing, Complete, Failed].';

COMMENT ON COLUMN camdecmpsaux.check_queue.check_queue_process_cd
    IS 'Identifies the check engine evaluation process that will evaluate the submission.';

COMMENT ON COLUMN camdecmpsaux.check_queue.facility_id
    IS 'Identifies the facility the evaluation process is associated with.';

COMMENT ON COLUMN camdecmpsaux.check_queue.monitor_plan_id
    IS 'Identifies the Monitor Plan Configuration to be evaluated.';

COMMENT ON COLUMN camdecmpsaux.check_queue.scheduler_id
    IS 'Identifies the Quartz.Net scheduler instance.';

COMMENT ON COLUMN camdecmpsaux.check_queue.submitted_date
    IS 'Date evaluation was submitted or queued.';

-- Index: idx_check_queue_status

-- DROP INDEX camdecmpsaux.idx_check_queue_status;

CREATE INDEX idx_check_queue_status
    ON camdecmpsaux.check_queue USING btree
    (check_queue_status_cd ASC NULLS LAST);

-- Index: idx_check_queue_process

-- DROP INDEX camdecmpsaux.idx_check_queue_process;

CREATE INDEX idx_check_queue_process
    ON camdecmpsaux.check_queue USING btree
    (check_queue_process_cd COLLATE pg_catalog."default" ASC NULLS LAST);