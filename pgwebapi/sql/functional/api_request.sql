--
-- pgwebapi.api_request()
--

--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgwebapi.api_request(
	IN a_request json,
  IN a_request_body text,
	OUT status int,
	OUT body text,
	OUT headers json,
  OUT commands json,
  OUT int_headers json,
	OUT diag json
)
  LANGUAGE plpgsql
	SECURITY DEFINER
AS $$
--
-- Запрос к WWW API
--
DECLARE
	v_request pgwebapi.request;
	v_response pgwebapi.response;
	v_route pgwebapi.route;

	-- error vars:
  e_code text;
  e_hint text;
	v_error json;
	v_message jsonb;

  -- diag vars:
  d_sqlstate text;
  d_hint text;
  d_message text;
  d_detail text;
  d_context text;
BEGIN
	v_request = pgwebapi.compose_request(a_request);

	<<internal>>
	BEGIN
		IF v_request.method <> 'GET' THEN
	  	BEGIN
	      v_request.body = a_request_body;
	    EXCEPTION WHEN invalid_text_representation THEN
				v_request.body_raw = a_request_body;
	    END;
		END IF;

		SELECT * INTO v_route
			FROM pgwebapi.route r
			WHERE r.area = v_request.area
				AND '/'||v_request.path ~* r.regexp_path
				AND r.func_attrs->'methods' @> to_jsonb(v_request.method)
			LIMIT 1;
		--
		IF NOT found THEN
			PERFORM pgwebapi.http_error(404, 'Route not found');
		END IF;

		v_request.route = v_route;

		IF v_route.params <> '{}'::text[]
		THEN
		 	SELECT hstore(v_route.params, r) INTO v_request.params
	      FROM regexp_matches('/'||v_request.path, v_route.regexp_path, 'g') r;
		END IF;

		-- прогнать запрос через api-специфичную функцию обработки запроса
		EXECUTE 'SELECT (r).* FROM '||quote_ident('www_'||v_request.area)||'._request_handler($1) r'
			INTO v_response
			USING v_request;

	EXCEPTION
	  WHEN OTHERS THEN
		  GET STACKED DIAGNOSTICS d_sqlstate = RETURNED_SQLSTATE,
	                            d_message = MESSAGE_TEXT,
	                            d_hint = PG_EXCEPTION_HINT,
	                            d_detail = PG_EXCEPTION_DETAIL,
	                            d_context = PG_EXCEPTION_CONTEXT;

  		IF d_sqlstate = 'P1001' THEN
	  		-- pgwebapi.error
        v_response.status = 400;

			  v_message = json_build_object(
					'message', d_message,
					'code', COALESCE(NULLIF(d_hint, ''), 'error')
				);
      ELSIF d_sqlstate ~ '^P2' THEN
        -- pgwebapi.http_error

        v_response.status = substring(d_sqlstate from 3 for 3)::int;
        v_message = d_message;

		  ELSE
		    -- RAISE, ext.assert, ...
				-- нестандартная ошибка, она будет обязательно учтена в логе

				v_response.status = 500;
				v_message = jsonb_build_object('message', 'Internal server error');

				diag = '{}';	-- значит что нужно заполнить diag
		  END IF;

			IF diag NOTNULL THEN
				diag = jsonb_pretty(jsonb_build_object('hint', d_hint,
																 'sqlstate', d_sqlstate,
																 'message', d_message,
																 'detail', d_detail,
																 'context', d_context,
																 'request', row_to_json(v_request)));
			END IF;

			IF diag NOTNULL THEN
				v_message = jsonb_set(v_message::jsonb, '{diag}', diag::jsonb);
			END IF;

	    v_response.body = v_message;

			v_response.headers = json_build_object(
				'Content-Type', 'application/javascript'
			);

			INSERT INTO _pgwebapi.error (uri, diag, request) VALUES (v_request.path, diag, hstore(v_request));
	END;

	-- прогнать ответ через api-специфичную функцию обработки ответа
	EXECUTE 'SELECT (r).* FROM '||quote_ident('www_'||v_request.area)||'._response_handler($1, $2) r'
		INTO v_response
		USING v_request, v_response;

	status = COALESCE(v_response.status, 200);
	body = COALESCE(v_response.body, '');
	headers = v_response.headers;
	commands = v_response.commands;
END;
$$;
--------------------------------------------------------------------------------
