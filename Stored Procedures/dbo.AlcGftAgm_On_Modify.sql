SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[AlcGftAgm_On_Modify]
(
  @piNum          char(14),
  @piToStat       int,
  @piOper         varchar(40),
  @poErrmsg       varchar(255) output
)
with Encryption
as
begin
  declare
    @vRet int,
    @stat int
  set @vRet = 0
  select @stat = stat from alcgftagm(nolock) where num = @piNum
  if @piToStat = 100
  begin
    if @stat <> 0 
    begin
      set @poErrmsg = '不是未审核协议，不能审核！'
      set @vRet = 1
      return(@vRet)
    end
    exec @vRet = AlcGftAgm_StatTo100 @piNum, @piToStat, @piOper, @poErrmsg output 
    if @vRet > 0 return(@vRet)
  end
  if @piToStat = 110 
  begin
    if @stat <> 100
    begin
      set @poErrmsg = '不是已审核协议，不能作废！'
      set @vRet = 2
      return (@vRet)
    end
    exec @vRet = AlcGftAgm_StatTo110 @piNum, @piToStat, @piOper, @poErrmsg output
    if @vRet > 0 return (@vRet)
  end  
  update AlcGftAgm set LstModifier = @piOper, LstUpdTime = getdate() where num = @piNum
  return @vRet 
end
GO
