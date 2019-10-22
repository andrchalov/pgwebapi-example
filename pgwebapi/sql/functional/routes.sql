--
-- pgwebapi.route
--

--------------------------------------------------------------------------------
CREATE TABLE pgwebapi.route (
	id text NOT NULL,
  area text NOT NULL,
  proc text NOT NULL,
	nm text NOT NULL,
	params text[] NOT NULL,
	regexp_path text NOT NULL,
	func_attrs jsonb NOT NULL,
	comments text NOT NULL,
	CONSTRAINT route_pkey PRIMARY KEY (id),
  CONSTRAINT route_ukey0 UNIQUE (proc, area)
);
--------------------------------------------------------------------------------
