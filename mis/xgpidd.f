      SUBROUTINE XGPIDD        
C        
C     THIS SUBROUTINE DEFINES ALL NAMED COMMON FOR SUBROUTINES        
C     XGPI,XOSGEN,XLNKHD,XIOFL,XPARAM,XSCNDM,XFLORD,XFLDEF AND XGPIDG.  
C     **NOTE - THIS PROGRAM MUST BE LOADED BEFORE ANY OF THE ABOVE.     
C        
      INTEGER  BCDCNT,CPNTRY,DIAG4,DIAG14,DIAG17,DIAG25,DMAP,DMPCNT,    
     1         DMPPNT,EOTFLG,IHOL(22),JMP,NAMOPT(26),PVT,SETEOR,SOL,    
     2         START,SUBSET        
C        
C     NAMED COMMON AREAS /XGPIC/ AND /XGPID/ CONTAIN        
C     MACHINE DEPENDENT DATA        
C        
C     COMMON /XGPIC / ICOLD,ISLSH,IEQUL,NBLANK,NXEQUI,        
C                        ** CONTROL CARD NAMES **        
C    1                NMED,NSOL,NDMAP,NESTM1,NESTM2,NEXIT,        
C                        ** DMAP CARD NAMES **        
C    2                NBEGIN,NEND,NJUMP,NCOND,NREPT,NTIME,NSAVE,NOUTPT, 
C    3                NCHKPT,NPURGE,NEQUIV,        
C      ** THE FOLLOWING CONSTANTS ARE INITIALIZED BY XGPIBS ROUTINE **  
C    4                NCPW,NBPC,NWPC,        
C    5                MASKLO,ISGNON,NOSGN,IALLON,MASKS(40)        
C        
      COMMON /XGPIC / ICOLD,IHOLC(21),        
     4                NCPW,NBPC,NWPC,        
     5                MASKHI,MASKLO,ISGNON,NOSGN,IALLON,MASKS(40)       
      COMMON /XGPID / ICST,IUNST,IMST,IHAPP,IDSAPP,IDMAPP,        
     1                ISAVE,ITAPE,IAPPND,INTGR,LOSGN,        
     2                NOFLGS,SETEOR,EOTFLG,IEQFLG,        
     3                CPNTRY(7),JMP(7)        
C        
C     ****** /XGPI1 / *******        
C        
C     COMMON /XGPI1 / LOSCAR,OSPRC,OSBOT,OSPNT,OSCAR(1)        
C        
C     NOTE - /XGPI1 / MUST BE LOADED AT THE END OF LONGEST LINK IN XGPI 
C                     BECAUSE IT DEFINES THE START OF OPEN CORE.        
C        
C     OSCAR  = OPERATION SEQUENCE CONTROL ARRAY        
C     LOSCAR = LENGTH OF OSCAR ARRAY        
C     OSPRC  = POINTER TO PRECEDING OSCAR ENTRY        
C     OSBOT  = POINTER TO LAST OSCAR ENTRY        
C     OSPNT  = POINTER TO PRESENT OSCAR ENTRY BEING PROCESSED        
C        
C     ***ORDER OF TABLES IN OPEN CORE DURING PHASE 1 OF COMPILATION.    
C        EQUIVALENCE (OSCAR,DMPCRD,LBLTBL,MED,IBUFR)        
C        
C     ***ORDER OF TABLES IN OPEN CORE DURING PHASE 2 OF COMPILATION.    
C        EQUIVALENCE (OSCAR,PTDIC,ICPDPL,MED,IBUFR)        
C     IBUFR  = GINO BUFFER AREA LOCATED AT HIGH ADDRESS END OF OPEN     
C              CORE.        
C     DMPCRD = DMAP SEQUENCE CARD IMAGE BUFFER        
C     PTDIC  = PROBLEM TAPE CHECKPOINT DICTIONARY        
C     MED    = MODULE EXECUTION DECISION TABLE FOR RESTARTS IN RIGID    
C              FORMATS        
C     ICPDPL = LIST OF CHECKPOINT FILES TO BE WRITTEN ON DATA POOL FROM 
C              OLD  PROBLEM TAPE IN ORDER TO RESTART PROBLEM.        
C     LBLTBL = TABLE OF LABEL NAMES AND PARAMETER NAMES REFERENCED BY   
C              LABEL,COND,PURGE AND EQUIV DMAP INSTRUCTIONS.        
C        
      COMMON /XGPI3 / PVT(200)        
      COMMON /XGPI4 / IRTURN,INSERT,ISEQN,DMPCNT,IDMPNT,DMPPNT,BCDCNT,  
     1                LENGTH,ICRDTP,ICHAR,NEWCRD,MODIDX,LDMAP,ISAVDW,   
     2                DMAP(200)        
      COMMON /XGPI5 / IAPP,START,ALTER(2),SOL,SUBSET,IFLAG,        
     1                IESTIM,ICFTOP,ICFPNT,LCTLFL,ICTLFL(1)        
      COMMON /XGPI6 / MEDTP,FNMTP,CNMTP,MEDPNT,LMED,IPLUS,DIAG14,DIAG17,
     1                DIAG4,DIAG25,IFIRST,IBUFF(20)        
      COMMON /XGPI7 / IFPNT,LFILE,IFILE(130)        
      COMMON /XGPI8 / ICPTOP,ICPBOT,LCPDPL        
      COMMON /MODDMP/ IFLG(6),NMPT(26)        
      DATA    NAMOPT/ 4HGO  ,4H    ,4HNOGO,4H    ,4HERR ,4H    ,4HLIST, 
     1                4H    ,4HNOLI,4HST  ,4HDECK,4H    ,4HNODE,4HCK  , 
     2                4HREF ,4H    ,4HNORE,4HF   ,4HOSCA,4HR   ,4HNOOS, 
     3                4HCAR ,4HALL ,4H    ,4HEXCE,4HPT  /        
      DATA    IHOL  / 4H/   ,4H=   ,4H    ,4HXEQU,4HMED ,4HSOL ,4HDMAP, 
     1                4HESTI,4HM   ,4HEXIT,4HBEGI,4HEND ,4HJUMP,4HCOND, 
     2                4HREPT,4HTIME,4HSAVE,4HOUTP,4HCHKP,4HPURG,4HEQUI, 
     3                4HXCHK/        
      DATA    IPLS  / 1H+   /        
C        
C     ****** /XGPIC / *******        
C        
C     NCPW   = NUMBER OF CHARACTERS PER WORD.        
C     NBPC   = NUMBER OF BITS PER CHARACTER.        
C     NWPC   = NUMBER OF WORDS PER INPUT CARD (72 CHARACTERS).        
C     MASKHI = MASK OUT ALL BITS EXCEPT LOW ORDER 15 BITS        
C            = 2**15 - 1        
C     MASKLO = MASK FOR HI ORDER 16 BITS, SIGN BIT NOT INCLUDED        
C            = LSHIFT(MASKHI,16)        
C     ISGNON = MASK OUT ALL BUT SIGN BIT        
C            = LSHIFT(1,NBPW-1)        
C     NOSGN  = MASK OUT ONLY SIGN BIT        
C            = COMPLF(ISGNON)        
C     IALLON = ALL BITS ON        
C            = COMPLF(0)        
C     MASKS  = TABLE OF MASKS FOR MASKING OUT VARIOUS CHARACTERS OF A   
C              WORD. TABLE LENGTH = 4*NCPW (40 MAX.)        
C        
C     DATA     ICOLD /1     /, ISLSH /4H/   /, IEQUL /4H=   /,        
C    1         NXEQUI/4HXEQU/, NMED  /4HMED /, NSOL  /4HSOL /,        
C    2         NDMAP /4HDMAP/, NESTM1/4HESTI/, NESTM2/4HM   /,        
C    3         NEXIT /4HEXIT/, NBEGIN/4HBEGI/, NEND  /4HEND /,        
C    3         NJUMP /4HJUMP/, NCOND /4HCOND/, NBLANK/4H    /,        
C    4         NREPT /4HREPT/, NTIME /4HTIME/, NSAVE /4HSAVE/,        
C    5         NCHKPT/4HCHKP/, NPURGE/4HPURG/, NEQUIV/4HEQUI/,        
C    6         MASKHI/32767 /, NOUTPT/4HOUTP/        
C        
      ICOLD  = 1        
      MASKHI = 32767        
C              2**15 - 1        
      DO 5 I = 1,21        
    5 IHOLC(I) = IHOL(I)        
C        
C     ****** /XGPID / *******        
C        
C     ICST,IUNST,IMST = COLD,UNMODIFIED,MODIFIED START CODES        
C     IHAPP,IDSAPP,IDMAPP = HEAT,DISPLACEMENT,DMAP APPROACH CODES       
C     ** THE FOLLOWING CONSTANTS ARE INITIALIZED IN XGPIBS ROUTINE **   
C     INTGR  = INTEGER TYPE CODE RETURNED BY XSCNDM        
C     ISAVE,ITAPE,IAPPND = FLAGS USED IN /XGPI7/        
C     MODFLG = PARAM MODIFY FLAG IN VPS        
C     LOSGN  = SIGN BIT OF LOW ORDER 16 BITS        
C     NOFLGS = MASK OUT FLAGS USED IN PTDIC TABLE AND ICPDPL        
C     SETEOR = END OF RECORD FLAG IN PTDIC,ICPDPL TABLES        
C     EOTFLG = END OF TAPE FLAG   IN PTDIC,ICPDPL TABLES        
C     IEQFLG = EQUIVALENCE FLAG   IN PTDIC,ICPDPL,DPL,FIAT TABLES       
C     CPNTRY = TABLE CONTAINING HEADER SECTION OF CHECKPOINT OSCAR ENTRY
C     JMP    = TABLE CONTAINING JUMP OSCAR ENTRY TO BE INSERTED        
C        
C     DATA  ICST  /1/, IUNST/2/, IMST/3/, IDMAPP/1/, ISAVE/1/,        
C    1      CPNTRY/6,2,0,4HXCHK, 4H    ,  0,0/,        
C    2      JMP   /7,3,0,4HJUMP, 4H    ,  0,0/        
C        
      ICST   = 1        
      IUNST  = 2        
      IMST   = 3        
      IDMAPP = 1        
      ISAVE  = 1        
      JMP(1) = 7        
      JMP(2) = 3        
      JMP(3) = 0        
      JMP(4) = IHOL(13)        
      JMP(5) = IHOL( 3)        
      JMP(6) = 0        
      JMP(7) = 0        
      CPNTRY(1) = 6        
      CPNTRY(2) = 2        
      CPNTRY(3) = 0        
      CPNTRY(4) = IHOL(22)        
      CPNTRY(5) = IHOL( 3)        
      CPNTRY(6) = 0        
      CPNTRY(7) = 0        
C        
C     ****** /XGPI3 / *******        
C        
C     PVT = PARAMETER VALUE TABLE        
C     DATA  PVT/200,2,0,0,1,195*0/        
C        
      PVT(1) = 200        
      PVT(2) = 2        
      DO 10 I = 3,200        
   10 PVT(I) = 0        
      PVT(5) = 1        
C        
C     ****** /XGPI4 / *******        
C        
C     IRTURN = RETURN CODE USED FOR ALTERNATE RETURNS        
C     INSERT = -1  INDICATES DMAP INSTRUCTION IS TO BE DELETED.        
C            =  0  PROCESS DMAP INSTRUCTION FROM MAIN STREAM.        
C            =  1  INSERT DMAP INSTRUCTION FROM ALTER FILE.        
C     ISEQN  = NEXT OSCAR SEQUENCE NUMBER TO BE ASSIGNED.        
C     DMPCNT = DMAP INSTRUCTION COUNTER        
C     IDMPNT = POINTER TO NEXT ITEM TO BE SCANNED IN DMAP ARRAY        
C     DMPPNT = POINTER TO ITEM IN DMAP ARRAY RETURNED BY XSCNDM ROUTINE 
C     BCDCNT = NUMBER OF BCD ENTRIES REMAINING IN DMAP ARRAY BEFORE MODE
C              CHANGES.        
C     LENGTH = LENGTH (IN WORDS) OF BINARY VALUE RETURNED BY XSCNDM     
C              ROUTINE.        
C     ICRDTP = POINTER TO NEXT WORD TO BE PROCESSED IN DMPCRD ARRAY.    
C     ICHAR  = POINTER TO NEXT CHARACTER TO BE PROCESSED IN DMPCRD ARRAY
C     NEWCRD = FLAG TO INDICATE WHETHER OR NOT TO PREPARE NEXT CARD     
C              IMAGE FOR TRANSLATION BY XRCARD ROUTINE.        
C     MODIDX = MODULE INDEX STORED IN OSCAR ENTRY FOR USE BY XSEM       
C              ROUTINE.        
C     LDMAP  = LENGTH OF DMAP ARRAY.        
C     ISAVDW = POINTER TO LAST DELIMITER ENCOUNTERED IN DMPCRD ARRAY,   
C              USED BY XSCNDM WHEN UNPACKING RIGID FORMAT DMAP SEQUENCE.
C     DMAP   = ARRAY CONTAINING OUTPUT FROM XRCARD ROUTINE.        
C        
C     DESCRIPTION OF VARIABLES EQUIVALENCED TO /XGPI4/ ENTRIES        
C     EQUIVALENCE (DMAP,ICF)        
C     ICF    = TEMPORARY STORAGE FOR CONTROL FILE DICTIONARY.        
C        
C     DATA     ISEQN/1/, DMPCNT/0/, ICHAR/1/, LDMAP/200/, BCDCNT/0/     
C        
      ISEQN  = 1        
      DMPCNT = 0        
      ICHAR  = 1        
      LDMAP  = 200        
      BCDCNT = 0        
C        
C     ****** /XGPI5/ *******        
C        
C     IAPP   = APPROACH CODE.        
C     START  = TYPE OF START CODE.        
C     ALTER  = DMAP NOS. OF INSTRUCTIONS TO BE ALTERED        
C     SOL    = SOLUTION CODE.        
C     SUBSET = SOLUTION SUBSET CODE.        
C     IFLAG  = FLAG FOR USE IN SUBROUTINE XLNKHD.        
C     IESTIM = POINTER TO ESTIM ENTRIES IN ICTLFL OR ZERO.        
C     ICFTOP = POINTER TO FIRST WORD IN ICTLFL ARRAY        
C     ICFPNT = POINTER TO NEXT AVAILABLE WORD IN ICTLFL ARRAY        
C     LCTLFL = LENGTH OF ICTLFL ARRAY.        
C     ICTLFL = ARRAY CONTAINING INFORMATION FROM ESTIM CONTROL CARD.    
C        
C     DATA     IESTIM/0/, ICFTOP/1/, LCTLFL/1/, IFLAG/0/        
C        
      IESTIM = 0        
      ICFTOP = 1        
      LCTLFL = 1        
      IFLAG  = 0        
C        
C     ****** /XGPI6/ *******        
C        
C     MED    = (SEE DESCRIPTION IN /XGPI1/)        
C     MEDTP  = POINTER TO FIRST WORD IN MED ARRAY.        
C     LMED   = LENGTH OF MED ARRAY.        
C     MEDPNT = POINTER TO AN ENTRY IN MED        
C     FNMTP  = POINTER TO FIRST WORD OF FILE NAME PORTION OF MED TABLE  
C     CNMTP  = POINTER TO FIRST WORD OF CARD NAME PORTION OF MED TABLE  
C     IPLUS  = PLUS CHARACTER FOR PRINTER SPACE SUPRESS        
C     DIAG14 = SKIP DMAP PRINT UNLESS RESTART (SET BY XGPI)        
C     DIAG17 = DMAP PUNCH OPTION FLAG (SET BY XGPI)        
C        
C     DATA     MEDTP/1/,  LMED/0/,  IPLUS/1H+/        
C        
      MEDTP  = 1        
      LMED   = 0        
      IPLUS  = IPLS        
C        
C     ****** /XGPI7/ *******        
C        
C     IFPNT  = POINTER TO LAST ENTRY IN FILE TABLE        
C     LFILE  = LENGTH OF FILE TABLE (IN WORDS)        
C     IFILE  = TABLE CONTAINING INFO FROM FILE DMAP INSTRUCTION        
C        
C     DATA     IFPNT/-2/,  LFILE/130/,  IFILE/130*0/        
C        
      IFPNT  = -2        
      LFILE  = 130        
      DO 20 I = 1,LFILE        
   20 IFILE(I) = 0        
C        
C     ****** /XGPI8 / *******        
C        
C     ICPDPL = (SEE /XGPI1/ FOR DESCRIPTION)        
C     ICPTOP = POINTER TO FIRST ENTRY IN ICPDPL ARRAY.        
C     ICPBOT = POINTER TO LAST  ENTRY IN ICPDPL ARRAY.        
C     LCPDPL = LENGTH OF ICPDPL ARRAY)        
C        
C     DATA     ICPTOP/0/,  ICPBOT/0/,  LCPDPL/0/        
C        
      ICPTOP = 0        
      ICPBOT = 0        
      LCPDPL = 0        
C        
C     ****** /MODDMP/ ********        
C        
      IFLG(1) = 1        
      IFLG(2) = 2        
      IFLG(3) = 0        
      IFLG(4) = 0        
      IFLG(5) = 0        
      IFLG(6) = 0        
      DO 30 I = 1,26        
   30 NMPT(I) = NAMOPT(I)        
C        
      RETURN        
      END        
