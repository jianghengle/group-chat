-- +micrate Up
ALTER TABLE users ADD COLUMN status VARCHAR;


-- +micrate Down
ALTER TABLE users DROP COLUMN status;
