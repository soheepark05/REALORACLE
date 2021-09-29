
/* < 오라클 sql 첫 단계 > */

-- : 한 줄 짜리 주석이다.

/* 
    여러줄 주석이다...
    
*/

-- 사용자의 계정을 생성하는 구문? : 관리자 계정만이 할 수 있다.
--[표현법] CREATE USER 계정명 IDENTIFIED BY 계정 비밀번호;
-- < 예시 >
CREATE USER KH IDENTIFIED BY KH;

-- 위에서 만든 사용자 계정에게 최소한의 권한(데이터 관리, 접속)을 부여함..
GRANT RESOURCE, CONNECT TO KH;

-- < 단축어 >
-- 1. ALT+F10 : 워크시트 생성
-- 2. CTRL + SHIFT + / : --이렇게 주석처리해줌  OR  CTRL+/ 해도된다.
-- 3. ALT + SHIFT + D : 한줄 삭제~


