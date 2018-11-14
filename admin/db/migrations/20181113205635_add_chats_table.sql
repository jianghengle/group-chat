-- +micrate Up
CREATE TABLE chats(
  id BIGSERIAL PRIMARY KEY,
  user_id INTEGER,
  group_id INTEGER,
  message character varying,
  timestamp BIGINT,
  attachment_key character varying,
  created_at timestamp without time zone,
  updated_at timestamp without time zone
);

CREATE INDEX chat_group_index ON chats (group_id);
CREATE INDEX chat_user_index ON chats (user_id);

-- +micrate Down
DROP INDEX chat_user_index;
DROP INDEX chat_group_index;

DROP TABLE chats;
