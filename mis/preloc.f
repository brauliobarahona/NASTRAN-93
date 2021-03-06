      SUBROUTINE PRELOC (*,BUF,FILE)        
C        
C     PRELOC OPENS AND POSITIONS REQUESTED FILE TO FIRST DATA RECORD.   
C     LOCATE POSITIONS FILE TO REQUESTED DATA RECORD WITHIN FILE.       
C        
      EXTERNAL        ANDF        
      INTEGER         BUF(2),FILE  ,NAM(2),TRL(7),NM1(2),FLAG  ,ANDF  , 
     1                TWO   ,RET   ,BFF(1),ID(2) ,FLG        
      COMMON /TWO   / TWO(32)        
      DATA    NAM   ,        NM1          /        
     1        4HPREL, 4HOC  ,4HLOCA,4HTE  /        
C        
C     OPEN FILE. IF PURGED, GIVE ALTERNATE RETURN.        
C     OTHERWISE SKIP HEADER RECORD        
C        
      TRL(1) = FILE        
      CALL RDTRL (TRL)        
      IF (TRL(1) .LT. 0) GO TO 10        
      IF (TRL(2)+TRL(3)+TRL(4)+TRL(5)+TRL(6)+TRL(7) .EQ. 0) GO TO 10    
      CALL OPEN (*10,FILE,BUF(2),0)        
      CALL FWDREC (*2,FILE)        
      BUF(1) = FILE        
      ICHECK = 123456789        
      RETURN        
   10 RETURN 1        
C        
C     FATAL FILE ERRORS        
C        
    2 CALL MESAGE (-2,FILE,NAM)        
    3 CALL MESAGE (-3,TRL,NM1)        
C        
C        
      ENTRY LOCATE (*,BFF,ID,FLG)        
C     ===========================        
C        
C     ENTRY TO POSITION DATA RECORD.        
C        
C     READ TRAILER FOR FILE. IF BIT NOT ON OR FILE PURGED,        
C     GIVE ALTERNATE RETURN.        
C        
      IF (ICHECK .NE. 123456789) CALL ERRTRC ('LOCATE  ',10)        
      TRL(1) = BFF(1)        
      CALL RDTRL (TRL)        
      IF (TRL(1) .LT. 0) RETURN 1        
      K = (ID(2)-1)/16        
      L =  ID(2)- 16*K        
      IF (ANDF(TRL(K+2),TWO(L+16)) .EQ. 0) RETURN 1        
C        
C     READ THREE ID WORDS FROM DATA RECORD.        
C     IF END-OF-FILE, REPOSITION FILE TO FIRST DATA RECORD AND RETRY.   
C     IF ID WORD MATCHES USER, RETURN.        
C        
      LAST = 0        
      ASSIGN 20 TO RET        
   20 CALL READ (*50,*20,TRL(1),TRL(2),3,0,FLAG)        
      IF (TRL(2) .NE. ID(1)) GO TO 22        
      FLG = TRL(4)        
      RETURN        
C        
C     SKIP RECORD. READ ID WORDS FROM NEXT RECORD. IF MATCH,RETURN.     
C     IF END-OF FILE, REPOSITION TO FIRST DATA RECORD AND RETRY.        
C     IF NO MATCH, TEST FOR RETURN TO ORIGINAL FILE POSITION. IF SO,    
C     QUEUE MESSAGE AND GIVE ALTERNATE RETURN. IF NOT, CONTINUE SEARCH. 
C        
   22 ASSIGN 30 TO RET        
   25 CALL FWDREC (*2,TRL(1))        
   30 CALL READ (*50,*3,TRL(1),TRL(5),3,0,FLAG)        
      IF (TRL(5) .NE. ID(1)) GO TO 32        
      FLG = TRL(7)        
      RETURN        
C        
   32 IF (TRL(5) .NE. TRL(2)) GO TO 25        
   35 CALL SSWTCH (40,J)        
      IF (J .NE. 0) CALL ERRTRC ('LOCATE  ',35)        
      CALL MESAGE (30,72,ID)        
      CALL FWDREC (*2,TRL(1))        
      RETURN 1        
C        
C     CODE TO POSITION FILE TO FIRST DATA RECORD.        
C        
   50 CALL REWIND (TRL(1))        
      IF (LAST .NE. 0) GO TO 35        
      LAST = 1        
      CALL FWDREC (*2,TRL(1))        
      GO TO RET, (20,30)        
      END        
