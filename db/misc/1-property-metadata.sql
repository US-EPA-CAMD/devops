-- Table: camdaux.property_metadata

-- DROP TABLE camdaux.property_metadata;
CREATE TABLE camdaux.property_metadata
(
    property_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 ),
    name character varying NOT NULL,
    json_name character varying NOT NULL,
    display_name character varying NOT NULL,
    description character varying NOT NULL,
    table_name character varying,
    sample_value character varying,
    CONSTRAINT pk_property_metadata PRIMARY KEY (property_id),
    CONSTRAINT uq_property_metadata_name UNIQUE (name, table_name),
    CONSTRAINT uq_property_metadata_json_name UNIQUE (name, table_name)
);

COMMENT ON TABLE camdaux.property_metadata
    IS 'Additional metadata and column label mappings used for API documentation, business rule authoring, and display of data in the frontend web system';

COMMENT ON COLUMN camdaux.property_metadata.property_id
    IS 'Record Identifier for the property_metadata metadata';

COMMENT ON COLUMN camdaux.property_metadata.name
    IS 'Name of database column or generic property_metadata name';

COMMENT ON COLUMN camdaux.property_metadata.json_name
    IS 'Serialized JSON property_metadata name';

COMMENT ON COLUMN camdaux.property_metadata.display_name
    IS 'Name displayed in applications & csv files';

COMMENT ON COLUMN camdaux.property_metadata.description
    IS 'Full description of a property_metadata';

COMMENT ON COLUMN camdaux.property_metadata.table_name
    IS 'Table name property_metadata is associated with';

COMMENT ON COLUMN camdaux.property_metadata.sample_value
    IS 'Sample data for the property_metadata';


insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('CO2_MASS_MEASURE_FLG'), 'co2MassMeasureFlg', 'CO2 Mass Measure Indicator', 'Describes how the CO2 Mass values were determined.', null, 'Measured');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('CO2_RATE'), 'co2Rate', 'CO2 Rate (short tons/mmBtu)', 'Average CO2 hourly emissions rate (short tons/mmBtu)', null, '0.103');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('CO2_RATE_MEASURE_FLG'), 'co2RateMeasureFlg', 'CO2 Rate Measure Indicator ', 'Describes how the CO2 Rate values were determined.', null, 'Calculated');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('FACILITY_NAME'), 'facilityName', 'Facility Name', 'The name given by the owners and operators to a facility', null, 'Barry');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('GLOAD'), 'grossLoad', 'Gross Load (MW)', 'Electrical generation in MW produced by combusting a given heat input of fuel.', null, '146');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('HEAT_INPUT'), 'heatInput', 'Heat Input (mmBtu)', 'Quantity of heat in mmBtu calculated by multiplying the quantity of fuel by the fuels heat content.', null, '1470.2');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('HG_CONTROL_INFO'), 'hgControlInfo', 'Hg Controls', 'Method or equipment used by the combustion unit to minimize Hg emissions.', null, 'Catalyst (gold, palladium, or other) used to oxidize mercury');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('NOX_CONTROL_INFO'), 'noxControlInfo', 'NOx Controls', 'Method or equipment used by the combustion unit to minimize NOx emissions.', null, 'Selective Catalytic Reduction, Low NOx Burner Technology w/ Separated OFA');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('NOX_MASS'), 'noxMass', 'NOx Mass (lbs)', 'NOx mass emissions (lbs)', null, '552.8');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('NOX_MASS_MEASURE_FLG'), 'noxMassMeasureFlg', 'NOx Mass Measure Indicator', 'Describes how the NOx Mass values were determined.', null, 'Measured and Substitute');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('NOX_RATE'), 'noxRate', 'NOx Rate (lbs/mmBtu)', 'The average rate of NOx emissions (lbs/mmBtu)', null, '0.376');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('NOX_RATE_MEASURE_FLG'), 'noxRateMeasureFlg', 'NOx Rate Measure Indicator', 'Describes how the NOx Rate values were determined.', null, 'Measured and Substitute');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('OP_DATE'), 'date', 'Date', 'Date on which activity occurred.', null, '2020-12-14');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('OP_HOUR'), 'hour', 'Hour', 'Hour in which activity occurred, recorded using local, standard time.', null, '23');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('OP_TIME'), 'opTime', 'Operating Time', 'Any part of an hour in which a unit combusts any fuel.', null, '0.95');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('ORISPL_CODE'), 'facilityId ', 'Facility ID', 'The Facility ID code assigned by the Department of Energy''s Energy Information Administration. The Energy Information Administration Plant ID code is also referred to as the ""ORIS code"", ""ORISPL code"", ""Facility ID"", or ""Facility code"", among other names. If a Plant ID code has not been assigned by the Department of Energy''s Energy Information Administration, then plant code means a code beginning with ""88"" assigned by the EPA''s Clean Air Markets Division for electronic reporting.', null, '3');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('PART_CONTROL_INFO'), 'pmControlInfo', 'PM Controls', 'Method or equipment used by the combustion unit to minimize PM emissions.', null, 'Electrostatic Precipitator');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('PRIMARY_FUEL_INFO'), 'primaryFuelInfo', 'Primary Fuel Type', 'The primary type of fuel combusted by the unit.', null, 'Coal');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('SECONDARY_FUEL_INFO'), 'secondaryFuelInfo', 'Secondary Fuel Type', 'The secondary type of fuel combusted by the unit.', null, 'Diesel, Pipeline Natural Gas');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('SLOAD'), 'steamLoad', 'Steam Load (1000 lb/hr)', 'Rate of steam pressure generated by a unit or source produced by combusting a given heat input of fuel. (1000 lb/hr)', null, '');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('SO2_CONTROL_INFO'), 'so2ControlInfo', 'SO2 Controls', 'Method or equipment used by the combustion unit to minimize SO2 emissions.', null, 'Wet Limestone');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('SO2_MASS'), 'so2Mass', 'SO2 Mass (lbs)', 'SO2 Mass Emissions (lbs)', null, '15.7');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('SO2_MASS_LBS'), 'so2Mass', 'SO2 Mass (lbs)', 'SO2 Mass Emissions (lbs)', null, '15.7');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('SO2_MASS_MEASURE_FLG'), 'so2MassMeasureFlg', 'SO2 Mass Measure Indicator', 'Describes how the SO2 Mass values were determined.', null, 'Substitute');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('SO2_RATE'), 'so2Rate', 'SO2 Rate (lbs/mmBtu)', 'Average SO2 hourly emissions rate (lbs/mmBtu)', null, '0.011');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('SO2_RATE_MEASURE_FLG'), 'so2RateMeasureFlg', 'SO2 Rate Measure Indicator', 'Describes how the SO2 Rate values were determined.', null, 'Calculated');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('STATE'), 'state', 'State', 'State in which the facility is located.', null, 'AL');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('STATE_NAME'), 'state', 'State', 'State in which the facility is located.', null, 'AL');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('UNIT_TYPE_INFO'), 'unitType', 'Unit Type', 'Type of unit or boiler.', null, 'Tangentially-fired');

insert into camdaux.property_metadata(name, json_name, display_name, description, table_name, sample_value)
values(lower('UNITID'), 'unitId', 'Unit ID', 'Unique identifier for each unit at a facility.', null, '5');
