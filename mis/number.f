      SUBROUTINE NUMBER (SND,NUM,NDSTK,LVLS2,NDEG,RENUM,LVLST,LSTPT,        
     1           NFLG,IBW2,IPF2,IPFA,ISDIR,STKA,STKB,STKC,STKD,NU,IDIM)        
C        
C     THIS ROUTINE IS USED ONLY IN BANDIT MODULE        
C        
C     NUMBER PRODUCES THE NUMBERING OF THE GRAPH FOR MIN BANDWIDTH        
C        
C     SND-      ON INPUT THE NODE TO BEGIN NUMBERING ON        
C     NUM-      ON INPUT AND OUTPUT, THE NEXT AVAILABLE NUMBER        
C     LVLS2-    THE LEVEL STRUCTURE TO BE USED IN NUMBERING        
C     RENUM-    THE ARRAY USED TO STORE THE NEW NUMBERING        
C     LVLST-    ON OUTPUT CONTAINS LEVEL STRUCTURE        
C     LSTPT(I)- ON OUTPUT, INDEX INTO LVLST TO FIRST NODE IN ITH LVL        
C               LSTPT(I+1) - LSTPT(I) = NUMBER OF NODES IN ITH LVL        
C     NFLG-     =+1 IF SND IS FORWARD END OF PSEUDO-DIAM        
C               =-1 IF SND IS REVERSE END OF PSEUDO-DIAM        
C     IBW2-     BANDWIDTH OF NEW NUMBERING COMPUTED BY NUMBER        
C     IPF2-     PROFILE OF NEW NUMBERING COMPUTED BY NUMBER        
C     IBW2 AND IPF2 HERE DO NOT INCLUDE DIAGONAL TERMS.        
C     IPFA-     WORKING STORAGE USED TO COMPUTE PROFILE AND BANDWIDTH        
C     ISDIR-    INDICATES STEP DIRECTION USED IN NUMBERING(+1 OR -1)        
C     STACKS HAVE DIMENSION OF IDIM        
C     NU-       WORK SPACE FOR BUNPAK        
C        
      INTEGER          SND,      STKA,     STKB,     STKC,     STKD,        
     1                 XA,       XB,       XC,       XD,       END,        
     2                 CX,       RENUM,    TEST        
      DIMENSION        STKA(1),  STKB(1),  STKC(1),  STKD(1),  LVLS2(1),        
     1                 NDEG(1),  RENUM(1), LVLST(1), LSTPT(1), NU(1),        
     2                 IPFA(1),  NDSTK(1)        
      COMMON /BANDB /  DUM3(3),  NGRID        
      COMMON /BANDG /  N,        IDPTH,    IDEG        
      COMMON /BANDS /  DUMS(4),  MAXGRD,   MAXDEG        
      COMMON /SYSTEM/  IBUF,     NOUT        
C        
C     SET UP LVLST AND LSTPT FROM LVLS2        
C        
      DO 10 I=1,N        
   10 IPFA(I)=0        
      NSTPT=1        
      DO 15 I=1,IDPTH        
      LSTPT(I)=NSTPT        
      DO 15 J=1,N        
      IF (LVLS2(J).NE.I) GO TO 15        
      LVLST(NSTPT)=J        
      NSTPT=NSTPT+1        
   15 CONTINUE        
      LSTPT(IDPTH+1)=NSTPT        
C        
C     THIS ROUTINE USES FOUR STACKS, A,B,C,AND D, WITH POINTERS        
C     XA,XB,XC, AND XD.  CX IS A SPECIAL POINTER INTO STKC WHICH        
C     INDICATES THE PARTICULAR NODE BEING PROCESSED.        
C     LVLN KEEPS TRACK OF THE LEVEL WE ARE WORKING AT.        
C     INITIALLY STKC CONTAINS ONLY THE INITIAL NODE, SND.        
C        
      LVLN=0        
      IF (NFLG.LT.0) LVLN=IDPTH+1        
      XC=1        
      STKC(XC)=SND        
   20 CX=1        
      XD=0        
      LVLN=LVLN+NFLG        
      LST=LSTPT(LVLN)        
      LND=LSTPT(LVLN+1)-1        
C        
C     BEGIN PROCESSING NODE STKC(CX)        
C        
   25 IPRO=STKC(CX)        
      RENUM(IPRO)=NUM        
      NUM=NUM+ISDIR        
      END=NDEG(IPRO)        
      XA=0        
      XB=0        
C        
C     CHECK ALL ADJACENT NODES        
C        
      CALL BUNPAK(NDSTK,IPRO,END,NU)        
      DO 40 I=1,END        
C     TEST =BUNPK(NDSTK,IPRO,I)        
      TEST =NU(I)        
      INX=RENUM(TEST)        
C        
C     ONLY NODES NOT NUMBERED OR ALREADY ON A STACK ARE ADDED        
C        
      IF (INX.EQ.0) GO TO 30        
      IF (INX.LT.0) GO TO 40        
C        
C     DO PRELIMINARY BANDWIDTH AND PROFILE CALCULATIONS        
C        
      NBW=(RENUM(IPRO)-INX)*ISDIR        
      IF (ISDIR.GT.0) INX=RENUM(IPRO)        
      IF (IPFA(INX).LT.NBW) IPFA(INX)=NBW        
      GO TO 40        
   30 RENUM(TEST)=-1        
C        
C     PUT NODES ON SAME LEVEL ON STKA, ALL OTHERS ON STKB        
C        
      IF (LVLS2(TEST).EQ.LVLS2(IPRO)) GO TO 35        
      XB=XB+1        
      IF (XB.GT.IDIM) GO TO 100        
      STKB(XB)=TEST        
      GO TO 40        
   35 XA=XA+1        
      IF (XA.GT.IDIM) GO TO 100        
      STKA(XA)=TEST        
   40 CONTINUE        
C        
C     SORT STKA AND STKB INTO INCREASING DEGREE AND ADD STKA TO STKC        
C     AND STKB TO STKD        
C        
      IF (XA.EQ.0) GO TO 50        
      IF (XA.EQ.1) GO TO 45        
      CALL SORTDG (STKC,STKA,XC,XA,NDEG)        
      GO TO 50        
   45 XC=XC+1        
      IF (XC.GT.IDIM) GO TO 100        
      STKC(XC)=STKA(XA)        
   50 IF (XB.EQ.0) GO TO 65        
      IF (XB.EQ.1) GO TO 60        
      CALL SORTDG (STKD,STKB,XD,XB,NDEG)        
      GO TO 65        
   60 XD=XD+1        
      IF (XD.GT.IDIM) GO TO 100        
      STKD(XD)=STKB(XB)        
C        
C     BE SURE TO PROCESS ALL NODES IN STKC        
C        
   65 CX=CX+1        
      IF (XC.GE.CX) GO TO 25        
C        
C     WHEN STKC IS EXHAUSTED LOOK FOR MIN DEGREE NODE IN SAME LEVEL        
C     WHICH HAS NOT BEEN PROCESSED        
C        
      MAX=IDEG+1        
      SND=N+1        
      DO 70 I=LST,LND        
      TEST=LVLST(I)        
      IF (RENUM(TEST).NE. 0) GO TO 70        
      IF (NDEG(TEST).GE.MAX) GO TO 70        
      RENUM(SND)=0        
      RENUM(TEST)=-1        
      MAX=NDEG(TEST)        
      SND=TEST        
   70 CONTINUE        
      IF (SND.EQ.N+1) GO TO 75        
      XC=XC+1        
      IF (XC.GT.IDIM) GO TO 100        
      STKC(XC)=SND        
      GO TO 25        
C        
C     IF STKD IS EMPTY WE ARE DONE, OTHERWISE COPY STKD ONTO STKC        
C     AND BEGIN PROCESSING NEW STKC        
C        
   75 IF (XD.EQ.0) GO TO 90        
      DO 80 I=1,XD        
   80 STKC(I)=STKD(I)        
      XC=XD        
      GO TO 20        
C        
C     DO FINAL BANDWIDTH AND PROFILE CALCULATIONS        
C        
   90 DO 95 I=1,N        
      IF (IPFA(I).GT.IBW2) IBW2=IPFA(I)        
      IPF2=IPF2+IPFA(I)        
   95 CONTINUE        
      RETURN        
C        
C     DIMENSION EXCEEDED  . . .  STOP JOB.        
C        
  100 NGRID=-3        
      RETURN        
      END        
