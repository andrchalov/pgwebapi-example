
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION www_pub.test2(IN pgwebapi.request, OUT pgwebapi.response)
  LANGUAGE plpgsql
AS $function$
--
-- Test2
--
-- uri: /test2
-- methods: GET
--
DECLARE

BEGIN
  $2.body = jsonb_pretty(row_to_json($1)::jsonb)::text;
END;
$function$;
--------------------------------------------------------------------------------
