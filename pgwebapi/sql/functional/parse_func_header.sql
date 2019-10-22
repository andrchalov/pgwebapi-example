--
-- pgwebapi.parse_function_header()
--

--------------------------------------------------------------------------------
CREATE FUNCTION pgwebapi.parse_func_header(
  IN a_src text,
	OUT title text,
	OUT comments text,
	OUT attrs hstore
)
  LANGUAGE plpgsql
AS $$
--
-- Функция парсинга заголовка тела api функции
--
-- Следует передавать в качестве src значение procsrc из каталога
-- pg_catalog.pg_proc
--
DECLARE
  v_header text NOT NULL = '';
	v_line text;
	v_regexp text[];
	v_val text;
BEGIN
	title = '';
	comments = '';
	attrs = ''::hstore;

  FOR v_line IN SELECT r FROM regexp_split_to_table(a_src, E'\n') r
	LOOP
    IF v_line ~ '^--(.+)' THEN
			v_regexp = regexp_matches(v_line, '^--\s*([a-z0-9\_\-]+)\s*:\s*(.+)');

			IF v_regexp NOTNULL THEN
 			  PERFORM pgwebapi.assert(comments = '');

			  attrs = attrs || hstore(v_regexp[1], v_regexp[2]);
			ELSE
			  SELECT r[1] INTO STRICT v_val
				  FROM regexp_matches(v_line, '^--\s*(.+)') r;

				IF attrs = ''::hstore AND comments = '' THEN
          title = title || v_val || ' ';
				ELSE
					comments = comments || v_val || E'\n';
				END IF;
			END IF;
		ELSIF v_line ~ '\s*' OR v_line ~ '^--\s*' THEN
		  -- ignore
		ELSE
			EXIT;
		END IF;
	END LOOP;

	title = rtrim(title);
END;
$$;
--------------------------------------------------------------------------------
