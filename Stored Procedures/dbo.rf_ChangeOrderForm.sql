SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[rf_ChangeOrderForm]
  @strOrdNum  char(10),
  @intInUse smallint,
  @strUserCode  varchar(10),           --提交人代码
  @strErrMsg  varchar(255)  output     --错误信息
as
begin
  declare
    @count int,
    @intEmpGid int;

  select @intEmpGid = GID
  from EMPLOYEE(nolock)
  where CODE = @strUserCode;
  if @intEmpGid is null
  begin
    select @strErrMsg = '员工 ' + @strUserCode + ' 不存在';
    return 2;
  end;

  if @intInUse = 1
  begin
    select @count = count(1) from RFEMPLOCKORD where ORDNUM = @strOrdNum;
    if @count > 0
    begin
      select @strErrMsg = '定单已被锁定, 不能再次锁定';
      return 3;
    end;
    insert into RFEMPLOCKORD(ORDNUM, EMPGID)
    values(@strOrdNum, @intEmpGid);
  end;

  if @intInUse = 0
  begin
    select @count = count(1)
    from RFEMPLOCKORD(nolock)
    where ORDNUM = @strOrdNum and EMPGID = @intEmpGid;
    if @count = 0
    begin
      select @strErrMsg = '未对 ' + @strOrdNum + ' 号定单进行锁定操作，不能解锁该定单';
      return 1;
    end;
    delete from RFEMPLOCKORD
    where ORDNUM = @strOrdNum and EMPGID = @intEmpGid;
  end;

  update ORDDTL
  set INUSE = @intInUse
  where NUM = @strOrdNum;
  return 0;
end;
GO
