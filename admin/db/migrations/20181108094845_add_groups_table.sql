-- +micrate Up
CREATE TABLE groups(
  id BIGSERIAL PRIMARY KEY,
  name character varying NOT NULL,
  category character varying,
  description character varying,
  capacity INTEGER,
  access character varying,
  enroll character varying,
  owner_id INTEGER,
  timestamp BIGINT,
  created_at timestamp without time zone,
  updated_at timestamp without time zone
);

-- +micrate Down
DROP TABLE groups;
