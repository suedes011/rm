CREATE TABLE employee(
employeeno int not null primary key,
ename varchar2(50) not null,
jobtitle varchar2(50) not null,
salary decimal(10,2),
deptno int not null);

ALTER TABLE employee
ADD FOREIGN KEY (deptno) REFERENCES department(deptno);

insert into employee values (7369,'SMITH','CLERK', ,800,10);
insert into employee values (7499,'ALLEN','SALESMAN',1600,30);
insert into employee values (7521,'WARD','SALESMAN', 1250,30);
insert into employee values (7566,'JONES','MANAGER', 2975,10);
insert into employee values (7698,'BLAKE','MANAGER', 2850,20);
insert into employee values (7782,'CLARK','MANAGER', 2450,30);
insert into employee values (7788,'SCOTT','ANALYST', 3000,20);
insert into employee values (7839,'KING','PRESIDENT',5000,10);
insert into employee values (7844,'TURNER','SALESMAN',1500,30);
insert into employee values (7876,'ADAMS','CLERK', 1100,30);
insert into employee values (7900,'JAMES','MANAGER', 12950,40);
insert into employee values (7934,'MILLER','CLERK',7000,20);
insert into employee values (7902,'FORD','ANALYST',3000,30);
insert into employee values (7654,'MARTIN','SALESMAN',1250,30);

CREATE TABLE department(
deptno int not null primary key,
dname varchar2(50) not null,
dmgrssn int not null);  

ALTER TABLE department
ADD FOREIGN KEY (dmgrssn) REFERENCES employee(employeeno);

insert into department values (10,'Accounting',7566);
insert into department values (20,'Research',7698);
insert into department values (30,'Sales',7782);
insert into department values (40,'Operations',7900);

create table trips(
tripid int not null primary key,
destinationcity varchar2(20) not null,
depart_date date not null,
return_date date not null,
ssn int not null,
expenses decimal(10,2));

ALTER TABLE trips
ADD FOREIGN KEY (ssn) REFERENCES employee(employeeno);

insert into trips values(120,'Paris','31-OCT-2021', '04-NOV-2021', 7900, 15000)
insert into trips values(115,'Mumbai',’01/09/2021’, ‘05/09/2021’, 7844, 1000);
insert into trips values(110,’Delhi’,’10/10/2021’, ‘12/10/2021’, 7900, 14000);
insert into trips values(115,’Mumbai’,’01-SEP-2021’, ’05-SEP-2021’, 7844, 1000);
insert into trips values(110,'Delhi','10-OCT-2021', '12-OCT-2021', 7900, 14000);
insert into trips values(118,'Delhi','10-OCT-2021', '12-OCT-2021', 7499, 2000);
insert into trips values(111,'Miami','31-OCT-2021', '09-OCT-2021', 7902, 2000);
insert into trips values(121,'Chennai','25-SEP-2021', '09-SEP-2021', 7654, 2000);
insert into trips values(112,'Delhi','25-SEP-2021', '29-SEP-2021', 7844, 2000);
insert into trips values(129,'LosAngels','25-AUG-2021', '09-SEP-2021', 7839, 2000);
insert into trips values(128,'Kolkatta','05-AUG-2021', '09-AUG-2021', 7566, 2000);
insert into trips values(130,'Paris','03-JAN-2021', '14-JAN-2021', 7900, 14000);
insert into trips values(127,'Delhi','05-AUG-2021', '11-AUG-2021', 7782, 2000);
insert into trips values(141,'Kolkatta','05-MAY-2022', '19-MAY-2022', 7566, 2000);
insert into trips values(142,'New York','03-APR-2022', '14-APR-2022', 7900, 14000);
insert into trips values(143,'Delhi','05-FEB-2022', '13-FEB-2022', 7782, 2000);


--1) List employee names , job titles and department names of those who are currently traveling. (stored procedure)

SELECT EMPLOYEE.ENAME,EMPLOYEE.JOBTITLE,DEPARTMENT.DNAME FROM EMPLOYEE INNER JOIN DEPARTMENT ON EMPLOYEE.DEPTNO = DEPARTMENT.DEPTNO INNER JOIN TRIPS ON EMPLOYEE.EMPLOYEENO = TRIPS.SSN WHERE TRIPS.RETURN_DATE >= SYSDATE;


CREATE OR REPLACE PROCEDURE Q1 IS
  CURSOR TEMP IS SELECT EMPLOYEE.ENAME,EMPLOYEE.JOBTITLE,DEPARTMENT.DNAME FROM EMPLOYEE INNER JOIN DEPARTMENT ON EMPLOYEE.DEPTNO = DEPARTMENT.DEPTNO INNER JOIN TRIPS ON EMPLOYEE.EMPLOYEENO = TRIPS.SSN WHERE TRIPS.RETURN_DATE >= SYSDATE;
  REC TEMP%ROWTYPE;
BEGIN
  OPEN TEMP;
  LOOP
    FETCH TEMP INTO REC;
    EXIT WHEN TEMP%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(REC.ename|| ' ' || REC.JOBTITLE || ' ' || REC.DNAME);
  END LOOP;
  CLOSE TEMP;
END;

EXECUTE Q1;


--2)List all the trips details of employee ‘Turner’ (stored procedure)

--SELECT * FROM EMPLOYEE INNER JOIN TRIPS ON EMPLOYEE.EMPLOYEENO = TRIPS.SSN WHERE EMPLOYEE.ENAME = 'TURNER';

CREATE OR REPLACE PROCEDURE Q2 IS
  CURSOR TEMP IS SELECT * FROM EMPLOYEE INNER JOIN TRIPS ON EMPLOYEE.EMPLOYEENO = TRIPS.SSN WHERE EMPLOYEE.ENAME = 'TURNER';
  REC TEMP%ROWTYPE;
BEGIN
  OPEN TEMP;
  LOOP
    FETCH TEMP INTO REC;
    EXIT WHEN TEMP%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(REC.ename|| ' ' || REC.employeeno || ' ' || REC.JOBTITLE || ' ' || REC.TRIPID || ' ' || REC.DESTINATIONCITY);
  END LOOP;
  CLOSE TEMP;
END;

EXECUTE Q2;

--3) Create a stored procedure for filtering employees of sales departments who have never traveled. Further add code to perform:If the employee is a salesman, deduct 2% of his salary.

SELECT EMPLOYEE.ENAME FROM employee WHERE EMPLOYEE.ENAME NOT IN(
SELECT distinct(employee.ename)
FROM ((employee
INNER JOIN department ON EMPLOYEE.EMPLOYEENO  = department.dmgrssn)
INNER JOIN trips ON EMPLOYEE.EMPLOYEENO = TRIPS.SSN) WHERE department.dname='Sales');

CREATE OR REPLACE PROCEDURE Q3 IS
  CURSOR TEMP IS SELECT EMPLOYEE.ENAME FROM employee WHERE EMPLOYEE.ENAME NOT IN(
SELECT distinct(employee.ename)
FROM ((employee
INNER JOIN department ON EMPLOYEE.EMPLOYEENO  = department.dmgrssn)
INNER JOIN trips ON EMPLOYEE.EMPLOYEENO = TRIPS.SSN) WHERE department.dname='Sales');
  REC TEMP%ROWTYPE;
BEGIN
  OPEN TEMP;
  LOOP
    FETCH TEMP INTO REC;
    EXIT WHEN TEMP%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(REC.ename);
  END LOOP;
  CLOSE TEMP;
END;


EXECUTE Q3;


--4) Create a Function to find the manager name who have traveled to Paris the maximum time

SELECT * FROM (SELECT EMPLOYEE.ENAME,COUNT(EMPLOYEE.ENAME) FROM EMPLOYEE INNER JOIN TRIPS ON EMPLOYEE.EMPLOYEENO = TRIPS.SSN WHERE TRIPS.destinationcity = 'Paris' GROUP BY EMPLOYEE.ENAME ORDER BY EMPLOYEE.ENAME) WHERE ROWNUM<=1;


CREATE OR REPLACE PROCEDURE Q4 IS
  CURSOR TEMP IS SELECT * FROM (SELECT EMPLOYEE.ENAME,COUNT(EMPLOYEE.ENAME) FROM EMPLOYEE INNER JOIN TRIPS ON EMPLOYEE.EMPLOYEENO = TRIPS.SSN WHERE TRIPS.destinationcity = 'Paris' GROUP BY EMPLOYEE.ENAME ORDER BY EMPLOYEE.ENAME) WHERE ROWNUM<=1;
  REC TEMP%ROWTYPE;
BEGIN
  OPEN TEMP;
  LOOP
    FETCH TEMP INTO REC;
    EXIT WHEN TEMP%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(REC.ename);
  END LOOP;
  CLOSE TEMP;
END;

EXECUTE Q4;


--5) Write a function to return the total traveling expenses of the Accounting Department having traveled to Delhi.

SELECT SUM(trips.expenses) FROM department INNER JOIN trips ON department.dmgrssn=trips.ssn WHERE department.dname='Accounting' AND trips.destinationcity = 'Kolkatta'



CREATE OR REPLACE FUNCTION
totalAcc
RETURN number IS
  total number := 0;
BEGIN
  SELECT SUM(trips.expenses) into total FROM department INNER JOIN trips ON department.dmgrssn=trips.ssn WHERE department.dname='Accounting' AND trips.destinationcity = 'Kolkatta';
  RETURN total ;
END;


DECLARE
  c number;
BEGIN
c := totalAcc();
dbms_output.put_line('Total: ' || c);
END;



--test -- ignore
CREATE OR REPLACE FUNCTION F4 RETURN EMPLOYEE.ENAME%TYPE IS
  total varchar2(50);
BEGIN
   SELECT EMPLOYEE.ENAME into total FROM (SELECT EMPLOYEE.ENAME,COUNT(EMPLOYEE.ENAME) FROM EMPLOYEE INNER JOIN TRIPS ON EMPLOYEE.EMPLOYEENO = TRIPS.SSN WHERE TRIPS.destinationcity = 'Paris' GROUP BY EMPLOYEE.ENAME ORDER BY EMPLOYEE.ENAME) WHERE ROWNUM<=1;
   return total;
END;

DECLARE
  c  varchar2(50);
BEGIN
c := F4();
dbms_output.put_line(c);
END;

--6) Write a block which accepts the Trip record data from the user and calls a procedure to insert it into the Trip table.

CREATE OR REPLACE FUNCTION F6(tid IN int, dcity IN varchar2(20), d_date IN date, r_date IN date, sn IN int, es IN decimal(10,2)) IS
BEGIN
INSERT INTO trips (tripid, destinationcity, depart_date, return_date,ssn,expenses)
VALUES (tid, dcity, d_date,r_date,sn,es);
END;

EXECUTE F6(&tid,'&dcity','&d_date','&r_date',&sn,&es)
