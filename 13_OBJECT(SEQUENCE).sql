/*
    <SEQUENCE>
        정수값을 순차적으로 생성하는 역할을 하는 객체이다. 
        
    <SEQUENCE 생성>
        [표현법]
            CREATE SEQUENCE 시퀀스명
            [START WITH 숫자]
            [INCREMENT BY 숫자]
            [MAXVALUE 숫자]
            [MINVALUE 숫자]
            [CYCLE | NOCYCLE]
            [CACHE 바이트크기 | NOCACHE]; (기본값 20바이트)
            
        [사용 구문]
            시퀀스명.CURRVAL : 현재 시퀀스의 값
            시퀀스명.NEXTVAL : 시퀀스 값을 증가시키고 증가된 시퀀스 값 
                              (기존 시퀀스 값에서 INCREMENT 값 만큼 증가된 값)
        
        * 캐시메모리
          - 미리 다음 값들을 생성해서 저장해둔다.
          - 매번 호출할 때마다 시퀀스 값을 새로 생성을 하는 것이 아닌 캐시 메모리 공간에 미리 생성된 값들을 사용한다.
*/

CREATE SEQUENCE SEQ_EMPNO
START WITH 300
INCREMENT BY 5
MAXVALUE 310
NOCYCLE
NOCACHE;

-- 현재 계정이 가지고 있는 시퀀스들에 대한 정보를 조회하는 데이터 딕셔너리
SELECT * FROM USER_SEQUENCES;

-- NEXTVAL를 한 번이라도 수행하지 않는 이상 CURRVAL를 가져올 수 없다.
-- CURRVAL는 마지막으로 수행된 NEXTVAL 값을 저장해서 보여주는 값이다.
SELECT SEQ_EMPNO.CURRVAL FROM DUAL;

SELECT SEQ_EMPNO.NEXTVAL FROM DUAL; -- 300
SELECT SEQ_EMPNO.CURRVAL FROM DUAL; -- 300
SELECT SEQ_EMPNO.NEXTVAL FROM DUAL; -- 305
SELECT SEQ_EMPNO.NEXTVAL FROM DUAL; -- 310
-- 지정한 MAXVALUE 값을 초과했기 때문에 오류가 발생한다.
SELECT SEQ_EMPNO.NEXTVAL FROM DUAL; -- ERROR
SELECT SEQ_EMPNO.CURRVAL FROM DUAL;

SELECT * FROM USER_SEQUENCES;

/*
    <SEQUENCE 수정>
        [표현법]
            ALTER SEQUENCE 시퀀스명
            [INCREMENT BY 숫자]
            [MAXVALUE 숫자]
            [MINVALUE 숫자]
            [CYCLE | NOCYCLE]
            [CACHE 바이트크기 | NOCACHE]; (기본값 20바이트)
        
        - START WITH는 변경이 불가능하다. 즉, 재설정하고 싶다면 기존 시퀀스를 삭제 후 재생성해야 한다.
*/

ALTER SEQUENCE SEQ_EMPNO
-- START WITH 200 -- 구문 오류 발생
INCREMENT BY 10
MAXVALUE 400;

SELECT * FROM USER_SEQUENCES;

SELECT SEQ_EMPNO.CURRVAL FROM DUAL; -- 310
SELECT SEQ_EMPNO.NEXTVAL FROM DUAL; -- 320

/*
    <시퀀스 삭제>
        DROP SEQUENCE 시퀀스명;
*/

DROP SEQUENCE SEQ_EMPNO;

------------------------------------------------------------------
-- 매번 새로운 사번이 발생되는 시퀀스 생성
CREATE SEQUENCE SEQ_EID
START WITH 910;

-- 매번 새로운 사번이 바생되는 시퀀스 사용
INSERT INTO EMPLOYEE
VALUES(SEQ_EID.NEXTVAL,'홍길동', '666666-6666666', 'HONG@KH.OR.KR', '01000001111', 'D2', 
            'J2', 50000000, 0.1, NULL, SYSDATE, NULL, DEFAULT);
            
INSERT INTO EMPLOYEE
VALUES(SEQ_EID.NEXTVAL,'도깨비', '666666-6666666', 'HONG@KH.OR.KR', '01000001111', 'D2', 
            'J2', 50000000, 0.1, NULL, SYSDATE, NULL, DEFAULT);

ROLLBACK;