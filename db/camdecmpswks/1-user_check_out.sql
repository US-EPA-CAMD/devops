-- Table: camdecmpswks.user_check_out

-- DROP TABLE camdecmpswks.user_check_out;

CREATE TABLE camdecmpswks.user_check_out
(
    facility_id integer NOT NULL,
    mon_plan_id text NOT NULL,
    checked_out_on timestamp without time zone NOT NULL,
    checked_out_by text NOT NULL,
    expiration timestamp without time zone NOT NULL,
    CONSTRAINT pk_user_check_out PRIMARY KEY (facility_id),
    CONSTRAINT uq_user_checkout_out UNIQUE (mon_plan_id),
    CONSTRAINT ck_user_check_out_lock CHECK (expiration >= checked_out_on + INTERVAL '15 minutes')
);