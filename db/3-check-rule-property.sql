-- Table: camdecmpsaux.check_rule_property

-- DROP TABLE camdecmpsaux.check_rule_property;

CREATE TABLE camdecmpsaux.check_rule_property
(
    property_id integer NOT NULL,
    check_rule_category_cd character varying NOT NULL,
    collection_item_source character varying,
    CONSTRAINT pk_check_rule_property PRIMARY KEY (property_id, check_rule_category_cd),
    CONSTRAINT fk_check_rule_property_property FOREIGN KEY (property_id)
        REFERENCES camdecmpsaux.property_metadata (property_id) MATCH SIMPLE,
    CONSTRAINT fk_check_rule_property_category FOREIGN KEY (check_rule_category_cd)
        REFERENCES camdecmpsaux.check_rule_category (check_rule_category_cd) MATCH SIMPLE,
    CONSTRAINT fk_check_rule_property_collection_item_source FOREIGN KEY (collection_item_source)
        REFERENCES camdecmpsaux.check_rule_category (check_rule_category_cd) MATCH SIMPLE
);

COMMENT ON TABLE camdecmpsaux.check_rule_property
    IS 'Property names for Code Effects Flex Source object.';

COMMENT ON COLUMN camdecmpsaux.check_rule_property.property_id
    IS 'Property associated with the check rule category.';

COMMENT ON COLUMN camdecmpsaux.check_rule_property.check_rule_category_cd
    IS 'Category associated with the check rule property.';

COMMENT ON COLUMN camdecmpsaux.check_rule_property.collection_item_source
    IS 'Flex Source type of individual items within a collection property.';

-- Index: idx_check_rule_property_property

-- DROP INDEX camdecmpsaux.idx_check_rule_property_property;

CREATE INDEX idx_check_rule_property_property
    ON camdecmpsaux.check_rule_property USING btree
    (property_id ASC NULLS LAST);

-- Index: idx_check_rule_property_category

-- DROP INDEX camdecmpsaux.idx_check_rule_property_category;

CREATE INDEX idx_check_rule_property_category
    ON camdecmpsaux.check_rule_property USING btree
    (check_rule_category_cd ASC NULLS LAST);

-- Index: idx_check_rule_property_collection_item_source

-- DROP INDEX camdecmpsaux.idx_check_rule_property_collection_item_source;

CREATE INDEX idx_check_rule_property_collection_item_source
    ON camdecmpsaux.check_rule_property USING btree
    (collection_item_source ASC NULLS LAST);


--insert into camdecmpsaux.check_rule_property(property_id, check_rule_category_cd, collection_item_source)
--values();