CREATE OR REPLACE PROCEDURE camdecmpswks.copy_monitor_plan_to_workspace(
	monPlanId	text
)
LANGUAGE 'plpgsql'
AS $$
BEGIN

	IF NOT EXISTS (
		SELECT * FROM camdecmpswks.monitor_plan WHERE mon_plan_id = monPlanId
	) THEN

		-- MONITOR_PLAN --
		INSERT INTO camdecmpswks.monitor_plan(
			mon_plan_id, fac_id, config_type_cd, last_updated, updated_status_flg, needs_eval_flg, chk_session_id, userid, add_date, update_date, submission_id, submission_availability_cd, pending_status_cd, begin_rpt_period_id, end_rpt_period_id
		)
		SELECT
			mon_plan_id, fac_id, config_type_cd, last_updated, updated_status_flg, needs_eval_flg, chk_session_id, userid, add_date, update_date, submission_id, submission_availability_cd, 'NOTSUB', begin_rpt_period_id, end_rpt_period_id
		FROM camdecmps.monitor_plan
		WHERE mon_plan_id = monPlanId;

		-- STACK_PIPE --
		INSERT INTO camdecmpswks.stack_pipe(
			stack_pipe_id, fac_id, stack_name, active_date, retire_date, userid, add_date, update_date
		)
		SELECT
			sp.stack_pipe_id, sp.fac_id, sp.stack_name, sp.active_date, sp.retire_date, sp.userid, sp.add_date, sp.update_date		
		FROM camdecmps.stack_pipe AS sp
		LEFT OUTER JOIN camdecmpswks.stack_pipe AS wks
			USING (stack_pipe_id)
		WHERE sp.fac_id = fac.fac_id
		AND wks.stack_pipe_id IS NULL;

		-- MONITOR_LOCATION --
		INSERT INTO camdecmpswks.monitor_location(
			mon_loc_id, stack_pipe_id, unit_id, userid, add_date, update_date
		)
		SELECT
			ml.mon_loc_id, ml.stack_pipe_id, ml.unit_id, ml.userid, ml.add_date, ml.update_date	
		FROM camdecmps.monitor_location AS ml
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- COMPONENT --
		INSERT INTO camdecmpswks.component(
			component_id, mon_loc_id, component_identifier, model_version, serial_number, manufacturer, component_type_cd, acq_cd, basis_cd, userid, add_date, update_date, hg_converter_ind
		)
		SELECT
			c.component_id, c.mon_loc_id, c.component_identifier, c.model_version, c.serial_number, c.manufacturer, c.component_type_cd, c.acq_cd, c.basis_cd, c.userid, c.add_date, c.update_date, c.hg_converter_ind
		FROM camdecmps.component AS c
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- ANALYZER_RANGE --
		INSERT INTO camdecmpswks.analyzer_range(
			analyzer_range_id, component_id, analyzer_range_cd, dual_range_ind, begin_date, begin_hour, end_date, end_hour, userid, add_date, update_date
		)
		SELECT
			ar.analyzer_range_id, ar.component_id, ar.analyzer_range_cd, ar.dual_range_ind, ar.begin_date, ar.begin_hour, ar.end_date, ar.end_hour, ar.userid, ar.add_date, ar.update_date
		FROM camdecmps.analyzer_range AS ar
		JOIN camdecmps.component
			USING(component_id)
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;		

		-- MATS_METHOD_DATA --
		INSERT INTO camdecmpswks.mats_method_data(
			mats_method_data_id, mon_loc_id, mats_method_cd, mats_method_parameter_cd, begin_date, begin_hour, end_date, end_hour, userid, add_date, update_date
		)
		SELECT
			mmd.mats_method_data_id, mmd.mon_loc_id, mmd.mats_method_cd, mmd.mats_method_parameter_cd, mmd.begin_date, mmd.begin_hour, mmd.end_date, mmd.end_hour, mmd.userid, mmd.add_date, mmd.update_date
		FROM camdecmps.mats_method_data AS mmd
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- MONITOR_DEFAULT --
		INSERT INTO camdecmpswks.monitor_default(
			mondef_id, mon_loc_id, parameter_cd, begin_date, begin_hour, end_date, end_hour, operating_condition_cd, default_value, default_purpose_cd, default_source_cd, fuel_cd, group_id, userid, add_date, update_date, default_uom_cd
		)
		SELECT
			md.mondef_id, md.mon_loc_id, md.parameter_cd, md.begin_date, md.begin_hour, md.end_date, md.end_hour, md.operating_condition_cd, md.default_value, md.default_purpose_cd, md.default_source_cd, md.fuel_cd, md.group_id, md.userid, md.add_date, md.update_date, md.default_uom_cd
		FROM camdecmps.monitor_default AS md
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- MONITOR_FORMULA --
		INSERT INTO camdecmpswks.monitor_formula(
			mon_form_id, mon_loc_id, parameter_cd, equation_cd, formula_identifier, begin_date, begin_hour, end_date, end_hour, formula_equation, userid, add_date, update_date
		)
		SELECT
			mf.mon_form_id, mf.mon_loc_id, mf.parameter_cd, mf.equation_cd, mf.formula_identifier, mf.begin_date, mf.begin_hour, mf.end_date, mf.end_hour, mf.formula_equation, mf.userid, mf.add_date, mf.update_date
		FROM camdecmps.monitor_formula AS mf
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- MONITOR_LOAD --
		INSERT INTO camdecmpswks.monitor_load(
			load_id, mon_loc_id, load_analysis_date, begin_date, begin_hour, end_date, end_hour, max_load_value, second_normal_ind, up_op_boundary, low_op_boundary, normal_level_cd, second_level_cd, userid, add_date, update_date, max_load_uom_cd
		)
		SELECT
			ml.load_id, ml.mon_loc_id, ml.load_analysis_date, ml.begin_date, ml.begin_hour, ml.end_date, ml.end_hour, ml.max_load_value, ml.second_normal_ind, ml.up_op_boundary, ml.low_op_boundary, ml.normal_level_cd, ml.second_level_cd, ml.userid, ml.add_date, ml.update_date, ml.max_load_uom_cd
		FROM camdecmps.monitor_load AS ml
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- MONITOR_LOCATION_ATTRIBUTE --
		INSERT INTO camdecmpswks.monitor_location_attribute(
			mon_loc_attrib_id, mon_loc_id, grd_elevation, duct_ind, bypass_ind, cross_area_flow, cross_area_exit, begin_date, end_date, stack_height, shape_cd, material_cd, add_date, update_date, userid
		)
		SELECT
			mla.mon_loc_attrib_id, mla.mon_loc_id, mla.grd_elevation, mla.duct_ind, mla.bypass_ind, mla.cross_area_flow, mla.cross_area_exit, mla.begin_date, mla.end_date, mla.stack_height, mla.shape_cd, mla.material_cd, mla.add_date, mla.update_date, mla.userid
		FROM camdecmps.monitor_location_attribute AS mla
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- MONITOR_METHOD --
		INSERT INTO camdecmpswks.monitor_method(
			mon_method_id, mon_loc_id, parameter_cd, sub_data_cd, bypass_approach_cd, method_cd, begin_date, begin_hour, end_date, end_hour, userid, add_date, update_date
		)
		SELECT
			mm.mon_method_id, mm.mon_loc_id, mm.parameter_cd, mm.sub_data_cd, mm.bypass_approach_cd, mm.method_cd, mm.begin_date, mm.begin_hour, mm.end_date, mm.end_hour, mm.userid, mm.add_date, mm.update_date
		FROM camdecmps.monitor_method AS mm
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- MONITOR_PLAN_COMMENT --
		INSERT INTO camdecmpswks.monitor_plan_comment(
			mon_plan_comment_id, mon_plan_id, mon_plan_comment, begin_date, end_date, userid, add_date, submission_availability_cd, update_date
		)
		SELECT
			mon_plan_comment_id, mon_plan_id, mon_plan_comment, begin_date, end_date, userid, add_date, submission_availability_cd, update_date
		FROM camdecmps.monitor_plan_comment
		WHERE mon_plan_id = monPlanId;

		-- MONITOR_PLAN_LOCATION --
		INSERT INTO camdecmpswks.monitor_plan_location(
			monitor_plan_location_id, mon_plan_id, mon_loc_id
		)
		SELECT
			monitor_plan_location_id, mon_plan_id, mon_loc_id
		FROM camdecmps.monitor_plan_location
		WHERE mon_plan_id = monPlanId;		

		-- MONITOR_QUALIFICATION --
		INSERT INTO camdecmpswks.monitor_qualification(
			mon_qual_id, mon_loc_id, qual_type_cd, begin_date, end_date, userid, add_date, update_date
		)
		SELECT
			mq.mon_qual_id, mq.mon_loc_id, mq.qual_type_cd, mq.begin_date, mq.end_date, mq.userid, mq.add_date, mq.update_date
		FROM camdecmps.monitor_qualification AS mq
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- MONITOR_QUALIFICATION_LEE --
		INSERT INTO camdecmpswks.monitor_qualification_lee(
			mon_qual_lee_id, mon_qual_id, qual_test_date, parameter_cd, qual_lee_test_type_cd, potential_annual_emissions, applicable_emission_standard, emission_standard_uom, emission_standard_pct, userid, add_date, update_date
		)
		SELECT
			mq.mon_qual_lee_id, mq.mon_qual_id, mq.qual_test_date, mq.parameter_cd, mq.qual_lee_test_type_cd, mq.potential_annual_emissions, mq.applicable_emission_standard, mq.emission_standard_uom, mq.emission_standard_pct, mq.userid, mq.add_date, mq.update_date
		FROM camdecmps.monitor_qualification_lee AS mq
		JOIN camdecmps.monitor_qualification
			USING (mon_qual_id)
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- MONITOR_QUALIFICATION_LME --		
		INSERT INTO camdecmpswks.monitor_qualification_lme(
			mon_lme_id, mon_qual_id, qual_data_year, so2_tons, nox_tons, op_hours, userid, add_date, update_date
		)
		SELECT
			mq.mon_lme_id, mq.mon_qual_id, mq.qual_data_year, mq.so2_tons, mq.nox_tons, mq.op_hours, mq.userid, mq.add_date, mq.update_date
		FROM camdecmps.monitor_qualification_lme AS mq
		JOIN camdecmps.monitor_qualification
			USING (mon_qual_id)
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- MONITOR_QUALIFICATION_PCT --		
		INSERT INTO camdecmpswks.monitor_qualification_pct(
			mon_pct_id, mon_qual_id, qual_year, yr1_qual_data_type_cd, yr1_qual_data_year, yr1_pct_value, yr2_qual_data_type_cd, yr2_qual_data_year, yr2_pct_value, yr3_qual_data_type_cd, yr3_qual_data_year, yr3_pct_value, avg_pct_value, userid, add_date, update_date
		)
		SELECT
			mq.mon_pct_id, mq.mon_qual_id, mq.qual_year, mq.yr1_qual_data_type_cd, mq.yr1_qual_data_year, mq.yr1_pct_value, mq.yr2_qual_data_type_cd, mq.yr2_qual_data_year, mq.yr2_pct_value, mq.yr3_qual_data_type_cd, mq.yr3_qual_data_year, mq.yr3_pct_value, mq.avg_pct_value, mq.userid, mq.add_date, mq.update_date
		FROM camdecmps.monitor_qualification_pct AS mq
		JOIN camdecmps.monitor_qualification
			USING (mon_qual_id)
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- MONITOR_SPAN --
		INSERT INTO camdecmpswks.monitor_span(
			span_id, mon_loc_id, mpc_value, mec_value, mpf_value, max_low_range, span_value, full_scale_range, begin_date, begin_hour, end_date, end_hour, default_high_range, flow_span_value, flow_full_scale_range, component_type_cd, span_scale_cd, span_method_cd, userid, add_date, update_date, span_uom_cd
		)
		SELECT
			ms.span_id, ms.mon_loc_id, ms.mpc_value, ms.mec_value, ms.mpf_value, ms.max_low_range, ms.span_value, ms.full_scale_range, ms.begin_date, ms.begin_hour, ms.end_date, ms.end_hour, ms.default_high_range, ms.flow_span_value, ms.flow_full_scale_range, ms.component_type_cd, ms.span_scale_cd, ms.span_method_cd, ms.userid, ms.add_date, ms.update_date, ms.span_uom_cd
		FROM camdecmps.monitor_span AS ms
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- MONITOR_SYSTEM --
		INSERT INTO camdecmpswks.monitor_system(
			mon_sys_id, mon_loc_id, system_identifier, sys_type_cd, begin_date, begin_hour, end_date, end_hour, sys_designation_cd, fuel_cd, userid, add_date, update_date
		)
		SELECT
			ms.mon_sys_id, ms.mon_loc_id, ms.system_identifier, ms.sys_type_cd, ms.begin_date, ms.begin_hour, ms.end_date, ms.end_hour, ms.sys_designation_cd, ms.fuel_cd, ms.userid, ms.add_date, ms.update_date
		FROM camdecmps.monitor_system AS ms
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- MONITOR_SYSTEM_COMPONENT --
		INSERT INTO camdecmpswks.monitor_system_component(
			mon_sys_comp_id, mon_sys_id, component_id, begin_hour, begin_date, end_date, end_hour, userid, add_date, update_date
		)
		SELECT
			msc.mon_sys_comp_id, msc.mon_sys_id, msc.component_id, msc.begin_hour, msc.begin_date, msc.end_date, msc.end_hour, msc.userid, msc.add_date, msc.update_date
		FROM camdecmps.monitor_system_component AS msc
		JOIN camdecmps.monitor_system
			USING(mon_sys_id)
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- RECT_DUCT_WAF --
		INSERT INTO camdecmpswks.rect_duct_waf(
			rect_duct_waf_data_id, mon_loc_id, waf_determined_date, waf_effective_date, waf_effective_hour, waf_method_cd, waf_value, num_test_runs, num_traverse_points_waf, num_test_ports, num_traverse_points_ref, duct_width, duct_depth, end_date, end_hour, add_date, update_date, userid
		)
		SELECT
			rdw.rect_duct_waf_data_id, rdw.mon_loc_id, rdw.waf_determined_date, rdw.waf_effective_date, rdw.waf_effective_hour, rdw.waf_method_cd, rdw.waf_value, rdw.num_test_runs, rdw.num_traverse_points_waf, rdw.num_test_ports, rdw.num_traverse_points_ref, rdw.duct_width, rdw.duct_depth, rdw.end_date, rdw.end_hour, rdw.add_date, rdw.update_date, rdw.userid
		FROM camdecmps.rect_duct_waf AS rdw
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- SYSTEM_FUEL_FLOW --
		INSERT INTO camdecmpswks.system_fuel_flow(
			sys_fuel_id, mon_sys_id, max_rate, begin_date, begin_hour, end_date, end_hour, max_rate_source_cd, userid, add_date, update_date, sys_fuel_uom_cd
		)
		SELECT
			sff.sys_fuel_id, sff.mon_sys_id, sff.max_rate, sff.begin_date, sff.begin_hour, sff.end_date, sff.end_hour, sff.max_rate_source_cd, sff.userid, sff.add_date, sff.update_date, sff.sys_fuel_uom_cd
		FROM camdecmps.system_fuel_flow AS sff
		JOIN camdecmps.monitor_system
			USING(mon_sys_id)
		JOIN camdecmps.monitor_plan_location
			USING(mon_loc_id)
		WHERE mon_plan_id = monPlanId;

		-- UNIT_CAPACITY --
		INSERT INTO camdecmpswks.unit_capacity(
			unit_cap_id, unit_id, begin_date, end_date, max_hi_capacity, userid, add_date, update_date
		)
		SELECT
			uc.unit_cap_id, uc.unit_id, uc.begin_date, uc.end_date, uc.max_hi_capacity, uc.userid, uc.add_date, uc.update_date
		FROM camdecmps.unit_capacity AS uc
		JOIN camd.unit AS u
			USING (unit_id)
		LEFT OUTER JOIN camdecmpswks.unit_capacity AS wks
			USING (unit_cap_id)
		WHERE u.fac_id = fac.fac_id
		AND wks.unit_cap_id IS NULL;

		-- UNIT_CONTROL --
		INSERT INTO camdecmpswks.unit_control(
			ctl_id, unit_id, control_cd, ce_param, install_date, opt_date, orig_cd, seas_cd, retire_date, indicator_cd, userid, add_date, update_date
		)
		SELECT
			uc.ctl_id, uc.unit_id, uc.control_cd, uc.ce_param, uc.install_date, uc.opt_date, uc.orig_cd, uc.seas_cd, uc.retire_date, uc.indicator_cd, uc.userid, uc.add_date, uc.update_date
		FROM camdecmps.unit_control AS uc
		JOIN camd.unit AS u
			USING (unit_id)
		LEFT OUTER JOIN camdecmpswks.unit_control AS wks
			USING (ctl_id)
		WHERE u.fac_id = fac.fac_id
		AND wks.ctl_id IS NULL;

		-- UNIT_FUEL --
		INSERT INTO camdecmpswks.unit_fuel(
			uf_id, unit_id, fuel_type, begin_date, end_date, indicator_cd, act_or_proj_cd, ozone_seas_ind, dem_so2, dem_gcv, sulfur_content, userid, add_date, update_date
		)
		SELECT
			uf.uf_id, uf.unit_id, uf.fuel_type, uf.begin_date, uf.end_date, uf.indicator_cd, uf.act_or_proj_cd, uf.ozone_seas_ind, uf.dem_so2, uf.dem_gcv, uf.sulfur_content, uf.userid, uf.add_date, uf.update_date
		FROM camdecmps.unit_fuel AS uf
		JOIN camd.unit AS u
			USING (unit_id)
		LEFT OUTER JOIN camdecmpswks.unit_fuel AS wks
			USING (uf_id)
		WHERE u.fac_id = fac.fac_id
		AND wks.uf_id IS NULL;

		-- UNIT_STACK_CONFIGURATION --
		INSERT INTO camdecmpswks.unit_stack_configuration(
			config_id, unit_id, stack_pipe_id, begin_date, end_date, userid, add_date, update_date
		)
		SELECT
			usc.config_id, usc.unit_id, usc.stack_pipe_id, usc.begin_date, usc.end_date, usc.userid, usc.add_date, usc.update_date
		FROM camdecmps.unit_stack_configuration AS usc
		JOIN camd.unit AS u
			USING (unit_id)
		LEFT OUTER JOIN camdecmpswks.unit_stack_configuration AS wks
			USING (config_id)
		WHERE u.fac_id = fac.fac_id
		AND wks.config_id IS NULL;		

	END IF;

END;
$$