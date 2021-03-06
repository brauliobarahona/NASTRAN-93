      SUBROUTINE MCE2        
C        
C     MCE2 PARTITIONS KGG INTO KNNB, KMNB AND KMMB THEN COMPUTES        
C        
C     KNN = KNNB + GM(T)*KMNB + KMNB(T)*GM + GM(T)*KMMB*GM        
C        
C     SIMILAR OPERATIONS ARE PERFORMED ON MGG, BGG AND K4GG IF THE      
C     MATRIX HAS NOT BEEN PURGED.        
C        
      INTEGER         SCR1  ,SCR2  ,SCR6  ,USET  ,MCB(7),GM    ,UG    , 
     1                UN    ,UM    ,BGG   ,BNNB  ,BMNB  ,BNN   ,BMMB    
      COMMON /BITPOS/ UM    ,UO    ,UR    ,USG   ,USB   ,UL    ,UA    , 
     1                UF    ,US    ,UN    ,UG    ,UE    ,UP        
C        
C     INPUT AND OUTPUT FILES        
C        
      DATA    USET  , GM , KGG, MGG, BGG, K4GG,   KNN, MNN, BNN, K4NN / 
     1        101   , 102, 103, 104, 105, 106 ,   201, 202, 203, 204  / 
C        
C     SCRATCH FILES        
C        
      DATA    SCR1  , SCR2, SCR6 / 301, 302, 306 /        
      DATA    KNNB  , KMNB, KMMB / 303, 304, 305 /        
      DATA    MNNB  , MMNB, MMMB / 303, 304, 305 /        
      DATA    BNNB  , BMNB, BMMB / 303, 304, 305 /        
      DATA    K4NNB , K4MNB,K4MMB/ 303, 304, 305 /        
C        
C     ARITHMETIC TYPES        
C        
C     PARTITION KGG INTO KNNB, KMNB, AND KMMB        
C        
      CALL UPART (USET,SCR1,UG,UN,UM)        
      CALL MPART (KGG,KNNB,KMNB,0,KMMB)        
C        
C     COMPUTE KNN        
C        
      CALL ELIM (KNNB,KMNB,KMMB,GM,KNN,SCR1,SCR2,SCR6)        
C        
C     TEST TO SEE IF MGG IS PRESENT        
C        
      MCB(1) = MGG        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LT. 0) GO TO 110        
C        
C     IF MGG PRESENT, PARTITION INTO MNNB, MMNB, AND MMMB        
C     THEN COMPUTE MNN        
C        
      CALL UPART (USET,SCR1,UG,UN,UM)        
      CALL MPART (MGG,MNNB,MMNB,0,MMMB)        
      CALL ELIM  (MNNB,MMNB,MMMB,GM,MNN,SCR1,SCR2,SCR6)        
C        
C     TEST TO SEE IF BGG IS PRESENT        
C        
  110 MCB(1) = BGG        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LT. 0) GO TO 130        
C        
C     IF BGG PRESENT, PARTITION INTO BNNB, BMNB, AND BMMB        
C     THEN COMPUTE BNN        
C        
      CALL UPART (USET,SCR1,UG,UN,UM)        
      CALL MPART (BGG,BNNB,BMNB,0,BMMB)        
      CALL ELIM  (BNNB,BMNB,BMMB,GM,BNN,SCR1,SCR2,SCR6)        
C        
C     TEST TO SEE IF K4GG IS PRESENT        
C        
  130 MCB(1) = K4GG        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LT. 0) RETURN        
C        
C     IF K4GG IS PRESENT, PARTITION INTO K4NNB, K4MNB, AND K4MMB        
C     THEN COMPUTE K4NN        
C        
      CALL UPART (USET,SCR1,UG,UN,UM)        
      CALL MPART (K4GG,K4NNB,K4MNB,0,K4MMB)        
      CALL ELIM  (K4NNB,K4MNB,K4MMB,GM,K4NN,SCR1,SCR2,SCR6)        
      RETURN        
      END        
