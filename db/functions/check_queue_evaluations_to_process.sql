CREATE OR REPLACE FUNCTION camdecmpsaux.check_queue_evaluations_to_process(
	schedulerid uuid,
	maxConcurrentEvals integer
)
RETURNS SETOF camdecmpsaux.check_queue
LANGUAGE 'plpgsql'
AS $$
DECLARE
	rowCount integer;
	numConcurrentEvals integer;
BEGIN
	SELECT COUNT(*) INTO numConcurrentEvals
	FROM camdecmpsaux.check_queue
	WHERE check_queue_status_cd = 'Processing'
    AND scheduler_id = schedulerId;

	IF (numConcurrentEvals >= maxConcurrentEvals) THEN
		rowCount := 0;
	ELSE
		rowCount := maxConcurrentEvals - numConcurrentEvals;
	END IF;

	WITH limited_rows as (
		SELECT check_queue_id
		FROM camdecmpsaux.check_queue
		WHERE check_queue_status_cd = 'Submitted'
		AND scheduler_id IS NULL
		ORDER BY submitted_on ASC
		LIMIT rowCount FOR UPDATE
	)
	UPDATE camdecmpsaux.check_queue as p
	SET scheduler_id = schedulerId
	FROM limited_rows as c
	WHERE p.check_queue_id = c.check_queue_id
	AND p.scheduler_id IS NULL;

	RETURN QUERY SELECT *
	FROM camdecmpsaux.check_queue
	WHERE check_queue_status_cd = 'Submitted'
	AND scheduler_id = schedulerId
	ORDER BY submitted_on ASC;
END;
$$