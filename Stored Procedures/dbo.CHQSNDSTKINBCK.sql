SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CHQSNDSTKINBCK](
	@NUM VARCHAR(14),
	@CLS VARCHAR(10),
	@OPERGID INT,
	@MSG VARCHAR(255) OUTPUT
) as
begin
  declare @GROUPID INT,     @NTYPE SMALLINT,    @NNOTE varchar(100),
          @EXTIME DATETIME, @RHQUUID CHAR(32),  @NSTAT SMALLINT
  --exec OPTREADINT 0, '...', 0, @optvalue output
  if not exists(select 1 from stkinbck where num = @num and cls = @cls and STAT = 6)
  begin
    set @msg = '不能定位已经复核的进货退货单'+@num+'-'+@cls
    return 1
  end  
  exec @GROUPID = SeqNextValue 'CHQBASIC'
  set @RHQUUID = '1'
  set @NTYPE = 0
  set @NNOTE = ''
  set @NSTAT = 0
  set @EXTIME = Getdate()
  insert into CQNSTKINBCK(GROUPID, RHQUUID, NTYPE, NSTAT, NNOTE, EXTIME, 
      CLS, NUM, SETTLENO, VENDOR, VENDORNUM, BILLTO, OCRDATE, 
      TOTAL, TAX, NOTE, FILDATE, FILLER, CHECKER, STAT, MODNUM, 
      PSR, RECCNT, SRC, SRCNUM, SNDTIME, PRNTIME, FINISHED, 
      CHKDATE, WRH, PRECHECKER, PRECHKDATE, GEN, GENBILL, 
      GENCLS, GENNUM)
    select @GROUPID, @RHQUUID, @NTYPE, @NSTAT, @NNOTE, @EXTIME, 
      CLS, NUM, SETTLENO, VENDOR, VENDORNUM, BILLTO, OCRDATE, 
      TOTAL, TAX, NOTE, FILDATE, FILLER, CHECKER, STAT, MODNUM, 
      PSR, RECCNT, SRC, SRCNUM, SNDTIME, PRNTIME, FINISHED, 
      CHKDATE, WRH, PRECHECKER, PRECHKDATE, GEN, GENBILL, 
      GENCLS, GENNUM
    from STKINBCK(nolock)
    where NUM = @NUM AND CLS = @CLS
    
  insert into CQNSTKINBCKDTL(GROUPID, RHQUUID, NTYPE, NSTAT, NNOTE, EXTIME,
      CLS, SETTLENO, NUM, LINE, GDGID, CASES, QTY, PRICE, TOTAL, 
      TAX, VALIDDATE, WRH, INPRC, RTLPRC, PAYQTY, PAYAMT, BNUM, 
      SUBWRH, NOTE, COST)
    select @GROUPID, @RHQUUID, @NTYPE, @NSTAT, @NNOTE, @EXTIME, 
      CLS, SETTLENO, NUM, LINE, GDGID, CASES, QTY, PRICE, TOTAL, 
      TAX, VALIDDATE, WRH, INPRC, RTLPRC, PAYQTY, PAYAMT, BNUM, 
      SUBWRH, NOTE, COST 
    from STKINBCKDTL(nolock)
    where NUM = @NUM AND CLS = @CLS
    
  declare @vdrgid int
  select @vdrgid = vendor from stkinbck (nolock)
    where NUM = @NUM AND CLS = @CLS 
  if exists(select 1 from vendorh (nolock) where gid = @vdrgid and upay = 1)
    update stkinbck set finished = 1
    where NUM = @NUM AND CLS = @CLS 
    
end;
GO
