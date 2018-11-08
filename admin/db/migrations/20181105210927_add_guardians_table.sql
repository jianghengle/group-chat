-- +micrate Up
CREATE TABLE guardians(
  id BIGSERIAL PRIMARY KEY,
  parent_id INTEGER,
  child_id INTEGER,
  master bool,
  relation character varying,
  created_at timestamp without time zone,
  updated_at timestamp without time zone
);

CREATE INDEX guardian_parent_index ON guardians (parent_id);
CREATE INDEX guardian_child_index ON guardians (child_id);


-- +micrate Down
DROP INDEX guardian_child_index;
DROP INDEX guardian_parent_index;

DROP TABLE guardians;