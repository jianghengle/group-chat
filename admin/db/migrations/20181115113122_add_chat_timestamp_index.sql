-- +micrate Up
CREATE INDEX chat_timestamp_index ON chats (timestamp);


-- +micrate Down
DROP INDEX chat_timestamp_index;
