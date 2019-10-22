--
-- PGWEBAPI
-- update--001.sql
--

CREATE ROLE nginx WITH LOGIN;
CREATE SCHEMA _pgwebapi AUTHORIZATION :"schema_owner";
CREATE EXTENSION IF NOT EXISTS hstore;

-------------------------------------------------------------------------------
CREATE TABLE _pgwebapi.error (
  id serial NOT NULL,
  uri text NOT NULL,
  diag json,
  request hstore NOT NULL,
  CONSTRAINT error_pkey PRIMARY KEY (id)
);
-------------------------------------------------------------------------------
