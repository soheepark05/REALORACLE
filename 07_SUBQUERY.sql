--<       목      차       >

-- 1. SUBQUERY 서브 쿼리
-- 2. 다중행 서브 쿼리
-- 3. IN / NOT IN (서브쿼리) / ANY / ALL
-- 4. 다중열 서브 쿼리(조회 결과 값은 한 행이지만 나열된 컬럼 수가 여러 개일 때)
-- 5. 다중행 다중열 서브 쿼리 : 서브 쿼리의 조회 결과값이 여러 행, 여러 열일 경우
-- 6.  <인라인 뷰> :FROM 절에 서브 쿼리를 제시하고, 서브 쿼리를 수행한 결과를 테이블 대신에 사용한다.
-- 7.  <RANK 함수> ☆



/*
    <SUBQUERY>
        하나의 SQL 문 안에 포함된 또 다른 SQL 문을 뜻한다.
        메인 쿼리(기존 쿼리)를 보조하는 역할을 하는 쿼리문이다.
*/

-- 서브 쿼리 예시
-- 노옹철 사원과 같은 부서원들을 조회
-- 1) 노옹철 사원의 부서 코드 조회 --> D9
SELECT EMP_NAME, DEPT_CODE
FROM EMPLOYEE
WHERE EMP_NAME = '노옹철';

-- 2) 부서 코드가 노옹철 사원의 부서 코드와 동일한 사원들을 조회
SELECT EMP_NAME, DEPT_CODE
FROM EMPLOYEE
WHERE DEPT_CODE = 'D9';

-- 3) 위의 2단계를 하나의 쿼리로 작성
SELECT EMP_NAME, DEPT_CODE
FROM EMPLOYEE
WHERE DEPT_CODE = (
    SELECT DEPT_CODE
    FROM EMPLOYEE
    WHERE EMP_NAME = '노옹철'
);

----------------------------------------------------------------
/*
    <서브 쿼리 구분>
        서브 쿼리는 서브 쿼리를 수행한 결과값의 행과 열의 개수에 따라서 분류를 할 수 있다.
        
        1. 단일행 서브 쿼리        : 서브 쿼리의 조회 결과 값의 행의 개수가 오로지 1개 일 때
        2. 다중행 서브 쿼리        : 서브 쿼리의 조회 결과 값의 행의 개수가 여러 행 일 때
        3. 다중열 서브 쿼리        : 서브 쿼리의 조회 결과 값이 한 행이지만 컬럼이 여러개 일 때
        4. 다중행, 다중열 서브 쿼리 : 서브 쿼리의 조회 결과 값이 여러행, 여러열 일 때
        
        * 서브 쿼리의 유형에 따라 서브 쿼리 앞에 붙는 연산자가 달라진다.
    <단일행 서브 쿼리>
        서브 쿼리의 조회 결과 값의 행의 개수가 오로지 1개 일 때 (단일행, 단일열)
        비교 연산자(단일행 연산자) 사용 가능 (=, !=, <>, ^=, >, <, >=, <=, ...)
*/

-- 1) 전 직원의 평균 급여보다 급여를 적게 받는 직원들의 이름, 직급 코드, 급여 조회
-- 전 직원 평균 급여
SELECT AVG(SALARY)
FROM EMPLOYEE; -- 1행 1열 (3047662.60869565217391304347826086956522)

-- 위 쿼리를 서브 쿼리로 사용하는 메인 쿼리 작성
SELECT EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY < (
    SELECT AVG(SALARY)
    FROM EMPLOYEE
)
ORDER BY SALARY;

-- 2) 최저 급여를 받는 직원의 사번, 이름, 직급 코드, 급여, 입사일 조회
-- 최저 급여 조회
SELECT MIN(SALARY)
FROM EMPLOYEE; -- 결과값 1행 1열 (1380000)

-- 위 쿼리를 서브 쿼리로 사용하는 메인 쿼리 작성
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY, HIRE_DATE
FROM EMPLOYEE
WHERE SALARY = (
    SELECT MIN(SALARY)
    FROM EMPLOYEE
);

-- 3) 노옹철 사원의 급여보다 더 많이 받는 사원의 사번, 사원명, 부서명, 직급 코드, 급여 조회
-- 노옹철 사원의 급여 조회
SELECT SALARY
FROM EMPLOYEE
WHERE EMP_NAME = '노옹철';

-- 위 쿼리를 서브 쿼리로 사용하는 메인 쿼리 작성 (ANSI)
SELECT E.EMP_ID, E.EMP_NAME, D.DEPT_TITLE, E.JOB_CODE, E.SALARY
FROM EMPLOYEE E
JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
WHERE SALARY > (
    SELECT SALARY
    FROM EMPLOYEE
    WHERE EMP_NAME = '노옹철'
);

-- 오라클 구문

-- 4) 부서별 급여의 합이 가장 큰 부서의 부서 코드, 급여의 합 조회
-- 각 부서별 급여의 합
SELECT MAX(SUM(SALARY))
FROM EMPLOYEE
GROUP BY DEPT_CODE;  -- 결과값 1행 1열 (17700000)

-- * 서브 쿼리는 WHERE 절 뿐만 아니라, SELECT / FROM / HAVING에서 사용이 가능하다.
SELECT DEPT_CODE, SUM(SALARY)
FROM EMPLOYEE
GROUP BY DEPT_CODE
HAVING SUM(SALARY) = (
    SELECT MAX(SUM(SALARY))
    FROM EMPLOYEE
    GROUP BY DEPT_CODE
);

-- 5) 전지연 사원이 속해있는 부서원들 조회 (단, 전지연 사원은 제외)
--    사번, 사원명, 전화번호, 직급명, 부서명, 입사일
-- 전지연 사원이 속해있는 부서 조회
SELECT DEPT_CODE
FROM EMPLOYEE
WHERE EMP_NAME = '전지연';

-- ANSI 구문
SELECT E.EMP_ID, E.EMP_NAME, E.PHONE, J.JOB_NAME, D.DEPT_TITLE, E.HIRE_DATE
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
WHERE E.DEPT_CODE = (
    SELECT DEPT_CODE
    FROM EMPLOYEE
    WHERE EMP_NAME = '전지연'
) AND E.EMP_NAME != '전지연';

-- 오라클 구문

----------------------------------------------------------------
/*
    <다중행 서브 쿼리>
        서브 쿼리의 조회 결과 값의 행의 개수가 여러 행 일 때
        
        IN / NOT IN (서브쿼리) : 여러 개의 결과값 중에서 한 개라도 일치하는 값이 있다면 혹은 없다면 TRUE를 리턴한다.
        ANY : 여러 개의 값들 중에서 한 개라도 만족하면 TRUE, IN과 다른 점은 비교 연산자를 사용한다는 점이다.
            SALARY = ANY(...) : IN과 같은 결과
            SALARY != ANY(...) : NOT IN과 같은 결과
            SALARY > ANY(...) : 최소값 보다 크면 TRUE 리턴
            SALARY < ANY(...) : 최대값 보다 작으면 TRUE 리턴 
        ALL : 여러 개의 값들 모두와 비교하여 만족해야한 TRUE
            SALARY > ALL(...) : 최대값 보다 크면 TRUE 리턴
            SALARY < ALL(...) : 최소값 보다 작으면 TRUE 리턴
*/
-- 1) 각 부서별 최고 급여를 받는 직원의 이름, 직급 코드, 부서 코드, 급여 조회
-- 부서별 최고 급여 조회
SELECT MAX(SALARY)
FROM EMPLOYEE
GROUP BY DEPT_CODE; -- (2890000, 3660000, 8000000, 3760000, 3900000, 2490000, 2550000)

-- 위 급여를 받는 사원들 조회
SELECT EMP_NAME, JOB_CODE, NVL(DEPT_CODE, '부서없음'), SALARY
FROM EMPLOYEE
WHERE SALARY IN (2890000, 3660000, 8000000, 3760000, 3900000, 2490000, 2550000)
ORDER BY DEPT_CODE;

-- 위의 쿼리문을 합쳐서 하나의 쿼리문으로 작성
SELECT EMP_NAME, JOB_CODE, NVL(DEPT_CODE, '부서없음'), SALARY
FROM EMPLOYEE
WHERE SALARY IN (
    SELECT MAX(SALARY)
    FROM EMPLOYEE
    GROUP BY DEPT_CODE
)
ORDER BY DEPT_CODE;

-- 2) 직원에 대해 사번, 이름, 부서 코드, 구분(사수/사원) 조회
-- 사수에 해당하는 사번을 조회
SELECT DISTINCT MANAGER_ID
FROM EMPLOYEE
WHERE MANAGER_ID IS NOT NULL; -- (201, 204, 100, 200, 211, 207, 214)

-- 사번이 위와 같은 직원들의 사번, 이름, 부서 코드, 구분(사수) 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE, '사수' AS "구분"
FROM EMPLOYEE
WHERE EMP_ID IN (201, 204, 100, 200, 211, 207, 214);

-- 하나의 쿼리문으로 작성
SELECT EMP_ID, EMP_NAME, DEPT_CODE, '사수' AS "구분"
FROM EMPLOYEE
WHERE EMP_ID IN (
    SELECT DISTINCT MANAGER_ID
    FROM EMPLOYEE
    WHERE MANAGER_ID IS NOT NULL
);

-- 일반 사원에 해당하는 정보 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE, '사원' AS "구분"
FROM EMPLOYEE
WHERE EMP_ID NOT IN (
    SELECT DISTINCT MANAGER_ID
    FROM EMPLOYEE
    WHERE MANAGER_ID IS NOT NULL
);

-- 위의 결과들을 하나의 결과로 확인 (UNION 방식)
SELECT EMP_ID, EMP_NAME, DEPT_CODE, '사수' AS "구분"
FROM EMPLOYEE
WHERE EMP_ID IN (
    SELECT DISTINCT MANAGER_ID
    FROM EMPLOYEE
    WHERE MANAGER_ID IS NOT NULL
)

UNION           -- 쿼리문 합치는 방법 중 하나

SELECT EMP_ID, EMP_NAME, DEPT_CODE, '사원' AS "구분"
FROM EMPLOYEE
WHERE EMP_ID NOT IN (
    SELECT DISTINCT MANAGER_ID
    FROM EMPLOYEE
    WHERE MANAGER_ID IS NOT NULL
);

--SELECT 절에 서브 쿼리를 사용하는 방법
SELECT EMP_ID, EMP_NAME, DEPT_CODE,
       CASE
            WHEN EMP_ID IN (
                SELECT DISTINCT MANAGER_ID
                FROM EMPLOYEE
                WHERE MANAGER_ID IS NOT NULL) 
            THEN '사수'
            ELSE '사원'
       END AS "구분"
FROM EMPLOYEE;

-- 3) 대리 직급임에도 과장 직급들의 최소 급여보다 많이 받는 직원의 사번, 이름, 직급, 급여 조회 (사원 -> 대리 -> 과장 -> 차장 -> 부장)
-- 과장 직급들의 급여 정보
SELECT SALARY
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE J.JOB_NAME = '과장'; -- (2200000, 2500000, 3760000)

-- 직급이 대리인 직원들 중에서 위 목록들 값 중에 하나라도 큰 경우
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE J.JOB_NAME = '대리' AND SALARY > ANY (2200000, 2500000, 3760000); -- SALARY > 220만 OR SALARY > 250만 OR SALARY > 376만

-- 한 개의 쿼리문으로 합쳐보기 
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE J.JOB_NAME = '대리' AND SALARY > ANY (
    SELECT SALARY
    FROM EMPLOYEE E
    JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
    WHERE J.JOB_NAME = '과장'
);

-- 4) 과장 직급임에도 차장 직급의 최대 급여보다 더 많이 받는 직원들의 사번, 이름, 직급, 급여 조회 (사원 -> 대리 -> 과장 -> 차장 -> 부장)
-- 차장 직급들의 급여 조회
SELECT SALARY
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE J.JOB_NAME = '차장'; -- (2800000, 1550000, 2490000, 2480000)

-- 과장 직급임에도 차장 직급의 최대 급여보다 더 많이 받는 직원
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY
FROM EMPLOYEE E
JOIN JOB J USING(JOB_CODE)
WHERE J.JOB_NAME = '과장' AND SALARY > ALL (2800000, 1550000, 2490000, 2480000);
-- SALARY > 280만 AND SALARY > 155만 AND SALARY > 249만 AND SALARY > 248만

-- 한 개의 쿼리문으로 합쳐보기
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY
FROM EMPLOYEE E
JOIN JOB J USING(JOB_CODE)
WHERE J.JOB_NAME = '과장' AND SALARY > ALL (
    SELECT SALARY
    FROM EMPLOYEE E
    JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
    WHERE J.JOB_NAME = '차장'
);

-------------------------------------------------------------------

/*
    <다중열 서브 쿼리>
        조회 결과 값은 한 행이지만 나열된 컬럼 수가 여러 개일 때
*/

-- 1) 하이유 사원과 같은 부서 코드, 같은 직급 코드에 해당하는 사원들 조회
-- 하이유 사원의 부서 코드와 직급 코드 조회
SELECT DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE EMP_NAME = '하이유'; -- D5, J5

-- 부서 코드가 D5이면서 직급 코드가 J5인 사원들 조회
SELECT EMP_NAME, DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5' AND JOB_CODE = 'J5';

-- 각각 단일행 서브 쿼리로 작성
SELECT EMP_NAME, DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE DEPT_CODE = (
    SELECT DEPT_CODE -- 단일행 서브 쿼리
    FROM EMPLOYEE
    WHERE EMP_NAME = '하이유'
)
AND JOB_CODE = (
    SELECT JOB_CODE  -- 단일행 서브 쿼리
    FROM EMPLOYEE
    WHERE EMP_NAME = '하이유'
);

-- 다중열 서브 쿼리를 사용해서 하나의 쿼리로 작성
SELECT EMP_NAME, DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE (DEPT_CODE, JOB_CODE) = (
    SELECT DEPT_CODE, JOB_CODE
    FROM EMPLOYEE
    WHERE EMP_NAME = '하이유'
);

SELECT EMP_NAME, DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE (DEPT_CODE, JOB_CODE) IN (
    SELECT DEPT_CODE, JOB_CODE
    FROM EMPLOYEE
    WHERE EMP_NAME = '하이유'
);

-- 2) 박나라 사원과 직급 코드가 일치 하면서 같은 사수를 가지고 있는 사원의 사번, 이름, 직급 코드, 사수 사번 조회
-- 박나라 사원의 직급 코드와 사수의 사번을 조회 --> 결과값 1행의 여러열
SELECT JOB_CODE, MANAGER_ID
FROM EMPLOYEE
WHERE EMP_NAME = '박나라'; -- ('J7', 207)

-- 위 쿼리문을 다중열 서브 쿼리로 사용하는 메인 쿼리문 작성
SELECT EMP_ID, EMP_NAME, JOB_CODE, MANAGER_ID
FROM EMPLOYEE
WHERE (JOB_CODE, MANAGER_ID) = (
    SELECT JOB_CODE, MANAGER_ID
    FROM EMPLOYEE
    WHERE EMP_NAME = '박나라'
);

SELECT EMP_ID, EMP_NAME, JOB_CODE, MANAGER_ID
FROM EMPLOYEE
WHERE (JOB_CODE, MANAGER_ID) IN (
    SELECT JOB_CODE, MANAGER_ID
    FROM EMPLOYEE
    WHERE EMP_NAME = '박나라'
);

-------------------------------------------------------------------
/*
    <다중행 다중열 서브 쿼리>
        서브 쿼리의 조회 결과값이 여러 행, 여러 열일 경우
*/
-- 1. 각 직급별로 최소 급여를 받는 사원들의 사번, 이름, 직급 코드, 급여 조회
-- 각 직급별 최소 급여 조회
SELECT JOB_CODE, MIN(SALARY)
FROM EMPLOYEE
GROUP BY JOB_CODE; 

-- 각 직급별 최소 급여를 받는 사원들의 사번, 이름, 직급 코드, 급여 조회
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE JOB_CODE = 'J2' AND SALARY = 3700000
   OR JOB_CODE = 'J7' AND SALARY = 1380000
   OR JOB_CODE = 'J3' AND SALARY = 3400000;

SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE (JOB_CODE, SALARY) IN (('J2', 3700000), ('J3', 3400000), ('J7', 1380000));

-- 다중행 다중열 서브 쿼리를 사용해서 각 직급별로 최소 급여를 받는 사원의 사번, 이름, 직급 코드, 급여 조회
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE (JOB_CODE, SALARY) IN (
    SELECT JOB_CODE, MIN(SALARY)
    FROM EMPLOYEE
    GROUP BY JOB_CODE
)
ORDER BY JOB_CODE;

-- 2. 각 부서별 최소 급여를 받는 사원들의 사번, 이름, 부서 코드, 급여 조회
-- 각 부서별 최소 급여 조회
SELECT NVL(DEPT_CODE, '부서없음'), MIN(SALARY)
FROM EMPLOYEE
GROUP BY DEPT_CODE;

-- 다중행 다중열 서브 쿼리를 사용해서 각 부서별로 최소 급여를 받는 사원들의 사번, 이름, 부서 코드, 급여 조회
SELECT EMP_ID, EMP_NAME, NVL(DEPT_CODE, '부서없음'), SALARY
FROM EMPLOYEE
WHERE (NVL(DEPT_CODE, '부서없음'), SALARY) IN(
    SELECT NVL(DEPT_CODE, '부서없음'), MIN(SALARY)
    FROM EMPLOYEE
    GROUP BY DEPT_CODE
)
ORDER BY DEPT_CODE;

SELECT DEPT_CODE, SALARY FROM EMPLOYEE;

-------------------------------------------------------------------
/*
    <인라인 뷰>
        FROM 절에 서브 쿼리를 제시하고, 서브 쿼리를 수행한 결과를 테이블 대신에 사용한다.
*/

-- 1) 인라인 뷰를 활용한 TOP-N 문석
-- 전 직원 중 급여가 가장 높은 상위 5명의 순위, 이름, 급여 조회
--  * ROWNUM : 오라클에서 제공하는 컬럼, 조회된 순서대로 1 부터 순번을 부여하는 컬럼
SELECT ROWNUM, EMP_NAME, SALARY
FROM EMPLOYEE
ORDER BY SALARY DESC;
-- 이미 순번이 정해진 다음에 정렬이 되었다.
-- FROM -> SELECT(순번이 정해진다.) -> ORDER BY

-- 해결 방법
-- ORDER BY 한 결과값을 가지고 ROWNUM을 부여하면 된다. (인라인 뷰 사용)

SELECT ROWNUM AS "순위", 
       EMP_NAME AS "사원명", 
       SALARY AS "급여"
FROM (
    SELECT EMP_NAME, SALARY
    FROM EMPLOYEE
    ORDER BY SALARY DESC
)
WHERE ROWNUM <= 5;

-- 2) 부서별 평균 급여가 높은 3개의 부서의 부서 코드, 평균 급여 조회
SELECT ROWNUM, DEPT_CODE, ROUND(평균급여)
FROM (
    SELECT NVL(DEPT_CODE, '부서없음') AS "DEPT_CODE", 
           AVG(NVL(SALARY, 0)) AS "평균급여"
    FROM EMPLOYEE
    GROUP BY DEPT_CODE
    ORDER BY 2 DESC
)
WHERE ROWNUM <= 3;

-- 2-1) WITH를 이용한 방법
WITH TOPN_SAL AS (
    SELECT NVL(DEPT_CODE, '부서없음') AS "DEPT_CODE", 
           AVG(NVL(SALARY, 0)) AS "평균급여"
    FROM EMPLOYEE
    GROUP BY DEPT_CODE
    ORDER BY 2 DESC
)

SELECT DEPT_CODE, ROUND(평균급여)
FROM TOPN_SAL
WHERE ROWNUM <= 3;

-------------------------------------------------------------------
/*
    <RANK 함수>
        [표현법]
            RANK() OVER(정렬 기준) / DENSE_RANK() OVER(정렬 기준)
        RANK() OVER(정렬 기준)       : 동일한 순위 이후의 등수를 동일한 인원수만큼 건너뛰고 순위를 계산한다. (ex. 공동 1위가 2명이명 다음 순위는 3위)
        DENSE_RANK() OVER(정렬 기준) : 동일한 순위 이후의 등수를 무조건 1씩 증가한다. (ex. 공동 1위가 2명이면 다음 순위는 2위 )
*/
-- 사원별 급여가 높은 순서대로 순위를 매겨서 순위, 사원명, 급여 조회
-- 공동 19위 2명 뒤에 순위는 21위
SELECT RANK() OVER(ORDER BY SALARY DESC) AS "RANK" ,EMP_NAME, SALARY
FROM EMPLOYEE;

-- 공동 19위 2명 뒤에 순위는 20위
SELECT DENSE_RANK() OVER(ORDER BY SALARY DESC) AS "RANK" ,EMP_NAME, SALARY
FROM EMPLOYEE;

-- 상위 5명만 조회
SELECT RANK() OVER(ORDER BY SALARY DESC) AS "RANK" ,EMP_NAME, SALARY
FROM EMPLOYEE
WHERE RANK() OVER(ORDER BY SALARY DESC) <= 5; -- RANK 함수는 WHERE 절에 사용할 수 없다.

SELECT RANK, EMP_NAME, SALARY
FROM (
    SELECT RANK() OVER(ORDER BY SALARY DESC) AS "RANK" ,EMP_NAME, SALARY
    FROM EMPLOYEE
)
WHERE RANK <= 5;