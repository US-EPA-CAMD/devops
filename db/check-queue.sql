-- Table: camdecmpsaux.check_queue

-- DROP TABLE camdecmpsaux.check_queue;

CREATE TABLE camdecmpsaux.check_queue
(
    check_queue_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 ),    
    check_queue_status_cd character varying(10) COLLATE pg_catalog."default" NOT NULL,    
    check_queue_process_cd character varying(10) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT pk_check_queue PRIMARY KEY (check_queue_id),
    CONSTRAINT fk_check_queue_process_cd FOREIGN KEY (check_queue_process_cd)
        REFERENCES camdecmpsmd.check_rule_process_code (check_rule_process_cd) MATCH SIMPLE
)

TABLESPACE pg_default;

COMMENT ON TABLE camdecmpsaux.check_queue
    IS 'Submissions to be processed by the Code Effects BRE evaluation processes.';

COMMENT ON COLUMN camdecmpsaux.check_queue.check_queue_id
    IS 'Identifies the check engine evaluation submission.';

COMMENT ON COLUMN camdecmpsaux.check_queue.check_queue_status_cd
    IS 'Status of the submission [Submitted, Processing, Complete, Failed].';

COMMENT ON COLUMN camdecmpsaux.check_queue.check_queue_process_cd
    IS 'Identifies the check engine evaluation process that will evaluate the submission.';

-- Index: idx_check_queue_status_code

-- DROP INDEX camdecmpsaux.idx_check_queue_status_code;

CREATE INDEX idx_check_queue_status_code
    ON camdecmpsaux.check_queue USING btree
    (check_queue_status_cd COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

-- Index: idx_check_queue_process_code

-- DROP INDEX camdecmpsaux.idx_check_queue_process_code;

CREATE INDEX idx_check_queue_process_code
    ON camdecmpsaux.check_queue USING btree
    (check_queue_process_cd COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;