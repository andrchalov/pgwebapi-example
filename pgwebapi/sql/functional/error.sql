--
-- pgwebapi.error()
--
-- Необходимо отделять исключения от обычных ошибок, предусмотренных системой.
-- Для этого определен код "P1001" исключения.
-- Перехват этого исключения не должен расцениваться как исключение (баг), а как
-- ошибка, допустимая системой.
--

--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgwebapi.error(a_msg text, a_code text DEFAULT null)
  RETURNS boolean
  LANGUAGE plpgsql
AS $$
--
-- Генерация ошибки.
--
BEGIN
  PERFORM pgwebapi.assert(NULLIF(a_msg, '') NOTNULL, 'Null argument');

  RAISE '%', a_msg
    USING errcode = 'P1001',
          hint = COALESCE(a_code, '');
END;
$$;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgwebapi.error(a_cond boolean, a_msg text, a_code text DEFAULT null)
  RETURNS boolean
  LANGUAGE plpgsql
AS $$
--
-- Генерация ошибки, если утверждение ложно.
--
BEGIN
  PERFORM pgwebapi.assert(
    a_cond NOTNULL AND NULLIF(a_msg, '') NOTNULL,
    'Null argument'
  );

	IF (a_cond) THEN
    RAISE '%', a_msg
      USING errcode = 'P1001',
            hint = COALESCE(a_code, '');
  ELSE
    RETURN true;
  END IF;
END;
$$;
--------------------------------------------------------------------------------
