--
-- Public www api
--

--------------------------------------------------------------------------------
CREATE SCHEMA www_pub AUTHORIZATION :schema_owner;
COMMENT ON SCHEMA www_pub IS 'Public www api';
--------------------------------------------------------------------------------

CREATE TABLE www_pub.func_attrs() INHERITS (pgwebapi.func_attrs);

SET LOCAL SESSION AUTHORIZATION :schema_owner;

\ir _request_handler.sql
\ir _response_handler.sql

\ir index.sql
\ir test1.sql
\ir test2.sql

RESET SESSION AUTHORIZATION;
