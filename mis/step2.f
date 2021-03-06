      SUBROUTINE STEP2 (U2,U1,U0,P,IBUF)        
C        
C     STEP2 WILL INTEGRATE FORWARD ONE TIME STEP        
C        
C     THIS ROUTINE IS SUITABLE FOR DOUBLE PRECISION OPERATION        
C        
      INTEGER          FILE(7) ,SQR     ,RDP     ,DUM     ,IBUF(1)      
      DOUBLE PRECISION U2(1)   ,U1(1)   ,U0(1)   ,P(1)        
      COMMON /TRDXX /  DUM(21) ,ISCR1   ,ISCR2   ,ISCR3   ,ISCR4   ,    
     1                 ISCR5   ,ISCR6   ,IOPEN   ,ISYM        
      COMMON /NAMES /  DUMM(8) ,RDP     ,DUMN(2) ,SQR        
      COMMON /INFBSX/  IFIL(7) ,IFILU(7)        
C        
      FILE(1) = ISCR1        
      FILE(2) = DUM(2)        
      FILE(4) = SQR        
C        
C     TELL MATVC2/INVFBS FILES ARE OPEN        
C        
      IOPEN = 1        
C        
C     FORM R.H.S. OF THE INTEGRATION EQUATION        
C        
      CALL MATVC2 (U1(1),P(1),FILE,IBUF)        
      FILE(1) = ISCR4        
      CALL MATVC2 (U0(1),P(1),FILE,IBUF)        
C        
C     CALL INVFBS/FBSINT TO DO THE FORWARD/BACKWARD PASS        
C        
      IFIL(1)  = ISCR2        
      IFILU(1) = ISCR3        
      CALL RDTRL (IFIL)        
      CALL RDTRL (IFILU)        
      IFIL(5) = RDP        
      IFIL(3) = DUM(3)        
      IF (ISYM .EQ. 1) IOPEN = - 20        
      IF (ISYM .EQ. 1) CALL INVFBS (P(1),U2(1),IBUF)        
      IF (ISYM .EQ. 0) CALL FBSINT (P(1),U2(1))        
      IOPEN = 0        
      RETURN        
      END        
