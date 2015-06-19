      SUBROUTINE MATPRN        
C        
C     MATRIX PRINT MODULE        
C     WILL PRINT UP TO 5 DBi INPUT MATRICES        
C     INPUT MATRICES CAN BE IN S.P, D.P, S.P.COMPLEX, OR D.P.COMPLEX    
C        
C     MATPRN  DB1,DB2,DB3,DB4,DB5//C,N,P1/C,N,P2/C,N,P3/C,N,P4/C,N,P5/  
C                                  C,N,P6        
C        
C     WHERE   P1 AND P2 ARE PRINT FORMAT CONTROLS        
C             P1 = 0, MATRICES PRINTED IN THEIR ORIG. PREC. (DEFAULT),  
C                = 1, MATRICES PRINTED IN S.P. PREC. (e.g.  x.xxxE+xx)  
C                = 2, MATRICES PRINTED IN D.P. PREC. (e.g. -x.xxxD+xx)  
C                =-1, ONLY THE DIAGONAL ELEMENTS OF THE MATRIX WILL BE  
C                     PRINTED IN THEIR ORIG. PRECISON        
C             P2 = NO. OF DATA VALUES PRINTED PER LINE (132 DIGITS/LINE)
C                = 8 TO 14 IF MATRICES ARE PRINTED IN S.P. (DEFAULT=10) 
C                = 6 TO 12 IF MATRICES ARE PRINTED IN D.P. (DEFAULT= 9) 
C        
C             P3, P4, P5 ARE PRINTOUT CONTROLS        
C             P3 = m, MATRIX COLUMNS, 1 THRU m, WILL BE PRINTED.        
C                  DEFAULT = 0, ALL MATRIX COLUMNS WILL BE PRINTED.     
C                =-m, SEE P4 = -n        
C             P4 = n, LAST n MATRIX COLUMNS ARE PRINTED. DEFAULT = 0    
C                =-n, AND P3 = -m, EVERY OTHER n MATRIX COLUMNS WILL BE 
C                  PRINTED, STARTIN FROM COLUMN m.        
C             P5 = k, EACH PRINTED COLUMN WILL NOT EXCEED k LINES LONG  
C                  AND THE REMAINING DATA WILL BE OMITTED.        
C             P6 = LU, WHERE LU LOGICAL FILE NUMBER = 11(UT1), 12(UT2), 
C                  14(INPT), 15(INT1),...,23(INT9), 24(IBM'S INPT).     
C                  DEFAULT IS ZERO, SYSTEM PRINTER.        
C                  IF LU IS 11 THRU 24, THE MATRIX PRINTOUT IS SAVED IN 
C                  FORTRAN UNIT LU.        
C        
C        
C     LAST REVISED BY G.CHAN/UNISYS        
C     12/91, NEW MODULE PARAMETERS TO ALLOW USER SOME CONTROL OVER      
C            POSSIBLY MASSIVE MATRIX PRINTOUT        
C     8/92,  TO PRINT ONLY THE DIAGONAL ELEMENTS FOR POSSIBLY MATRIX    
C            SINGULARITY CHECK, AND PARAMETER P6        
C        
      INTEGER         P1,P2,P3,P4,P5,P6        
      DIMENSION       MCB(7)        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /BLANK / P1,P2,P3,P4,P5,P6        
      COMMON /SYSTEM/ IBUF,NOUT        
C        
      IF (P1.LE.2 .AND. P2.LE.14) GO TO 30        
      WRITE  (NOUT,10) UWM,P1,P2,P3,P4,P5,P6        
   10 FORMAT (A25,', MATPRN PARAMETERS APPEAR IN ERROR.  P1,P2,P3,P4,', 
     1        'P5,P6 =',6I5, /5X,'P1 IS RESET TO ZERO, AND P2 TO 6 TO', 
     2        ' 14 DEPENDING ON TYPE OF DATA')        
C        
C     CHECK THAT USER REALY WANTS TO SET P3,P4,P5, AND INSTEAD HE SETS  
C     THEM TO P1,P2,P3        
C        
      IF (P4.NE.0 .OR. P5.NE.0 .OR. P3.GT.50) GO TO 30        
      P3 = P1        
      P4 = P2        
      P5 = P3        
      WRITE  (NOUT,20) P3,P4,P5        
   20 FORMAT (5X,'P3,P4,P5 ARE SET TO ',3I5)        
      GO TO 30        
   30 DO 110 I = 1,5        
      MCB(1) = 100 + I        
      CALL RDTRL (MCB(1))        
      IF (MCB(1) .LT. 0) GO TO 110        
      IF (P1 .EQ. -1) GO TO 90        
      ITYP = MCB(5)        
      NDPL = P2        
      IF (NDPL .NE. 0) GO TO 40        
      NDPL = 9        
      IF (MOD(ITYP,2) .EQ. 1) NDPL = 10        
   40 NPL  = NDPL        
      GO TO (50,60,70,80), ITYP        
   50 IF (NDPL .LT.  8) NPL = 8        
      IF (NDPL .GT. 14) NPL = 14        
      GO TO 90        
   60 IF (NDPL .LT.  6) NPL = 6        
      IF (NDPL .GT. 12) NPL = 12        
      GO TO 90        
   70 NDPL = (NDPL/2)*2        
      NPL  = NDPL        
      IF (P1.LE.0 .OR. P1.GT.2) GO TO 50        
      GO TO (50,60), P1        
   80 NDPL = (NDPL/2)*2        
      NPL  = NDPL        
      IF (P1.LE.0 .OR. P1.GT.2) GO TO 60        
      GO TO (50,60), P1        
   90 IPREC = P1        
      IF (IPREC.EQ.1 .OR. IPREC.EQ.2 .OR. P1.EQ.-1) GO TO 100        
      IPREC = 2        
      IF (MOD(ITYP,2) .EQ. 1) IPREC = 1        
  100 IOUT = NOUT        
      IF (P6.GE.11 .AND. P6.LE.24) IOUT = P6        
      CALL MATDUM (MCB(1),IPREC,NPL,IOUT)        
  110 CONTINUE        
      RETURN        
      END        