SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[StkOutChk_GenDspMst](
  @cls char(10),
  @num char(10),
  @wrh int,
  @total money,
  @reccnt int,
  @filler int,
  @slr int,
  @dsp_num char(10) output,
  @msg varchar(100) output
)
With Encryption As
begin
  declare
    @store int,
    @cur_settleno int,
    @max_dsp_num char(10)

  select @store = usergid from system
  select @cur_settleno = max(NO) from MONTHSETTLE
  if (@wrh is null) or (exists (select * from stkoutdtl(nolock) where cls = @cls and num = @num and
    ((wrh <> @wrh) or (wrh is null))))
  begin
    set @msg = '单据头和明细的仓位必须一致.'
    return(1)
  end
  select @dsp_num = null
  select @max_dsp_num = max(num) from dsp
  if @max_dsp_num is null select @dsp_num = '0000000001'
  else execute nextbn @max_dsp_num, @dsp_num output
  insert into DSP (
    NUM, WRH, INVNUM, CREATETIME, TOTAL, RECCNT, FILLER, OPENER,
    LSTDSPTIME, LSTDSPEMP, CLS, POSNOCLS, FLOWNO, NOTE, SETTLENO,
    /* 2000-05-11 */ SRC)
    /* 2000-2-21 DSPMODE, BUYERNAME, TEL, ADDR, NEARBY, DSPDATE ) */
  values (@dsp_num, @wrh, @num, getdate(), @total, @reccnt, @filler, @slr,
    null, null, 'STKOUT', @cls, @num, null, @cur_settleno,
    /* 2000-05-11 */ @store)

  return (0)
end
GO
