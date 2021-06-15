CREATE OR REPLACE PROCEDURE camdecmps.get_initial_values(
	monPlanID text,
	defaultEvaluationEndDate date,
	INOUT evaluationEndDate date,
	INOUT maximumFutureDate date,
	INOUT result character,
	INOUT errorMessage text
)
LANGUAGE 'plpgsql'
AS $$
DECLARE
    errMsg text;
	errState text;
    errContext text;
	firstMethodDatePlusOneYear date;
	nowPlusOneYear date := CURRENT_DATE + INTERVAL '1 year';
BEGIN
	-- Earliest Method Begin Date Plus One Year
	SELECT MIN(mth.begin_date) + INTERVAL '1 year'
	INTO firstMethodDatePlusOneYear
	FROM camdecmps.monitor_plan_location mpl
	JOIN camdecmps.monitor_method mth
		ON mth.mon_loc_id = mpl.mon_loc_id
	WHERE mpl.mon_plan_id = monPlanID;

	-- Determine Evaluation End Date
	IF 	(firstMethodDatePlusOneYear IS NULL) OR
		(defaultEvaluationEndDate >= firstMethodDatePlusOneYear)
	THEN
		evaluationEndDate := defaultEvaluationEndDate;
	ELSE
		evaluationEndDate := firstMethodDatePlusOneYear;
	END IF;

	-- Determine Maximum Future Date
	IF 	(firstMethodDatePlusOneYear IS NULL) OR
		(nowPlusOneYear >= firstMethodDatePlusOneYear)
	THEN
		maximumFutureDate := nowPlusOneYear;
	ELSE
		maximumFutureDate := firstMethodDatePlusOneYear;
	END IF;

	result := 'T';
	errorMessage := '';

	EXCEPTION WHEN OTHERS THEN
    	GET STACKED DIAGNOSTICS
            errState   = RETURNED_SQLSTATE,
            errMsg = MESSAGE_TEXT,
            errContext = PG_EXCEPTION_CONTEXT;
		errorMessage := 'SQL State: ' || errState || '; Message: ' || errMsg || '; Context: ' || errContext;
		result := 'F';
END;
$$
