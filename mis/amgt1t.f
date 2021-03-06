      SUBROUTINE AMGT1T (NLINE,NL,ACPT,NSTNS,C3T,C4T)        
C        
C     GENERATE CONSTANTS C3T AND C4T FOR        
C     STREAMLINE NL OF SWEPT TURBOPROP BLADE.        
C        
      REAL       L1,L2,L3        
      INTEGER    ACPT,FILE,NAME(2)        
      DIMENSION  PN(3),P1(3),FN(3),F1(3),S1(3),SN(3),DATA(3)        
      DATA FILE/ 102 /, NAME / 4HAMGT,4H1T  /        
C        
C     INPUT VARIABLES -        
C     NLINE      TOTAL NO. OF STREAMLINES        
C     NL         PRESENT STEAMLINE        
C     ACPT       SCRATCH UNIT WITH BASIC COORDINATES OF NODES        
C     NSTNS      TOTAL NO. OF STATIONS        
C        
C     OUTPUT VARIABLES -        
C     C3T        CONSTANTS USED BY SUB. AND SUP. AERODYNAMIC ROUTINES   
C     C4T        USED IN DEFINING DATA BLOCK AJJ        
C        
C     LOCAL VARIABLES -        
C     PN         COORDINATES TRAILING EDGE PREVIOUS STREAMLINE        
C     P1         COORDINATES LEADING EDGE PREVIOUS STREAMLINE        
C     FN         COORDINATES TRAILING EDGE NEXT STREAMLINE        
C     F1         COORDINATES LEADING EDGE NEXT STREAMLINE        
C     S1         COORDINATES OF LEADING EDGE OF CURRENT STREAMLINE      
C     SN         COORDINATES OF TRAILING EDGE OF CURRENT STREAMLINE     
C        
C     EXTRACT LEADING COORDINATES OF CURRENT STREAMLINE        
C        
      CALL FREAD (ACPT,DATA,3,0)        
      DO 1 I = 1,3        
   1  S1(I) = DATA(I)        
C        
C     SKIP TO TRAILING EDGE COORDINATES OF CURRENT STREAMLINE        
C        
      NSKIP = (2-NSTNS)*3        
      CALL READ (*905,*900,ACPT,DATA,NSKIP,0,MM)        
      CALL FREAD (ACPT,DATA,3,0)        
      DO 2 I = 1,3        
  2   SN(I) = DATA(I)        
C        
C     EXTRACT COORDINATES FOR PREVIOUS--P-FOR FIRST STREAMLINE        
C        
      IF (NL .NE. 1) GO TO 10        
      DO 5 I = 1,3        
      PN(I) = SN(I)        
  5   P1(I) = S1(I)        
C        
C     NOW COORDINATES FOR NEXT -F- FOR LAST STREAMLINE        
C        
 10   IF (NL .NE. NLINE) GO TO 15        
      DO 12 I = 1,3        
      FN(I) = SN(I)        
 12   F1(I) = S1(I)        
      GO TO 50        
C        
C     NOW COORDINATES FOR NEXT -F- FOR ALL OTHER STREAMLINES        
C        
C     SKIP FIRST 10 WORDS OF NEXT STREAMLINE        
C        
 15   CALL READ (*905,*900,ACPT,DATA,-10,0,MM)        
      CALL FREAD (ACPT,DATA,3,0)        
      F1(1) = DATA(1)        
      F1(2) = DATA(2)        
      F1(3) = DATA(3)        
C        
C     COMPUTE SKIP TO TRAILING EDGE COORDINATES        
C        
      NSKIP = (2-NSTNS)*3        
      CALL READ (*905,*900,ACPT,DATA,NSKIP,0,MM)        
      CALL FREAD (ACPT,DATA,3,0)        
      FN(1) = DATA(1)        
      FN(2) = DATA(2)        
      FN(3) = DATA(3)        
 50   A1 = SN(1) - S1(1)        
      B1 = SN(2) - S1(2)        
      C1 = SN(3) - S1(3)        
C        
      A2 = FN(1) - P1(1)        
      B2 = FN(2) - P1(2)        
      C2 = FN(3) - P1(3)        
C        
      A3 = PN(1) - F1(1)        
      B3 = PN(2) - F1(2)        
      C3 = PN(3) - F1(3)        
C        
      A4 = B2*C1 - B1*C2        
      B4 = C2*A1 - C1*A2        
      C4 = A2*B1 - A1*B2        
C        
      A5 = B1*C3 - B3*C1        
      B5 = C1*A3 - C3*A1        
      C5 = A1*B3 - A3*B1        
C        
      L1 = SQRT(A1**2 + B1**2 + C1**2)        
      L2 = SQRT(A4**2 + B4**2 + C4**2)        
      L3 = SQRT(A5**2 + B5**2 + C5**2)        
C        
      A6 = 0.5*(A4/L2 + A5/L3)        
      B6 = 0.5*(B4/L2 + B5/L3)        
      C6 = 0.5*(C4/L2 + C5/L3)        
C        
      A7 = (B1*C6 - B6*C1)/L1        
      B7 = (C1*A6 - C6*A1)/L1        
      C7 = (A1*B6 - A6*B1)/L1        
C        
      A8 = F1(1) - P1(1)        
      B8 = F1(2) - P1(2)        
      C8 = F1(3) - P1(3)        
C        
      A9 = FN(1) - PN(1)        
      B9 = FN(2) - PN(2)        
      C9 = FN(3) - PN(3)        
C        
      W1 = A7*A8 + B7*B8 + C7*C8        
      W2 = A7*A9 + B7*B9 + C7*C9        
C        
      C3T = (W2-W1)/(2.0*L1)        
      C4T = W1/2.0        
C        
      IF (NL .EQ. NLINE) RETURN        
C        
C     RETURN TO START OF RECORD        
C        
      CALL BCKREC (ACPT)        
C        
C     COMPUTE SKIP TO NEXT STREAMLINE AT EXIT FROM THIS ROUTINE        
C        
      NSKIP = -6 - (10+3*NSTNS)*NL        
      CALL READ (*905,*900,ACPT,DATA,NSKIP,0,MM)        
C        
C     SET PREVIOUS COORDINATES -P- TO PRESENT STREAMLINE COORDINATES    
C        
      DO 800 I = 1,3        
      PN(I) = SN(I)        
 800  P1(I) = S1(I)        
      RETURN        
C        
C     E-O-R    ENCOUNTERED        
 900  IP1 = -3        
      GO TO 999        
C        
C     E-O-F    ENCOUNTERED        
C        
 905  IP1 = -2        
 999  CALL MESAGE (IP1,FILE,NAME)        
      RETURN        
      END        
