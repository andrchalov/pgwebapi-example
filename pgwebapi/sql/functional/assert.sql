--
-- pgwebapi.assert()
--

--------------------------------------------------------------------------------
CREATE FUNCTION pgwebapi.assert(
  a_cond boolean DEFAULT false,
	a_msg text DEFAULT 'Assertion failed'
)
  RETURNS boolean
  LANGUAGE plpgsql
AS $$
--
-- Проверка утверждения a_cond = true
-- Функция используется для системных assert-ов на баги, пользователи не должны
-- видеть сообщения.
--
BEGIN
  IF (a_cond ISNULL OR a_msg ISNULL) THEN
	  RAISE 'Null argument';
	END IF;

	IF (NOT a_cond) THEN
    RAISE '%', a_msg;
  ELSE
    RETURN TRUE;
  END IF;
END;
$$;
--------------------------------------------------------------------------------
