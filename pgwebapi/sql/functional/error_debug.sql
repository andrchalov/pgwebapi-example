
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgwebapi.error_debug(
  a_error_id bigint,
  a_isolated boolean DEFAULT true
)
  RETURNS void
  LANGUAGE plpgsql
AS $function$
DECLARE
  v_apierror record;
  v_request pgwebapi.request;
  v_response pgwebapi.response;
BEGIN
  SELECT id, request INTO v_apierror
    FROM _pgwebapi.error
    WHERE id = $1;
  --
  IF NOT found THEN
    RAISE 'Error #% not found', $1;
  END IF;

  v_request = populate_record(v_request, v_apierror.request);

  -- прогнать запрос через api-специфичную функцию обработки запроса
  EXECUTE 'SELECT (r).* FROM '||quote_ident('www_'||v_request.area)||'._request_handler($1) r'
    INTO v_response
    USING v_request;

  IF $2 THEN
    RAISE 'SUCCESS'
      USING DETAIL = jsonb_pretty(row_to_json(v_response)::jsonb);
  ELSE
    RAISE INFO 'SUCCESS';
  END IF;
END;
$function$;
-------------------------------------------------------------------------------
