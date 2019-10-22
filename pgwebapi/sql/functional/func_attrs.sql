--
-- Additional api functions attributes
--

CREATE TABLE pgwebapi.func_attrs (
  nm text NOT NULL,
  mandatory boolean NOT NULL DEFAULT false,
  multiple boolean NOT NULL DEFAULT false,
  acceptable_values text[] NOT NULL DEFAULT '{}'::text[],
  conflicts text[] NOT NULL DEFAULT '{}'::text[],
  CONSTRAINT func_attrs_pkey PRIMARY KEY (nm)
);

INSERT INTO pgwebapi.func_attrs
  (nm, mandatory, multiple, acceptable_values, conflicts) VALUES

  ('uri', true, false, default, default),
  ('methods', true, true, array['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'], default);
