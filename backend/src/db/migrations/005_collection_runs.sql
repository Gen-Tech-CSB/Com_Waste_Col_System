CREATE TYPE run_status AS ENUM ('pending', 'collected', 'partial', 'not_collected', 'missed');

CREATE TABLE collection_runs (
  id SERIAL PRIMARY KEY,
  schedule_id INT NOT NULL REFERENCES collection_schedules(id) ON DELETE CASCADE,
  run_date DATE NOT NULL,
  status run_status NOT NULL DEFAULT 'pending',
  reason VARCHAR(255),
  marked_by INT REFERENCES users(id),
  marked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (schedule_id, run_date)
);

CREATE INDEX idx_runs_date ON collection_runs (run_date, status);