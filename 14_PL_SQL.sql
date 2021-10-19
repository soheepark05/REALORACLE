/*
    <PL/SQL>
        오라클 자체에 내장되어 있는 절차적 언어로 SQL 문장 내에서 변수의 정의, 조건 처리(IF), 반복 처리(LOOP, FOR, WHILE) 등을 지원한다.
        (다수의 SQL 문을 한 번에 실행이 가능하다.)
        
        [PL/SQL의 구조]
            1) 선언부(DECLARE SECTION)         : DECLARE로 시작, 변수나 상수를 선언 및 초기화하는 부분이다.
            2) 실행부(EXECUTABLE SECTION)      : BEGIN로 시작, SQL 문, 제어문(조건, 반복문) 등의 로직을 기술하는 부분이다. 
            3) 예외 처리부(EXCEPTION SECTION)   : EXCEPTION로 시작, 예외 발생 시 해결하기 위한 구문을 기술하는 부분이다.
*/

-- 출력기능 활성화
SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('HELLO ORACLE!');
END;
/

/*
    1) 선언부(DECLARE SECTION)
        변수 및 상수를 선언해 놓는 공간이다. (선언과 동시에 초기화도 가능)
        변수 및 상수는 일반 타입 변수, 레퍼런스 타입 변수, ROW 타입 변수로 선언해서 사용할 수 있다.
        
      1-1) 일반 타입 변수 선언 및 초기화
        [표현법]
            변수명 [CONSTANT] 자료형(크기) [:= 값];
*/

DECLARE
    EID NUMBER;
    ENAME VARCHAR2(30);
    PI CONSTANT NUMBER := 3.14;
BEGIN
    EID := 888;
    ENAME := '배장남';
--    PI := 3.15; -- 에러 발생
    
    DBMS_OUTPUT.PUT_LINE('EID : ' || EID);
    DBMS_OUTPUT.PUT_LINE('ENAME : ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('PI : ' || PI);
END;
/

/*
      1-2) 레퍼런스 타입 변수 선언 및 초기화
        [표현법]
            변수명 테이블명.컬럼명%TYPE;
        
        - 해당하는 테이블의 컬럼에 데이터 타입을 참조해서 그 타입으로 변수를 지정한다.
*/

DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
BEGIN
    -- 사원명을 입력받아서 사원의 사번, 사원명, 급여정보를 각각 EID, ENAME, SAL 변수에 대입 후 출력한다.
    SELECT EMP_ID, EMP_NAME, SALARY
    INTO EID, ENAME, SAL
    FROM EMPLOYEE
    WHERE EMP_NAME = '&NAME'; -- &(앰퍼샌드) 기호는 대체 변수(값을 입력)를 입력하기 위한 창을 띄어주는 구문이다.
    
    DBMS_OUTPUT.PUT_LINE('EID : ' || EID);
    DBMS_OUTPUT.PUT_LINE('ENAME : ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('SAL : ' || SAL);
END;
/

------------------- 실습 문제 -------------------
-- 레퍼런스 타입 변수로 EID, ENAME, JCODE, DTITLE, SAL를 선언하고 
-- 각 자료형은 EMPLOYEE 테이블의 EMP_ID, EMP_NAME, JOB_CODE, SALARY 컬럼의 타입과
-- DEPARTMENT 테이블의 DEPT_TITLE 컬럼의 타입을 참조한다.
-- 사용자가 입력한 사번과 일치하는 사원을 조회(사번, 사원명, 직급 코드, 부서명, 급여)한 후 조회 결과를 각 변수에 대입 후 출력한다.

DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    JCODE EMPLOYEE.JOB_CODE%TYPE;
    DTITLE DEPARTMENT.DEPT_TITLE%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
BEGIN
    SELECT E.EMP_ID, 
           E.EMP_NAME, 
           E.JOB_CODE, 
           D.DEPT_TITLE, 
           E.SALARY
    INTO EID, ENAME, JCODE, DTITLE, SAL
    FROM EMPLOYEE E
    JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
    WHERE EMP_ID = &사번;
    
    DBMS_OUTPUT.PUT_LINE('사번 : ' || EID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('직급 코드 : ' || JCODE);
    DBMS_OUTPUT.PUT_LINE('부서명 : ' || DTITLE);
    DBMS_OUTPUT.PUT_LINE('급여 : ' || SAL);
END;
/

/*
      1-3) ROW 타입 변수 선언 및 초기화
        [표현법]
            변수명 테이블명%ROWTYPE;
            
        - 하나의 테이블의 여러 컴럼의 값을 한꺼번에 저장할 수 있는 변수를 의미한다.
        - 모든 컬럼을 조회하는 경우에 사용하기 편리하다.
*/

DECLARE
    EMP EMPLOYEE%ROWTYPE;
BEGIN
    SELECT *
    INTO EMP
    FROM EMPLOYEE
    WHERE EMP_NAME = '&사원명';
    
    DBMS_OUTPUT.PUT_LINE('사번 : ' || EMP.EMP_ID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || EMP.EMP_NAME);
    DBMS_OUTPUT.PUT_LINE('주민번호 : ' || EMP.EMP_NO);
    DBMS_OUTPUT.PUT_LINE('이메일 : ' || EMP.EMAIL);
    DBMS_OUTPUT.PUT_LINE('전화번호 : ' || EMP.PHONE);
    DBMS_OUTPUT.PUT_LINE('부서 코드 : ' || EMP.DEPT_CODE);
    DBMS_OUTPUT.PUT_LINE('직급 코드 : ' || EMP.JOB_CODE);
    DBMS_OUTPUT.PUT_LINE('급여 : ' || EMP.SALARY);
END;
/

-------------------------------------------
/*
    2) 실행부(EXECUTABLE SECTION)
      2-1) 선택문
         1) 단일 IF 구문
           [표현법]
             IF 조건식 THEN
               실행 문장
             END IF;
*/
-- 사번을 입력받은 후 해당 사원의 사번, 이름, 급여, 보너스를 출력
-- 단, 보너스를 받지 않는 사원은 보너스 출력 전에 '보너스를 지급받지 않는 사원입니다.'라는 문구를 출력한다.

DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
    BONUS EMPLOYEE.BONUS%TYPE;
BEGIN
    SELECT EMP_ID, EMP_NAME, SALARY, NVL(BONUS, 0)
    INTO EID, ENAME, SAL, BONUS
    FROM EMPLOYEE
    WHERE EMP_ID = '&사번';
    
    DBMS_OUTPUT.PUT_LINE('사번 : ' || EID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('급여 : ' || TO_CHAR(SAL, 'FM99,999,999') || '원');
    
    IF (BONUS = 0) THEN 
        DBMS_OUTPUT.PUT_LINE('보너스를 지급받지 않는 사원입니다.');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('보너스율 : ' || BONUS * 100 || '%');
END;
/

/*
         2) IF ~ ELSE 구문
           [표현법]
             IF 조건식 THEN
               실행 문장
             ELSE 
               실행 문장
             END IF;
*/
-- 위의 PL/SQL을 IF ~ ELSE 구문으로 변경하여 작성
DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
    BONUS EMPLOYEE.BONUS%TYPE;
BEGIN
    SELECT EMP_ID, EMP_NAME, SALARY, BONUS
    INTO EID, ENAME, SAL, BONUS
    FROM EMPLOYEE
    WHERE EMP_ID = '&사번';
    
    DBMS_OUTPUT.PUT_LINE('사번 : ' || EID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('급여 : ' || TO_CHAR(SAL, 'FM99,999,999') || '원');
    
    IF (BONUS IS NULL) THEN 
        DBMS_OUTPUT.PUT_LINE('보너스를 지급받지 않는 사원입니다.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('보너스율 : ' || BONUS * 100 || '%');
    END IF;
END;
/
-- 사번을 입력받아 해당 사원의 사번, 이름, 부서명, 국가 코드를 조회한 후 출력한다.
-- 단, 국가 코드가 'KO'이면 국내팀 그 외는 해외팀으로 출력한다.

DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    DTITLE DEPARTMENT.DEPT_TITLE%TYPE;
    NCODE LOCATION.NATIONAL_CODE%TYPE;
    TEAM VARCHAR2(10);
BEGIN
    SELECT E.EMP_ID, E.EMP_NAME, D.DEPT_TITLE, L.NATIONAL_CODE
    INTO EID, ENAME, DTITLE, NCODE
    FROM EMPLOYEE E
    JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
    JOIN LOCATION L ON (D.LOCATION_ID = L.LOCAL_CODE)
    WHERE E.EMP_ID = '&사번';
    
    IF (NCODE = 'KO') THEN
        TEAM := '국내팀';
    ELSE
        TEAM := '해외팀';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('사번 : ' || EID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('부서 : ' || DTITLE);
    DBMS_OUTPUT.PUT_LINE('국가 코드 : ' || NCODE);
    DBMS_OUTPUT.PUT_LINE('소속 : ' || TEAM);
END;
/

/*
         3) IF ~ ELSIF ~ ELSE 구문
           [표현법]
             IF 조건식 THEN
               실행 문장
             ELSIF 조건식 THEN
               실행 문장
             ...
             [ELSE 
               실행 문장]
             END IF;
*/
-- 점수를 입력받아 SCORE 변수에 저장한 후 학점은 입력된 점수에 따라 GRADE 변수에 저장한다.
--   90점 이상은 'A'
--   80점 이상은 'B'
--   70점 이상은 'C'
--   60점 이상은 'D'
--   60점 미만은 'F'
-- 출력은 '당신의 점수는 95점이고, 학점은 A학점입니다.' 와 같이 출력한다.
DECLARE
    SCORE NUMBER;
    GRADE CHAR(1);
BEGIN
    SCORE := '&점수';
    
    IF(SCORE > 100 OR SCORE < 0) THEN
        DBMS_OUTPUT.PUT_LINE('점수를 잘못 입력하였습니다.');
        RETURN;
    ELSIF(SCORE >= 90) THEN    
        GRADE := 'A';
    ELSIF(SCORE >= 80) THEN
        GRADE := 'B';
    ELSIF(SCORE >= 70) THEN
        GRADE := 'C';
    ELSIF(SCORE >= 60) THEN
        GRADE := 'D';
    ELSE
        GRADE := 'F';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('당신의 점수는 ' || SCORE || '점이고, 학점은 ' || GRADE || '학점 입니다.');
END;
/

-- 사용자에게 입력받은 사번과 일치하는 사원의 급여 조회 후 급여 등급을 출력한다.
-- 500만원 이상이면 '고급'
-- 300만원 이상이면 '중급'
-- 300만원 미만이면 '초급'
-- 출력은 '해당 사원의 급여 등급은 고급입니다.' 와 같이 출력한다.
DECLARE
    SAL EMPLOYEE.SALARY%TYPE;
    GRADE VARCHAR2(10);
BEGIN
    SELECT EMP_ID, SALARY
    INTO SAL
    FROM EMPLOYEE
    WHERE EMP_ID = '&사번';
    
    IF(SAL >= 5000000) THEN
        GRADE := '고급';
    ELSIF(SAL >= 3000000) THEN
        GRADE := '중급';
    ELSE
        GRADE := '초급';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('해당 사원의 급여 등급은 ' || GRADE || '입니다.');
END;
/

DECLARE
    SAL EMPLOYEE.SALARY%TYPE;
    GRADE SAL_GRADE.SAL_LEVEL%TYPE;
BEGIN
    SELECT SALARY
    INTO SAL
    FROM EMPLOYEE
    WHERE EMP_ID = '&사번';
    
    SELECT SAL_LEVEL
    INTO GRADE
    FROM SAL_GRADE
    WHERE SAL BETWEEN MIN_SAL AND MAX_SAL;   
    
    DBMS_OUTPUT.PUT_LINE('해당 사원의 급여 등급은 ' || GRADE || '입니다.');
END;
/

/*
        4) CASE 구문 
          [표현법]
            CASE 비교 대상
                 WHEN 비교값1 THEN 결과값1
                 WHEN 비교값2 THEN 결과값2
                 WHEN 비교값3 THEN 결과값3
                 ...
                 [ELSE 결과값]
            END;
*/
-- 사번을 입력받은 후에 사원의 모든 컬럼 데이이터를 EMP에 대입하고 DEPT_CODE에 따라 알맞는 부서를 출력한다.
DECLARE
    EMP EMPLOYEE%ROWTYPE;
    DNAME VARCHAR2(30);
BEGIN
    SELECT *
    INTO EMP
    FROM EMPLOYEE
    WHERE EMP_ID = '&사번';
    
    DNAME := CASE EMP.DEPT_CODE
                WHEN 'D1' THEN '인사관리부'
                WHEN 'D2' THEN '회계관리부'
                WHEN 'D3' THEN '마케팅부'
                WHEN 'D4' THEN '국내영업부'
                WHEN 'D5' THEN '해외영업1부'
                WHEN 'D6' THEN '해외영업2부'
                WHEN 'D7' THEN '해외영업3부'
                WHEN 'D8' THEN '기술지원부'
                WHEN 'D9' THEN '총무부'
             END;
    
     DBMS_OUTPUT.PUT_LINE('사번 : ' || EMP.EMP_ID);
     DBMS_OUTPUT.PUT_LINE('이름 : ' || EMP.EMP_NAME);
     DBMS_OUTPUT.PUT_LINE('부서 코드 : ' || EMP.DEPT_CODE);
     DBMS_OUTPUT.PUT_LINE('부서명 : ' || DNAME);
END;
/

SELECT * FROM DEPARTMENT;

/*
      2-2) 반복문
        1) BASIC LOOP
            [표현법]
                LOOP
                    반복적으로 실행시킬 구문
                    
                    [반복문을 빠져나갈 조건문 작성]
                      1)IF 조건식 THEN EXIT; END IF; 
                      2) EIXT WHEN 조건식;
                END LOOP;
*/
-- 1 ~ 5까지 순차적으로 1씩 증가하는 값을 출력
DECLARE
    NUM NUMBER := 1;
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE(NUM);
        
        NUM := NUM + 1;
        
--        IF NUM > 5 THEN
--            EXIT;        
--        END IF;
        
        EXIT WHEN NUM > 5;
    END LOOP;
END;
/

/*
        2) WHILE LOOP
            [표현법]
                WHILE 조건식
                LOOP
                    반복적으로 실행할 구문;
                END LOOP;
*/
-- 1 ~ 5까지 순차적으로 1씩 증가하는 값을 출력
DECLARE
    NUM NUMBER := 1;
BEGIN
    WHILE NUM <= 5 
    LOOP
        DBMS_OUTPUT.PUT_LINE(NUM);
        
        NUM := NUM + 1;        
    END LOOP;
END;
/
-- 구구단(2 ~ 9단) 출력
DECLARE
    DAN NUMBER := 2;
    SU NUMBER;
BEGIN
    WHILE DAN <= 9
    LOOP
        SU := 1;
        
        WHILE SU <= 9
        LOOP
            DBMS_OUTPUT.PUT_LINE(DAN || ' x ' || SU || ' = ' || DAN * SU);
            SU := SU + 1;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('');
        DAN := DAN + 1;
    END LOOP;
END;
/

/*
        3) FOR LOOP
            [표현법]
                FOR 변수 IN [REVERSE] 초기값..최종값
                LOOP
                    반복적으로 실행할 구문;
                END LOOP;
*/
-- 1 ~ 5까지 순차적으로 1씩 증가하는 값을 출력
BEGIN
    FOR NUM IN 1..5
    LOOP
        DBMS_OUTPUT.PUT_LINE(NUM);
    END LOOP;
END;
/

-- 역순으로 출력
BEGIN
    FOR NUM IN REVERSE 1..5
    LOOP
        DBMS_OUTPUT.PUT_LINE(NUM);
    END LOOP;
END;
/

-- 구구단(2 ~ 9단) 출력 (단, 짝수단만 출력한다.)
BEGIN
    FOR DAN IN REVERSE 2..9
    LOOP
        IF (MOD(DAN, 2) = 0) THEN
            FOR SU IN 1..9
            LOOP
                DBMS_OUTPUT.PUT_LINE(DAN || ' X ' || SU || ' = ' || DAN * SU);
            END LOOP;
            
            DBMS_OUTPUT.PUT_LINE('');
        END IF;
    END LOOP;
END;
/

-- 반복문(FOR 구문)을 이용한 데이터 삽입
CREATE TABLE TEST(
    NUM NUMBER,
    CREATE_DATE DATE
);

TRUNCATE TABLE TEST;
SELECT * FROM TEST;

-- TEST 테이블에 10개의 행을 INSERT하는 PL/SQL 작성
BEGIN
    FOR NUM IN 1..10
    LOOP
        INSERT INTO TEST VALUES(NUM, SYSDATE);
        
        IF (MOD(NUM, 2) != 0) THEN
            COMMIT;
        ELSE 
            ROLLBACK;
        END IF;
    END LOOP;
END;
/

/*
    3) 예외처리부(EXCEPTION SECTION)
        예외란 실행 중 발생하는 오류를 뜻하고 PL/SQL 문에서 발생한 예외를 예외처리부에서 코드적으로 처리가 가능하다.  
        
        [표현식]
            DECLARE
            ...
            BEGIN
            ...
            EXCEPTION
                WHEN 예외명 1 THEN 예외처리구문 1;
                WHEN 예외명 2 THEN 예외처리구문 2;
                ...
                WHEN OUTERS THEN 예외처리구문;
        
        * 오라클에서 미리 정의되어 있는 예외(시스템 예외)
          - NO_DATA_FOUND    : SELECT 문의 수행 결과가 한 행도 없을 경우 발생한다.
          - TOO_MANY_ROWS    : 한 행이 리턴되야하는데 SELECT 문에서 여러 개의 행을 반환할 때 발생한다.
          - ZERO_DIVIDE      : 숫자를 0으로 나눌 때 발생한다.
          - DUP_VAL_ON_INDEX : UNIQUE 제약 조건을 가진 컬럼에 중복된 데이터가 INSERT 될 때 발생한다.
*/
-- 사용자가 입력한 수로 나눗셈 연산
DECLARE
    RESULT NUMBER;
BEGIN
    RESULT  := 10 / &숫자;
    
    DBMS_OUTPUT.PUT_LINE('결과 : ' || RESULT);
EXCEPTION
    WHEN ZERO_DIVIDE THEN DBMS_OUTPUT.PUT_LINE('나누기 연산시 0으로 나눌 수 없습니다.');
END;
/

-- UNIQUE 제약조건 위배시
BEGIN
    UPDATE EMPLOYEE
    SET EMP_ID = 200
    WHERE EMP_NAME = '&이름';
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN DBMS_OUTPUT.PUT_LINE('이미 존재하는 사번입니다.');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다.');
END;
/

-- 너무 많은 행이 조회가 되었을 때
DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
BEGIN
    SELECT EMP_ID, EMP_NAME
    INTO EID, ENAME
    FROM EMPLOYEE
    WHERE MANAGER_ID = '&사수번호';
    
    DBMS_OUTPUT.PUT_LINE('사번 : ' || EID);
    DBMS_OUTPUT.PUT_LINE('사원명 : ' || ENAME);
EXCEPTION
    --WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('너무 많은 행이 조회되었습니다.');
    --WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('조회 결과가 없습니다.');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다.');
END;
/

SELECT EMP_ID, EMP_NAME
    FROM EMPLOYEE
    WHERE MANAGER_ID = 203;












