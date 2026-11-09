CREATE TYPE report_category AS ENUM ('missed_pickup', 'illegal_dumping', 'overflowing_bin', 'other');
CREATE TYPE report_status AS ENUM ('submitted', 'under_review', 'in_progress', 'resolved', 'rejected');

CREATE SEQUENCE report_ref_seq;

CREATE TABLE reports (
  id SERIAL PRIMARY KEY,
  reference_no VARCHAR(20) NOT NULL UNIQUE
    DEFAULT ('WR-' || to_char(now(), 'YYYY') || '-' || lpad(nextval('report_ref_seq')::text, 5, '0')),
  user_id INT NOT NULL REFERENCES users(id),
  area_id INT NOT NULL REFERENCES areas(id),
  category report_category NOT NULL,
  description TEXT NOT NULL,
  location_note VARCHAR(255),
  latitude NUMERIC(9,6),
  longitude NUMERIC(9,6),
  status report_status NOT NULL DEFAULT 'submitted',
  assigned_to INT REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK ((latitude IS NULL) = (longitude IS NULL))
);

CREATE INDEX idx_reports_user ON reports (user_id, created_at DESC);
CREATE INDEX idx_reports_status ON reports (status);
CREATE INDEX idx_reports_area ON reports (area_id);

CREATE TABLE report_photos (
  id SERIAL PRIMARY KEY,
  report_id INT NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
  file_path TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE report_status_history (
  id SERIAL PRIMARY KEY,
  report_id INT NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
  status report_status NOT NULL,
  remarks TEXT,
  changed_by INT REFERENCES users(id),
  changed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);