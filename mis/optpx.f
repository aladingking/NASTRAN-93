      SUBROUTINE OPTPX (DTYP)        
C        
C     PROCESS PLIMIT CARDS INTO ELEMENT SECTIONS THAT MAY BE READ BY    
C     OPTP1D        
C     MPT ASSUMED PREPOSITIONED TO PLIMIT CARDS.        
C        
      INTEGER         COUNT,YCOR,B1P1,NPOW,EPT,NAME(2),SYSBUF,OUTTAP,   
     1                DTYP(1),ETP(21),ANY,ALL,STOR(21),BLANK,EJECT,     
     2                SCRTH1,ENTRY,X(7),IY(1)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / SKP1(2),COUNT,SKP2(2),YCOR,B1P1,NPOW,SKP3(4),NKLW,
     1                MPT,EPT,SKP5(4),SCRTH1,NELTYP,ENTRY(21)        
      COMMON /OPTPW1/ KCOR,K(10)        
CZZ   COMMON /ZZOPT1/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /NAMES / NRD,NOEOR,NWRT,NWEOR        
      COMMON /SYSTEM/ SYSBUF,OUTTAP        
      COMMON /GPTA1 / NTYPES,LAST,INCR,NE(1)        
      EQUIVALENCE     (STOR(1),K(10)),(CORE(1),X(1)),(X(7),IY(1))       
      DATA    ETP   / 21*0 /,  ALL / 4HALL /,  BLANK / 1H  /,        
     1        NAME  / 4H OPT,  4HPX        /        
C        
      MAXW  = 0        
      IALL  = 0        
      ANY   = 0        
      NOCOR = 0        
      NOGO  = 0        
      NX    = 1        
      ASSIGN 10 TO IRET        
C        
C     MAKE PRELIMINARY PASS        
C        
   10 IMHERE = 10        
      CALL READ (*310,*110,MPT,K,9,0,NWDS)        
      IF (K(1) .EQ. ALL) GO TO 30        
      DO 20 I = 1,NTYPES        
      IF (DTYP(I) .EQ. 0) GO TO 20        
      IDX = INCR*(I-1) + 1        
      IF (NE(IDX  ) .NE. K(1)) GO TO 20        
      IF (NE(IDX+1) .EQ. K(2)) GO TO 40        
   20 CONTINUE        
      GO TO 50        
C        
C     ALL SPECIFIED        
C        
   30 IALL = IALL + 1        
      GO TO 10        
C        
C     LEGAL ELEMENT TYPE        
C        
   40 I = DTYP(I)        
      ETP(I) = ETP(I) + 1        
      ANY = ANY + 1        
      GO TO 10        
C        
C     ILLEGAL ELEMENT TYPE        
C        
   50 NOGO = NOGO + 1        
      IF (NOGO .GT. 1) GO TO  70        
      CALL PAGE2 (-4)        
      WRITE  (OUTTAP,60) UFM        
   60 FORMAT (A23,' 2290, THE FOLLOWING ILLEGAL ELEMENT TYPES FOUND ON',
     1       ' PLIMIT CARD')        
   70 STOR(NX  ) = K(1)        
      STOR(NX+1) = K(2)        
      NX = NX + 2        
      IF (NX .LT. 20) GO TO 10        
   80 I = EJECT(2)        
      IF (I .EQ. 0) GO TO 90        
      CALL PAGE2 (-2)        
      WRITE  (OUTTAP,60) UFM        
   90 WRITE  (OUTTAP,100) STOR        
  100 FORMAT (1H0,9X,10(2A4,1X))        
      NX = 1        
      GO TO IRET, (10,130)        
C        
C     LAST PLIMIT        
C        
  110 IF (NX .LE. 1) GO TO 130        
      ASSIGN 130 TO IRET        
      DO 120 I = NX,20        
  120 STOR(I) = BLANK        
      GO TO 80        
C        
C     CONTINUE PROCESSING LEGAL CARDS UNLESS ANY = 0        
C        
  130 IF (ANY.EQ.0 .AND. IALL.EQ.0) GO TO 300        
      CALL BCKREC (MPT)        
      IMHERE = 130        
      CALL READ (*310,*320,MPT,STOR(1),3,NOEOR,NWDS)        
C        
      LOC1 = 1        
C        
C     START OF OUTPUT LOOP        
C        
      DO 290 N = 1,NTYPES        
      IDE = DTYP(N)        
      IF (IDE .LE. 0) GO TO 290        
      IDX = ENTRY(IDE)        
      IDX = INCR*(IDX-1)        
      NEN = 0        
      NDE = ETP(IDE)        
      IF (NDE .LE. 0) GO TO 160        
      NWDS = 0        
C        
      IMHERE = 140        
      DO 150 M = 1,NDE        
  140 CALL READ (*310,*320,MPT,STOR(1),9,NOEOR,NWDS)        
      IF (STOR(1) .NE. NE(IDX+1)) GO TO 140        
      IF (STOR(2) .NE. NE(IDX+2)) GO TO 140        
      CALL OPTPX1 (*260,STOR,NOGO,NEN,LOC1)        
  150 CONTINUE        
      CALL BCKREC (MPT)        
      IMHERE = 150        
      CALL READ (*310,*320,MPT,STOR(1),3,NOEOR,NWDS)        
C        
C     CHECK IF ALL SPECIFIED        
C        
  160 IF (IALL .LE. 0) GO TO 190        
      IMHERE = 170        
      DO 180 M = 1,IALL        
  170 CALL READ (*310,*320,MPT,STOR(1),9,NOEOR,NWDS)        
      IF (STOR(1) .NE. ALL) GO TO 170        
      CALL OPTPX1 (*260,STOR,NOGO,NEN,LOC1)        
  180 CONTINUE        
      CALL BCKREC (MPT)        
      IMHERE = 180        
      CALL READ (*310,*320,MPT,STOR(1),3,NOEOR,NWDS)        
C        
C     CONTINUE PROCESSING LEGAL CARDS - SORT ON SECOND WORD        
C        
  190 IF (NEN .EQ. 0) GO TO 290        
      CALL SORT (0,0,4,2,IY(LOC1),NEN)        
C        
C     CHECK SECOND WORD        
C        
      I1  = IY(LOC1  )        
      I2  = IY(LOC1+1)        
      I3  = IY(LOC1+2)        
      I4  = IY(LOC1+3)        
      LOC2= LOC1 + NEN        
      L   = LOC2        
      IF (L+4 .GT. YCOR) NWDS = 1        
      NX = NEN - 3        
      IF (NX .LT. 5) GO TO 250        
      DO 240 M = 5,NX,4        
      J  = LOC1 + M - 1        
      J1 = IY(J  )        
      J2 = IY(J+1)        
C        
      IF (I1 .GE. J1) GO TO 220        
      IF (I2 .GE. J1) GO TO 220        
C        
C     CHECK FOR EXPANDING THE THRU        
C        
      IF (I2 .NE.    J1-1) GO TO 200        
      IF (I3 .NE. IY(J+2)) GO TO 200        
      IF (I4 .NE. IY(J+3)) GO TO 200        
      I2 = J2        
      IF (M .NE. NX) GO TO 240        
      IY(NX) = I1        
      GO TO 250        
C        
C     OUTPUT PLIMIT DATA IN SETS OF 4        
C        
  200 IF (NOGO.GT.0 .OR. NWDS.GT.0) GO TO 210        
      IY(L  ) = I1        
      IY(L+1) = I2        
      IY(L+2) = I3        
      IY(L+3) = I4        
  210 L = L + 4        
      IF (L+3 .GT. YCOR) NWDS = NWDS + 4        
      I1 = J1        
      I2 = J2        
      I3 = IY(J+2)        
      I4 = IY(J+3)        
      GO TO 240        
C        
C     OVERLAPPING RANGE ERROR CONDITION        
C        
  220 CALL PAGE2 (-2)        
      WRITE  (OUTTAP,230) UFM,I1,I2,J1,J2        
  230 FORMAT (A23,' 2291, PLIMIT RANGE INCORRECT FOR',I8,' THRU',I8,    
     1       ' AND',I8,' THRU',I8,'.')        
      I1 = J1        
      I2 = J2        
      NOGO = NOGO + 1        
  240 CONTINUE        
C        
C     AFTER ELEMENTS THAT MAY BE OPTIMIZED, FLUSH BUFFER.        
C        
  250 IF (L+3 .GT. YCOR) GO TO 260        
      IY(L  ) = IY(NX  )        
      IY(L+1) = IY(NX+1)        
      IY(L+2) = IY(NX+2)        
      IY(L+3) = IY(NX+3)        
      L = L + 3        
      GO TO 280        
C        
C     INSUFFICIENT CORE FOR ELEMENTS OF THIS TYPE        
C        
  260 CALL PAGE2 (-2)        
      NOCOR = 1        
      NWDS  = NWDS + 3        
      WRITE  (OUTTAP,270) UFM,NE(IDX+1),NE(IDX+2),NWDS        
  270 FORMAT (A23,' 2292, INSUFFICIENT CORE FOR PLIMIT DATA, ELEMENT ', 
     1       2A4,I5,' WORDS SKIPPED.')        
      NOGO = NOGO + 1        
C        
C     WRITE ONTO SCRATCH FILE        
C        
  280 IF (NOGO .GT. 0) GO TO 290        
      MAXW = MAX0(L,MAXW)        
      STOR(1) = IDE        
      STOR(2) = (L-LOC2+1)/4        
      CALL WRITE (SCRTH1,STOR(1),2,NOEOR)        
C        
C     AFTER ELEMENT TYPE, NUMBER WORDS - WRITE DATA        
C        
      CALL WRITE (SCRTH1,IY(LOC2),L-LOC2+1,NWEOR)        
C        
  290 CONTINUE        
C        
C     END OF OUTPUT LOOP        
C        
      CALL EOF (SCRTH1)        
  300 IF (NOGO  .EQ. 0) NKLW  = MAXW        
      IF (NOGO  .GT. 0) COUNT = -1        
      IF (NOCOR .NE. 0) NKLW  = -64        
      RETURN        
C        
C     ILLEGAL EOF (310), EOR (320)        
C        
  310 J = -2        
      NWDS = -222        
      GO TO 330        
  320 J = -3        
  330 WRITE  (OUTTAP,340) IMHERE,NWDS        
  340 FORMAT ('  ERROR IN OPTPX.  IMHERE=',I4,',  NWDS=',I6)        
      CALL MESAGE (J,MPT,NAME)        
      GO TO 300        
      END        
