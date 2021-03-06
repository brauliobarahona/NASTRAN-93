      SUBROUTINE YRCARD (OUT,NFLAG,IN)        
C        
C     THIS WAS NASTRAN ORIGINAL XRCARD ROUTINE, AND IS NOW RENAMED      
C     YRCARD        
C     THIS ROUTINE IS CALLED ONLY BY XRCARD        
C     THIS ROUTINE CAN BE DELETED IF THE NEW XRCARD ROUTINE PASSES      
C     ALL RELIABILITY TESTS                 G.CHAN/UNISYS,  2/1988      
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL         LSHIFT,RSHIFT,COMPLF        
      LOGICAL          ALPHA,DELIM,EXPONT,POWER,LMINUS,PASS,NOGO        
      REAL             FL1        
      DOUBLE PRECISION XDOUBL        
      DIMENSION        NDOUBL(2),NUM(10),TYPE(72),CHAR(72),OUT(1),      
     1                 IN(18),NT(15),CHARS(13)        
      CHARACTER        UFM*23        
      COMMON /XMSSG /  UFM        
      COMMON /LHPWX /  LOWPW,HIGHPW        
      COMMON /SYSTEM/  IBUFSZ,F6,NOGO,DUM1(7),NPAGES,NLINES        
      EQUIVALENCE      (FL1      ,INT1  ), (XDOUBL,NDOUBL(1)),        
     1                 (NUM(10)  ,ZERO  ), (CHARS( 1),DOLLAR),        
     2                 (CHARS( 2),PLUS  ), (CHARS( 3),EQUAL ),        
     3                 (CHARS( 4),MINUS ), (CHARS( 5),COMMA ),        
     4                 (CHARS( 6),SLASH ), (CHARS( 7),OPAREN),        
     5                 (CHARS( 8),CPAREN), (CHARS( 9),E     ),        
     6                 (CHARS(10),D     ), (CHARS(11),PERIOD),        
     7                 (CHARS(12),BLANK ), (CHARS(13),ASTK  )        
      DATA    BLANKS/  4H     /, BLANK / 4H     /, DOLLAR/ 4H$    /,    
     1        EQUAL /  1H=    /, ASTK  / 1H*    /, COMMA / 1H,    /,    
     2        SLASH /  1H/    /, CPAREN/ 1H)    /, OPAREN/ 1H(    /,    
     3        PLUS  /  1H+    /, MINUS / 1H-    /, PERIOD/ 1H.    /,    
     4        E     /  1HE    /, D     / 1HD    /, PASS  / .FALSE./,    
     5        NUM   /  1H1, 1H2, 1H3,1H4,1H5, 1H6, 1H7,1H8,1H9,1H0/     
C        
      IF (PASS) GO TO 50        
      PASS   = .TRUE.        
      A77777 = COMPLF(0)        
      A67777 = RSHIFT(LSHIFT(A77777,1),1)        
C        
C     READ AND TYPE 72 CHARACTERS        
C        
   50 N = 0        
      DO 90 I = 1,18        
      DO 90 J = 1,4        
      N = N + 1        
      CHARAC = KHRFN1(BLANKS,1,IN(I),J)        
      IF (CHARAC .EQ. BLANK) GO TO 70        
      DO 60 K = 1,10        
      IF (CHARAC .EQ. NUM(K)) GO TO 80        
   60 CONTINUE        
      TYPE(N) = -1        
      GO TO 90        
   70 TYPE(N) = 0        
      GO TO 90        
   80 TYPE(N) = 1        
   90 CHAR(N) = CHARAC        
      ALPHA = .FALSE.        
      DELIM = .TRUE.        
      IOUT  = 0        
      N     = 0        
      ASAVE = 1        
      OUT(ASAVE) = 0        
  100 IF (N .EQ. 72) GO TO 510        
      IF (NFLAG-IOUT .LT. 5) GO TO 660        
      LMINUS = .FALSE.        
      N = N + 1        
      NCHAR = CHAR(N)        
      IF (TYPE(N)) 110,100,210        
  110 IF (NCHAR.EQ.PLUS .OR. NCHAR.EQ.MINUS .OR. NCHAR.EQ.PERIOD)       
     1    GO TO 200        
      IF (NCHAR .EQ. DOLLAR) GO TO 180        
C        
C     GOOD ALPHA FIELD OR DELIMETER        
C        
      IF (ALPHA) GO TO 120        
      IF ((NCHAR.EQ.COMMA .OR. NCHAR.EQ.DOLLAR) .AND. (.NOT.DELIM))     
     1    GO TO 180        
      IF (NCHAR.EQ.CPAREN .AND. .NOT.DELIM) GO TO 180        
      IOUT  = IOUT + 1        
      ASAVE = IOUT        
      OUT(ASAVE) = 0        
      ALPHA = .TRUE.        
  120 IF (NCHAR.EQ.OPAREN .OR. NCHAR.EQ.SLASH .OR. NCHAR.EQ.EQUAL .OR.  
     1    NCHAR.EQ.COMMA  .OR. NCHAR.EQ.ASTK  .OR. NCHAR.EQ.DOLLAR)     
     2    GO TO 180        
      IF (NCHAR .EQ. CPAREN) GO TO 180        
      OUT(ASAVE) = OUT(ASAVE) + 1        
      IOUT  = IOUT + 2        
      DELIM = .FALSE.        
      OUT(IOUT-1) = BLANKS        
      OUT(IOUT  ) = BLANKS        
      ICHAR = 0        
      GO TO 150        
  130 IF (N .EQ. 72) GO TO 510        
      N = N + 1        
      NCHAR = CHAR(N)        
      IF (TYPE(N)) 140,100,150        
  140 IF (NCHAR.EQ.OPAREN .OR. NCHAR.EQ.SLASH .OR. NCHAR.EQ.EQUAL .OR.  
     1    NCHAR.EQ.COMMA  .OR. NCHAR.EQ.ASTK  .OR. NCHAR.EQ.DOLLAR)     
     2    GO TO 180        
      IF (NCHAR .EQ. CPAREN) GO TO 180        
  150 IF (ICHAR .EQ. 8) GO TO 130        
      ICHAR = ICHAR + 1        
      IF (ICHAR .LE. 4) GO TO 160        
      IPOS = ICHAR - 4        
      WORD = IOUT        
      GO TO 170        
  160 IPOS = ICHAR        
      WORD = IOUT - 1        
C        
C     CLEAR SPOT IN WORD FOR CHAR(N) AND PUT CHAR(N) IN IT        
C        
  170 OUT(WORD) = KHRFN1(OUT(WORD),IPOS,NCHAR,1)        
C        
C     GO FOR NEXT CHARACTER        
C        
      GO TO 130        
C        
C        
C     DELIMETER HIT        
C        
  180 IF (.NOT. DELIM) GO TO 190        
      IF (IOUT .EQ. 0) IOUT = 1        
      IOUT = IOUT + 2        
      OUT(ASAVE)  = OUT(ASAVE) + 1        
      OUT(IOUT-1) = BLANKS        
      OUT(IOUT  ) = BLANKS        
  190 IF (NCHAR .EQ. DOLLAR) GO TO 520        
      DELIM = .TRUE.        
      IF (NCHAR .EQ. CPAREN) DELIM = .FALSE.        
      IF (NCHAR .EQ.  COMMA) GO TO 100        
      IF (NCHAR .EQ. CPAREN) GO TO 100        
C        
C     OUTPUT DELIMETER        
C        
      IOUT = IOUT + 2        
      OUT(ASAVE ) = OUT(ASAVE) + 1        
      OUT(IOUT-1) = A77777        
      OUT(IOUT  ) = KHRFN1(BLANKS,1,NCHAR,1)        
      GO TO 100        
C        
C        
  200 IF (NCHAR .EQ.  MINUS) LMINUS = .TRUE.        
      IF (NCHAR .NE. PERIOD) N = N + 1        
      IF (N .GT. 72) GO TO 530        
C        
  210 ALPHA = .FALSE.        
      DELIM = .FALSE.        
      IT = 0        
      NT(1) = 0        
      DO 260 I = N,72        
      IF (TYPE(I)) 290,270,220        
C        
C     INTEGER CHARACTER        
C        
  220 DO 230 K = 1,9        
      IF (CHAR(I) .EQ. NUM(K)) GO TO 250        
  230 CONTINUE        
      K  = 0        
  250 IT = IT + 1        
      IF (IT .LT. 16) NT(IT) = K        
  260 CONTINUE        
C        
C     FALL HERE IMPLIES WE HAVE A SIMPLE INTEGER        
C        
  270 NUMBER = 0        
      DO 280 I = 1,IT        
      IF (((A67777-NT(I))/10) .LT. NUMBER) GO TO 550        
  280 NUMBER = NUMBER*10 + NT(I)        
      IF (LMINUS) NUMBER = - NUMBER        
      IOUT = IOUT + 2        
      OUT(IOUT-1) = -1        
      OUT(IOUT  ) = NUMBER        
      N = N + IT - 1        
      GO TO 100        
C        
C     REAL NUMBER, DELIMETER, OR ERROR IF FALL HERE        
C        
C     COUNT THE NUMBER OF DIGITS LEFT BEFORE CARD END OR DELIMETER HIT  
C        
  290 N1 = I        
      DO 300 N2 = N1,72        
      IF (CHAR(N2).EQ.OPAREN .OR. CHAR(N2).EQ.SLASH .OR.        
     1    CHAR(N2).EQ.EQUAL  .OR. CHAR(N2).EQ.COMMA .OR.        
     2    CHAR(N2).EQ.DOLLAR .OR. TYPE(N2).EQ.0) GO TO 310        
      IF (CHAR(N2) .EQ. CPAREN) GO TO 310        
  300 CONTINUE        
      N2 = 73        
  310 IF (N1 .EQ. N2) GO TO 270        
C        
C     CHARACTER N1 NOW MUST BE A DECIMAL FOR NO ERROR        
C        
      IF (CHAR(N1) .NE. PERIOD) GO TO 570        
      POWER = .FALSE.        
      N1 = N1 + 1        
      N2 = N2 - 1        
      PLACES = 0        
      PSIGN  = 0        
      EXPONT = .FALSE.        
      IPOWER = 0        
      PRECIS = 0        
      IF (N2 .LT. N1) GO TO 410        
      DO 400 I = N1,N2        
      IF (TYPE(I)) 360,570,320        
C        
C     NUMERIC        
C        
  320 DO 330 K = 1,9        
      IF (CHAR(I) .EQ. NUM(K)) GO TO 340        
  330 CONTINUE        
      K  = 0        
  340 IF (EXPONT) GO TO 350        
      IT = IT + 1        
      IF (IT .LT. 16) NT(IT) = K        
      PLACES = PLACES + 1        
      GO TO 400        
C        
C     BUILD IPOWER HERE        
C        
  350 POWER  = .TRUE.        
      IPOWER = IPOWER*10 + K        
      IF (IPOWER .GT. 1000) GO TO 630        
      GO TO 400        
C        
C     START EXPONENTS HERE        
C        
  360 IF (EXPONT) GO TO 380        
      EXPONT = .TRUE.        
      IF (CHAR(I).NE.PLUS .AND. CHAR(I).NE.MINUS) GO TO 370        
      PRECIS = E        
      PSIGN = CHAR(I)        
      GO TO 390        
  370 IF (CHAR(I).NE.E .AND. CHAR(I).NE.D) GO TO 600        
      PRECIS = CHAR(I)        
      GO TO 390        
C        
C     SIGN OF POWER        
C        
  380 IF (POWER) GO TO 590        
      IF (PSIGN.NE.0 .OR.(CHAR(I).NE.PLUS .AND. CHAR(I).NE.MINUS))      
     1    GO TO 610        
      PSIGN = CHAR(I)        
      POWER = .TRUE.        
  390 IF (I .EQ. 72) GO TO 530        
  400 CONTINUE        
  410 N = N2        
C        
C     ALL DATA COMPLETE FOR FLOATING POINT NUMBER        
C     15 FIGURES WILL BE ACCEPTED ONLY        
C        
      IF (IT .LE. 15) GO TO 420        
      IPOWER = IPOWER + IT - 15        
      IT = 15        
  420 IF (PSIGN .EQ. MINUS) IPOWER = -IPOWER        
      IPOWER = IPOWER - PLACES        
      NUMBER = 0        
      IF (IT .LT. 7) GO TO 430        
      N2 = 7        
      GO TO 440        
  430 N2 = IT        
  440 DO 450 I = 1,N2        
  450 NUMBER = NUMBER*10 + NT(I)        
      XDOUBL = DBLE(FLOAT(NUMBER))        
      IF (IT .LE. 7) GO TO 470        
      NUMBER = 0        
      N2 = IT - 7        
      DO 460 I = 1,N2        
      IT = I + 7        
  460 NUMBER = NUMBER*10 + NT(IT)        
      XDOUBL = XDOUBL*10.0D0**N2 + DBLE(FLOAT(NUMBER))        
  470 IF (LMINUS) XDOUBL = -XDOUBL        
C        
C     POWER HAS TO BE WITHIN RANGE OF MACHINE        
C        
      ICHEK = IPOWER + IT        
      IF (XDOUBL .EQ. 0.0D0) GO TO 490        
      IF (ICHEK .LT.LOWPW+1 .OR. ICHEK .GT.HIGHPW-1 .OR.        
     1    IPOWER.LT.LOWPW+1 .OR. IPOWER.GT.HIGHPW-1) GO TO 640        
      XDOUBL = XDOUBL*10.0D0**IPOWER        
  490 IF (PRECIS .EQ. D) GO TO 500        
      FL1  = XDOUBL        
      IOUT = IOUT + 2        
      OUT(IOUT-1) =-2        
      OUT(IOUT  ) = INT1        
      GO TO 100        
  500 IOUT = IOUT + 3        
      OUT(IOUT-2) =-4        
      OUT(IOUT-1) = NDOUBL(1)        
      OUT(IOUT  ) = NDOUBL(2)        
      GO TO 100        
C        
C        
C     PREPARE TO RETURN        
C        
  510 IF (.NOT. DELIM) GO TO 520        
      OUT(IOUT+1) = 0        
      RETURN        
  520 OUT(IOUT+1) = A67777        
      RETURN        
C        
C     ERRORS        
C        
  530 WRITE  (F6,540) UFM        
  540 FORMAT (A23,' 300 *** INVALID DATA COLUMN 72')        
      GO TO  680        
  550 WRITE  (F6,560) UFM        
  560 FORMAT (A23,' 300 *** INTEGER DATA OUT OF MACHINE RANGE')        
      GO TO  680        
  570 WRITE  (F6,580) UFM,N1        
  580 FORMAT (A23,' 300 *** INVALID CHARACTER FOLLOWING INTEGER IN ',   
     1       'COLUMN',I3)        
      GO TO  680        
  590 CONTINUE        
  600 CONTINUE        
  610 WRITE  (F6,620) UFM,I        
  620 FORMAT (A23,' 300 *** DATA ERROR-UNANTICIPATED CHARACTER IN ',    
     1       'COLUMN',I3)        
      GO TO  680        
  630 CONTINUE        
  640 WRITE  (F6,650) UFM        
  650 FORMAT (A23,' 300 *** DATA ERROR - MISSING DELIMITER OR REAL ',   
     1       'POWER OUT OF MACHINE RANGE')        
      GO TO  680        
  660 WRITE  (F6,670) UFM        
  670 FORMAT (A23,' 300 *** ROUTINE XRCARD FINDS OUTPUT BUFFER TOO ',   
     1       'SMALL TO PROCESS CARD COMPLETELY')        
  680 NOGO = .TRUE.        
      WRITE  (F6,690) CHAR        
  690 FORMAT (/5X,1H',72A1,1H')        
      OUT(1) = 0        
C        
      RETURN        
      END        
