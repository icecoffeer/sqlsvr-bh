SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VDRBEPADJ_CHECK] (
  @num varchar(14),
  @oper varchar(30),
  @msg varchar(255) output
) as
begin
  declare
    @beginDate datetime,
    @endDate datetime,
    @dept varchar(10),
    @deptName varchar(40),
    @strGid int,
    @strCode varchar(10),
    @strName varchar(50),
    @vdrGid int,
    @vdrCode varchar(10),
    @vdrName varchar(100) 
  if not exists(select 1 from VENDOR V(nolock), VDRBEPADJ VD(nolock) where V.GID = VD.VDRGID and VD.NUM = @num)
  begin
    set @msg = '供应商不存在，无法审核'
    return 1
  end 
  if not exists(select 1 from DEPT D(nolock), VDRBEPADJ VD(nolock) where D.CODE = VD.DEPT and VD.NUM = @num)
  begin
    set @msg = '部门不存在，无法审核'
    return 1
  end     
  declare vdrbepadjcursor cursor for
    select BEGINDATE, ENDDATE, DEPT, STOREGID, VDRGID from VDRBEP
  open vdrbepadjcursor
  fetch next from vdrbepadjcursor into
    @beginDate, @endDate, @dept, @strGid, @vdrGid
  while @@fetch_status = 0
  begin
  	if exists (select 1 from VDRBEPADJ where @beginDate >= BEGINDATE and @beginDate < ENDDATE and NUM = @num and DEPT = @dept
  	and VDRGID = @vdrGid)
  	begin
  	  select @vdrCode = CODE, @vdrName = NAME from VENDOR(nolock) where GID = @vdrGid
  	  select @deptName = NAME from DEPT(nolock) where CODE = @dept
  	  select @strCode = CODE, @strName = NAME from STORE(nolock) where GID = @strGid
  		set @msg = '生效日期冲突，不能审核。  '
  		  + '供应商：[' + rtrim(@vdrCode) + ']' + rtrim(@vdrName) + ', '
  		  + '部门：[' + rtrim(@dept) + ']' + rtrim(@deptName) + ', '
  		 -- + '门店：[' + rtrim(@strCode) + ']' + rtrim(@strName) + '   '
  		  + '在当前值表中已存在从' + convert(varchar(30), @beginDate, 102) + '到'
        + convert(varchar(30), @endDate, 102) +'的保底计划！'
      close vdrbepadjcursor
      deallocate vdrbepadjcursor
      return 1
  	end
  	if exists (select 1 from VDRBEPADJ where @endDate <= ENDDATE and @endDate > BEGINDATE and NUM = @num and DEPT = @dept
  	and VDRGID = @vdrGid)
  	begin
  	  select @vdrCode = CODE, @vdrName = NAME from VENDOR(nolock) where GID = @vdrGid
  	  select @deptName = NAME from DEPT(nolock) where CODE = @dept
  	  select @strCode = CODE, @strName = NAME from STORE(nolock) where GID = @strGid
  		set @msg = '生效日期冲突，不能审核。  '
  		  + '供应商：[' + rtrim(@vdrCode) + ']' + rtrim(@vdrName) + ', '
  		  + '部门：[' + rtrim(@dept) + ']' + rtrim(@deptName) + ', '
  		 -- + '门店：[' + rtrim(@strCode) + ']' + rtrim(@strName) + '   '
  		  + '在当前值表中已存在从' + convert(varchar(30), @beginDate, 102) + '到'
        + convert(varchar(30), @endDate, 102) +'的保底计划！'
      close vdrbepadjcursor
      deallocate vdrbepadjcursor
      return 1
  	end
  	if exists (select 1 from VDRBEPADJ where @endDate >= ENDDATE and @beginDate <= BEGINDATE and NUM = @num and DEPT = @dept
  	and VDRGID = @vdrGid)
  	begin
  	  select @vdrCode = CODE, @vdrName = NAME from VENDOR(nolock) where GID = @vdrGid
  	  select @deptName = NAME from DEPT(nolock) where CODE = @dept
  	  select @strCode = CODE, @strName = NAME from STORE(nolock) where GID = @strGid
  		set @msg = '生效日期冲突，不能审核。  '
  		  + '供应商：[' + rtrim(@vdrCode) + ']' + rtrim(@vdrName) + ', '
  		  + '部门：[' + rtrim(@dept) + ']' + rtrim(@deptName) + ', '
  		 -- + '门店：[' + rtrim(@strCode) + ']' + rtrim(@strName) + '   '
  		  + '在当前值表中已存在从' + convert(varchar(30), @beginDate, 102) + '到'
        + convert(varchar(30), @endDate, 102) +'的保底计划！'
      close vdrbepadjcursor
      deallocate vdrbepadjcursor
      return 1
  	end
  	fetch next from vdrbepadjcursor into
      @beginDate, @endDate, @dept, @strGid, @vdrGid
  end 
  close vdrbepadjcursor
  deallocate vdrbepadjcursor

  update VDRBEPADJ set STAT = 100, CHECKER = @oper, CHKDATE = getdate(), LSTUPDTIME = getdate(), LSTUPDOPER = @oper 
    where NUM = @num;
  exec VDRBEPADJ_ADD_LOG @Num, 100, '审核', @Oper; 
  return 0
end
GO
