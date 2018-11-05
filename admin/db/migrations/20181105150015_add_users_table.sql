-- +micrate Up
CREATE TABLE users(
  id BIGSERIAL PRIMARY KEY,
  email character varying NOT NULL,
  encrypted_password character varying,
  auth_token character varying,
  role character varying,
  first_name character varying,
  last_name character varying,
  created_at timestamp without time zone,
  updated_at timestamp without time zone
);

CREATE INDEX user_email_index ON users (email);
CREATE INDEX user_auth_token_index ON users (auth_token);


-- +micrate Down
DROP INDEX user_auth_token_index;
DROP INDEX user_email_index;

DROP TABLE users;