-- +micrate Up
CREATE TABLE users(
  id BIGSERIAL PRIMARY KEY,
  email character varying UNIQUE NOT NULL,
  encrypted_password character varying,
  auth_token character varying,
  role character varying,
  full_name character varying,
  created_at timestamp without time zone,
  updated_at timestamp without time zone
);

CREATE INDEX user_auth_token_index ON users (auth_token);


-- +micrate Down
DROP INDEX user_auth_token_index;

DROP TABLE users;