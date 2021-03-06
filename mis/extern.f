      SUBROUTINE EXTERN (NEX,NGRAV,GVECT,ILIST,PG,N1,IHARM)        
C        
C     GENERATES EXTERNAL LOADS        
C        
      IMPLICIT INTEGER (A-Z)        
      INTEGER         PG(1),ILIST(1),NAME(2),IZ(1)        
      REAL            CORE,GVECT(1)        
      COMMON /TRANX / IDUM(14)        
      COMMON /BLANK / NROWSP        
CZZ   COMMON /ZZSSA1/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /LOADX / LCARE,SLT,BGPDT,OLD,CSTM,SIL,ISIL,EST,MPT,NN(7),  
     1                NOBLD,IDIT,ICM,ILID        
      COMMON /SYSTEM/ SYSBUF        
      COMMON /PACKX / ITYA,ITYB,II,JJ,INCUR        
      COMMON /HMATDD/ IIHMAT,NNHMAT,MPTFIL,IDITFL        
      COMMON /PINDEX/ IEST(45)        
      COMMON /GPTA1 / JDUM        
      EQUIVALENCE     (CORE(1),IZ(1))        
      DATA    CASECC, PERMBD,HCFLDS,REMFLS,SCR6,HCCENS, NAME         /  
     1        110   , 112   ,304   ,305   ,306 ,307   , 4HEXTE,4HRN  /  
C        
      IEST(1) =-1        
      IDUM(1) = 0        
      JOPEN = 0        
      IPRE  = 0        
      INCUR = 1        
      II    = 1        
      JJ    = NROWSP        
      NGRAV = 0        
      OLD   = 0        
      ICM   = 1        
      ITYA  = 1        
      ITYB  = 1        
      IBUF1 = LCARE - SYSBUF + 1        
      IBUF2 = IBUF1 - SYSBUF        
      IBUF3 = IBUF2 - SYSBUF        
      IBUF4 = IBUF3 - SYSBUF        
      IBUF5 = IBUF4 - SYSBUF        
      LCORE = IBUF5 - SYSBUF        
      CALL GOPEN (SLT,CORE(IBUF1),0)        
      CALL GOPEN (BGPDT,CORE(IBUF2),0)        
      FILE = CSTM        
      CALL OPEN (*20,CSTM,CORE(IBUF3),0)        
      ICM  = 0        
      CALL SKPREC (CSTM,1)        
   20 CALL GOPEN (SIL,CORE(IBUF4),0)        
      FILE = SLT        
      ISIL = 0        
      IF (LCORE .LT. NROWSP) GO TO 1580        
C        
      III  = 1        
      DO 1400 NLOOP = 1,N1        
C        
      ILID = ILIST(III)        
      IF (ILID .NE. 0) GO TO 30        
      CALL SKPREC (SLT,1)        
      GO TO 1310        
   30 DO 40 I = 1,NROWSP        
   40 CORE(I) = 0.0        
      NOGRAV  = 0        
      NGROLD  = NGRAV        
   50 CALL READ (*1520,*1300,SLT,NOBLD,1,0,FLAG)        
      CALL FREAD (SLT,IDO,1,0)        
      IF (NOGRAV .EQ.  1) GO TO 1570        
      IF (NOBLD .EQ. -20) GO TO 800        
      GO TO (100,100,120,120,140,140,160,200,220,300,        
     1       320,340,600,620,630,640,360,700,730,800,        
     2       800,800,800,800,400), NOBLD        
  100 DO 110 J = 1,IDO        
  110 CALL DIRECT        
      GO TO 50        
  120 DO 130 J = 1,IDO        
  130 CALL TPONT        
      GO TO 50        
  140 DO 150 J = 1,IDO        
  150 CALL FPONT        
      GO TO 50        
  160 DO 170 J = 1,IDO        
  170 CALL SLOAD        
      GO TO 50        
  200 IF (NOGRAV .EQ. 2) GO TO 1570        
      DO 210 J = 1,IDO        
      CALL GRAV (NGRAV,GVECT(1),NEX,ILIST(1),NLOOP)        
  210 CONTINUE        
      NOGRAV = 1        
      GO TO 50        
  220 DO 230 J = 1,IDO        
  230 CALL PLOAD        
      GO TO 50        
C        
C     RFORCE CARDS        
C        
  300 DO 310 J = 1,IDO        
  310 CALL RFORCE (LCORE)        
      GO TO 50        
C        
C     PRESAX CARDS        
C        
  320 DO 330 J = 1,IDO        
  330 CALL PRESAX (IHARM)        
      GO TO 50        
C        
C     QHBDY CARDS        
C        
  340 DO 350 J = 1,IDO        
      CALL QHBDY        
  350 CONTINUE        
      GO TO 50        
C        
C     PLOAD3 CARDS        
C        
  360 DO 370 J = 1,IDO        
  370 CALL PLOAD3        
      GO TO 50        
C        
C     PLOAD4 CARDS        
C        
  400 CALL PLOAD4 (IBUF5,IDO,JOPEN)        
      GO TO 50        
C        
C     QVOL CARDS (MODIFIED USER ENTRYS)        
C        
  600 DO 610 J = 1,IDO        
      CALL QVOL        
  610 CONTINUE        
      GO TO 50        
C        
C     QBDY1 CARDS (MODIFIED USER ENTRYS)        
C        
  620 KKKK = 1        
      GO TO 650        
C        
C     QBDY2 CARDS (MODIFIED USER ENTRYS)        
C        
  630 KKKK = 2        
      GO TO 650        
C        
C     QVECT CARDS (MODIFIED USER ENTRYS)        
C        
  640 KKKK = 3        
  650 DO 660 J = 1,IDO        
      CALL QLOADL (KKKK)        
  660 CONTINUE        
      GO TO 50        
C        
C     PLOAD1 CARDS        
C        
  700 IF (IPRE .EQ. 1) GO TO 710        
      IPRE  = 1        
      LCORE = LCORE - SYSBUF - 1        
      MCORE = LCORE - NROWSP - 1        
      IF (LCORE .LT. NROWSP) GO TO 1580        
      CALL PREMAT (CORE(NROWSP+1),CORE(NROWSP+1),CORE(LCORE),MCORE,     
     1             NCORE,MPT,IDIT)        
  710 DO 720 J = 1,IDO        
      CALL PLBAR1 (IDO,LCORE)        
  720 CONTINUE        
      GO TO 50        
C        
C     PLOADX CARDS        
C        
  730 DO 740 J = 1,IDO        
      CALL PLOADX        
  740 CONTINUE        
      GO TO 50        
C        
C     CEMLOOP, SPCFLD, GEMLOOP, MDIPOLE, AND REMFLUX CARDS        
C        
C     BRING HEAT MATERIALS INTO CORE        
C        
  800 IF (IPRE .EQ. 1) GO TO 1230        
      IPRE = 1        
C        
C     1ST AND LAST AVAILABLE LOCATIONS IN OPEN CORE        
C        
      IIHMAT = NROWSP        
      NNHMAT = LCORE        
      MPTFIL = MPT        
      IDITFL = IDIT        
      CALL PREHMA (CORE)        
C        
C     NOW NNHMAT CONTAINS LAST LOCATION OF MATERIAL INFO        
C        
      NEXTZ = NNHMAT + 1        
C        
C     OPEN HCFLDS TO CONTAIN APPLIED MAGNETIC FIELD LOAD        
C        
      LCORE = LCORE - SYSBUF        
      IF (LCORE .LE. NEXTZ) GO TO 1580        
C        
C     STORE SILS  ON PERMBDY, IF ANY, INTO OPEN CORE        
C        
      NBDYS = 0        
      FILE  = PERMBD        
      CALL OPEN (*820,PERMBD,CORE(LCORE+1),0)        
      CALL FWDREC (*1520,PERMBD)        
      CALL READ (*1520,*810,PERMBD,CORE(NEXTZ),LCORE-NEXTZ+1,0,NBDYS)   
      GO TO 1580        
  810 CALL CLOSE (PERMBD,1)        
  820 CONTINUE        
      NEXTZ = NEXTZ + NBDYS        
C        
C     NOW CHECK FOR FORCE REQUESTS ON CASECC(MAGNETIC FIELD REQUESTS)   
C     MAKE A UNIQUE LIST OF ELEMENT ID-S CORRESPONDING TO ALL SUBCASES. 
C     IF A SUBCASE REQUESTS ALL, NO LIST IS NECESSARY.        
C        
      ALL    = 0        
      NELOUT = 0        
      IJ     = 0        
C        
C     1ST GET MAXIMUM LENGTH OF CASE CONTROL IN ORDER TO STORE ELEMENT  
C     ID-S        
C        
      NCC = 0        
      CALL GOPEN (CASECC,CORE(LCORE+1),0)        
  830 CALL READ (*850,*840,CASECC,CORE(NEXTZ),LCORE-NEXTZ+1,0,KCC)      
      GO TO 1580        
  840 NCC = MAX0(NCC,KCC)        
      GO TO 830        
  850 CALL REWIND (CASECC)        
      CALL FWDREC (*1520,CASECC)        
      KSET = NEXTZ + NCC        
C        
  860 CALL READ (*1200,*870,CASECC,CORE(NEXTZ),LCORE-NEXTZ+1,0,NCC)     
      GO TO 1580        
  870 SETNO = IZ(NEXTZ+25)        
      IF (SETNO .EQ. 0) GO TO 860        
      IF (SETNO .GT. 0) GO TO 1010        
C        
C     ALL        
C        
 1000 ALL    = 1        
      NELOUT = 0        
      GO TO 1200        
C        
C     CREATE UNIQUE LIST OF ELEMENT ID-S        
C        
 1010 ILSYM  = IZ(NEXTZ+165)        
      ISETNO = ILSYM  + IZ(ILSYM+NEXTZ-1) + NEXTZ        
 1020 ISET   = ISETNO + 2        
      NSET   = IZ(ISETNO+1) + ISET - 1        
      IF (IZ(ISETNO) .EQ. SETNO) GO TO 1030        
      ISETNO = NSET + 1        
C        
C     IF SET CANNOT BE FOUND, SET TO ALL. BUT SHOULD NOT HAPPEN        
C        
      IF (ISETNO .LT. NCC+NEXTZ-1) GO TO 1020        
      GO TO 1000        
C        
C     PICK UP ELEMENT ID-S. STORE IN UNIQUE LIST        
C        
 1030 I = ISET        
 1040 IF (I    .EQ. NSET) GO TO 1060        
      IF (IZ(I+1) .GT. 0) GO TO 1060        
      IB = IZ(I  )        
      N  =-IZ(I+1)        
      I  = I + 1        
      ASSIGN 1050 TO RET        
      GO TO 1100        
 1050 IB = IB + 1        
      IF (IB .LE. N) GO TO 1100        
      GO TO 1070        
 1060 IB = IZ(I)        
      ASSIGN 1070 TO RET        
      GO TO 1100        
 1070 I = I + 1        
      IF (I .LE. NSET) GO TO 1040        
C        
C     DONE WITH THIS SET. GO BACK FOR ANOTHER        
C        
      GO TO 860        
C        
C     SEARCH LIST OF ELEMENT ID-S. ADD ID TO LIST IF NOT A DUPLICATE    
C        
 1100 IF (IJ .NE. 0) GO TO 1110        
      MSET = KSET        
      IZ(MSET) = IB        
      NELOUT = 1        
      IJ = MSET        
      GO TO RET, (1050,1070)        
 1110 DO 1120 J = MSET,IJ        
      IF (IZ(J) .EQ. IB) GO TO RET, (1050,1070)        
 1120 CONTINUE        
      IJ = IJ + 1        
      IF (IJ .LT. LCORE) GO TO 1130        
      GO TO 1000        
 1130 IZ(IJ) = IB        
      NELOUT = NELOUT + 1        
      GO TO RET, (1050,1070)        
C        
C     DONE WITH ALL CASES. IF ALL.NE.1, MOVE THE ID-S UP IN CORE        
C        
 1200 CALL CLOSE (CASECC,1)        
      IF (ALL .EQ. 1) GO TO 1220        
C        
      DO 1210 J = 1,NELOUT        
 1210 IZ(NEXTZ+J-1) = IZ(MSET+J-1)        
      NEXTZ = NEXTZ + NELOUT        
 1220 CONTINUE        
C        
      CALL GOPEN (HCFLDS,CORE(LCORE+1),1)        
      I = LCORE - SYSBUF        
      J = I     - SYSBUF        
      LCORE = J - SYSBUF        
      IF (LCORE .LE. NEXTZ) GO TO 1580        
      CALL GOPEN (REMFLS,CORE(I+1),1)        
      CALL GOPEN (HCCENS,CORE(J+1),1)        
      CALL GOPEN (SCR6,CORE(LCORE+1),1)        
C        
C     NO DO LOOP ON IDO. IN EANDM WE WILL READ ALL CARDS        
C        
 1230 CALL EANDM (NOBLD,IDO,NEXTZ,LCORE,NBDYS,ALL,NELOUT)        
      GO TO 50        
C        
C        
 1300 IF (NGROLD .NE. NGRAV) GO TO 1400        
      CALL PACK (CORE,PG,PG(1))        
 1310 III = III + 1        
C        
 1400 CONTINUE        
C        
      CALL CLOSE (BGPDT,1)        
      IF (ICM .EQ. 0) CALL CLOSE (CSTM,1)        
      CALL CLOSE (SLT,1)        
      CALL CLOSE (SIL,1)        
      IF (IPRE .NE. 1) GO TO 1410        
      CALL CLOSE (HCFLDS,1)        
      CALL CLOSE (REMFLS,1)        
      CALL CLOSE (HCCENS,1)        
      CALL CLOSE (SCR6,1)        
 1410 CONTINUE        
      RETURN        
C        
C     FILE ERRORS        
C        
 1520 IP1 = -2        
      GO TO 1600        
 1570 IP1 = -7        
      GO TO 1600        
 1580 IP1 = -8        
 1600 CALL MESAGE (IP1,FILE,NAME(1))        
      RETURN        
      END        
