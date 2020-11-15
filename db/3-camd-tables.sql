--SET DATABASE
\c cgawsbrokerprodg1t1yiwikl6s1rs

CREATE SCHEMA "CAMD" AUTHORIZATION uwoha4melpr2pzxq;

CREATE TABLE "CAMD"."COMPANY" (
  "COMPANY_ID" NUMERIC(38,0) NOT NULL, 
	"COMPANY_NAME" VARCHAR(100) NOT NULL, 
	"USERID" VARCHAR(8) NOT NULL, 
	"ADD_DATE" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL, 
	"UPDATE_DATE" DATE,
	CONSTRAINT "PK_COMPANY" PRIMARY KEY ("COMPANY_ID"), 
	CONSTRAINT "UQ_COMPANY" UNIQUE ("COMPANY_NAME")
);
COMMENT ON COLUMN "CAMD"."COMPANY"."COMPANY_ID" IS 'COMPANY identity key.';
COMMENT ON COLUMN "CAMD"."COMPANY"."COMPANY_NAME" IS 'Name of COMPANY.';
COMMENT ON COLUMN "CAMD"."COMPANY"."USERID" IS 'The user name of the person or process that created the record if the Update" DATE" IS empty.  Otherwise this" IS the user name of the person or process that made the last update.';
COMMENT ON COLUMN "CAMD"."COMPANY"."ADD_DATE" IS 'Date the record was created.';
COMMENT ON COLUMN "CAMD"."COMPANY"."UPDATE_DATE" IS 'Date of the last record update.';
COMMENT ON TABLE "CAMD"."COMPANY" IS 'Identifies companies that own and/or operate units or are linked to a person.';

CREATE TABLE "CAMD"."CONTACT_RELATION" (
  "CNT_REL_ID" NUMERIC(38,0) NOT NULL, 
	"CNT_ID" NUMERIC(38,0) NOT NULL, 
	"PPL_ID" NUMERIC(38,0) NOT NULL, 
	"RELATION_TYPE_CD" VARCHAR(25) NOT NULL, 
	"BEGIN_DATE" DATE NOT NULL, 
	"END_DATE" DATE,
	"USERID" VARCHAR(8) NOT NULL, 
	"ADD_DATE" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL, 
	"UPDATE_DATE" DATE,
	CONSTRAINT "PK_CONTACT_RELATION" PRIMARY KEY ("CNT_REL_ID")
);
COMMENT ON COLUMN "CAMD"."CONTACT_RELATION"."CNT_REL_ID" IS 'Identity key for CONTACT_RELATION table.';
COMMENT ON COLUMN "CAMD"."CONTACT_RELATION"."CNT_ID" IS 'PEOPLE ID for representative.';
COMMENT ON COLUMN "CAMD"."CONTACT_RELATION"."PPL_ID" IS 'PEOPLE ID for agent.';
COMMENT ON COLUMN "CAMD"."CONTACT_RELATION"."RELATION_TYPE_CD" IS 'Lookup code which defines the scope of the relationship or agent responsibilities.';
COMMENT ON COLUMN "CAMD"."CONTACT_RELATION"."BEGIN_DATE" IS 'Date on which a relationship or an activity began.';
COMMENT ON COLUMN "CAMD"."CONTACT_RELATION"."END_DATE" IS 'Date on which a relationship or an activity ended.';
COMMENT ON COLUMN "CAMD"."CONTACT_RELATION"."USERID" IS 'The user name of the person or process that created the record if the Update" DATE" IS empty.  Otherwise this" IS the user name of the person or process that made the last update.';
COMMENT ON COLUMN "CAMD"."CONTACT_RELATION"."ADD_DATE" IS 'Date the record was created.';
COMMENT ON COLUMN "CAMD"."CONTACT_RELATION"."UPDATE_DATE" IS 'Date of the last record update.';
COMMENT ON TABLE "CAMD"."CONTACT_RELATION" IS 'Table captures the relationship that one or more representatives have with each other.  The PPL_ID" IS the agent''s id and the CNT_ID shows the representative''s id.';

CREATE TABLE "CAMD"."GENERATOR" (
  "GEN_ID" NUMERIC(38,0) NOT NULL, 
	"FAC_ID" NUMERIC(38,0) NOT NULL, 
	"GENID" VARCHAR(8) NOT NULL, 
	"GEN_SOURCE_CD" VARCHAR(7) NOT NULL, 
	"ARP_NAMEPLATE_CAPACITY" NUMERIC(7,3),
	"OTHER_NAMEPLATE_CAPACITY" NUMERIC(7,3),
	"UTILITY_IND" NUMERIC(1,0),
	"PRIME_MOVER_TYPE_CD" VARCHAR(7),
	"GEN_CAPACITY_FACTOR" NUMERIC(5,3),
	"ONLINE_YEAR" NUMERIC(4,0),
	"EIA_YEAR" NUMERIC(4,0),
	"USERID" VARCHAR(8) NOT NULL, 
	"ADD_DATE" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL, 
	"UPDATE_DATE" DATE,
	CONSTRAINT "PK_GENERATOR" PRIMARY KEY ("GEN_ID"), 
	CONSTRAINT "UQ_GENERATOR" UNIQUE ("FAC_ID", "GENID")
);
COMMENT ON COLUMN "CAMD"."GENERATOR"."GEN_ID" IS 'Identity key for GENERATOR table.';
COMMENT ON COLUMN "CAMD"."GENERATOR"."FAC_ID" IS 'FACILITY ID identity key.';
COMMENT ON COLUMN "CAMD"."GENERATOR"."GENID" IS 'Public identifier used for GENERATOR as reported to EIA and for New Unit Exemption purposes.';
COMMENT ON COLUMN "CAMD"."GENERATOR"."GEN_SOURCE_CD" IS 'Source code of GENERATOR data.';
COMMENT ON COLUMN "CAMD"."GENERATOR"."ARP_NAMEPLATE_CAPACITY" IS 'Design nameplate capacity, in megawatts, of the GENERATOR.';
COMMENT ON COLUMN "CAMD"."GENERATOR"."OTHER_NAMEPLATE_CAPACITY" IS 'Nameplate capacity, in megawatts, of the GENERATOR as applicable to other programs such as CAIR.';
COMMENT ON COLUMN "CAMD"."GENERATOR"."UTILITY_IND" IS 'Identifies whether a GENERATOR" IS a utility or a non-utility.';
COMMENT ON COLUMN "CAMD"."GENERATOR"."PRIME_MOVER_TYPE_CD" IS 'Type, such as combined cycle, steam turbine, etc., of a GENERATOR.';
COMMENT ON COLUMN "CAMD"."GENERATOR"."GEN_CAPACITY_FACTOR" IS 'Capacity factor based on actual operations.';
COMMENT ON COLUMN "CAMD"."GENERATOR"."ONLINE_YEAR" IS 'Four digit year that the GENERATOR came online.';
COMMENT ON COLUMN "CAMD"."GENERATOR"."EIA_YEAR" IS 'The year for which EIA identification information" IS provided.';
COMMENT ON COLUMN "CAMD"."GENERATOR"."USERID" IS 'The user name of the person or process that created the record if the Update" DATE" IS empty.  Otherwise this" IS the user name of the person or process that made the last update.';
COMMENT ON COLUMN "CAMD"."GENERATOR"."ADD_DATE" IS 'Date the record was created.';
COMMENT ON COLUMN "CAMD"."GENERATOR"."UPDATE_DATE" IS 'Date of the last record update.';
COMMENT ON TABLE "CAMD"."GENERATOR" IS 'Identifies power generator associated with FACILITY.';

CREATE TABLE "CAMD"."PERSON" (
  "PPL_ID" NUMERIC(38,0) NOT NULL, 
	"PERSON_TYPE_CD" VARCHAR(7) NOT NULL, 
	"LAST_NAME" VARCHAR(25) NOT NULL, 
	"FIRST_NAME" VARCHAR(25) NOT NULL, 
	"MIDDLE_INITIAL" VARCHAR(1),
	"SUFFIX" VARCHAR(8),
	"JOB_TITLE" VARCHAR(100),
	"COMPANY_ID" NUMERIC(38,0),
	"AGENCY_ID" NUMERIC(38,0),
	"ADDRESS1" VARCHAR(50),
	"ADDRESS2" VARCHAR(50),
	"CITY" VARCHAR(20),
	"STATE_CD" VARCHAR(2),
	"ZIP_CODE" VARCHAR(10),
	"COUNTRY_CD" VARCHAR(7),
	"PROVINCE" VARCHAR(25),
	"PHONE_NUMBER" VARCHAR(18),
	"EXTENSION" VARCHAR(5),
	"FAX_NUMBER" VARCHAR(18),
	"CELL_PHONE_NUMBER" VARCHAR(18),
	"EMAIL_ADDRESS" VARCHAR(70),
	"LOGIN" VARCHAR(8),
	"PASSWORD" VARCHAR(300),
	"PASSWORD_CHANGE_DATE" DATE,
	"INITIAL_PASSWORD_IND" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	"PASSWORD_LOCKED_IND" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	"PASSWORD_FAILED_CNT" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	"RESET_PASSWORD_CODE" VARCHAR(100),
	"RESET_PASSWORD_REQUEST_DATE" DATE,
	"RESET_PASSWORD_FAIL_CNT" NUMERIC(1,0),
	"SECURITY_GROUP_CD" VARCHAR(7),
	"SUBSCRIBER_IND" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	"HIDE_PHISHING_IND" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	"CONSULTANT_IND" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	"EMAIL_REMOVED_DATE" DATE,
	"PPL_COMMENT" VARCHAR(4000),
	"USERID" VARCHAR(8) NOT NULL, 
	"ADD_DATE" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL, 
	"UPDATE_DATE" DATE,
	"ACR_ID" NUMERIC,
	"EMAIL_SIGNATURE" VARCHAR(4000),
	"CROMERR_FAILED_CNT" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	"CROMERR_LOCKED_IND" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	CONSTRAINT "PK_PERSON" PRIMARY KEY ("PPL_ID"), 
	CONSTRAINT "UQ_PERSON_LOGIN" UNIQUE ("LOGIN")
);
COMMENT ON COLUMN "CAMD"."PERSON"."PPL_ID" IS 'PERSON identity key.';
COMMENT ON COLUMN "CAMD"."PERSON"."PERSON_TYPE_CD" IS 'Identifies the type of user in system.';
COMMENT ON COLUMN "CAMD"."PERSON"."LAST_NAME" IS 'The last name of a requestor.';
COMMENT ON COLUMN "CAMD"."PERSON"."FIRST_NAME" IS 'The first name of a requestor.';
COMMENT ON COLUMN "CAMD"."PERSON"."MIDDLE_INITIAL" IS 'The middle initial of a STAFF or CONTACT person.';
COMMENT ON COLUMN "CAMD"."PERSON"."SUFFIX" IS 'Suffix of PERSON name.';
COMMENT ON COLUMN "CAMD"."PERSON"."JOB_TITLE" IS 'The job title or description for a person. ';
COMMENT ON COLUMN "CAMD"."PERSON"."COMPANY_ID" IS 'COMPANY identity key.';
COMMENT ON COLUMN "CAMD"."PERSON"."AGENCY_ID" IS 'AGENCY identity key.';
COMMENT ON COLUMN "CAMD"."PERSON"."ADDRESS1" IS 'Mailing or street address line 1. ';
COMMENT ON COLUMN "CAMD"."PERSON"."ADDRESS2" IS 'Mailing or street address line 2. ';
COMMENT ON COLUMN "CAMD"."PERSON"."CITY" IS 'The city address for an AGENCY or individual. ';
COMMENT ON COLUMN "CAMD"."PERSON"."STATE_CD" IS 'State abbreviation for state in which FACILITY, CONTACT, AGENCY, ACCOUNT, REQUEST, PROGRAM, or STAFF" IS located.';
COMMENT ON COLUMN "CAMD"."PERSON"."ZIP_CODE" IS 'The US Postal Service zip code.';
COMMENT ON COLUMN "CAMD"."PERSON"."COUNTRY_CD" IS 'Country name.';
COMMENT ON COLUMN "CAMD"."PERSON"."PROVINCE" IS 'Name of province or state for international addresses.';
COMMENT ON COLUMN "CAMD"."PERSON"."PHONE_NUMBER" IS 'Phone" NUMERIC for CONTACT or STAFF, AGENCY, and ACCOUNT REQUEST. ';
COMMENT ON COLUMN "CAMD"."PERSON"."EXTENSION" IS 'Extension of person''s phone" NUMERIC.';
COMMENT ON COLUMN "CAMD"."PERSON"."FAX_NUMBER" IS 'The facsimile" NUMERIC for an individual.';
COMMENT ON COLUMN "CAMD"."PERSON"."CELL_PHONE_NUMBER" IS 'Cell phone" NUMERIC for CONTACT or STAFF, AGENCY and ACCOUNT REQUEST. ';
COMMENT ON COLUMN "CAMD"."PERSON"."EMAIL_ADDRESS" IS 'The email address for an individual. ';
COMMENT ON COLUMN "CAMD"."PERSON"."LOGIN" IS 'The User logon name or ID for CAMD databases assigned by CAMD to CONTACT and STAFF.';
COMMENT ON COLUMN "CAMD"."PERSON"."PASSWORD" IS 'The encrypted User Password assigned by CAMD and maintained by the CONTACT or STAFF to authenticate access to CAMD databases.';
COMMENT ON COLUMN "CAMD"."PERSON"."PASSWORD_CHANGE_DATE" IS 'Date user changed password.';
COMMENT ON COLUMN "CAMD"."PERSON"."INITIAL_PASSWORD_IND" IS 'Indicates whether the user needs to change their password on next login.';
COMMENT ON COLUMN "CAMD"."PERSON"."PASSWORD_LOCKED_IND" IS 'Identifies whether the user" IS locked out of the application for wrong password attempts.';
COMMENT ON COLUMN "CAMD"."PERSON"."PASSWORD_FAILED_CNT" IS 'NUMERIC of failed login attempts since last successful login attempt.';
COMMENT ON COLUMN "CAMD"."PERSON"."RESET_PASSWORD_CODE" IS 'Unique code requested by user to use to reset their password.';
COMMENT ON COLUMN "CAMD"."PERSON"."RESET_PASSWORD_REQUEST_DATE" IS 'Date the reset password code was requested.';
COMMENT ON COLUMN "CAMD"."PERSON"."RESET_PASSWORD_FAIL_CNT" IS 'NUMERIC of times the user has entered the incorrect reset password code.';
COMMENT ON COLUMN "CAMD"."PERSON"."SECURITY_GROUP_CD" IS 'Indicates the person''s access group.';
COMMENT ON COLUMN "CAMD"."PERSON"."SUBSCRIBER_IND" IS 'Indicates the submission status the person''s subscriber agreement.';
COMMENT ON COLUMN "CAMD"."PERSON"."HIDE_PHISHING_IND" IS 'Indicates if the user has chosen to hide the phishing notice.';
COMMENT ON COLUMN "CAMD"."PERSON"."CONSULTANT_IND" IS 'Indicates if the user" IS identified as a consultant and has access to the Consultant Access module in CBS.';
COMMENT ON COLUMN "CAMD"."PERSON"."EMAIL_REMOVED_DATE" IS 'Date, if any, when CAMD removed a users email address. Null indicates not removed.';
COMMENT ON COLUMN "CAMD"."PERSON"."PPL_COMMENT" IS 'Text description of the PERSON record.';
COMMENT ON COLUMN "CAMD"."PERSON"."USERID" IS 'The user name of the person or process that created the record if the Update" DATE" IS empty.  Otherwise this" IS the user name of the person or process that made the last update.';
COMMENT ON COLUMN "CAMD"."PERSON"."ADD_DATE" IS 'Date the record was created.';
COMMENT ON COLUMN "CAMD"."PERSON"."UPDATE_DATE" IS 'Date of the last record update.';
COMMENT ON COLUMN "CAMD"."PERSON"."ACR_ID" IS 'Identity key for ACCOUNT REQUEST.';
COMMENT ON COLUMN "CAMD"."PERSON"."EMAIL_SIGNATURE" IS 'Used by the CSA email generator to store an email signature.';
COMMENT ON COLUMN "CAMD"."PERSON"."CROMERR_FAILED_CNT" IS 'NUMERIC of failed CROMERR/challenge answer attempts since last successful attempt.';
COMMENT ON COLUMN "CAMD"."PERSON"."CROMERR_LOCKED_IND" IS 'Identifies whether the user" IS locked out of the application for wrong challenge answers.';
COMMENT ON TABLE "CAMD"."PERSON" IS 'The PERSON table stores information on all AGENTS, REPS, STAFF, and CONTACTS.';

CREATE TABLE "CAMD"."PLANT" (
  "FAC_ID" NUMERIC(38,0) NOT NULL, 
	"ORIS_CODE" NUMERIC(6,0),
	"FACILITY_NAME" VARCHAR(40) NOT NULL, 
	"DESCRIPTION" VARCHAR(4000),
	"STATE" VARCHAR(2) NOT NULL, 
	"COUNTY_CD" VARCHAR(8),
	"SIC_CODE" NUMERIC(4,0),
	"EPA_REGION" NUMERIC(2,0),
	"NERC_REGION" VARCHAR(5),
	"AIRSID" VARCHAR(10),
	"FINDSID" VARCHAR(12),
	"STATEID" VARCHAR(15),
	"LATITUDE" NUMERIC(7,4),
	"LONGITUDE" NUMERIC(8,4),
	"FRS_ID" VARCHAR(12),
	"PAYEE_ID" NUMERIC(6,0),
	"PERMIT_EXP_DATE" DATE,
	"LATLON_SOURCE" VARCHAR(200),
	"TRIBAL_LAND_CD" VARCHAR(7),
	"FIRST_ECMPS_RPT_PERIOD_ID" NUMERIC(38,0),
	"USERID" VARCHAR(8) NOT NULL, 
	"ADD_DATE" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL, 
	"UPDATE_DATE" DATE,
	CONSTRAINT "PK_PLANT" PRIMARY KEY ("FAC_ID"), 
	CONSTRAINT "UQ_PLANT_NAME_STATE" UNIQUE ("FACILITY_NAME", "STATE"), 
	CONSTRAINT "UQ_PLANT_ORIS_CODE" UNIQUE ("ORIS_CODE")
);
COMMENT ON COLUMN "CAMD"."PLANT"."FAC_ID" IS 'FACILITY ID identity key.';
COMMENT ON COLUMN "CAMD"."PLANT"."ORIS_CODE" IS 'EIA-assigned identifier or FACILITY ID assigned by CAMD (if EIA" NUMBER" IS not applicable).';
COMMENT ON COLUMN "CAMD"."PLANT"."FACILITY_NAME" IS 'Name of FACILITY, as reported by representative on Certification of Representation forms or equivalent.';
COMMENT ON COLUMN "CAMD"."PLANT"."DESCRIPTION" IS 'Text description of FACILITY or FACILITY configuration.';
COMMENT ON COLUMN "CAMD"."PLANT"."STATE" IS 'State abbreviation for state in which FACILITY, CONTACT, AGENCY, ACCOUNT REQUEST, PROGRAM, or STAFF" IS located. ';
COMMENT ON COLUMN "CAMD"."PLANT"."COUNTY_CD" IS 'Concatenation of State and county code.';
COMMENT ON COLUMN "CAMD"."PLANT"."SIC_CODE" IS 'Standard Industrial Classification System identification" NUMERIC, on a FACILITY basis.   ';
COMMENT ON COLUMN "CAMD"."PLANT"."EPA_REGION" IS 'The EPA Region in which a FACILITY" IS located.';
COMMENT ON COLUMN "CAMD"."PLANT"."NERC_REGION" IS 'Code for one of thirteen regions as specified by the  North American Electric Reliability Council.';
COMMENT ON COLUMN "CAMD"."PLANT"."AIRSID" IS 'The identifier for the FACILITY in the AIRS Facility Subsystem (AFS).';
COMMENT ON COLUMN "CAMD"."PLANT"."FINDSID" IS 'Cross-reference field for FINDS database.';
COMMENT ON COLUMN "CAMD"."PLANT"."STATEID" IS 'The State identification" NUMERIC for a FACILITY or UNIT.';
COMMENT ON COLUMN "CAMD"."PLANT"."LATITUDE" IS 'The latitude at which a FACILITY" IS located.';
COMMENT ON COLUMN "CAMD"."PLANT"."LONGITUDE" IS 'The longitude at which a FACILITY" IS located.';
COMMENT ON COLUMN "CAMD"."PLANT"."FRS_ID" IS 'The cross-media Facility Registry System identifier for a FACILITY.';
COMMENT ON COLUMN "CAMD"."PLANT"."PAYEE_ID" IS 'ID of a payee entity.';
COMMENT ON COLUMN "CAMD"."PLANT"."PERMIT_EXP_DATE" IS 'Date permit expires.';
COMMENT ON COLUMN "CAMD"."PLANT"."LATLON_SOURCE" IS 'Source of latitude/longitude data.';
COMMENT ON COLUMN "CAMD"."PLANT"."TRIBAL_LAND_CD" IS 'Tribal Land abbreviation for tribal land in which FACILITY, CONTACT, AGENCY, ACCOUNT REQUEST, PROGRAM or STAFF" IS located.';
COMMENT ON COLUMN "CAMD"."PLANT"."FIRST_ECMPS_RPT_PERIOD_ID" IS 'Identity key from REPORTING_PERIOD for the first quarter a facility reports via ECMPS.';
COMMENT ON COLUMN "CAMD"."PLANT"."USERID" IS 'The user name of the person or process that created the record if the Update" DATE" IS empty.  Otherwise this" IS the user name of the person or process that made the last update.';
COMMENT ON COLUMN "CAMD"."PLANT"."ADD_DATE" IS 'Date the record was created.';
COMMENT ON COLUMN "CAMD"."PLANT"."UPDATE_DATE" IS 'Date of the last record update.';
COMMENT ON TABLE "CAMD"."PLANT" IS 'Identifies an electric generating or industrial facility consisting of UNITS known to or potentially subject to a trading program.';

CREATE TABLE "CAMD"."PLANT_PERSON" (
  "FAC_PPL_ID" NUMERIC(38,0) NOT NULL, 
	"FAC_ID" NUMERIC(38,0),
	"PPL_ID" NUMERIC(38,0) NOT NULL, 
	"RESPONSIBILITY_ID" VARCHAR(7) NOT NULL, 
	"PRG_CD" VARCHAR(7),
	"BEGIN_DATE" DATE NOT NULL, 
	"END_DATE" DATE,
	"CERT_DATE" DATE,
	"USERID" VARCHAR(8) NOT NULL, 
	"ADD_DATE" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL, 
	"UPDATE_DATE" DATE,
	CONSTRAINT "PK_PLANT_PERSON" PRIMARY KEY ("FAC_PPL_ID")
);
COMMENT ON COLUMN "CAMD"."PLANT_PERSON"."FAC_PPL_ID" IS 'FACILITY and PEOPLE relationship identity key.';
COMMENT ON COLUMN "CAMD"."PLANT_PERSON"."FAC_ID" IS 'Identity key for FACILITY table.';
COMMENT ON COLUMN "CAMD"."PLANT_PERSON"."PPL_ID" IS 'PEOPLE identity key.';
COMMENT ON COLUMN "CAMD"."PLANT_PERSON"."RESPONSIBILITY_ID" IS 'Responsibility key.';
COMMENT ON COLUMN "CAMD"."PLANT_PERSON"."PRG_CD" IS 'Code used to identify regulatory PROGRAM applicable to UNIT.';
COMMENT ON COLUMN "CAMD"."PLANT_PERSON"."BEGIN_DATE" IS 'Date on which a relationship or an activity began. ';
COMMENT ON COLUMN "CAMD"."PLANT_PERSON"."END_DATE" IS 'Date on which a relationship or an activity ended.';
COMMENT ON COLUMN "CAMD"."PLANT_PERSON"."CERT_DATE" IS 'Date the MATS RO was certified for the facility.';
COMMENT ON COLUMN "CAMD"."PLANT_PERSON"."USERID" IS 'The user name of the person or process that created the record if the Update" DATE" IS empty. Otherwise this" IS the user name of the person or process that made the last update.';
COMMENT ON COLUMN "CAMD"."PLANT_PERSON"."ADD_DATE" IS 'Date the record was created.';
COMMENT ON COLUMN "CAMD"."PLANT_PERSON"."UPDATE_DATE" IS 'Date of the last record update.';
COMMENT ON TABLE "CAMD"."PLANT_PERSON" IS 'Links facilities to people (representatives, contacts, staff).';

CREATE TABLE "CAMD"."UNIT" (
  "UNIT_ID" NUMERIC(38,0) NOT NULL, 
	"FAC_ID" NUMERIC(38,0) NOT NULL, 
	"UNITID" VARCHAR(6) NOT NULL, 
	"UNIT_DESCRIPTION" VARCHAR(4000),
	"INDIAN_COUNTRY_IND" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	"STATEID" VARCHAR(6),
	"BOILER_SEQUENCE_NUMBER" NUMERIC(38,0),
	"COMM_OP_DATE" DATE,
	"COMM_OP_DATE_CD" VARCHAR(1),
	"COMR_OP_DATE" DATE,
	"COMR_OP_DATE_CD" VARCHAR(1),
	"SOURCE_CATEGORY_CD" VARCHAR(7),
	"NAICS_CD" NUMERIC(6,0),
	"NO_ACTIVE_GEN_IND" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	"NON_LOAD_BASED_IND" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	"ACTUAL_90TH_OP_DATE" DATE,
	"MOVED_IND" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	"USERID" VARCHAR(8) NOT NULL, 
	"ADD_DATE" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL, 
	"UPDATE_DATE" DATE,
	CONSTRAINT "PK_UNIT" PRIMARY KEY ("UNIT_ID"), 
	CONSTRAINT "UQ_UNIT" UNIQUE ("FAC_ID", "UNITID")
);
COMMENT ON COLUMN "CAMD"."UNIT"."UNIT_ID" IS 'Identity key for UNIT table.';
COMMENT ON COLUMN "CAMD"."UNIT"."FAC_ID" IS 'FACILITY ID identity key.';
COMMENT ON COLUMN "CAMD"."UNIT"."UNITID" IS 'Public identifier used for UNIT for PROGRAM identification purposes.';
COMMENT ON COLUMN "CAMD"."UNIT"."UNIT_DESCRIPTION" IS 'Text description of UNIT or UNIT configuration.';
COMMENT ON COLUMN "CAMD"."UNIT"."INDIAN_COUNTRY_IND" IS 'Indicates whether of not a unit" IS located in Indian Country.';
COMMENT ON COLUMN "CAMD"."UNIT"."STATEID" IS 'The state identification" NUMERIC for a FACILITY or UNIT.';
COMMENT ON COLUMN "CAMD"."UNIT"."BOILER_SEQUENCE_NUMBER" IS 'A CAMD assigned unique identifier for each boiler or unit.';
COMMENT ON COLUMN "CAMD"."UNIT"."COMM_OP_DATE" IS 'First day of operation that a UNIT generated electricity for sale, including the sale of test generation.';
COMMENT ON COLUMN "CAMD"."UNIT"."COMM_OP_DATE_CD" IS 'Code indicating whether the UNIT initial operation" DATE" IS projected or actual.';
COMMENT ON COLUMN "CAMD"."UNIT"."COMR_OP_DATE" IS 'First day of commercial operation for a UNIT.';
COMMENT ON COLUMN "CAMD"."UNIT"."COMR_OP_DATE_CD" IS 'Code indicating whether the commercial operation" DATE for a UNIT" IS projected or actual.';
COMMENT ON COLUMN "CAMD"."UNIT"."SOURCE_CATEGORY_CD" IS 'General description of FACILITY type.';
COMMENT ON COLUMN "CAMD"."UNIT"."NAICS_CD" IS 'North American Industry Classification System code.  Provides information about the economic sector and specific industry, on a facility level.';
COMMENT ON COLUMN "CAMD"."UNIT"."NO_ACTIVE_GEN_IND" IS 'Indicator to show that the unit does not currently have an active generator (1) or that the unit does currently have an active generator (0).';
COMMENT ON COLUMN "CAMD"."UNIT"."NON_LOAD_BASED_IND" IS 'Non load based unit indicator.';
COMMENT ON COLUMN "CAMD"."UNIT"."ACTUAL_90TH_OP_DATE" IS 'Stores the actual 90th operating" DATE for a unit.  Supplied by sources via SMS/CBS.';
COMMENT ON COLUMN "CAMD"."UNIT"."MOVED_IND" IS 'Indicates whether or not a unit was moved from another facility.';
COMMENT ON COLUMN "CAMD"."UNIT"."USERID" IS 'The user name of the person or process that created the record if the Update" DATE" IS empty.  Otherwise this" IS the user name of the person or process that made the last update.';
COMMENT ON COLUMN "CAMD"."UNIT"."ADD_DATE" IS 'Date the record was created.';
COMMENT ON COLUMN "CAMD"."UNIT"."UPDATE_DATE" IS 'Date of the last record update.';
COMMENT ON TABLE "CAMD"."UNIT" IS 'Identifies industrial boilers or electric generating units.';

CREATE TABLE "CAMD"."UNIT_BOILER_TYPE" (
	"UNIT_BOILER_TYPE_ID" NUMERIC(38,0) NOT NULL,
	"UNIT_ID" NUMERIC(38,0) NOT NULL,
	"UNIT_TYPE_CD" VARCHAR(7) NOT NULL,
	"BEGIN_DATE" DATE NOT NULL,
	"END_DATE" DATE,
	"USERID" VARCHAR(8) NOT NULL,
	"ADD_DATE" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"UPDATE_DATE" DATE,
	CONSTRAINT "PK_UNIT_BOILER_TYPE" PRIMARY KEY ("UNIT_BOILER_TYPE_ID"),
	CONSTRAINT "UQ_UNIT_BOILER_TYPE" UNIQUE ("UNIT_ID", "UNIT_TYPE_CD", "BEGIN_DATE")
);
COMMENT ON COLUMN "CAMD"."UNIT_BOILER_TYPE"."UNIT_BOILER_TYPE_ID" IS 'Identity key for UNIT_BT_TYPE table.';
COMMENT ON COLUMN "CAMD"."UNIT_BOILER_TYPE"."UNIT_ID" IS 'Identity key for UNIT table.';
COMMENT ON COLUMN "CAMD"."UNIT_BOILER_TYPE"."UNIT_TYPE_CD" IS 'The type of UNIT or boiler.';
COMMENT ON COLUMN "CAMD"."UNIT_BOILER_TYPE"."BEGIN_DATE" IS 'Date on which a relationship or an activity began. ';
COMMENT ON COLUMN "CAMD"."UNIT_BOILER_TYPE"."END_DATE" IS 'Date on which a relationship or an activity ended.';
COMMENT ON COLUMN "CAMD"."UNIT_BOILER_TYPE"."USERID" IS 'The user name of the person or process that created the record if the Update Date is empty.  Otherwise this is the user name of the person or process that made the last update.';
COMMENT ON COLUMN "CAMD"."UNIT_BOILER_TYPE"."ADD_DATE" IS 'Date the record was created.';
COMMENT ON COLUMN "CAMD"."UNIT_BOILER_TYPE"."UPDATE_DATE" IS 'Date of the last record update.';
COMMENT ON TABLE "CAMD"."UNIT_BOILER_TYPE"  IS 'Identifies historical unit type for a unit id.';

CREATE TABLE "CAMD"."UNIT_GENERATOR" (
  "UNIT_GEN_ID" NUMERIC(38,0) NOT NULL, 
	"UNIT_ID" NUMERIC(38,0) NOT NULL, 
	"GEN_ID" NUMERIC(38,0) NOT NULL, 
	"BEGIN_DATE" DATE NOT NULL, 
	"END_DATE" DATE,
	"USERID" VARCHAR(8) NOT NULL, 
	"ADD_DATE" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL, 
	"UPDATE_DATE" DATE,
	CONSTRAINT "PK_UNIT_GENERATOR" PRIMARY KEY ("UNIT_GEN_ID"), 
	CONSTRAINT "UQ_UNIT_GENERATOR" UNIQUE ("UNIT_ID", "GEN_ID", "BEGIN_DATE")
);
COMMENT ON COLUMN "CAMD"."UNIT_GENERATOR"."UNIT_GEN_ID" IS 'Identity key for UNIT_GENERATOR table.';
COMMENT ON COLUMN "CAMD"."UNIT_GENERATOR"."UNIT_ID" IS 'Identity key for UNIT table.';
COMMENT ON COLUMN "CAMD"."UNIT_GENERATOR"."GEN_ID" IS 'The identifier used to identify a GENERATOR, as reported to EIA and for New Unit Exemption purposes.';
COMMENT ON COLUMN "CAMD"."UNIT_GENERATOR"."BEGIN_DATE" IS 'Date on which a relationship or an activity began.';
COMMENT ON COLUMN "CAMD"."UNIT_GENERATOR"."END_DATE" IS 'Date on which a relationship or an activity ended.';
COMMENT ON COLUMN "CAMD"."UNIT_GENERATOR"."USERID" IS 'The user name of the person or process that created the record if the Update" DATE" IS empty.  Otherwise this" IS the user name of the person or process that made the last update.';
COMMENT ON COLUMN "CAMD"."UNIT_GENERATOR"."ADD_DATE" IS 'Date the record was created.';
COMMENT ON COLUMN "CAMD"."UNIT_GENERATOR"."UPDATE_DATE" IS 'Date of the last record update.';
COMMENT ON TABLE "CAMD"."UNIT_GENERATOR" IS 'Stores the relationship between UNIT and GENERATOR.';

CREATE TABLE "CAMD"."UNIT_OP_STATUS" (
  "UNIT_OP_STATUS_ID" NUMERIC(38,0) NOT NULL, 
	"UNIT_ID" NUMERIC(38,0) NOT NULL, 
	"OP_STATUS_CD" VARCHAR(7) NOT NULL, 
	"BEGIN_DATE" DATE NOT NULL, 
	"END_DATE" DATE,
	"USERID" VARCHAR(8) NOT NULL, 
	"ADD_DATE" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL, 
	"UPDATE_DATE" DATE,
	CONSTRAINT "PK_UNIT_OP_STATUS" PRIMARY KEY ("UNIT_OP_STATUS_ID"), 
	CONSTRAINT "UQ_UNIT_OP_STATUS" UNIQUE ("UNIT_ID", "OP_STATUS_CD", "BEGIN_DATE")
);
COMMENT ON COLUMN "CAMD"."UNIT_OP_STATUS"."UNIT_OP_STATUS_ID" IS 'Identity key for UNIT_OP_STATUS table.';
COMMENT ON COLUMN "CAMD"."UNIT_OP_STATUS"."UNIT_ID" IS 'Identity key for UNIT table.';
COMMENT ON COLUMN "CAMD"."UNIT_OP_STATUS"."OP_STATUS_CD" IS 'Operating status for a unit.';
COMMENT ON COLUMN "CAMD"."UNIT_OP_STATUS"."BEGIN_DATE" IS 'Date on which a relationship or an activity began.';
COMMENT ON COLUMN "CAMD"."UNIT_OP_STATUS"."END_DATE" IS 'Date on which a relationship or an activity ended.';
COMMENT ON COLUMN "CAMD"."UNIT_OP_STATUS"."USERID" IS 'The user name of the person or process that created the record if the Update" DATE" IS empty. Otherwise this" IS the user name of the person or process that made the last update.';
COMMENT ON COLUMN "CAMD"."UNIT_OP_STATUS"."ADD_DATE" IS 'Date the record was created.';
COMMENT ON COLUMN "CAMD"."UNIT_OP_STATUS"."UPDATE_DATE" IS 'Date of the last record update.';
COMMENT ON TABLE "CAMD"."UNIT_OP_STATUS" IS 'Used to track operating status for a unit.';

CREATE TABLE "CAMD"."UNIT_OWNER" (
  "UNIT_OWNER_ID" NUMERIC(38,0) NOT NULL, 
	"UNIT_ID" NUMERIC(38,0) NOT NULL, 
	"COMP_ID" NUMERIC(38,0) NOT NULL, 
	"OWNER_TYPE_CD" VARCHAR(7) NOT NULL, 
	"BEGIN_DATE" DATE,
	"END_DATE" DATE,
	"USERID" VARCHAR(8) NOT NULL, 
	"ADD_DATE" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL, 
	"UPDATE_DATE" DATE,
	CONSTRAINT "PK_UNIT_OWNER" PRIMARY KEY ("UNIT_OWNER_ID"), 
	CONSTRAINT "UQ_UNIT_OWNER_COMP_OWN_DATE" UNIQUE ("UNIT_ID", "COMP_ID", "OWNER_TYPE_CD", "BEGIN_DATE")
);
COMMENT ON COLUMN "CAMD"."UNIT_OWNER"."UNIT_OWNER_ID" IS 'Identity key for UNIT_OWNER table.';
COMMENT ON COLUMN "CAMD"."UNIT_OWNER"."UNIT_ID" IS 'Identity key for UNIT table.';
COMMENT ON COLUMN "CAMD"."UNIT_OWNER"."COMP_ID" IS 'Identity key for COMPANY table.';
COMMENT ON COLUMN "CAMD"."UNIT_OWNER"."OWNER_TYPE_CD" IS 'Indicates type of owner, operator or both.';
COMMENT ON COLUMN "CAMD"."UNIT_OWNER"."BEGIN_DATE" IS 'Date on which a relationship or an activity began.';
COMMENT ON COLUMN "CAMD"."UNIT_OWNER"."END_DATE" IS 'Date on which a relationship or an activity ended.';
COMMENT ON COLUMN "CAMD"."UNIT_OWNER"."USERID" IS 'The user name of the person or process that created the record if the Update" DATE" IS empty.  Otherwise this" IS the user name of the person or process that made the last update.';
COMMENT ON COLUMN "CAMD"."UNIT_OWNER"."ADD_DATE" IS 'Date the record was created.';
COMMENT ON COLUMN "CAMD"."UNIT_OWNER"."UPDATE_DATE" IS 'Date of the last record update.';
COMMENT ON TABLE "CAMD"."UNIT_OWNER" IS 'The person or organization who has the title (ownership) of the UNIT or ACCOUNT or" IS responsible for the operation of the FACILITY. (Also known as binding party.) Stores the relationship between UNIT and OWNER.';

CREATE TABLE "CAMD"."UNIT_PROGRAM" (
  "UP_ID" NUMERIC(38,0) NOT NULL, 
	"UNIT_ID" NUMERIC(38,0) NOT NULL, 
	"PRG_ID" NUMERIC(38,0) NOT NULL, 
	"PRG_CD" VARCHAR(7),
	"CLASS_CD" VARCHAR(7),
	"APP_STATUS_CD" VARCHAR(7),
	"OPTIN_IND" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	"DEF_IND" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	"DEF_END_DATE" DATE,
	"UP_COMMENT" VARCHAR(1000),
	"UNIT_MONITOR_CERT_BEGIN_DATE" DATE,
	"UNIT_MONITOR_CERT_DEADLINE" DATE,
	"EMISSIONS_RECORDING_BEGIN_DATE" DATE,
	"TRUEUP_BEGIN_YEAR" NUMERIC(4,0),
	"END_DATE" DATE,
	"NON_EGU_IND" NUMERIC(1,0) DEFAULT 0 NOT NULL, 
	"NONSTANDARD_CD" VARCHAR(7),
	"NONSTANDARD_COMMENT" VARCHAR(1000),
	"SO2_AFFECT_YEAR" NUMERIC(4,0),
	"SO2_PHASE" VARCHAR(1),
	"USERID" VARCHAR(8) NOT NULL, 
	"ADD_DATE" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL, 
	"UPDATE_DATE" DATE,
	CONSTRAINT "PK_UNIT_PROGRAM" PRIMARY KEY ("UP_ID"), 
	CONSTRAINT "UQ_UNIT_PROGRAM" UNIQUE ("UNIT_ID", "PRG_ID")
);
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."UP_ID" IS 'UNIT and PROGRAM relationship identity key.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."UNIT_ID" IS 'Identity key for UNIT table.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."PRG_ID" IS 'PROGRAM identity key.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."PRG_CD" IS 'Code used to identify regulatory PROGRAM applicable to UNIT.  ';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."CLASS_CD" IS 'The regulatory category with respect to a specific PROGRAM for a UNIT.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."APP_STATUS_CD" IS 'Status of applicability (Unknown, Interim, Final). ';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."OPTIN_IND" IS 'Indicator that UNIT" IS an opt-in unit.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."DEF_IND" IS 'An indicator that a UNIT has not operated since the day on which it was affected by the PROGRAM.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."DEF_END_DATE" IS 'The" DATE on which the UNIT became operational after the program participation" DATE and was therefore subject to the PROGRAM''s regulatory requirements.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."UP_COMMENT" IS 'Comment for unit program record.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."UNIT_MONITOR_CERT_BEGIN_DATE" IS 'Date beginning timeline for completion of certification testing.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."UNIT_MONITOR_CERT_DEADLINE" IS 'Date by which monitor certification must be completed.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."EMISSIONS_RECORDING_BEGIN_DATE" IS 'Date a unit first begins recording hourly emissions data.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."TRUEUP_BEGIN_YEAR" IS 'First year the unit was expected for true up.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."END_DATE" IS 'Date on which a relationship or an activity ended.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."NON_EGU_IND" IS 'Identifies whether unit" IS electric-generating.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."NONSTANDARD_CD" IS 'Code used to identify type of nonstandard unit program situation.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."NONSTANDARD_COMMENT" IS 'Comment for nonstandard unit program situation.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."SO2_AFFECT_YEAR" IS 'LEGACY - First year in which UNIT was affected by SO2 emission limits under Part 72.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."SO2_PHASE" IS 'LEGACY - Indicator of whether a UNIT was affected by SO2 allowance holding requirements in 1995 (Phase I) or 2000 (Phase II).';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."USERID" IS 'The user name of the person or process that created the record if the Update" DATE" IS empty.  Otherwise this" IS the user name of the person or process that made the last update.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."ADD_DATE" IS 'Date the record was created.';
COMMENT ON COLUMN "CAMD"."UNIT_PROGRAM"."UPDATE_DATE" IS 'Date of the last record update.';
COMMENT ON TABLE "CAMD"."UNIT_PROGRAM" IS 'The specific PROGRAM in which the UNIT" IS or may be participating.';
