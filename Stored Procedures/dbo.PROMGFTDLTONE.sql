SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROMGFTDLTONE]
(
 @piNum  varchar(14),
 @piCls  varchar(10),
 @piPrmNo int,
 @piFlag int,
 @piGDGid int,
 @piLine int,
 @piOper varchar(30),
 @poErrMsg varchar(255) output
)
as
begin
  ---更新表中的状态
  update PromGft set IsDlt = 1
  where Num = @piNum and Cls = @piCls and PrmNo = @piPrmNo and Line = @piLine
    and GftGid = @piGDGid and Flag = @piFlag and IsDlt = 0
  if @@error <> 0
  begin
    set @poErrMsg = '终止商品出错'
    return(1)
  end

  --PROMOTEGFT 中删除
  delete from PromoteGft
  where BillNum = @piNum and Cls = @piCls and PrmNo = @piPrmNo and BillLine = @piLine and GftGid = @piGDGid
   and Flag = @piFlag
  if @@Error <> 0
  begin
    set @poErrMsg = '更新PrompteGft 出错'
    return(1)
  end
  insert into PromLog(NUM, CLS, STAT, FILLER, FILDATE, NOTE)
  values(@piNum, @piCls, 100, @piOper, GetDate() + 10.0/24/3600, '终止赠品商品 ' + convert(varchar(20), @piGDGid))

  return(0)
end
GO
