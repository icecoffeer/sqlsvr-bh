SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MXFDMD_CHKTO401]
(
  @Num varchar(14),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin

  declare @vRet int,
          @Stat int,  @SrcStat int,
          @Line int, @GdName varchar(50),
          @OptAutoSendBill int
  exec OptReadInt 0, 'PS3_AutoSendBill', 0, @OptAutoSendBill output
  select @Stat = STAT from MXFDMD(nolock) where NUM = @Num

  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能请求总部批准.'
    return(1)
  end

  select @Line = M.LINE, @GdName = RTrim(G.NAME) + '[' + RTrim(G.CODE) + ']'
  from MXFDMDDTL M(nolock), GOODS G(nolock)
  where M.NUM = @Num
    and M.GDGID = G.GID
    and G.SALE = 3

  if @Line is not null
  begin
    set @Msg = '第 ' + convert(varchar(5), @Line) + ' 行的商品 ' + @GdName + '是联销商品，不允许请求总部批准'
    return(1)
  end

  update MXFDMD
  set STAT = @ToStat ,  DMDDATE = GETDATE(), DMDOPER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num

  exec MXFDMD_ADD_LOG @Num, @ToStat, '请求总部批准', @Oper;
  --自动发送
  if @OptAutoSendBill = 1
  begin
    exec @vRet = MXFDMD_Snd @Num, @Oper, @Msg output
    if @vRet <> 0 return @vRet
  end
  return 0
end
GO
