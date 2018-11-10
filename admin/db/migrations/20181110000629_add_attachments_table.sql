-- +micrate Up
CREATE TABLE attachments(
  id BIGSERIAL PRIMARY KEY,
  key character varying,
  filename character varying,
  location character varying,
  created_at timestamp without time zone,
  updated_at timestamp without time zone
);

CREATE INDEX attachment_key_index ON attachments (key);

-- +micrate Down
DROP INDEX attachment_key_index;

DROP TABLE attachments;