/*
    <TCL(Transaction Control Language)>
        트랜잭션을 제어하는 언어이다.

        * 트랜잭션
          - 하나의 논리적인 작업 단위를 트랜잭션이라고 한다.
            ATM에서 현금 출금
                1. 카드 삽입
                2. 메뉴 선택
                3. 금액 확인 및 인증
                4. 실제 계좌에서 금액만큼 인출
                5. 실제 현금 인출
                6. 완료
          - 각각의 업들을 묶어서 하나의 작업 단위로 만들어 버리는 것을 트랜잭션이라고 한다.
          - 데이터의 변경 사항(DML)들을 묶어서 하나의 트랜잭션에 담아 처리한다.
            (COMMIT 하기 전까지의 변경사항들을 하나의 트랜잭션에 담게 된다.)
          - 트랜잭션은 DML(INSERT, UPDATE, DELETE)을 대상으로 적용된다.
          - COMMIT(트랜잭션 종료 처리 후 저장), ROLLBACK(트랜잭션 취소), SAVEPOINT(임시저장)을 통해서 트랜잭션을 제어한다.
            COMMIT
                메모리 버퍼에 임시 저장된 데이터를 DB에 반영한다.
                모든 작업들을 정상적으로 처리하겠다고 확정하는 구문, 하나의 트랜잭션 과정을 종료하게 된다.
            ROLLBACK
                메모리 버퍼에 임시 저장된 데이터를 삭제한 후 마지막 COMMIT 시점으로 돌아간다.
                모든 작업들을 취소 처리하겠다고 확정하는 구문, 하나의 트랜잭션 과정을 취소하게 된다.
            SAVEPOINT
                저장점을 정의해두면 ROLLBACK 진행할 때 전체 작업을 ROLLBACK 하는 게 아닌 SAVEPOINT 까지의 일부만 롤백 한다.
                    SAVEPOINT 포인트명;     -- 저장점 지정
                    ROLLBACK TO 포인트명;   -- 해당 포인트 지점까지의 트랜잭션만 롤백 한다.
        
*/
-- 새로운 테이블 생성
CREATE TABLE EMP_01 
AS SELECT EMP_ID, EMP_NAME, DEPT_TITLE
   FROM EMPLOYEE E
   LEFT OUTER JOIN DEPARTMENT D ON(E.DEPT_CODE = D.DEPT_ID);

-- EMP_ID가 900, 901인 사원 지우기
DELETE FROM EMP_01
WHERE EMP_ID IN (900, 901);

-- 두 개의 행이 삭제된 시점에 SAVEPOINT 지정
SAVEPOINT SP;
 
-- EMP_ID가 200인 사원 지우기
DELETE FROM EMP_01
WHERE EMP_ID = 200;

ROLLBACK TO SP;

ROLLBACK;

COMMIT;

-- EMP_ID가 213인 사원 지우기
DELETE FROM EMP_01
WHERE EMP_ID = 213;

-- DDL 구문을 실행하는 순간 기존에 메모리 버퍼에 임시 저장된 변경사항들이 무조건 DB에 반영된다. (COMMIT 시켜버린다.)
CREATE TABLE TEST (
    TID NUMBER
);

ROLLBACK;

SELECT *
FROM EMP_01
ORDER BY EMP_ID;

DROP TABLE EMP_01;
DROP TABLE TEST;