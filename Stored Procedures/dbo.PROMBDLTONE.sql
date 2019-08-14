SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROMBDLTONE]
(
 @piNum  varchar(14), 
 @piCls  varchar(10),
 @piGDGid int,
 @piLine int, 
 @piOper varchar(30),
 @poErrMsg varchar(255) output
)
as 
begin
  ---更新表中的状态
  update PromBGoods set IsDlt = 1
  where Num = @piNum and GDGid = @piGDGid and Line = @piLine
  if @@error <> 0 
  begin
    set @poErrMsg = '终止商品出错'
    return(1)
  end
  
  --从Prices 中删除  
  delete from Prices 
  where BillNum = @piNum and Cls = @piCls and BillLine = @piLine and GDGid = @piGDGid
  if @@Error <> 0 
  begin
    set @poErrMsg = '更新Prices 出错'
    return(1)
  end     
  insert into PromBLog(NUM, STAT, FILLER, FILDATE, NOTE)
  values(@piNum, 100, @piOper, GetDate(), '终止商品 ' + convert(varchar(20), @piGDGid))

  return(0)           
end                   
GO
