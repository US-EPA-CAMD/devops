-- Table: camdecmpswks.unit_fuel

-- DROP TABLE camdecmpswks.unit_fuel;

CREATE TABLE camdecmpswks.unit_fuel
(
    uf_id character varying(45) COLLATE pg_catalog."default" NOT NULL,
    unit_id numeric(38,0) NOT NULL,
    fuel_type character varying(7) COLLATE pg_catalog."default" NOT NULL,
    begin_date date NOT NULL,
    end_date date,
    indicator_cd character varying(7) COLLATE pg_catalog."default",
    act_or_proj_cd character varying(7) COLLATE pg_catalog."default",
    ozone_seas_ind numeric(1,0),
    dem_so2 character varying(7) COLLATE pg_catalog."default",
    dem_gcv character varying(7) COLLATE pg_catalog."default",
    sulfur_content numeric(5,4),
    userid character varying(8) COLLATE pg_catalog."default" NOT NULL,
    add_date date NOT NULL,
    update_date date,
    CONSTRAINT pk_unit_fuel PRIMARY KEY (uf_id),
    CONSTRAINT uq_unit_fuel UNIQUE (unit_id, fuel_type, begin_date),
    CONSTRAINT fk_unit_fuel_dem_method_code_gcv FOREIGN KEY (dem_gcv)
        REFERENCES camdecmpsmd.dem_method_code (dem_method_cd) MATCH SIMPLE,
    CONSTRAINT fk_unit_fuel_dem_method_code_so2 FOREIGN KEY (dem_so2)
        REFERENCES camdecmpsmd.dem_method_code (dem_method_cd) MATCH SIMPLE,
    CONSTRAINT fk_unit_fuel_fuel_indicator_code FOREIGN KEY (indicator_cd)
        REFERENCES camdecmpsmd.fuel_indicator_code (fuel_indicator_cd) MATCH SIMPLE,
    CONSTRAINT fk_unit_fuel_fuel_type_code FOREIGN KEY (fuel_type)
        REFERENCES camdecmpsmd.fuel_type_code (fuel_type_cd) MATCH SIMPLE,
    CONSTRAINT fk_unit_fuel_unit FOREIGN KEY (unit_id)
        REFERENCES camd.unit (unit_id) MATCH SIMPLE,
    CONSTRAINT ck_unit_fuel_act_or_proj_cd CHECK (act_or_proj_cd::text = ANY (ARRAY['A'::character varying, 'P'::character varying, NULL::character varying]::text[]))
);