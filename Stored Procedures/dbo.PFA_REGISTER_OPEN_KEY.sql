SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_OPEN_KEY] (
  @piKey varchar(500),              --指定的键
  @piCanCreate int = 0              --若不存在是否创建，0-否；1-是
) as                                --返回值，0-成功；其它-失败
begin
  declare @sNewKey varchar(500), @nRet int, @nCnt int
  
  if @piKey is null or rtrim(@piKey) = '' return -1
  exec PFA_REGISTER_TO_ABSKEY @piKey, @sNewKey output
  --检查键是否存在
  exec @nRet = PFA_REGISTER_KEY_EXISTS @sNewKey
  if @nRet = 0
  begin
    if @piCanCreate = 0 return 0
    exec PFA_REGISTER_FORCE_KEY @sNewKey
  end
  --修改栈顶
  select @nCnt = count(*) from TMP_PFA_REGISTER_STACK
    where SPID = @@spid
  update TMP_PFA_REGISTER_STACK set FKEY = @sNewKey
    where SPID = @@spid and ITEMNO = @nCnt - 1
  return 0
end
GO
