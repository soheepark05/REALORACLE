SELECT * FROM employee;

/* <SELECT>
    [표현법] 
        SELECT 컬럼, 컬럼, 컬럼, ..., 컬럼
            FROM 테이블명;
            
            - 데이터를 조회할 때 사용하는 구무
            - SELECT를 통해서 조회된 결과물을 RESULT SET이라고 한다.(즉, 조회된 행들의 집합)
            - 조회하고자 하는 컬럼들은 반드시 FROM 절에 기술한 테이블에 존재하는 컬럼이어야 한다.
            
        */
        
-- EMPLOYYE 테이블에 전체 사원의 모든 컬럼 정보 조회
SELECT * FROM EMPLOYEE;

-- EMPlOYEE 테이블의 전체 사원들의 사번, 이름, 급여만을 조회
SELECT EMP_ID, EMP_NAME, SALARY
FROM EMPLOYEE;

-- 아래와 같이 쿼리는 대소문자를 가리지 않지만 관례상 대문자로 작성한다.
select emp_id, emp_name, salary
from employee;

------------실습 문제-------
-- 1. Job 테이블의 모든 컬럼 (*)정보 조회
SELECT * FROM JOB;
-- 2. JOB테이블의 직급명 컬럼만 조회
SELECT JOB_NAME FROM JOB;
-- 3. department 테이블의 모든 컬럼 정보조회
SELECT DEPT_ID, DEPT_TITLE, LOCATION_ID FROM DEPARTMENT;
-- 4. EMPLOYEE테이블의 사원명, 이메일, 전화번호, 입사일(HIRE_DATE)정보만 조회
SELECT EMP_NAME, EMAIL, PHONE, HIRE_DATE FROM EMPLOYEE;
---------------------------------
/*

    <컬럼값을 통한 산술 연산>
    SELECT절에 컬럼명 입력 부분에서 산술연산자를 사용해서 결과를 조회할 수 있다..
    */
    
    -- EMPLOYEE 테이블에서 직원명, 직원의 연봉(연봉 = 급여 * 12)

SELECT EMP_NAME, SALARY * 12
FROM EMPLOYEE;

-- EMPLOYEE 테이블에서 직원명, 급여, 연봉, 보너스가 포함된 연봉((급여+(보너스*급여))*12) 조회
-- 산술 연산 중 NULL값이 존재할 경우 산술 연산한 결과값은 무조건 NULL이다.

SELECT EMP_NAME, SALARY, SALARY * 12, (SALARY + (BONUS * SALARY)) * 12
FROM EMPLOYEE;

-- EMPLOYEE 테이블에서 직원명, 입사일, 근무일수(오늘 날짜 - 입사일)
-- DATE형식 끼리도 연산이 가능합니다.
-- SYSDATE는 현재 날짜를 출력한다.
-- CELL(NUMBER)는 매개값으로 전달되는 수를 올림하는 함수
SELECT EMP_NAME, HIRE_DATE,/* SYSDATE - HIRE_DATE*/ CELL(SYSDATE - HIRE_DATE)
FROM EMPLOYEE;
----------------------------------------
/*
    <컬럼명에 별칭 지정하기>
    [표현법]
        컬럼 AS 별칭 / 컬럼 AS "별칭" / 컬럼 별칭 / 컬럼 "별칭"
    
    - 산술 연산을 하게 되면 컬럼명이 지저분해진다. 이때 컬럼명에 별칭을 부여해서 깔끔하게 보여 줄 수 있따.
    - 별칭을 부여할 때 띄어쓰기 또는 특수 문자가 별칭에 포함될 경우에는 반드시 큰따옴표("")로 감싸주어야한다.
    
    ALT + SHIFT D 한줄삭제
*/
-- EMPLOYEE 테이블에서 직원명, 급여, 연봉, 보너스가 포함된 연봉((급여+(보너스*급여))*12)조회
SELECT EMP_NAME AS 이름, SALARY AS "급여", SALARY * 12 연봉, (SALARY + (BONUS* SALARY)) * 12 "총 소득(원)"
FROM EMPLOYEE;
-----------------------
/* <리터럴>
        임의로 지정된 문자열('')를 SELECT 절에 사용하면 테이블에 존재하는 데이터처럼 조회가 가능하다.
        리터럴은 RESULT SET의 모든 행에 반복적으로 출력된다.
*/
-- EMPLOYEE 테이블에서 직원 번호, 직원명, 급여, 단위(원) 조회?
SELECT EMP_ID, EMP_NAME, SALARY, '원' AS "단위(원)"
FROM EMPLOYEE;
------------------------------
/* 
        <DISTINCT>
        컬럼에 포함된 중복 값을 한번씩만 표시하고자 할 때 사용한다.
        SELECT 절에 한번만 기술 할 수있다,
        */
-- EMPLOYEE 테이블에서 직원 코드 조회
SELECT JOB_CODE
FROM EMPLOYEE;

-- EMPLOYEE 테이블에서 직원 코드(중복제거) 조회
SELECT DISTINCT JOB_CODE
FROM EMPLOYEE;

-- DISTINCT 는 SELECT절에 한번만 기술할 수 있다.
-- SELECT DISTINCT JOB_CODE, DISTINCT DEPT _ CODE
SELECT DISTINCT JOB_CODE, DEPT_CODE
FROM EMPLOYEE;


/* <WHERE 절>
        [표현법]
            SELECT 컬럼, 컬럼, 컬럼, ..., 컬럼
                FROM 테이블 명
            WHERE 조건식;
            
            - 조회하고자 하는 테이블에서 해당 조건에 만족하는 결과만을 조회하고자 할 때 사용한다.
            - 조건식에는 다양한 연산자들을 사용할 수 있다.
            
        <비교 연산자>
        =            : 동등 연산
        >, <, >=, <= : 대소 비교
        != , ^=, <>  : 같지 않다
        
        */

----------EMPLOYEE 테이블에서 부서 코드가 D9와 일치하는 사원들의 모든 컬럼 조회
SELECT * FROM EMPLOYEE
WHERE DEPT_CODE = 'D9'; /*동등비교 == 아님*/

-- EMPLOYEE 테이블에서 부서 코드가 D9가 아닌 사원들의 사번, 사원명, 부서 코드만 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE
FROM EMPLOYEE
--WHERE DEPT_CODE != 'D9';
--WHERE DEPT_CODE ^= 'D9';
WHERE DEPT_CODE <> 'D9';

-- EMPLOYEE 테이블에서 급여가 400만원 이상인 직원들의 직원명, 부서 코드, 급여 조회
SELECT EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY >= 4000000;
-- EMPLOYEE 테이블에서 재직 중 (ENT_YN 값이 'N')인직원들의 사번, 이름 입사일 조회
SELECT EMP_ID, EMP_NAME
FROM EMPLOYEE
WHERE ENT_YN = 'N';

------- 실습 문제 ----------
-- 1. EMPLOYEE 테이블에서 급여(SALARY)가 300만원 이상인 직원의 이름 , 급여, 입사일 조회
-- 2. EMPLOYEE 테이블에서 연봉이 5000만원 이상인 직원의 이름, 급여, 연봉, 입사일 조회

---------------------------




SELECT * FROM EMPLOYEE;

