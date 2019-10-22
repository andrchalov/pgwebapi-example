
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION www_pub._response_handler(
  IN pgwebapi.request,
  INOUT pgwebapi.response
)
 LANGUAGE plpgsql
AS $function$
--
-- Кастомный обработчик ответов app api
--
BEGIN
END;
$function$;
--------------------------------------------------------------------------------
