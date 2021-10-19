/*
    <DML(Data Manipulation Language)>
        데이터 조작 언어로 테이블에 값을 삽입(INSERT)하거나, 수정(UPDATE), 삭제(DELETE)하는 구문이다.
        
    <INSERT>
        테이블에 새로운 행을 추가하는 구문이다.
        
        [표현법]
            1) INSERT INTO 테이블명 VALUES(값, 값, 값, ..., 값);
               테이블에 모든 컬럼에 값을 INSERT 하고자 할 때 사용한다.
               컬럼 순번을 지켜서 VALUES에 값을 나열해야 한다.
            2) INSERT INTO 테이블명(컬럼명, 컬럼명, ..., 컬럼명) VALUES(값, 값, ..., 값);
               테이블에 내가 선택한 컬럼에 대한 값만 INSERT 하고자 할 때 사용한다.
               선택이 안된 컬럼들은 기본적으로 NULL 값이 들어간다. (NOT NULL 제약조건이 걸려있는 컬럼은 반드시 선택해서 값을 제시해야 한다.)
               단, 기본값(DEFAULT)이 지정되어 있으면 NULL이 아닌 기본값이 들어간다.
            3) INSERT INTO 테이블명 (서브 쿼리);
               VALUES를 대신해서 서브 쿼리로 조회한 결과값을 통채로 INSERT 한다.(즉, 여러행을 INSERT 시킬 수 있다.)
               서브 쿼리의 결과값이 INSERT 문에 지정된 컬럼의 개수와 데이터 타입이 같아야 한다.
*/
-- 표현법 1)번 사용
INSERT INTO EMPLOYEE
VALUES('900', '공유', '901008-1080503', 'kong@kh.or.kr', '01055556666', 'D1', 'J7', 
        4300000, 0.2, '200', SYSDATE, NULL, DEFAULT);

-- 표현법 2)번 사용
INSERT INTO EMPLOYEE(EMP_ID, EMP_NAME, EMP_NO, JOB_CODE)
VALUES(901, '문인수', '991008-1111999', 'J7');

SELECT * 
FROM EMPLOYEE 
ORDER BY EMP_ID DESC;

-- 표현법 3)번 사용
-- 새로운 테이블 생성
CREATE TABLE EMP_01 (
    EMP_ID NUMBER,
    EMP_NAME VARCHAR2(30),
    DEPT_TITLE VARCHAR2(35)
);

-- 전체 사원의 사번, 이름, 부서명을 조회하여 결과값을 EMP_01 테이블에 INSERT 한다.

INSERT INTO EMP_01(
    SELECT EMP_ID, EMP_NAME, DEPT_TITLE
    FROM EMPLOYEE E
    LEFT OUTER JOIN DEPARTMENT D ON(E.DEPT_CODE = D.DEPT_ID)    
);

INSERT INTO EMP_01(EMP_ID, EMP_NAME) (
    SELECT EMP_ID, EMP_NAME
    FROM EMPLOYEE E
    LEFT OUTER JOIN DEPARTMENT D ON(E.DEPT_CODE = D.DEPT_ID)    
);

SELECT * FROM EMP_01;
DROP TABLE EMP_01;

/*
    <INSERT ALL>
        두 개 이상의 테이블에 INSERT 하는데 동일한 서브 쿼리가 사용되는 경우
        INSERT ALL을 이용해서 여러 테이블에 한 번 데이터 삽입이 가능하다.
        
        [표현법]
            1) INSERT ALL
               INTO 테이블명1[(컬럼, 컬럼, ...)] VALUES(값, 값, ... )
               INTO 테이블명2[(컬럼, 컬럼, 컬럼, ...)] VALUES(값, 값, 값, ...)
                    서브 쿼리;
                    
            2) INSERT ALL
               WHEN 조건 1 THEN
                    INTO 테이블명1[(컬럼, 컬럼, ...)] VALUES(값, 값, ... )
               WHEN 조건 2 THEN
                    INTO 테이블명2[(컬럼, 컬럼, ...)] VALUES(값, 값, ... )
               서브 쿼리;
*/
-- 표현법 1)번을 테스트할 테이블 만들기(테이블 구조만 복사)
CREATE TABLE EMP_DEPT
AS SELECT EMP_ID, EMP_NAME, DEPT_CODE, HIRE_DATE
   FROM EMPLOYEE
   WHERE 1 = 0;
   
CREATE TABLE EMP_MANAGER
AS SELECT EMP_ID, EMP_NAME, MANAGER_ID
   FROM EMPLOYEE
   WHERE 1 = 0;

-- EMP_DEPT 테이블에 EMPLOYEE 테이블의 부서 코드가 D1인 직원의 사번, 이름, 부서 코드, 입사일을
-- EMP_MANAGER 테이블에 EMPLOYEE 테이블의 부서 코드가 D1인 직원 사번, 이름, 관리자 사번을 조회하여 삽입한다.

INSERT ALL
INTO EMP_DEPT VALUES (EMP_ID, EMP_NAME, DEPT_CODE, HIRE_DATE)
INTO EMP_MANAGER VALUES (EMP_ID, EMP_NAME, MANAGER_ID)
    SELECT EMP_ID, EMP_NAME, DEPT_CODE, HIRE_DATE, MANAGER_ID
    FROM EMPLOYEE
    WHERE DEPT_CODE = 'D1';
    
SELECT * FROM EMP_DEPT;
SELECT * FROM EMP_MANAGER;

DROP TABLE EMP_DEPT;
DROP TABLE EMP_MANAGER;

-- 표현법 2)번을 테스트할 테이블 만들기(테이블 구조만 복사)
CREATE TABLE EMP_OLD
AS SELECT EMP_ID, EMP_NAME, HIRE_DATE, SALARY
   FROM EMPLOYEE
   WHERE 1 = 0;

CREATE TABLE EMP_NEW
AS SELECT EMP_ID, EMP_NAME, HIRE_DATE, SALARY
   FROM EMPLOYEE
   WHERE 1 = 0;

-- EMPLOYEE 테이블의 입사일 기준으로 2000년 1월 1일 이전에 입사한 사원의 정보는 EMP_OLD 테이블에 삽입하고
-- 2000년 1월 1일 이후에 입사한 사원의 정보는 EMP_NEW 테이블에 삽입한다.
INSERT ALL
WHEN HIRE_DATE < '2000/01/01' THEN
    INTO EMP_OLD VALUES(EMP_ID, EMP_NAME, HIRE_DATE, SALARY)
WHEN HIRE_DATE >= '2000/01/01' THEN
    INTO EMP_NEW VALUES(EMP_ID, EMP_NAME, HIRE_DATE, SALARY)
SELECT EMP_ID, EMP_NAME, HIRE_DATE, SALARY
FROM EMPLOYEE;

SELECT * FROM EMP_OLD;
SELECT * FROM EMP_NEW;

DROP TABLE EMP_OLD;
DROP TABLE EMP_NEW;

------------------------------------------------------------------------

/*
    <UPDATE>
        테이블에 기록된 데이터를 수정하는 구문이다.
        
        [표현법]
            UPDATE 테이블명
            SET 컬럼명 = 변경하려는 값,
                컬럼명 = 변경하려는 값,
                ...
            [WHERE 조건];
            
            UPDATE 테이블명
            SET 컬럼명 = (서브 쿼리),
                컬럼명 = (서브 쿼리),
                ...
            [WHERE 조건];
            
        -- SET 절에서 여러 개의 컬럼을 콤마(,)로 나열해서 값을 동시에 변경할 수 있다.
        -- WHERE 절을 생략하면 모든 행의 데이터가 변경된다.
        -- UPDATE 시에 서브 쿼리를 사용해서 서브 쿼리를 수행한 결과값으로 컬럼의 값을 변경할 수 있다.(WHERE 절에도 서브 쿼리 사용가능)
*/
-- 테스트 진행할 테이블 생성
CREATE TABLE DEPT_COPY
AS SELECT * FROM DEPARTMENT;

CREATE TABLE EMP_SALARY
AS SELECT EMP_ID, EMP_NAME, SALARY, BONUS
   FROM EMPLOYEE;
   
SELECT * FROM DEPT_COPY;
SELECT * FROM EMP_SALARY;

-- DEPT_ID가 'D9'인 부서명을 '전략기획팀'으로 수정
UPDATE DEPT_COPY
SET DEPT_TITLE = '전략기획팀'
WHERE DEPT_ID = 'D9';

ROLLBACK;

-- 노옹철 사원의 급여를 1000000원으로 변경
UPDATE EMP_SALARY
SET SALARY = 1000000
WHERE EMP_NAME = '노옹철';

-- 선동일 사원의 급여를 7000000원으로, 보너스를 0.2로 변경하시오.
UPDATE EMP_SALARY
SET SALARY = 7000000,
    BONUS = 0.2
WHERE EMP_NAME = '선동일';

-- 모든 사원의 급여를 기존 급여에서 10프로 인상한 금액(기존 급여 * 1.1)으로 변경
UPDATE EMP_SALARY
SET SALARY = SALARY * 1.1;

-- UPDATE 시 변경할 값은 해당 컬럼에 대한 제약조건에 위배되면 안 된다.
-- 사번이 200번인 사원의 사원번호를 NULL로 변경
UPDATE EMP_SALARY
SET EMP_ID = NULL -- NOT NULL 제약조건에 위배된다.
WHERE EMP_ID = 200; 

-- EMPLOYEE 테이블에서 노옹철 사원의 부서 코드를 'D0'으로 변경
UPDATE EMPLOYEE
SET DEPT_CODE = 'D0'  -- FOREIGN KEY 제약조건에 위배된다.
WHERE EMP_NAME = '노옹철';

SELECT * FROM EMP_SALARY;

ROLLBACK;

-- 방명수 사원의 급여와 보너스율을 유재식 사원과 동일하게 변경
SELECT SALARY, BONUS
FROM EMP_SALARY
WHERE EMP_NAME = '유재식';

-- 1) 단일행 서브 쿼리를 각각의 컬럼에 적용
UPDATE EMP_SALARY
SET SALARY = (
        SELECT SALARY
        FROM EMP_SALARY
        WHERE EMP_NAME = '유재식' 
    ),
    BONUS = (
        SELECT BONUS
        FROM EMP_SALARY
        WHERE EMP_NAME = '유재식'
    )
WHERE EMP_NAME = '방명수';

-- 2) 다중열 서브 쿼리를 사용해서 SALARY, BONUS 컬럼을 한 번에 변경
UPDATE EMP_SALARY
SET (SALARY, BONUS) = (
    SELECT SALARY, BONUS
    FROM EMP_SALARY
    WHERE EMP_NAME = '유재식'
)
WHERE EMP_NAME = '방명수';

-- 노옹철, 전형돈, 정중하, 하동운 사원들의 급여와 보너스를 유재식 사원과 동일하게 변경
UPDATE EMP_SALARY
SET (SALARY, BONUS) = (
    SELECT SALARY, BONUS
    FROM EMP_SALARY
    WHERE EMP_NAME = '유재식'
)
-- WHERE EMP_NAME = '노옹철' OR EMP_NAME = '전형돈' OR EMP_NAME = '정중하' OR EMP_NAME = '하동운';
WHERE EMP_NAME IN ('노옹철', '전형돈', '정중하', '하동운');

SELECT * 
FROM EMP_SALARY
WHERE EMP_NAME = '방명수';

ROLLBACK;

-- EMP_SALARY 테이블에서 아시아 지역에 근무하는 직원의 보너스를 0.3으로 변경
SELECT EMP_ID
FROM EMPLOYEE E
JOIN DEPARTMENT D ON(E.DEPT_CODE = D.DEPT_ID)
JOIN LOCATION L ON(D.LOCATION_ID = L.LOCAL_CODE)
WHERE L.LOCAL_NAME LIKE 'ASIA%';

UPDATE EMP_SALARY
SET BONUS = 0.3
WHERE EMP_ID IN (
    SELECT EMP_ID
    FROM EMPLOYEE E
    JOIN DEPARTMENT D ON(E.DEPT_CODE = D.DEPT_ID)
    JOIN LOCATION L ON(D.LOCATION_ID = L.LOCAL_CODE)
    WHERE L.LOCAL_NAME LIKE 'ASIA%'
);

SELECT * FROM EMP_SALARY;

------------------------------------------------------------------

/*
    <DELETE>
        테이블에 기록 된 데이터를 삭제하는 구문이다. (행 단위로 삭제한다.)
    
        [표현법]
            DELETE FROM 테이블명
            [WHERE 조건식];
            
        - WHERE 절을 제시하지 않으면 전체 행이 삭제된다.
*/

COMMIT;

-- 공유 사원의 데이터 지우기
DELETE FROM EMP_SALARY
WHERE EMP_NAME = '공유';

ROLLBACK; -- 마지막 커밋 시점으로 롤백된다.

DELETE FROM EMP_SALARY
WHERE EMP_NAME = '문인수';

SELECT * FROM EMP_SALARY;

COMMIT;

-- DEPARTMENT 테이블에서 DEPT_ID가 D1인 부서를 삭제
DELETE 
FROM DEPARTMENT
WHERE DEPT_ID = 'D1'; -- D1의 값을 참조하는 자식 테이블 데이터가 있기 때문에 삭제가 되지 않는다.

-- DEPARTMENT 테이블에서 DEPT_ID가 D3인 부서를 삭제
DELETE FROM DEPARTMENT
WHERE DEPT_ID = 'D3'; -- D3의 값을 참조하는 자식 테이블 테이터가 없기 때문에 삭제가 된다.

SELECT * 
FROM DEPARTMENT;

ROLLBACK;

/*
    <TRUNCATE>
        테이블의 전체 행을 삭제할 때 사용하는 구문으로 DELETE 보다 수행 속도가 더 빠르다.
        별도의 조건 제시가 불가능하고 ROLLBACK이 불가능하다.
    
        [표현법]
            TRUNCATE TABLE 테이블명;
*/

SELECT *
FROM EMP_SALARY;

SELECT *
FROM DEPT_COPY;

DELETE FROM EMP_SALARY;
DELETE FROM DEPT_COPY;

ROLLBACK;

TRUNCATE TABLE EMP_SALARY;
TRUNCATE TABLE DEPT_COPY;

ROLLBACK; -- ROLLBACK이 불가능하다.