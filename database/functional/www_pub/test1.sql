
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION www_pub.test1(IN pgwebapi.request, OUT pgwebapi.response)
  LANGUAGE plpgsql
AS $function$
--
-- Test1
--
-- uri: /test1
-- methods: GET
--
DECLARE

BEGIN
  $2.body = 'Current time: '||(current_time)::text;
END;
$function$;
--------------------------------------------------------------------------------
