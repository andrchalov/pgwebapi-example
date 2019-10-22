--
-- PGWEBAPI
--

--------------------------------------------------------------------------------
CREATE SCHEMA pgwebapi AUTHORIZATION :"schema_owner";
GRANT USAGE ON SCHEMA pgwebapi TO nginx;
--------------------------------------------------------------------------------

SET LOCAL SESSION AUTHORIZATION :"schema_owner";

\ir assert.sql
\ir func_attrs.sql
\ir routes.sql
\ir init.sql
\ir types.sql
\ir parse_func_header.sql
\ir compose_request.sql
\ir cookie_parse.sql
\ir route_parse.sql
\ir error.sql
\ir http_error.sql
\ir api_request.sql
\ir error_debug.sql

RESET SESSION AUTHORIZATION;
