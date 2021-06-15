CREATE OR REPLACE PROCEDURE camdecmpswks.delete_workspace_monitor_plan(
	monPlanId	text
)
LANGUAGE 'plpgsql'
AS $$
DECLARE
	unitIds 	integer[];
	monLocIds text[];
BEGIN
	SELECT ARRAY(
		SELECT unit_id
		FROM camd.unit
		JOIN camdecmps.monitor_plan
			USING (fac_id)
		WHERE mon_plan_id = monPlanId
	) INTO unitIds;

	SELECT ARRAY(
		SELECT mon_loc_id
		FROM camdecmps.monitor_plan_location
		WHERE mon_plan_id = monPlanId
	) INTO monLocIds;

	-- ANALYZER_RANGE --
	DELETE FROM camdecmpswks.analyzer_range
	WHERE analyzer_range_id IN (
		SELECT analyzer_range_id
		FROM camdecmpswks.analyzer_range
		JOIN camdecmpswks.component
			USING(component_id)
		WHERE mon_loc_id = ANY(monLocIds)
	);

	-- MONITOR_SYSTEM_COMPONENT --
	DELETE FROM camdecmpswks.monitor_system_component
	WHERE mon_sys_comp_id IN (
		SELECT mon_sys_comp_id
		FROM camdecmpswks.monitor_system_component	
		JOIN camdecmpswks.monitor_system
			USING(mon_sys_id)
		WHERE mon_loc_id = ANY(monLocIds)
	);

	-- SYSTEM_FUEL_FLOW --
	DELETE FROM camdecmpswks.system_fuel_flow
	WHERE sys_fuel_id IN (
		SELECT sys_fuel_id
		FROM camdecmpswks.system_fuel_flow	
		JOIN camdecmpswks.monitor_system
			USING(mon_sys_id)
		WHERE mon_loc_id = ANY(monLocIds)
	);

	-- COMPONENT --
	DELETE FROM camdecmpswks.component
	WHERE mon_loc_id = ANY(monLocIds);

	-- MATS_METHOD_DATA --
	DELETE FROM camdecmpswks.mats_method_data
	WHERE mon_loc_id = ANY(monLocIds);

	-- MONITOR_DEFAULT --
	DELETE FROM camdecmpswks.monitor_default
	WHERE mon_loc_id = ANY(monLocIds);

	-- MONITOR_FORMULA --
	DELETE FROM camdecmpswks.monitor_formula
	WHERE mon_loc_id = ANY(monLocIds);

	-- MONITOR_LOAD --
	DELETE FROM camdecmpswks.monitor_load
	WHERE mon_loc_id = ANY(monLocIds);

	-- MONITOR_LOCATION_ATTRIBUTE --
	DELETE FROM camdecmpswks.monitor_location_attribute
	WHERE mon_loc_id = ANY(monLocIds);

	-- MONITOR_METHOD --
	DELETE FROM camdecmpswks.monitor_method
	WHERE mon_loc_id = ANY(monLocIds);

	-- MONITOR_SPAN --
	DELETE FROM camdecmpswks.monitor_span
	WHERE mon_loc_id = ANY(monLocIds);

	-- MONITOR_SYSTEM --
	DELETE FROM camdecmpswks.monitor_system
	WHERE mon_loc_id = ANY(monLocIds);

	-- RECT_DUCT_WAF --
	DELETE FROM camdecmpswks.rect_duct_waf
	WHERE mon_loc_id = ANY(monLocIds);

	-- MONITOR_PLAN_LOCATION --
	DELETE FROM camdecmpswks.monitor_plan_location
	WHERE mon_plan_id = monPlanId;

	-- MONITOR_LOCATION --
	DELETE FROM camdecmpswks.monitor_location
	WHERE mon_loc_id = ANY(monLocIds);

	-- UNIT_CAPACITY --
	DELETE FROM camdecmpswks.unit_capacity
	WHERE unit_id = ANY (unitIds);

	-- UNIT_CONTROL --
	DELETE FROM camdecmpswks.unit_control
	WHERE unit_id = ANY (unitIds);

	-- UNIT_FUEL --
	DELETE FROM camdecmpswks.unit_fuel
	WHERE unit_id = ANY (unitIds);

	-- UNIT_STACK_CONFIGURATION --	
	DELETE FROM camdecmpswks.unit_stack_configuration
	WHERE unit_id = ANY (unitIds);

	-- STACK_PIPES --
	DELETE FROM camdecmpswks.stack_pipe
	WHERE stack_pipe_id IN (
		SELECT stack_pipe_id 
		FROM camdecmpswks.stack_pipe	
		JOIN camdecmpswks.monitor_plan
			USING (fac_id)
		WHERE mon_plan_id = monPlanId
	);

	-- MONITOR_PLAN --
	DELETE FROM camdecmpswks.monitor_plan
	WHERE mon_plan_id = monPlanId;

END;
$$