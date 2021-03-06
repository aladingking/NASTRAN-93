      SUBROUTINE EMA1        
C        
C     EMA1 ASSEMBLES A STRUCTURAL MATRIX FOR THE MODEL FROM EACH OF     
C     THE INDIVIDUAL ELEMENT STRUCTURAL MATRICES.        
C        
C     EMA1   GPECT,KDICT,KELEM,SIL,ECT / KGG / C,N,NOK4/ C,N,WTMASS     
C        
C     NOK4 .NE. -1 MEANS MULTIPLY BY DAMPING FACTOR (GE)        
C     ABS(WTMASS-1.0) .GT. 1.E-6 MEANS MULTIPLY BY WTMASS        
C        
C     EMA1 USES 2 SCRATCH FILES        
C        
      LOGICAL          LAST        
      INTEGER          SYSTEM  ,SYSBUF ,ZI(1)  ,RD     ,RDREW  ,WRT   , 
     1                 WRTREW  ,CLSREW ,CLS    ,GPECT  ,SIL    ,ECT   , 
     2                 SUBNAM(2)       ,SCR1   ,SCR2   ,ELEM   ,DOFG  , 
     3                 MCBKGG(7)       ,TYPIN1 ,TYPOU1 ,TYPIN2 ,PREC  , 
     4                 TRLSIL(7)       ,EVEN   ,BUF(10),BUF1   ,BUF2  , 
     5                 BUF3    ,OPENW  ,OPENR  ,SILNBR ,OPCLS  ,MCB(7), 
     6                 TT(3)   ,OLDCOD ,SCALAS(32)     ,DOF           , 
     7                 BLOCK(20)        
      REAL             ZS(1)   ,XS(4)        
      DOUBLE PRECISION ZD      ,XD     ,D        
      CHARACTER        UFM*23  ,UWM*25 ,UIM*29 ,SFM*25        
      COMMON /XMSSG /  UFM     ,UWM    ,UIM    ,SFM        
      COMMON /SYSTEM/  SYSTEM(80)        
      COMMON /NAMES /  RD      ,RDREW  ,WRT    ,WRTREW ,CLSREW ,CLS     
      COMMON /BLANK /  NOK4    ,WTMASS        
      COMMON /PACKX /  TYPIN1  ,TYPOU1 ,II1    ,JJ1    ,INCR1        
      COMMON /UNPAKX/  TYPIN2  ,II2    ,JJ2    ,INCR2        
      COMMON /ZBLPKX/  XD(2)   ,IX        
      COMMON /GPTA1 /  NELEM   ,JLAST  ,INCRE  ,ELEM(1)        
      COMMON /MA1XX /  D(18)        
CZZ   COMMON /ZZEMA1/  ZD(1)        
      COMMON /ZZZZZZ/  ZD(1)        
      EQUIVALENCE      (SYSTEM(1),SYSBUF), (SYSTEM(2),NOUT),        
     1                 (TRLSIL(2),NBRSIL), (TRLSIL(3),LUSET),        
     2                 (SYSTEM(22),MACH ), (ZD(1),ZS(1),ZI(1)),        
     3                 (XD(1),XS(1))        
C        
C     DEFINITION OF INPUT DATA BLOCKS        
C        
      DATA    GPECT ,  KDICT, KELEM, SIL, ECT  /        
     1        101   ,  102  , 103  , 104, 105  /        
C        
C     DEFINITION OF OUTPUT DATA BLOCKS        
C        
      DATA    KGG   /  201  /        
C        
C     DEFINITION OF SCRATCH FILES        
C        
      DATA    SCR1  ,  SCR2 / 301, 302 /        
C        
C     MISCELANEOUS DATA        
C        
      DATA    SUBNAM/  4HEMA1,4H    /, NHEMA1/ 4HEMA1/,        
     1        LARGE /  2147483647   /, LPCB  / 8     /        
C        
C     DATA    TERMS /  1, 0, 9, 0, 0, 18 /,        
C    1        SCL   /  1, 1, 0           /        
C        
C     STATEMENT FUNCTION        
C        
      EVEN(N) = 2*((N+1)/2)        
C        
C     PERFORM GENERALIZATION        
C        
      LCORE = KORSZ(ZD)        
      TRLSIL(1) = SIL        
      CALL RDTRL (TRLSIL)        
      WRITE  (NOUT,999) (TRLSIL(I),I=1,7)        
  999 FORMAT (1H ,7I10)        
      ISIL0 = LCORE - NBRSIL - 1        
      LCORE = ISIL0        
      BUF1  = LCORE - SYSBUF        
      BUF2  = BUF1 - SYSBUF        
      BUF3  = BUF2 - SYSBUF        
      BUF(1)= KELEM        
      CALL RDTRL (BUF)        
      WRITE (NOUT,999) (BUF(I),I=1,7)        
      PREC  = BUF(2)        
      CALL MAKMCB (MCBKGG,KGG,LUSET,6,PREC)        
      OPENW = WRTREW        
      OPENR = RDREW        
      LAST  = .FALSE.        
      SILNBR= 0        
      OPCLS = CLS        
      MAXDCT= 0        
      MAXVEC= 0        
      OLDCOD= 0        
C        
C     SET SWITCH FOR MULTIPLICATION BY DAMPING AND/OR WEIGHT MASS FACTOR
C        
      EPS = ABS(WTMASS-1.0)        
      IF (EPS.LT.1.E-6 .AND. NOK4.LT.0) ASSIGN 244 TO KFACT        
      IF (EPS.LT.1.E-6 .AND. NOK4.GE.0) ASSIGN 245 TO KFACT        
      IF (EPS.GE.1.E-6 .AND. NOK4.LT.0) ASSIGN 246 TO KFACT        
      IF (EPS.GE.1.E-6 .AND. NOK4.GE.0) ASSIGN 247 TO KFACT        
C        
C     READ THE CONTENTS OF THE SIL DATA BLOCK INTO CORE        
C        
      CALL GOPEN (SIL,ZI(BUF1),RDREW)        
      CALL FREAD (SIL,ZI(ISIL0+1),NBRSIL,1)        
      CALL CLOSE (SIL,CLSREW)        
      ZI(ISIL0+NBRSIL+1) = LUSET + 1        
      CALL CDCBUG (NHEMA1,100,ZI(ISIL0+1),NBRSIL+1)        
C        
C     READ THE KDICT AND ECT DATA BLOCKS. WRITE A MODIFIED KDICT ON SCR2
C     WHICH INCLUDES THE INTERNAL GRID NUMBERS FOR EACH ELEMENT.        
C     THE FORMAT FOR EACH RECORD ON SCR2 IS...        
C     3-WORD RECORD HEADER        
C        1  ELEMENT TYPE        
C        2  NBR OF WORDS PER ENTRY( N )        
C        3  NBR OF GRID POINTS PER ENTRY        
C     N-WORD ELEMENT ENTRY        
C        1  ELEMENT ID( INTERNAL NUMBER )        
C        2  FORM OF COLUMN PARTITIONS( 1=RECT, 2=DIAG )        
C        3  NUMBER OF TERMS PER COLUMN PARTITION        
C        4  SCALAR CODE DEFINING DOF PER GRID POINT        
C        5  GE        
C        6  INTERNAL INDEX OF 1ST GRID POINT        
C        7  GINO ADDRESS OF 1ST COLUMN PARTITION        
C       ...        
C       N-1 INTERNAL INDEX OF LAST GRID POINT        
C        N  GINO ADDRESS OF LAST COLUMN PARTITION        
C        
C     NOTE...        
C     GRID POINTS ARE IN SORT BY INTERNAL INDEX. ZERO INDICATES        
C     MISSING GRID POINT. ANY ZERO-S ARE LAST IN LIST.        
C        
      CALL GOPEN (KDICT,ZI(BUF1),RDREW )        
      CALL GOPEN (ECT  ,ZI(BUF2),RDREW )        
      CALL GOPEN (SCR2 ,ZI(BUF3),WRTREW)        
  111 CALL READ  (*124,*111,KDICT,BUF(4),3,0,J)        
      CALL CDCBUG (NHEMA1,111,BUF(4),3)        
  112 CALL ECTLOC (*900,ECT,BUF,I)        
      CALL CDCBUG (NHEMA1,112,BUF,3)        
      IF (ELEM(I+2) .EQ. BUF(4)) GO TO 114        
      CALL SKPREC (ECT,1)        
      GO TO 112        
  114 BUF(5) = BUF(5) + BUF(6)        
      CALL WRITE (SCR2,BUF(4),3,0)        
      IGRID  = ELEM(I+12)        
      NBRGRD = ELEM(I+ 9)        
      NWDECT = ELEM(I+ 5)        
      IDICT  = NWDECT + 1        
      NWDDCT = BUF(5) - BUF(6)        
      NGRID  = IGRID + NBRGRD - 1        
      MAXDCT = MAX0(MAXDCT,BUF(5))        
      IF (NBRGRD .NE. BUF(6)) GO TO 901        
  115 CALL READ (*122,*122,ECT,ZI,NWDECT,0,J)        
      CALL CDCBUG (NHEMA1,115,ZI,NWDECT)        
      CALL FREAD (KDICT,ZI(IDICT),NWDDCT,0)        
      CALL CDCBUG (NHEMA1,116,ZI(IDICT),NWDDCT)        
      DO 116 J = IGRID,NGRID        
      IF (ZI(J) .EQ. 0) ZI(J) = LARGE        
  116 CONTINUE        
      CALL SORT (0,0,1,1,ZI(IGRID),NBRGRD)        
      DO 118 J = IGRID,NGRID        
      IF (ZI(J) .EQ. LARGE) ZI(J) = 0        
  118 CONTINUE        
      CALL CDCBUG (NHEMA1,118,ZI(IGRID),NBRGRD)        
      CALL WRITE  (SCR2,ZI(IDICT),NWDDCT-NBRGRD,0)        
      ILOC = IDICT + NWDDCT - NBRGRD        
      DO 120 J = 1,NBRGRD        
      CALL WRITE (SCR2,ZI(IGRID+J-1),1,0)        
      CALL WRITE (SCR2,ZI(ILOC +J-1),1,0)        
  120 CONTINUE        
      MAXVEC = MAX0(MAXVEC,ZI(IDICT+2)*PREC)        
      GO TO 115        
  122 CALL SKPREC (KDICT,1)        
      CALL WRITE (SCR2,0,0,1)        
      GO TO 111        
  124 CALL CLOSE (KDICT,CLSREW)        
      CALL CLOSE (  ECT,CLSREW)        
      CALL CLOSE ( SCR2,CLSREW)        
      TT(1) = MAXDCT        
      TT(2) = MAXVEC        
      CALL CDCBUG (NHEMA1,125,TT,2)        
C        
C     READ GPECT AND PREPARE THE SCR1 DATA BLOCK. FOR EACH GRID/SCALAR  
C     POINT, TWO RECORDS ARE WRITTEN. THE 1ST CONTAINS 6 WORDS...       
C       1  INTERNAL INDEX OF GRID/SCALAR POINT        
C       2  DOF OF POINT (1=SCALAR, 6=GRID)        
C       3  DOF OF EACH CONNECTED POINT (0 IF NO CONNECTED POINTS)       
C       4  NUMBER OF CONNECTED POINTS        
C       5  INDEX OF  1ST CONNECTED POINT        
C       6  INDEX OF LAST CONNECTED POINT        
C        
C     THE 2ND RECORD IS A PACKED COLUMN WHICH CONTAINS A NON-ZERO TERM  
C     FOR EACH CONNECTED POINT.        
C        
      TYPIN1 = 1        
      TYPOU1 = 1        
      INCR1  = 1        
      INCR2  = 1        
      CALL MAKMCB (MCB,SCR1,NBRSIL,1,1)        
      ILOOK0 = NBRSIL + 1        
      IF (ILOOK0+LUSET+1 .GE. BUF3) CALL MESAGE (-8,0,SUBNAM)        
      DO 131 I = 1,NBRSIL        
      J = ZI(ISIL0+I)        
      ZI(ILOOK0+J) = I        
  131 CONTINUE        
      CALL CDCBUG (NHEMA1,131,ZI(ILOOK0+1),LUSET)        
      CALL GOPEN (GPECT,ZI(BUF1),RDREW )        
      CALL GOPEN (SCR1 ,ZI(BUF2),WRTREW)        
      DO 148 II = 1,NBRSIL        
      NBRCON = BUF(4)        
      MINNBR = BUF(5)        
      MAXNBR = BUF(6)        
      IF (II .NE. 1) GO TO 130        
      NBRCON = NBRSIL        
      MINNBR = 1        
      MAXNBR = NBRSIL        
  130 CALL FREAD (GPECT,BUF,2,0)        
      BUF(1) = II        
      BUF(3) = 0        
      BUF(4) = 0        
      BUF(5) = LARGE        
      BUF(6) = 0        
      IF (NBRCON .EQ. 0) GO TO 134        
      DO 132 I = MINNBR,MAXNBR        
      ZI(I) = 0        
  132 CONTINUE        
  134 CALL READ (*138,*138,GPECT,TT,3,0,I)        
      CALL CDCBUG (NHEMA1,134,TT,3)        
      NBRGRD = IABS(TT(1)) - 2        
      DO 136 I = 1,NBRGRD        
      CALL FREAD (GPECT,SILNBR,1,0)        
      J = ZI(ILOOK0+SILNBR )        
      IF (ZS(J) .NE. 0) GO TO 136        
      BUF(3) = MAX0(BUF(3),ZI(ISIL0+J+1)-ZI(ISIL0+J))        
      BUF(4) = BUF(4) + 1        
      BUF(5) = MIN0(BUF(5),J)        
      BUF(6) = MAX0(BUF(6),J)        
      ZS(J)  = 1.0        
  136 CONTINUE        
      GO TO 134        
  138 CALL WRITE (SCR1,BUF,6,1)        
      CALL CDCBUG (NHEMA1,138,BUF,6)        
      IF (BUF(4) .EQ. 0) GO TO 142        
C        
C     PACK COLUMN FOR POINT WITH CONNECTED POINTS        
C        
      II1 = BUF(5)        
      JJ1 = BUF(6)        
      CALL CDCBUG (NHEMA1,139,ZI(II1),JJ1-II1+1)        
      CALL PACK (ZS(II1),SCR1,MCB)        
      GO TO 148        
C        
C     HERE IF PIVOT HAS NO CONNECTED POINTS        
C        
  142 CONTINUE        
      MCB(2) = MCB(2) + 1        
C        
C     CLOSE FILES        
C        
  148 CONTINUE        
      CALL CLOSE (GPECT,CLSREW)        
      CALL CLOSE ( SCR1,CLSREW)        
      CALL WRTTRL (MCB)        
C        
C     ALLOCATE STORAGE FOR MAXIMUM COLUMN OF ELEMENT MATRIX        
C     AND MAXIMUM ENTRY FROM MODIFIED KDICT( SCR2 )        
C        
      IDICT = MAXVEC + 1        
      IGRID = IDICT + 5        
      IPVT  = IDICT + MAXDCT        
      LCORE = EVEN( BUF2 ) - 1        
C        
C        
C     BEGIN A PASS BY OPENING SCR1 AND SETTING ALLOCATION POINTERS      
C        
C        
  150 CALL GOPEN (SCR1,ZI(BUF1),OPENR)        
      II = IPVT        
      JJ = LCORE        
C        
C     BEGIN A PIVOT ALLOCATION BY READING PIVOT CONTROL BLOCK FROM SCR1 
C        
  160 CONTINUE        
      TT(1) = II        
      TT(2) = JJ        
      CALL CDCBUG (NHEMA1,160,TT,2)        
      IF (II+LPCB .GE. JJ) GO TO 202        
      CALL FREAD (SCR1,ZI(II),6,1)        
      SILNBR = ZI(II)        
      ZI(II+6) = 0        
      ZI(II+7) = 0        
      IF (ZI(II+3) .EQ. 0) GO TO 195        
C        
C     ATTEMPT TO ALLOCATE SPACE FOR CONNECTED GRID VECTOR        
C     AND FOR MATRICES CONNECTED TO THE PIVOT        
C        
      NWDCGV = ZI(II+5) - ZI(II+4) + 1        
      NWDMAT = PREC*ZI(II+1)*ZI(II+2)*ZI(II+3)        
      IF (II+LPCB .GE. JJ-NWDCGV-NWDMAT) GO TO 200        
      IMAT = JJ - NWDMAT        
      ZI(II+6) = IMAT - EVEN(NWDCGV)        
      ZI(II+7) = IMAT        
      JJ   = ZI(II+6)        
      NMAT = IMAT + NWDMAT - 1        
      DO 165 I = IMAT,NMAT        
      ZS(I) = 0        
  165 CONTINUE        
      ICGVEC = JJ        
      NCGVEC = ICGVEC + NWDCGV - 1        
C        
C     UNPACK CONNECTED GRID VECTOR. CONVERT NON-ZERO POSITIONS TO       
C     RELATIVE POINTERS (IN PRECISION OF PROBLEM) TO THE CORRESPONDING  
C     1ST TERM OF THE ELEMENT MATRIX        
C        
      II2 = ZI(II+4)        
      JJ2 = ZI(II+5)        
      NTRMEC = ZI(II+2)        
      KK = 1        
      TYPIN2 = 1        
      CALL UNPACK (*902,SCR1,ZS(ICGVEC))        
      DO 174 I = ICGVEC,NCGVEC        
      IF (ZI(I) .EQ. 0) GO TO 174        
      ZI(I) = KK        
      KK = KK + NTRMEC        
  174 CONTINUE        
      CALL CDCBUG (NHEMA1,174,ZI(II),8)        
      CALL CDCBUG (NHEMA1,175,ZI(ICGVEC),NWDCGV)        
      IF (KK-1 .NE. ZI(II+2)*ZI(II+3)) GO TO 903        
C        
C     TEST FOR LAST PIVOT. IF NOT, TRY TO ALLOCATE ANOTHER PIVOT        
C        
  195 IF (SILNBR .EQ. NBRSIL) GO TO 210        
      II = II + LPCB        
      GO TO 160        
C        
C     HERE IF CURRENT PIVOT CANNOT BE ALLOCATED -- MAKE SURE AT LEAST   
C     ONE PIVOT HAS BEEN ALLOCATED.        
C        
  200 CALL BCKREC (SCR1)        
  202 IF (II .EQ. IPVT) CALL MESAGE (-8,0,SUBNAM)        
      NPVT = II - LPCB        
      GO TO 220        
C        
C     HERE WHEN LAST PIVOT HAS BEEN READ AND ALLOCATED        
C        
  210 LAST = .TRUE.        
      OPCLS= CLSREW        
      NPVT = II        
C        
C        
C     CLOSE SCR1, OPEN SCR2 AND KELEM. PREPARE TO ASSEMBLE        
C     STRUCTURAL MATRIX FOR THOSE PIVOTS CURRENTLY ALLOCATED.        
C        
C        
  220 CONTINUE        
      CALL CLOSE (SCR1,OPCLS)        
      CALL GOPEN (SCR2, ZI(BUF1),RDREW)        
      CALL GOPEN (KELEM,ZI(BUF2),RDREW)        
C        
C     READ HEADER FOR CURRENT ELEMENT TYPE FROM SCR2        
C        
  230 CONTINUE        
      CALL READ (*260,*230,SCR2,TT,3,0,I)        
      CALL CDCBUG (NHEMA1,230,TT,3)        
      NWDDCT = TT(2)        
      NGRID  = IGRID + 2*(TT(3)-1)        
C        
C     READ AN ELEMENT DEFINITION. IF ANY GRID POINT IS IN CURRENT       
C     ALLOCATION, PREPARE TO PROCESS IT.        
C        
  240 CALL READ (*230,*230,SCR2,ZI(IDICT),NWDDCT,0,I)        
      CALL CDCBUG (NHEMA1,240,ZI(IDICT),NWDDCT)        
      DO 242 I = IGRID,NGRID,2        
      IF (ZI(I).GE.ZI(IPVT) .AND. ZI(I).LE.ZI(NPVT))        
     1    GO TO KFACT, (244,245,246,247)        
  242 CONTINUE        
      GO TO 240        
  244 FACTOR = 1.0        
      GO TO 248        
  245 FACTOR = ZS(IDICT+4)        
      GO TO 248        
  246 FACTOR = WTMASS        
      GO TO 248        
  247 FACTOR = WTMASS*ZS(IDICT+4)        
C        
C     DECODE RELATIVE COLUMN NUMBERS        
C        
  248 IF (OLDCOD .EQ. ZI(IDICT+3)) GO TO 250        
      ICODE = ZI(IDICT+3)        
      CALL DECODE (ICODE,SCALAS,NSCA)        
      OLDCOD = ZI(IDICT+3)        
C        
C     READ EACH COLUMN OF THE ELEMENT MATRIX.        
C     ADD IT TO THE STRUCTURAL MATRIX.        
C        
  250 NWDCOL = PREC*ZI(IDICT+2)        
      IF (ZI(IDICT+1) .EQ. 2) NWDCOL = PREC        
  252 II = IPVT + (ZI(I)-ZI(IPVT))*LPCB        
      TT(1) = I        
      TT(2) = ZI(I)        
      TT(3) = NSCA        
      CALL CDCBUG (NHEMA1,252,TT,3)        
      CALL FILPOS (KELEM,ZI(I+1))        
      ICGVEC = ZI(II+6)        
      IMAT   = ZI(II+7)        
      DO 254 J = 1,NSCA        
      CALL FREAD (KELEM,ZI,NWDCOL,0)        
      CALL CDCBUG(NHEMA1,254,ZI,NWDCOL)        
      IF (PREC .EQ. 1) CALL EMA1S (J,NSCA,SCALAS,ZI(II),ZI(IDICT),      
     1                             ZI(ICGVEC),ZI(IMAT),ZI,FACTOR)       
      IF (PREC .EQ. 2) CALL EMA1D (J,NSCA,SCALAS,ZI(II),ZI(IDICT),      
     1                             ZI(ICGVEC),ZI(IMAT),ZI,FACTOR)       
  254 CONTINUE        
  255 IF (I .EQ. NGRID) GO TO 240        
      I = I + 2        
      IF (ZI(I).GE.ZI(IPVT) .AND. ZI(I).LE.ZI(NPVT)) GO TO 252        
      GO TO 255        
C        
C     ALL COLUMNS OF STRUCTURAL MATRIX NOW ALLOCATED ARE COMPLETE.      
C     OPEN KGG AND PACK COLUMNS.        
C        
  260 CALL CLOSE (SCR2,CLSREW)        
      CALL CLOSE (KELEM,CLSREW)        
      CALL GOPEN (KGG,ZI(BUF1),OPENW)        
      DO 269 II = IPVT,NPVT,LPCB        
      DOF    = ZI(II+1)        
      DOFG   = ZI(II+2)        
      NBRCON = ZI(II+3)        
      ICGVEC = ZI(II+6)        
      IMAT   = ZI(II+7)        
      II1    = ZI(II+4)        
      II2    = ZI(II+5)        
      KK     = IMAT        
      CALL CDCBUG (NHEMA1,260,ZI(IMAT),((II2-II1+1)*(DOF*DOFG)))        
C        
C     PACK COLUMNS WITH BLDPK        
C        
      DO 268 JJ = 1,DOF        
      CALL BLDPK (PREC,PREC,KGG,BLOCK,1)        
      IF (NBRCON .EQ. 0) GO TO 266        
      I = ICGVEC        
      DO 264 J = II1,II2        
      IF (ZI(I) .EQ. 0) GO TO 263        
      K  = ZI(ISIL0+J)        
      N  = K + MIN0(DOFG,ZI(ISIL0+J+1)-ZI(ISIL0+J)) - 1        
      LL = KK        
      DO 262 SILNBR = K,N        
      CALL BLDPKI (ZS(LL),SILNBR,KGG,BLOCK)        
      LL = LL + PREC        
  262 CONTINUE        
      KK = KK + DOFG*PREC        
  263 I  = I + 1        
  264 CONTINUE        
  266 CALL BLDPKN (KGG,BLOCK,MCBKGG)        
  268 CONTINUE        
  269 CONTINUE        
      CALL CLOSE (KGG,OPCLS)        
C        
C     TEST FOR COMPLETION OF LAST PASS        
C        
      IF (LAST) GO TO 310        
      OPENR = RD        
      OPENW = WRT        
      GO TO 150        
C        
C     KGG NOW COMPLETE -- WRITE ITS TRAILER.        
C        
  310 CONTINUE        
      CALL WRTTRL (MCBKGG)        
      RETURN        
C        
C     FATAL ERRORS        
C        
  900 KERR = 112        
      GO TO 990        
  901 KERR = 114        
      GO TO 990        
  902 KERR = 172        
      GO TO 990        
  903 KERR = 174        
      GO TO 990        
C        
C     PROCESS LOGIC ERROR        
C        
  990 WRITE  (NOUT,991) SFM,KERR        
  991 FORMAT (A25,' 3102, EMA1 LOGIC ERROR',I4)        
      IF (MACH.EQ.2 .OR. MACH.EQ.5 .OR. MACH.EQ.21) KERR = -KERR        
      CALL GPERR (SUBNAM,KERR)        
      RETURN        
      END        
