SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_STORE_ON_ADDNEW] (
  @piGid int,           --店GID
  @piOper varchar(40),  --操作人
  @poErrMsg varchar(255) output -- 出错信息
) with encryption as
begin    
  declare
    @on_addnew_sp varchar(500),
    @ret int
  exec PFA_REGISTER_READ_STR 'PS3\STORE\ON_ADDNEW\ON_ADDNEW_SP', @on_addnew_sp output
  if @on_addnew_sp <> ''
  --执行注册存储过程
  begin
    exec @ret = PS3_STORE_GENSQL @on_addnew_sp, @piGid, @piOper, @poErrMsg output
    return @ret
  end
  else
    return 0      
end
GO
