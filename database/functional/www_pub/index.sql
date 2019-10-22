
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION www_pub.index(IN pgwebapi.request, OUT pgwebapi.response)
  LANGUAGE plpgsql
AS $function$
--
-- Главная страница
--
-- uri: /
-- methods: GET
--
BEGIN
  $2.body = '<h1>PGWEBAPI</h1>';
  $2.body = $2.body || '<p><a href="/test1">test1</a></p>';
  $2.body = $2.body || '<p><a href="/test2">test2</a></p>';

  $2.headers = json_build_object('Content-Type', 'text/html');
END;
$function$;
--------------------------------------------------------------------------------
