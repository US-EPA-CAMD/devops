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
    submitted_on timestamp NOT NULL,
    CONSTRAINT pk_check_queue PRIMARY KEY (check_queue_id),
    CONSTRAINT fk_check_queue_process FOREIGN KEY (check_queue_process_cd)
        REFERENCES camdecmpsaux.check_process (check_process_cd) MATCH SIMPLE
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

COMMENT ON COLUMN camdecmpsaux.check_queue.submitted_on
    IS 'Timestamp evaluation was submitted or queued.';

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


INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 1, 'TWCORNEL5-CE9F29AAC6764B649442259B0D7C2CF1', null, current_date - INTERVAL '40 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 1, 'TWCORNEL5-CE9F29AAC6764B649442259B0D7C2CF1', null, current_date - INTERVAL '35 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 2, 'MDC-7C15B3D1B20542C3B54DD57F03A516E5', null, current_date - INTERVAL '30 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 3, 'MDC-613AD75BF31C4B9EA561E42E38A458DE', null, current_date - INTERVAL '25 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 4, 'MDC-490E982E642244F3BC7B465C8775857E', null, current_date - INTERVAL '20 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 5, 'MDC-3E3DF340AB7D42C1A0A2C18160678FAD', null, current_date - INTERVAL '15 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 6, 'MDC-DC8A2E84AFCD4746B5CFB83CD4EA07E7', null, current_date - INTERVAL '10 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 7, 'MDC-5C8FD4C28D6747C4B4C082D489E9C289', null, current_date - INTERVAL '9 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 8, 'MDC-AB84508C61C94D6C8EF07C424BE62CF9', null, current_date - INTERVAL '8 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 9, 'MDC-3452D85B77474F68B84F657DF6D21597', null, current_date - INTERVAL '7 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 10, 'CPU1733-97DAE5341D864BC48553946E61C8D864', null, current_date - INTERVAL '6 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 11, 'MDC-843C8B44997F4E259611D958FBAB6875', null, current_date - INTERVAL '5 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 12, 'MDC-70A01A935FCD4B62AD6BB619D39AA243', null, current_date - INTERVAL '4 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 13, 'EGWITLT01-C88ABE75BA5D4C6CB5E2D1EFEC8C4F38', null, current_date - INTERVAL '3 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 14, 'MDC-70F3C86015FC4AB38F36847C0D62EEA3', null, current_date - INTERVAL '2 hours');

INSERT INTO camdecmpsaux.check_queue(check_queue_status_cd, check_queue_process_cd, facility_id, monitor_plan_id, scheduler_id, submitted_on)
VALUES ('Submitted', 'MP', 15, 'MDC-B2870B2F139347B984216CD3DA7EE776', null, current_date - INTERVAL '1 hours');