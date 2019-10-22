
--------------------------------------------------------------------------------
CREATE FUNCTION pgwebapi.init()
	RETURNS void
	LANGUAGE plpgsql
AS $function$
--
-- Заполнение таблицы pgwebapi.route
--
DECLARE
	v_proc record;
	v_header record;
	v_parsed_path record;

	v_func_attrs jsonb NOT NULL = '{}'::jsonb;

	v_attr record;
	v_attr_key text;
	v_attr_val jsonb;

	v_allowed_attrs jsonb;
BEGIN
	TRUNCATE pgwebapi.route;

  FOR v_proc IN
    SELECT nspname||'.'||proname AS fullname, nspname, proname, prosrc,
					 (regexp_matches(n.nspname, '^www_(\w+)$'))[1] AS area
			FROM pg_catalog.pg_proc p
      JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
			LEFT JOIN pg_catalog.pg_description d ON p.oid = d.objoid
			WHERE n.nspname ~ '^www_(\w+)$'
				AND NOT p.proname ~ '^_'
	LOOP
		v_header = pgwebapi.parse_func_header(v_proc.prosrc);

		EXECUTE format(
			'SELECT jsonb_object_agg(p.nm, row_to_json(p))
				FROM (
					TABLE pgwebapi.func_attrs UNION TABLE %I.func_attrs
				) p
			', 'www_'||v_proc.area, v_proc.proname
		) INTO v_allowed_attrs;

		-- проверить наличие всех обязательных атрибутов у функции
		FOR v_attr IN
			SELECT (p).*
				FROM jsonb_each(v_allowed_attrs) p
				WHERE p.value->'mandatory' = 'true'::jsonb
		LOOP
			IF NOT v_header.attrs ? v_attr.key THEN
				RAISE 'PGWEBAPI: Missing mandatory attribute "%" in api function "%"', v_attr.key, v_proc.fullname;
			END IF;
		END LOOP;

		SELECT jsonb_object_agg(
			key,
			CASE WHEN v_allowed_attrs->key->'multiple' = 'true'::jsonb
					 THEN to_jsonb(regexp_split_to_array(value, '\s*,\s*'))
					 ELSE to_jsonb(value)
			END
		)
		FROM each(v_header.attrs)
		INTO v_func_attrs;

		FOR v_attr_key, v_attr_val IN SELECT key, value FROM jsonb_each(v_func_attrs)
		LOOP
			-- проверка допустимости атрибута
			IF NOT v_allowed_attrs ? v_attr_key THEN
				RAISE 'PGWEBAPI: Unknown attribute "%" in api function "%"', v_attr_key, v_proc.fullname;
			END IF;

			-- если у параметра определен список допустимых значений
			IF jsonb_array_length(v_allowed_attrs->v_attr_key->'acceptable_values') > 0 THEN
				-- проверить допустимость значения
				IF NOT v_allowed_attrs->v_attr_key->'acceptable_values' @> v_attr_val
				THEN
					RAISE 'PGWEBAPI: Value "%" of attribute "%" in api function "%" not acceptable', v_attr_val, v_attr_key, v_proc.fullname;
				END IF;
			END IF;

			-- проверить взаимоисключения параметров
			IF jsonb_array_length(v_allowed_attrs->v_attr_key->'conflicts') > 0 THEN
				DECLARE
					v_key text;
				BEGIN
					FOR v_key IN SELECT jsonb_array_elements_text(v_allowed_attrs->v_attr_key->'conflicts')
					LOOP
						IF v_header.attrs ? v_key THEN
							RAISE 'PGWEBAPI: Attribute "%" should not specified with attribute "%" in function "%"', v_attr_key, v_key, v_proc.fullname;
						END IF;
					END LOOP;
				END;
			END IF;
		END LOOP;

		v_parsed_path = pgwebapi.route_parse(v_header.attrs->'uri');

		INSERT INTO pgwebapi.route (
			id, area, proc, nm, params, regexp_path, func_attrs, comments
		) VALUES (
			v_proc.fullname, v_proc.area, v_proc.proname, v_header.title,
			v_parsed_path.params, v_parsed_path.regexp_path, v_func_attrs,
			v_header.comments
		);
	END LOOP;
END;
$function$;
--------------------------------------------------------------------------------
