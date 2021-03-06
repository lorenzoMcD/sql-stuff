--11/18/19
DECLARE
  MYCOUNTER NUMBER (2) := 0;
BEGIN
  LOOP
    MYCOUNTER := MYCOUNTER + 1;
    Dbms_Output.PUT_LINE ('Value is' || MYCOUNTER);
    IF MYCOUNTER = 20 THEN
        EXIT;
      END IF;
      Dbms_Output.PUT_LINE('Still in the loop');
      END LOOP;
      Dbms_Output.PUT_LINE('The loop ended.');
END;
/

DECLARE
  MYCOUNTER NUMBER (2) := 0;
BEGIN
  LOOP
      MYCOUNTER := MYCOUNTER + 1;
      Dbms_Output.PUT_LINE('NOW THE COUNTER IS ' || MYCOUNTER);
      EXIT WHEN MYCOUNTER = 20;
      Dbms_Output.PUT_LINE('STILL IN THE LOOP');
      END LOOP;
      Dbms_Output.PUT_LINE('OUT OF THE LOOP');
END;
/

--11QER/31
--SELECT THE EASY WAY
--NEVER NAME THE VARIABLE AND THE ATTRIBUTE EXACTLY THE SAME
DECLARE
  PRICE PRODUCT.P_PRICE%TYPE;
  QTY   PRODUCT.P_QOH%TYPE;
  TOTAL NUMBER(12,2);
  CODE PRODUCT.P_CODE%TYPE;
BEGIN
  CODE := '11QER/31';
  SELECT P_PRICE, P_QOH
  INTO PRICE, QTY
  FROM PRODUCT
  WHERE P_CODE = CODE;
  TOTAL := PRICE * QTY;
  Dbms_Output.PUT_LINE('TOTAL IS  ' || TOTAL);
END;
/

DECLARE
  PRODROW PRODUCT%ROWTYPE;
  TOTAL NUMBER (12,2);
  CODE PRODUCT.P_CODE%TYPE := '11QER/31';
BEGIN
  SELECT *
  INTO PRODROW
  FROM PRODUCT
  WHERE P_CODE = CODE;
  TOTAL := PRODROW.P_PRICE * PRODROW.P_QOH;
  Dbms_Output.PUT_LINE('THE TOTAL FOR ' || PRODROW.P_DESCRIPT || ' IS ' || TOTAL);
END;
/

--SELECT THE HARD WAY
CREATE OR REPLACE PROCEDURE PRODTOTALS AS
BEGIN
  DECLARE
    CURSOR PROD_C IS SELECT P_CODE, P_DESCRIPT, P_PRICE, P_QOH
                      FROM PRODUCT JOIN VENDOR ON PRODUCT.V_CODE = VENDOR.V_CODE
                      WHERE V_STATE = 'TN';
    PRODROW PROD_C%ROWTYPE;
    TOTAL NUMBER (12,2);
  BEGIN
   OPEN PROD_C;
   LOOP
    FETCH PROD_C INTO PRODROW;
    EXIT WHEN PROD_C%FOUND = FALSE;
    TOTAL := PRODROW.P_PRICE * PRODROW.P_QOH;
    Dbms_Output.PUT_LINE('THE TOTAL FOR ' || PRODROW.P_CODE || ', ' || PRODROW.P_DESCRIPT
                          || ' IS ' || TOTAL);
  END LOOP;
  CLOSE PROD_C;
  Dbms_Output.PUT_LINE('FINISHED.');
  END;
END;
/

SELECT * FROM USER_PROCEDURES;

EXEC PRODTOTALS;




















