
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION www_pub._request_handler(IN pgwebapi.request, OUT pgwebapi.response)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
--
-- Кастомный обработчик запросов pub api
--
DECLARE
  v_error json;
BEGIN
  DECLARE
    -- diag vars:
    d_sqlstate text;
    d_message text;
  BEGIN
    -- вызвать api функцию
    EXECUTE 'SELECT (r).* FROM '||quote_ident('www_pub')||'.'||quote_ident($1.route.proc)||'($1) r'
      INTO $2
      USING $1;
  EXCEPTION WHEN OTHERS THEN
	  GET STACKED DIAGNOSTICS d_sqlstate = RETURNED_SQLSTATE,
                            d_message = MESSAGE_TEXT;

    IF d_sqlstate = 'P2400' THEN
      v_error = d_message::json;
    ELSE
      RAISE;
    END IF;
  END;

  IF v_error NOTNULL THEN
    $2.status = 400;
    $2.body = v_error;
  END IF;
END;
$function$;
--------------------------------------------------------------------------------
