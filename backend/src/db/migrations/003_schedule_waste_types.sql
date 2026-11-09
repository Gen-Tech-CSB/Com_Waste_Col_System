ALTER TABLE collection_schedules
  ADD COLUMN waste_types TEXT[] NOT NULL
  DEFAULT ARRAY['biodegradable','non_biodegradable','recyclable'];

UPDATE collection_schedules SET waste_types = ARRAY[waste_type::text];

ALTER TABLE collection_schedules DROP COLUMN waste_type;
DROP TYPE waste_type;

ALTER TABLE collection_schedules
  ADD CONSTRAINT chk_waste_types
  CHECK (cardinality(waste_types) >= 1
    AND waste_types <@ ARRAY['biodegradable','non_biodegradable','recyclable','special']);

CREATE UNIQUE INDEX uq_schedule_area_day_time
  ON collection_schedules (area_id, day_of_week, start_time);