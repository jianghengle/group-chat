-- +micrate Up
CREATE TABLE groups(
  id BIGSERIAL PRIMARY KEY,
  name character varying NOT NULL,
  category character varying,
  description character varying,
  status character varying,
  owner_id INTEGER,
  timestamp BIGINT,
  created_at timestamp without time zone,
  updated_at timestamp without time zone
);

CREATE INDEX group_owner_id_index ON groups (owner_id);

-- +micrate Down
DROP INDEX group_owner_id_index;

DROP TABLE groups;
