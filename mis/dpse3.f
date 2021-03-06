      SUBROUTINE DPSE3        
C        
C     PRESSURE STIFFNESS CALCULATIONS FOR A TRIANGULAR MEMBRANE        
C     ELEMENT (3 GRID POINTS).        
C     THREE 6X6 STIFFNESS MATRICES FOR THE PIVOT POINT ARE INSERTED.    
C        
C     DOUBLE PRECISION VERSION        
C        
C     WRITTEN BY E. R. CHRISTENSEN/SVERDRUP, 9/91, VERSION 1.1        
C     INSTALLED IN NASTRAN AS ELEMENT DPSE3 BY G.CHAN/UNISYS, 2/92      
C        
C     REFERENCE - E. CHRISTENEN: 'ADVACED SOLID ROCKET MOTOR (ASRM)
C                 MATH MODELS - PRESSURE STIFFNESS EFFECTS ANALYSIS',
C                 NASA TD 612-001-02, AUGUST 1991
C
C     LIMITATION -        
C     (1) ALL GRID POINTS USED BY ANY IF THE CPSE2/3/4 ELEMENTS MUST BE 
C         IN BASIC COORDINATE SYSTEM!!!        
C     (2) CONSTANT PRESSURE APPLIED OVER AN ENCLOSED VOLUMN ENCOMPASSED 
C         BY THE CPSE2/3/4 ELEMENTRS        
C     (3) PRESSURE ACTS NORMALLY TO THE CPSE2/3/4 SURFACES        
C        
C     SEE NASTRAN DEMONSTRATION PROBLEM -  T13022A
C        
      DOUBLE PRECISION GAMMA,KIJ,SGN,SGN1,SGN2,DP,C        
      DIMENSION        NECPT(5)        
C     COMMON /SYSTEM/  IBUF,NOUT        
      COMMON /DS1AAA/  NPVT,ICSTM,NCSTM        
      COMMON /DS1AET/  ECPT(21),DUM2(2),DUM9(9)        
      COMMON /DS1ADP/  GAMMA,KIJ(36),SGN,SGN1,SGN2,DP(21),C(9)        
      EQUIVALENCE      (NECPT(1),ECPT(1))        
C        
C     ECPT FOR THE PRESSURE STIFFNESS CPES3 ELEMENT        
C        
C     ECPT( 1) = ELEMENT ID        
C     ECPT( 2) = SIL FOR GRID POINT A OR 1        
C     ECPT( 3) = SIL FOR GRID POINT B OR 2        
C     ECPT( 4) = SIL FOR GRID POINT C OR 3        
C     ECPT( 5) = PRESSURE        
C     ECPT( 6) = NOT USED        
C     ECPT( 7) = NOT USED        
C     ECPT( 8) = NOT USED        
C     ECPT( 9) = COORD. SYSTEM ID 1        
C     ECPT(10) = X1        
C     ECPT(11) = Y1        
C     ECPT(12) = Z1        
C     ECPT(13) = COORD. SYSTEM ID 2        
C     ECPT(14) = X2        
C     ECPT(15) = Y2        
C     ECPT(16) = Z2        
C     ECPT(17) = COORD. SYSTEM ID 3        
C     ECPT(18) = X3        
C     ECPT(19) = Y3        
C     ECPT(20) = Z3        
C     ECPT(21) = ELEMENT TEMPERATURE        
C     ECPT(22) THRU (32) = DUM2 AND DUM9, NOT USED IN THIS ROUTINE      
C        
C     STORE ECPT IN DOUBLE PRECISION        
C        
      DP(5) = ECPT(5)        
      K = 9        
      DO 20 I = 1,3        
      DO 10 J = 1,3        
      K = K + 1        
   10 DP(K) = ECPT(K)        
   20 K = K + 1        
C        
C     CALCULATE THE THREE VECTORS R1, R2 AND R2 USED IN COMPUTING       
C     THE PRESSURE STIFFNESS MATRICES:        
C        
C     R1 = RA - 2*RC + RB        
C     R2 = 2*RB - RA - RC        
C     R3 = RB - 2*RA + RC        
C        
C     R1 STORED IN C(1), C(2), C(3)        
C     R2 STORED IN C(4), C(5), C(6)        
C     R3 STORED IN C(7), C(8), C(9)        
C        
      C(1) = DP(10) - 2.0D0*DP(18) + DP(14)        
      C(2) = DP(11) - 2.0D0*DP(19) + DP(15)        
      C(3) = DP(12) - 2.0D0*DP(20) + DP(16)        
C        
      C(4) = 2.0D0*DP(14) - DP(10) - DP(18)        
      C(5) = 2.0D0*DP(15) - DP(11) - DP(19)        
      C(6) = 2.0D0*DP(16) - DP(12) - DP(20)        
C        
      C(7) = DP(14) - 2.0D0*DP(10) + DP(18)        
      C(8) = DP(15) - 2.0D0*DP(11) + DP(19)        
      C(9) = DP(16) - 2.0D0*DP(12) + DP(20)        
C        
      DO 30 I = 1,3        
      IF (NECPT(I+1) .NE. NPVT) GO TO 30        
      NPIVOT = I        
      GO TO 40        
   30 CONTINUE        
      RETURN        
C        
C     GENERATE THE THREE BY THREE PARTITIONS IN GLOBAL COORDINATES HERE 
C        
C     SET COUNTERS ACCORDING TO WHICH GRID POINT IS THE PIVOT        
C        
   40 IF (NPIVOT-2) 50,60,70        
C        
C     SET COUNTERS AND POINTERS FOR CALCULATING KAB, KAC        
C        
   50 NI = 2        
      NJ = 3        
      NK = 1        
      K1 = 1        
      K2 = 4        
      SGN1 = 1.0D0        
      SGN2 = 1.0D0        
      GO TO 80        
C        
C     SET COUNTERS AND POINTERS FOR CALCULATING KBA, KBC        
C     NOTE THAT KBA = -KAB        
C        
   60 NI = 1        
      NJ = 3        
      NK = 2        
      K1 = 1        
      K2 = 7        
      SGN1 =-1.0D0        
      SGN2 = 1.0D0        
      GO TO 80        
C        
C     SET COUNTERS AND POINTERS FOR CALCULATING KCA, KCB        
C     NOTE THAT KCA = -KAC, KCB = -KBC        
C        
   70 NI = 1        
      NJ = 2        
      NK = 1        
      K1 = 4        
      K2 = 7        
      SGN1 =-1.0D0        
      SGN2 =-1.0D0        
C        
   80 GAMMA =-DP(5)/12.0D0        
      SGN   = SGN1*GAMMA        
      K = K1        
      DO 100 I = NI,NJ,NK        
      DO 90  J = 1,36        
   90 KIJ(J) = 0.0D0        
      KK2 = K + 1        
      KK3 = K + 2        
      KIJ( 2) =-C(KK3)*SGN        
      KIJ( 3) = C(KK2)*SGN        
      KIJ( 7) = C(KK3)*SGN        
      KIJ( 9) =-C(K  )*SGN        
      KIJ(13) =-C(KK2)*SGN        
      KIJ(14) = C(K  )*SGN        
      CALL DS1B (KIJ(1),NECPT(I+1))        
      SGN = SGN2*GAMMA        
      K   = K2        
  100 CONTINUE        
C        
      RETURN        
      END        
