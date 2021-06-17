-- Table: camdecmpswks.user_check_out

-- DROP TABLE camdecmpswks.user_check_out;

CREATE TABLE camdecmpswks.user_check_out
(
    facility_id integer NOT NULL,
    mon_plan_id text NOT NULL,
    checked_out_on timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    checked_out_by text NOT NULL,
    last_activity timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_user_check_out PRIMARY KEY (facility_id),
    CONSTRAINT uq_user_checkout_out UNIQUE (mon_plan_id)
);