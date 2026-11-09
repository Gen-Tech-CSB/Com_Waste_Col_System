CREATE TYPE user_role AS ENUM ('resident', 'admin', 'collector');

CREATE TABLE barangays (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE areas (
  id SERIAL PRIMARY KEY,
  barangay_id INT NOT NULL REFERENCES barangays(id),
  name VARCHAR(100) NOT NULL,
  UNIQUE (barangay_id, name)
);

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role user_role NOT NULL DEFAULT 'resident',
  area_id INT REFERENCES areas(id),
  phone VARCHAR(20),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);