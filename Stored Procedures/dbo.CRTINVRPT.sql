SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
cREATE procedure [dbo].[CRTINVRPT] (
  @store int,
  @settleno int,
  @date datetime,
  @wrh int,
  @gdgid int
) with encryption as
begin
  if not exists ( select * from INVDRPT
  where ASETTLENO = @settleno and ADATE = @date
  and BGDGID = @gdgid and BWRH = @wrh and ASTORE = @store) begin
    insert into INVDRPT (ASETTLENO, ADATE, BGDGID, BWRH, ASTORE,
      FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC, LSTUPDTIME)
    select @settleno, @date, @gdgid, @wrh, @store,
      INPRC, RTLPRC, DXPRC, PAYRATE, INVPRC, getdate()
      from GOODSH
      where GID = @gdgid
  end

  if not exists ( select * from INVMRPT
  where ASETTLENO = @settleno
  and BGDGID = @gdgid and BWRH = @wrh and ASTORE = @store) begin
    insert into INVMRPT (ASETTLENO, BGDGID, BWRH, ASTORE,
      FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC)
    select @settleno, @gdgid, @wrh, @store,
      INPRC, RTLPRC, DXPRC, PAYRATE, INVPRC
      from GOODSH
      where GID = @gdgid
  end

  declare @yno int
  select @yno = YNO from V_YM where MNO = @settleno

  if not exists ( select * from INVYRPT
  where ASETTLENO = @yno
  and BGDGID = @gdgid and BWRH = @wrh and ASTORE = @store) begin
    insert into INVYRPT (ASETTLENO, BGDGID, BWRH, ASTORE,
      FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC)
    select @yno, @gdgid, @wrh, @store,
      INPRC, RTLPRC, DXPRC, PAYRATE, INVPRC
      from GOODSH
      where GID = @gdgid
  end
end
GO
