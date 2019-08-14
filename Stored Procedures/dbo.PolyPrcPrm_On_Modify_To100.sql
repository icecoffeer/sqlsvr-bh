SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyPrcPrm_On_Modify_To100](
  @Num char(14),
  @ToStat int,
  @Oper varchar(30),
  @Msg varchar(255) output
)
as
begin
  declare
    @return_status smallint,
    @OcrType int,
    @OcrTime datetime,
    @Present datetime,
    @Stat int
  set @Present = GetDate()
  select @Stat = STAT from POLYPRCPRM(nolock) where NUM = @Num
  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能审核。'
    return 1
  end
  update POLYPRCPRM
    set STAT = @ToStat, LSTUPDOPER = @Oper, LSTUPDTIME = @Present,
      CHECKER = @Oper, CHKDATE = @Present
    where NUM = @Num
  exec PolyPrcPrm_AddLog @Num, @ToStat, '审核', @Oper

  select @OcrType = OCRTYPE, @OcrTime = OCRTIME from POLYPRCPRM(nolock)
    where NUM = @Num
  if (@OcrType = 0) or (@OcrType = 1 and @OcrTime <= @Present)
  begin
    exec @return_status = PolyPrcPrm_On_Modify_To800 @Num, 800, @Oper, @Msg output
    if @return_status <> 0 return @return_status
  end
  return 0
end
GO
