/*
    <TRIGGER>
        테이블이 INSERT, UPDATE, DELETE 등 DML 구문에 의해서 변경될 경우(테이블에 이벤트 발생 시)
        자동으로 실행될 내용을 정의해놓는 객체이다.
        
        * 트리거의 종류
          1) SQL 문의 실행 시기에 따른 분류]
            - BEFORE TRIGGER : 해당 SQL 문장 실행 전 트리거를 실행한다.
            - AFTER TRIGGER  : 해당 SQL 문장 실행 후 트리거를 실행한다.
          
          2) SQL 문에 의해 영향을 받는 행에 따른 분류
            - 문장 트리거(STATEMENT TRIGGER) : 해당 SQL 문에 대해 한 번만 트리거를 실행한다.
            - 행 트리거 (ROW TRIGGER)        : 해당 SQL 문에 영향을 받는 행마다 트리거를 실행한다. (FOR EACH ROW 옵션을 기술)
            
        [표현법]
            CREATE OR REPLACE TRIGGER 트리거명
            BEFORE|AFTER INSERT|UPDATE|DELETE ON 테이블명
            [FOR EACH ROW]
            [DECLARE
                선언부]
            BEGIN
                실행부
            [EXCEPTION
                예외처리부]
            END;
            /
*/
CREATE OR REPLACE TRIGGER TRG_01
AFTER UPDATE ON EMPLOYEE
BEGIN
    DBMS_OUTPUT.PUT_LINE('업데이트 실행!!');
END;
/

CREATE OR REPLACE TRIGGER TRG_02
AFTER UPDATE ON EMPLOYEE
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('변경 전 : ' || :OLD.DEPT_CODE ||', 변경 후 : ' || :NEW.DEPT_CODE);
END;
/

UPDATE EMPLOYEE
SET DEPT_CODE = 'D1'
WHERE DEPT_CODE = 'D9';

SELECT * FROM EMPLOYEE;

ROLLBACK;

-----------------------------------------------------------------
-- 상품 입고, 출고 관련 예시
-- 1. 상품에 대한 데이터를 보관할 테이블 (PRODUCT)

CREATE TABLE PRODUCT(
    PCODE NUMBER PRIMARY KEY,   -- 상품코드
    PNAME VARCHAR2(30),         -- 상품명
    BRAND VARCHAR2(30),         -- 브랜드 명
    PRICE NUMBER,               -- 가격
    STOCK NUMBER DEFAULT 0      -- 재고
);

-- 상품코드가 중복되지 않게 새로운 번호를 발생하는 시퀀스 객체를 생성한다.
CREATE SEQUENCE SEQ_PCODE;

INSERT INTO PRODUCT VALUES(SEQ_PCODE.NEXTVAL, 'Z플립', '삼성', 1500000, DEFAULT);
INSERT INTO PRODUCT VALUES(SEQ_PCODE.NEXTVAL, '아이폰13', '애플', 1000000, DEFAULT);
INSERT INTO PRODUCT VALUES(SEQ_PCODE.NEXTVAL, '사오미폰', '사오미', 800000, DEFAULT);

SELECT * FROM PRODUCT;

-- 2. 상품 입출고 상세 이력을 보관할 테이블 (PRODETAIL)
CREATE TABLE PRODETAIL (
    DCODE NUMBER PRIMARY KEY,           -- 입출력 이력 코드
    PDATE DATE,                         -- 상품 입/출고 일
    AMOUNT NUMBER,                      -- 수량
    STATUS VARCHAR2(10),                -- 상태(입고/출고)
    PCODE NUMBER,                       -- 상품 코드(외래 키로 지정, PRODUCT 테이블을 참조)
    CHECK(STATUS IN ('입고', '출고')),
    FOREIGN KEY(PCODE)REFERENCES PRODUCT
);

CREATE SEQUENCE SEQ_DCODE;

-- 1번 상품이 오늘 날짜로 10개 입고
INSERT INTO PRODETAIL VALUES (SEQ_DCODE.NEXTVAL, SYSDATE, 10, '입고', 1);
-- 재고 수량도 변경해야 한다.
UPDATE PRODUCT
SET STOCK = STOCK + 10
WHERE PCODE = 1;

-- 2번 상품이 오늘 날짜로 20개 입고
INSERT INTO PRODETAIL VALUES (SEQ_DCODE.NEXTVAL, SYSDATE, 20, '입고', 2);
-- 재고 수량도 변경해야 한다.
UPDATE PRODUCT
SET STOCK = STOCK + 20
WHERE PCODE = 2;

-- 3번 상품이 오늘 날짜로 5개 입고
INSERT INTO PRODETAIL VALUES (SEQ_DCODE.NEXTVAL, SYSDATE, 5, '입고', 3);
-- 재고 수량도 변경해야 한다.
UPDATE PRODUCT
SET STOCK = STOCK + 5
WHERE PCODE = 3;

--2번 상품이 오늘 날짜로 5개 출고
INSERT INTO PRODETAIL VALUES (SEQ_DCODE.NEXTVAL, SYSDATE, 5, '출고', 2);
-- 재고 수량도 변경해야 한다.
UPDATE PRODUCT
SET STOCK = STOCK - 5
WHERE PCODE = 2;

-- PRODETAIL 테이블에 데이터 삽입 시 PRODUCT 테이블에 재고 수량이 업데이트 되도록 트리거를 생성한다.
CREATE OR REPLACE TRIGGER TRG_PRO_STOCK
AFTER INSERT ON PRODETAIL
FOR EACH ROW
BEGIN
     DBMS_OUTPUT.PUT_LINE(:NEW.STATUS || ' ' || :NEW.AMOUNT || ' ' || :NEW.PCODE);
     
     -- 상품이 입고된 경우
     IF (:NEW.STATUS = '입고') THEN
        UPDATE PRODUCT
        SET STOCK = STOCK + :NEW.AMOUNT
        WHERE PCODE = :NEW.PCODE;
     END IF;
     
     -- 상품이 출고된 경우
     IF (:NEW.STATUS = '출고') THEN
        UPDATE PRODUCT
        SET STOCK = STOCK - :NEW.AMOUNT
        WHERE PCODE = :NEW.PCODE;
     END IF;
END;
/

-- 2번 상품이 오늘 날짜로 20개가 입고
INSERT INTO PRODETAIL VALUES (SEQ_DCODE.NEXTVAL, SYSDATE, 20, '입고', 2);

-- 2번 상품이 오늘 날짜로 25개가 출고
INSERT INTO PRODETAIL VALUES (SEQ_DCODE.NEXTVAL, SYSDATE, 25, '출고', 2);

-- 2번 상품이 오늘 날짜로 25개가 출고
INSERT INTO PRODETAIL VALUES (SEQ_DCODE.NEXTVAL, SYSDATE, 25, '출고', 2);

SELECT * FROM PRODUCT;
SELECT * FROM PRODETAIL;

ROLLBACK;