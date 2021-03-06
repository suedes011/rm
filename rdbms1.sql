CREATE TABLE AUTHOR
(
  AUTHOR_ID INTEGER PRIMARY KEY,
  AUTHOR_NAME VARCHAR2(20) NOT NULL,
  MEIBI_METRIC NUMBER NOT NULL,
  MEIBIX_METRIC NUMBER NOT NULL
);

CREATE TABLE POST
(
  POST_ID INTEGER PRIMARY KEY,
  POST_TITLE VARCHAR2(100) NOT NULL,
  AUTHOR_ID INTEGER NOT NULL,
  POST_CONTENT VARCHAR2(3000) NOT NULL,
  POST_URL VARCHAR2(150) NOT NULL,
  POST_DATE DATE NOT NULL,
  NW INTEGER NOT NULL,
  NWWS INTEGER NOT NULL,
  MEIBI_METRIC NUMBER NOT NULL,
  MEIBIX_METRIC NUMBER NOT NULL,
  CONSTRAINT AFK FOREIGN KEY(AUTHOR_ID) REFERENCES AUTHOR(AUTHOR_ID)
);

CREATE TABLE INLINK
(
  INLINK_ID INTEGER NOT NULL,
  POST_ID INTEGER NOT NULL,
  INLINK_TITLE VARCHAR2(100) NOT NULL,
  INLINK_DATE DATE NOT NULL,
  INLINK_URL VARCHAR2(150) NOT NULL,
  CONSTRAINT IPK PRIMARY KEY(INLINK_ID,POST_ID),
  CONSTRAINT IFK FOREIGN KEY(POST_ID) REFERENCES POST(POST_ID)
);

CREATE TABLE COMMENTS
(
  COMMENT_ID INTEGER NOT NULL,
  POST_ID INTEGER NOT NULL,
  COMMENT_CONTENT VARCHAR2(2000) NOT NULL,
  COMMENT_DATE VARCHAR(5) NOT NULL,
  CONSTRAINT CPK PRIMARY KEY(COMMENT_ID,POST_ID),
  CONSTRAINT CFK FOREIGN KEY(POST_ID) REFERENCES POST(POST_ID)
);

SELECT COUNT(*) FROM AUTHOR INNER JOIN POST ON AUTHOR.AUTHOR_ID=POST.AUTHOR_ID WHERE AUTHOR_NAME='Jason Kincaid';

--SELECT * FROM () INNER JOIN COMMENTS ON AID


--SELECT AUTHOR.AUTHOR_ID AS AID,COUNT(AUTHOR.AUTHOR_ID) AS NOP FROM AUTHOR INNER JOIN POST ON AUTHOR.AUTHOR_ID=POST.AUTHOR_ID GROUP BY AUTHOR.AUTHOR_ID;
SELECT POST_DATE,COUNT(POST_DATE) FROM POST GROUP BY POST_DATE ORDER BY COUNT(POST_DATE);
SELECT POST_DATE FROM (SELECT POST_DATE,COUNT(*) AS CO FROM POST GROUP BY POST_DATE ORDER BY COUNT(*) DESC) WHERE ROWNUM<=1;


SELECT AUTHOR_NAME,COUNT(AUTHOR_NAME) FROM AUTHOR INNER JOIN POST ON AUTHOR.AUTHOR_ID=POST.AUTHOR_ID GROUP BY AUTHOR_NAME HAVING COUNT(AUTHOR_NAME)>(SELECT COUNT(*) FROM AUTHOR  INNER JOIN POST ON AUTHOR.AUTHOR_ID=POST.AUTHOR_ID WHERE AUTHOR_NAME='&AUTHOR_NAME');

SELECT AUTHOR.AUTHOR_ID AS AID,COUNT(*) AS PCO FROM AUTHOR INNER JOIN POST ON AUTHOR.AUTHOR_ID=POST.AUTHOR_ID GROUP BY AUTHOR.AUTHOR_ID;
SELECT POST.POST_ID AS PID1,COUNT(*) AS CCO FROM POST INNER JOIN COMMENTS ON POST.POST_ID=COMMENTS.POST_ID GROUP BY POST.POST_ID;
SELECT POST.POST_ID AS PID2,COUNT(*) AS ICO FROM POST INNER JOIN INLINK ON POST.POST_ID=INLINK.POST_ID GROUP BY POST.POST_ID;
SELECT * FROM 
  (SELECT POST.POST_ID AS PID1,COUNT(*) AS CCO FROM POST INNER JOIN COMMENTS ON POST.POST_ID=COMMENTS.POST_ID GROUP BY POST.POST_ID) 
  INNER JOIN 
  (SELECT POST.POST_ID AS PID2,COUNT(*) AS ICO FROM POST INNER JOIN INLINK ON POST.POST_ID=INLINK.POST_ID GROUP BY POST.POST_ID) 
ON PID1=PID2;
SELECT * FROM () FULL OUTER JOIN () ON  
SET SERVEROUTPUT ON;

--1
DECLARE 
  CURSOR F10 IS SELECT AUTHOR.AUTHOR_NAME,COUNT(AUTHOR.AUTHOR_NAME) AS CO FROM AUTHOR INNER JOIN POST ON AUTHOR.AUTHOR_ID=POST.AUTHOR_ID GROUP BY AUTHOR.AUTHOR_NAME;
  ANAME F10%ROWTYPE;
BEGIN
  OPEN F10;
  LOOP
    FETCH F10 INTO ANAME;
    EXIT WHEN F10%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(ANAME.AUTHOR_NAME || ' ' || ANAME.CO);
  END LOOP;
  CLOSE F10;
END;

--2
DECLARE 
  CURSOR F10 IS SELECT AUTHOR.AUTHOR_NAME FROM AUTHOR FULL OUTER JOIN POST ON AUTHOR.AUTHOR_ID=POST.AUTHOR_ID WHERE AUTHOR_NAME='Marc Benioff';
  ANAME AUTHOR.AUTHOR_NAME%TYPE;
  CO INTEGER;
BEGIN
  OPEN F10;
  LOOP
    FETCH F10 INTO ANAME;
    CO := SQL%ROWCOUNT;
    EXIT WHEN F10%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(ANAME || '   ->   ' || CO);
  END LOOP;
  CLOSE F10;
END;
  
--3  
DECLARE 
  CURSOR F10 IS SELECT POST.POST_TITLE,POST.POST_DATE,POST.POST_URL FROM AUTHOR INNER JOIN POST ON AUTHOR.AUTHOR_ID=POST.AUTHOR_ID WHERE AUTHOR_NAME='John Biggs';
  ANAME F10%ROWTYPE;
BEGIN
  OPEN F10;
  LOOP
    FETCH F10 INTO ANAME;
    EXIT WHEN F10%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(ANAME.POST_TITLE || '   ||   ' || ANAME.POST_DATE || '   ||   ' ||ANAME.POST_URL);
  END LOOP;
  CLOSE F10;
END;

--4
DECLARE 
  CURSOR F10 IS SELECT PT,POST_DATE,CO,POST_URL FROM (SELECT POST.POST_TITLE AS PT,COUNT(POST_TITLE) AS CO FROM POST INNER JOIN COMMENTS ON POST.POST_ID=COMMENTS.POST_ID GROUP BY POST.POST_TITLE) INNER JOIN POST ON PT=POST.POST_TITLE ORDER BY CO;
  POS POST.POST_TITLE%TYPE;
  COU INTEGER;
  DT POST.POST_DATE%TYPE;
  UR POST.POST_URL%TYPE;
BEGIN
  OPEN F10;
  LOOP
    FETCH F10 INTO POS, DT, COU, UR;
    EXIT WHEN F10%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(POS || '   ||   ' || DT || '   ||   ' || COU || '   ||   ' || UR);
  END LOOP;
  CLOSE F10;
END;

--5
DECLARE 
  CURSOR F10 IS SELECT * FROM (SELECT ANAME AS AUTHOR_NAME,COUNT(ANAME) AS NO_OF_COMMENTS FROM (SELECT AUTHOR.AUTHOR_NAME AS ANAME,POST_ID AS PID FROM AUTHOR INNER JOIN POST ON AUTHOR.AUTHOR_ID=POST.AUTHOR_ID) INNER JOIN COMMENTS ON PID=POST_ID GROUP BY ANAME ORDER BY NO_OF_COMMENTS DESC) WHERE ROWNUM<=10;
  ANAME AUTHOR.AUTHOR_NAME%TYPE;
  CO INTEGER;
BEGIN
  OPEN F10;
  LOOP
    FETCH F10 INTO ANAME, CO;
    EXIT WHEN F10%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(ANAME || '   ->   ' || CO);
  END LOOP;
  CLOSE F10;
END;

--PROCEDURES
CREATE OR REPLACE PROCEDURE HELLO AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('Hello Wolrd!');
END;

--a1
CREATE OR REPLACE PROCEDURE PA1 AS
  CURSOR F10 IS SELECT POST_TITLE,POST_DATE,POST_URL,NW FROM POST;
  POST_R F10%ROWTYPE;
  POSTRANKP CHAR;
  PROCEDURE RANK(NW IN NUMBER, POSTRANK OUT CHAR) IS
    BEGIN
      IF NW >= 500 THEN
        POSTRANK := 'A';
      ELSIF NW >= 200 THEN
        POSTRANK := 'B';
      ELSIF NW < 200 THEN
        POSTRANK := 'C';
      ELSE
        POSTRANK := 'F';
      END IF;
    END;
BEGIN
  OPEN F10;
  LOOP
    FETCH F10 INTO POST_R;
    EXIT WHEN F10%NOTFOUND;
    RANK(POST_R.NW,POSTRANKP);
    DBMS_OUTPUT.PUT_LINE(POST_R.POST_TITLE || '   ||   ' || POSTRANKP || '   ||   ' || POST_R.POST_DATE || '   ||   ' || POST_R.POST_URL);
  END LOOP;
  CLOSE F10;
END;

--a2
CREATE OR REPLACE PROCEDURE PA2 AS 
  CURSOR F10 IS SELECT AUTHOR.AUTHOR_ID AS AID,NW,AUTHOR.MEIBI_METRIC AS MM FROM AUTHOR INNER JOIN POST ON AUTHOR.AUTHOR_ID=POST.POST_ID WHERE NW>100;  
  AUID AUTHOR.AUTHOR_ID%TYPE;
  NWO POST.NW%TYPE;
  MET AUTHOR.MEIBI_METRIC%TYPE;
  PROCEDURE UPDATEMEIBI(AU IN INTEGER, N IN INTEGER) IS
  BEGIN 
    IF N >= 10 THEN
      UPDATE AUTHOR SET MEIBI_METRIC=MEIBI_METRIC*1.02 WHERE AUTHOR.AUTHOR_ID=AUID;
      --SELECT MEIBI_METRIC INTO RET WHERE AUTHOR.AUTHOR_ID=AUID;
    END IF;
  END;
BEGIN
  OPEN F10;
  LOOP
    FETCH F10 INTO AUID, NWO, MET;
    EXIT WHEN F10%NOTFOUND;
    UPDATEMEIBI(AUID,NWO);
    DBMS_OUTPUT.PUT_LINE(AUID || '   ||   ' || NWO || '   ||   ' || MET);
  END LOOP;
  CLOSE F10;
END;
EXECUTE PA2;

--f
CREATE OR REPLACE PROCEDURE PF AS
  CURSOR F10 IS SELECT AUNAME,COUNT(AUNAME) AS NOPOSTS,SUM(NW) AS SUMW,AVG(NW) AS AVGW FROM (SELECT AUTHOR_NAME AS AUNAME,AUTHOR_ID AS AID FROM (SELECT * FROM AUTHOR ORDER BY MEIBIX_METRIC DESC) WHERE ROWNUM<=100) INNER JOIN POST ON AID=POST.AUTHOR_ID GROUP BY AUNAME;
  ANAME AUTHOR.AUTHOR_NAME%TYPE;
  PONO INTEGER;
  TOTWO INTEGER;
  AVGWO INTEGER;
BEGIN
  OPEN F10;
  LOOP
    FETCH F10 INTO ANAME, PONO, TOTWO, AVGWO;
    EXIT WHEN F10%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(ANAME || '   ||   ' || PONO || '   ||   ' || TOTWO || '   ||   ' || AVGWO);
  END LOOP;
  CLOSE F10;
END;
EXECUTE PF;

--i
CREATE OR REPLACE PROCEDURE PI AS
  CURSOR F10 IS SELECT AUTHOR_NAME FROM AUTHOR INNER JOIN POST ON AUTHOR.AUTHOR_ID=POST.AUTHOR_ID GROUP BY AUTHOR_NAME HAVING COUNT(AUTHOR_NAME)>(SELECT COUNT(*) FROM AUTHOR  INNER JOIN POST ON AUTHOR.AUTHOR_ID=POST.AUTHOR_ID WHERE AUTHOR_NAME='&AUTHOR_NAME');
  ANAME AUTHOR.AUTHOR_NAME%TYPE;
BEGIN  
  OPEN F10;
  LOOP
    FETCH F10 INTO ANAME;
    EXIT WHEN F10%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(ANAME);
  END LOOP;
  CLOSE F10;
END;






















CREATE OR REPLACE FUNCTION F2(ANAME IN VARCHAR2)
RETURN NUMBER IS
  NOPOSTS INTEGER := 0;
  TOTAL_MEIBI AUTHOR.MEIBI_METRIC%TYPE := 0;
BEGIN
  SELECT SUM(MEIBI_METRIC) INTO TOTAL_MEIBI FROM POST WHERE AUTHOR_ID=(SELECT AUTHOR_ID FROM AUTHOR WHERE AUTHOR_NAME=ANAME);
  SELECT COUNT(*) INTO NOPOSTS FROM AUTHOR INNER JOIN POST ON AUTHOR.AUTHOR_ID=POST.AUTHOR_ID WHERE AUTHOR_NAME=ANAME;
  TOTAL_MEIBI := TOTAL_MEIBI / NOPOSTS;
  RETURN TOTAL_MEIBI;
END;

DECLARE
  ANAME VARCHAR(20);
  RET NUMBER := 0;
BEGIN
  ANAME := '&ANAME';
  RET := F2(ANAME);
  DBMS_OUTPUT.PUT_LINE('Average MEIBI Metric Score For ' || ANAME || ': ' || RET);
END;

CREATE OR REPLACE FUNCTION F5(Y IN INTEGER)
RETURN INTEGER IS
  NOPOSTS INTEGER := 0;
BEGIN
  SELECT COUNT(*) INTO NOPOSTS FROM POST WHERE EXTRACT(YEAR FROM POST_DATE)=Y;
  RETURN NOPOSTS;
END;

DECLARE
  Y INTEGER;
  RET INTEGER := 0;
BEGIN
  Y := &Y;
  RET := F5(Y);
  DBMS_OUTPUT.PUT_LINE('Number of Posts Published in ' || Y || ': ' || RET);
END;

CREATE OR REPLACE FUNCTION F4
RETURN DATE IS
  PDATE DATE;
BEGIN
  SELECT POST_DATE INTO PDATE FROM (SELECT POST_DATE,COUNT(*) FROM POST GROUP BY POST_DATE ORDER BY COUNT(*) DESC) WHERE ROWNUM<=1;
  RETURN PDATE;
END;

DECLARE
  RET DATE;
BEGIN
  RET := F4();
  DBMS_OUTPUT.PUT_LINE('Day on Which Most Posts Were Published: ' || RET);
END;

