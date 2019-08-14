SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[StkoutChk_GenDspCheck](
  @dsp_num char(10)
)
With Encryption As
begin
  declare
    @total money,
    @reccnt int
  /* 2000-10-12 */
  select @total=sum(saletotal), @reccnt=count(1) from dspdtl where num = @dsp_num
  /* 2000-10-27 */
  if @reccnt=0
    delete from dsp where num=@dsp_num
  else
    update dsp set total=@total, reccnt=@reccnt where num=@dsp_num
  return(0)
end
GO
