-- +micrate Up
CREATE TABLE memberships(
  id BIGSERIAL PRIMARY KEY,
  user_id INTEGER,
  group_id INTEGER,
  timestamp BIGINT,
  created_at timestamp without time zone,
  updated_at timestamp without time zone
);

CREATE INDEX membership_user_index ON memberships (user_id);
CREATE INDEX membership_group_index ON memberships (group_id);

-- +micrate Down
DROP INDEX membership_group_index;
DROP INDEX membership_user_index;

DROP TABLE memberships;
