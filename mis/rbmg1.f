      SUBROUTINE RBMG1
C*****
C RBMG1 PARTITIONS KAA INTO KLL, KLR AND KRR AND MAA SIMILARLY.
C*****
C
      INTEGER       USET  ,UA    ,UL    ,UR    ,SCR1
      COMMON/BITPOS/UM    ,UO    ,UR    ,USG   ,USB   ,UL    ,UA
     1             ,UF    ,US    ,UN    ,UG    ,UE    ,UP
C*****
C     INPUT DATA FILES
C*****
      DATA USET,KAA,MAA/101,102,103/                                    
C*****                                                                  
C     OUTPUT DATA FILES
C*****
      DATA  KLL,KLR,KRR,MLL,MLR,MRR/201,202,203,204,205,206/            
C*****                                                                  
C     SCRATCH DATA FILES
C*****
      DATA SCR1/301/                                                    
C*****                                                                  
C     PARTITION  KAA INTO KLL,KLR, AND KRR
C     PARTITION  MAA INTO MLL,MLR, AND MRR
C*****
      CALL UPART(USET,SCR1,UA,UL,UR)
      CALL MPART(KAA,KLL,0,KLR,KRR)
      CALL MPART(MAA,MLL,0,MLR,MRR)
      RETURN
      END
