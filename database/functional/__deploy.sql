
CREATE SCHEMA data AUTHORIZATION :"schema_owner";

\ir www_pub/__deploy.sql

SELECT pgwebapi.init();
