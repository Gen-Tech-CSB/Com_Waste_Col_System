CREATE TYPE waste_type AS ENUM ('biodegradable', 'non_biodegradable', 'recyclable', 'special');

CREATE TABLE collection_schedules (
  id SERIAL PRIMARY KEY,
  area_id INT NOT NULL REFERENCES areas(id),
  day_of_week SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  waste_type waste_type NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (end_time > start_time)
);
