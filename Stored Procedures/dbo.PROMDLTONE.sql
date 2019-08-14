SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROMDLTONE]
(
 @piNum  varchar(14),
 @piCls  varchar(10),
 @piGDGid int,
 @piLine int,
 @piFlag int,
 @piOper varchar(30),
 @poErrMsg varchar(255) output
)
as
begin
  if @piCls = '捆绑' and @piFlag = 1
  begin
    set @poErrMsg = '捆绑促销的固定商品不能进行单个商品终止操作'
    return(1)
  end
  if @piCls = '组合价' and @piFlag = 1
  begin
    set @poErrMsg = '组合价促销的固定商品不能进行单个商品终止操作'
    return(1)
  end
  ---更新表中的状态
  if @piCls = '数量'
  begin
    update PrmGradeQGOODS set IsDlt = 1
    where Num = @piNum and Cls = @piCls and GDGid = @piGDGid and Line = @piLine
    if @@error <> 0
    begin
      set @poErrMsg = '终止商品出错'
      return(1)
    end;
    update PRMGRADEQ set LSTUPDOPER = @piOper, LSTUPDTIME = getdate()
    where Num = @PiNum and CLS = @PiCls;
    if @@error <> 0
    begin
      set @poErrMsg = '终止商品出错'
      return(1)
    end;
  end;
  ---更新表中的状态
  else if @piCls = '组合价'
  begin
    update PROMFPRCGOODS set IsDlt = 1
    where Num = @piNum and Cls = @piCls and GDGid = @piGDGid and Line = @piLine
    if @@error <> 0
    begin
      set @poErrMsg = '终止商品出错'
      return(1)
    end;
    update PROMFPRC set LSTUPDOPER = @piOper, LSTUPDTIME = getdate()
    where Num = @PiNum and CLS = @PiCls;
    if @@error <> 0
    begin
      set @poErrMsg = '终止商品出错'
      return(1)
    end;
  end;
  else begin
    update PromGoods set IsDlt = 1
    where Num = @piNum and Cls = @piCls and GDGid = @piGDGid and Flag = @piFlag and Line = @piLine
    if @@error <> 0
    begin
      set @poErrMsg = '终止商品出错'
      return(1)
    end
  end;

  --从Promote 中删除
  delete from Promote
  where BillNum = @piNum and Cls = @piCls and BillLine = @piLine and GDGid = @piGDGid
   and Flag = @piFlag
  if @@Error <> 0
  begin
    set @poErrMsg = '更新Promote 出错'
    return(1)
  end
    --从PromoteQty 中删除
  delete from promoteqty
  where BillNum = @piNum and Cls = @piCls and GDGid = @piGDGid and Flag = @piFlag
  if @@Error <> 0
  begin
    set @poErrMsg = '更新PromoteQty 出错'
    return(1)
  end
  insert into PromLog(NUM, CLS, STAT, FILLER, FILDATE, NOTE)
  values(@piNum, @piCls, 100, @piOper, GetDate(), '终止商品 ' + convert(varchar(20), @piGDGid))

  return(0)
end
GO
