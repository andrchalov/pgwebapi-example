--
-- pgwebapi.types
--

--------------------------------------------------------------------------------
CREATE TYPE pgwebapi.request_method AS ENUM (
  'GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'
);
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE TYPE pgwebapi.request AS (
	area text,
	host text,
	path text,
	args jsonb,
	remote_addr inet,
  remote_host text,
	user_agent text,
  cookies hstore,
	body json,
  body_raw text,
	params hstore,
	method text,
	server_host text,
	server_addr text,
	headers json,
	route pgwebapi.route,
	custom jsonb,
  resp_headers json,
  status smallint,
	body_bytes_sent bigint,
  request_completion text
);
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE TYPE pgwebapi.response AS (
  body text,  -- NULL = ''
	status int, -- NULL = 200
	headers jsonb,
  commands jsonb  -- system commands (interlal redirect, speed limit, etc.)
);
--------------------------------------------------------------------------------
