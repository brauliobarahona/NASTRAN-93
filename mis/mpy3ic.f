      SUBROUTINE MPY3IC (Z,IZ,DZ)        
C        
C     IN-CORE PRODUCT.        
C        
      LOGICAL         FIRST1,FIRST2,E        
      INTEGER         FILEA,FILEB,FILEE,FILEC,CODE,PREC,SCR1,SCR3,FILE, 
     1                BUF1,BUF2,BUF3,BUF4,D,ZPNTRS,TYPIN,TYPOUT,ROW1,   
     2                ROWM,UTYP,UROW1,UROWN,UINCR,EOL,EOR,PRECM        
      DOUBLE PRECISION DZ(1),DD,NN,MM,PP        
      DIMENSION       Z(1),IZ(1),NAME(2)        
      COMMON /MPY3TL/ FILEA(7),FILEB(7),FILEE(7),FILEC(7),SCR1,SCR2,    
     1                SCR,LKORE,CODE,PREC,LCORE,SCR3(7),BUF1,BUF2,      
     2                BUF3,BUF4,E        
      COMMON /MPY3CP/ ITRL,ICORE,N,NCB,M,NK,D,MAXA,ZPNTRS(22),LAEND,    
     1                FIRST1,FIRST2,K,K2,KCOUNT,IFLAG,KA,LTBC,J,I,NTBU  
      COMMON /PACKX / TYPIN,TYPOUT,ROW1,ROWM,INCR        
      COMMON /UNPAKX/ UTYP,UROW1,UROWN,UINCR        
      COMMON /ZNTPKX/ A(2),DUM(2),IROW,EOL,EOR        
      COMMON /SYSTEM/ SYSBUF,NOUT        
      EQUIVALENCE     (ISAVP ,ZPNTRS( 1)), (NSAVP ,ZPNTRS( 2)),        
     1                (IPOINT,ZPNTRS( 3)), (NPOINT,ZPNTRS( 4)),        
     2                (IACOLS,ZPNTRS( 5)), (NACOLS,ZPNTRS( 6)),        
     3                (ITRANS,ZPNTRS( 7)), (NTRANS,ZPNTRS( 8)),        
     4                (IC    ,ZPNTRS( 9)), (NC    ,ZPNTRS(10)),        
     5                (IBCOLS,ZPNTRS(11)), (NBCOLS,ZPNTRS(12)),        
     6                (IBCID ,ZPNTRS(13)), (NBCID ,ZPNTRS(14)),        
     7                (IBNTU ,ZPNTRS(15)), (NBNTU ,ZPNTRS(16)),        
     8                (IKTBP ,ZPNTRS(17)), (NKTBP ,ZPNTRS(18)),        
     9                (IANTU ,ZPNTRS(19)), (NANTU ,ZPNTRS(20)),        
     O                (IAKJ  ,ZPNTRS(21)), (NAKJ  ,ZPNTRS(22))        
      DATA     NAME / 4HMPY3,4HIC   /        
C        
C        
C     INITIALIZATION.        
C        
      FIRST1 = .TRUE.        
      FIRST2 = .TRUE.        
      DD     = D        
      NN     = NCB        
      MM     = M        
      PP     = PREC        
C        
C     OPEN CORE POINTERS        
C        
      ISAVP  = 1        
      NSAVP  = NCB        
      IPOINT = NSAVP  + 1        
      NPOINT = NSAVP  + NCB        
      IACOLS = NPOINT + 1        
C     NACOLS = NPOINT + D*NCB*M/10000        
      NACOLS = NPOINT + (DD*NN*MM/10000.D0 + 0.5D0)        
      ITRANS = NACOLS + 1        
      IF (PREC.NE.1 .AND. MOD(ITRANS,2).NE.1) ITRANS = ITRANS + 1       
C     NTRANS = ITRANS + PREC*D*NCB*M/10000 - 1        
      NTRANS = ITRANS + (PP*DD*NN*MM/10000.D0 + 0.5D0) - 1        
      IC = NTRANS + 1        
      IF (PREC.NE.1 .AND. MOD(IC,2).NE.1) IC = IC + 1        
      NC = IC + PREC*M - 1        
      IBCOLS= NC + 1        
      NBCOLS= NC + PREC*N*NK        
      IBCID = NBCOLS + 1        
      NBCID = NBCOLS + NK        
      IBNTU = NBCID  + 1        
      NBNTU = NBCID  + NK        
      IKTBP = NBNTU  + 1        
      NKTBP = NBNTU  + MAXA        
      IANTU = NKTBP  + 1        
      NANTU = NKTBP  + MAXA        
      IAKJ  = NANTU  + 1        
      NAKJ  = NANTU  + PREC*MAXA        
C        
C     PACK PARAMETERS        
C        
      TYPIN = PREC        
      TYPOUT= PREC        
      ROW1  = 1        
      INCR  = 1        
C        
C     UNPACK PARAMETERS        
C        
      UTYP  = PREC        
      UROW1 = 1        
      UINCR = 1        
C        
C     PREPARE B AND A(T).        
C        
      CALL MPY3A (Z,Z,Z)        
C        
C     OPEN FILES AND CHECK EXISTENCE OF MATRIX E.        
C        
      IF (.NOT.E) GO TO 20        
      FILE = FILEE(1)        
      CALL OPEN (*5001,FILEE,Z(BUF4),2)        
      CALL FWDREC (*5002,FILEE)        
   20 FILE = FILEA(1)        
      CALL OPEN (*5001,FILEA,Z(BUF1),2)        
      CALL FWDREC (*5002,FILEA)        
      FILE = SCR1        
      CALL OPEN (*5001,SCR1,Z(BUF2),0)        
      FILE = FILEC(1)        
      CALL GOPEN (FILEC,Z(BUF3),1)        
      ROWM = FILEC(3)        
C        
C     PROCESS COLUMNS OF C ONE BY ONE.        
C        
      DO 1000 J = 1,M        
C        
C     INITIALIZE COLUMN OF C.        
C        
      DO 30 IX = IC,NC        
   30 Z(IX) = 0.        
      IF (.NOT.E) GO TO 50        
      UROWN = M        
      CALL UNPACK (*50,FILEE,Z(IC))        
   50 PRECM = PREC*M        
C        
C     PROCESS A AND PERFORM FIRST PART OF PRODUCT.        
C        
      CALL MPY3B (Z,Z,Z)        
C        
C     TEST IF PROCESSING IS COMPLETE        
C        
      IF (IFLAG .EQ. 0) GO TO 900        
C        
C     PROCESS REMAINING TERMS OF COLUMN J OF A.        
C        
C     TEST IF BCOLS IS FULL        
C        
  100 IF (K2 .LT. NK) GO TO 150        
C        
C     CALCULATE NEXT TIME USED FOR COLUMNS OF B AND/OR TERMS OF A       
C        
      IF (.NOT.FIRST2) GO TO 120        
      FIRST2 = .FALSE.        
      IBC = IBCID - 1        
      IB  = IBNTU - 1        
      DO 110 II = 1,NK        
      IBC= IBC + 1        
      I  = IZ(IBC)        
      CALL MPY3NU (Z)        
      IB = IB + 1        
  110 IZ(IB) = NTBU        
  120 IK = IKTBP - 1        
      IA = IANTU - 1        
      DO 140 II = 1,K        
      IK = IK + 1        
      IA = IA + 1        
      IF (IZ(IK) .EQ. 0) GO TO 130        
      I  = IZ(IK)        
      CALL MPY3NU (Z)        
      IZ(IA) = NTBU        
      GO TO 140        
  130 IZ(IA) = 0        
  140 CONTINUE        
C        
C     ADD OR REPLACE COLUMN OF B INTO CORE AND PERFORM COMPUTATION      
C        
  150 CALL MPY3C (Z,Z,Z)        
      IF (KCOUNT .EQ. K) GO TO 900        
      IF (FIRST2) GO TO 100        
      GO TO 150        
C        
C     PACK COLUMN OF C.        
C        
  900 CALL PACK (Z(IC),FILEC,FILEC)        
 1000 CONTINUE        
C        
C     CLOSE FILES.        
C        
      CALL CLOSE (FILEA,2)        
      CALL CLOSE (SCR1,1)        
      CALL CLOSE (FILEC,1)        
      IF (E) CALL CLOSE (FILEE,2)        
      GO TO 9999        
C        
C     ERROR MESSAGES.        
C        
 5001 NERR = -1        
      GO TO 6000        
 5002 NERR = -2        
 6000 CALL MESAGE (NERR,FILE,NAME)        
C        
 9999 RETURN        
      END        
