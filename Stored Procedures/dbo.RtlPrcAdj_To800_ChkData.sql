SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RtlPrcAdj_To800_ChkData] 
(
 @d_cls int,
 @p_num char(14),
 @d_line int,
 @d_gdgid int,
 @launch datetime,
 @fildate datetime,
 @ret1 int output
)
As
Begin
  declare @lastadjtime datetime,
          @lastadjnum char(14),
          @lastfildate datetime,
          @cls1 char(10),
          @cls2 char(10),
          @cls3 char(10)
  
  set @cls1=null
  set @cls2=null
  set @cls3=null
  set @ret1=1
  if @d_cls >= 4 
  begin
    set @cls3='最高售价'
    set @d_cls=@d_cls-4
  end  
  if @d_cls >= 2 
  begin
    set @cls2='最低售价'
    set @d_cls=@d_cls-2
  end  
  if @d_cls >= 1 
  begin
    set @cls1='核算售价'
    set @d_cls=@d_cls-1
  end  
  /*判断此行商品调价是否生效*/
  if @cls1 is not null
  begin
    if exists(select 1 from gdprcadj(nolock) where gdgid = @d_gdgid and cls = @cls1)
    begin
      select
        @lastadjtime = lstadjtime, @lastadjnum = prcadjnum, @lastfildate = prcadjfildate
      from gdprcadj(nolock) where gdgid = @d_gdgid and cls = @cls1
          
      if @launch is not null
      begin
        if @launch < @lastadjtime
        begin
          update rtlprcadjdtl set note = '本行不生效，调价单' 
            	+ @lastadjnum + '上同种商品已生效并在本调价单生效日期之后'
            where num = @p_num and line = @d_line
	  select @ret1 = 0
        end else
          update gdprcadj set lstadjtime = @launch, prcadjnum = @p_num, prcadjfildate = @fildate
          where gdgid = @d_gdgid and cls = @cls1
        end 
      else
      begin
        if @lastfildate is not null and (@fildate <  @lastfildate) 
        begin
            update rtlprcadjdtl set note = '本行不生效，调价单' 
            	+ @lastadjnum + '上同种商品已生效并在本调价单生效日期之后'
            where num = @p_num and line = @d_line
	  select @ret1 = 0
        end else
          update gdprcadj set lstadjtime = getdate(), prcadjnum = @p_num, prcadjfildate = @fildate
          where gdgid = @d_gdgid and cls = @cls1
      end
    end else
    begin
      if @launch is not null
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate)
        values(@d_gdgid, @cls1, @launch, @p_num, @fildate)
      else
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate)
        values(@d_gdgid, @cls1, getdate(), @p_num, @fildate)
    end        
  end
  if @cls2 is not null
  begin
    if exists(select 1 from gdprcadj(nolock) where gdgid = @d_gdgid and cls = @cls2)
    begin
      select
        @lastadjtime = lstadjtime, @lastadjnum = prcadjnum, @lastfildate = prcadjfildate
      from gdprcadj(nolock) where gdgid = @d_gdgid and cls = @cls2
          
      if @launch is not null
      begin
        if @launch < @lastadjtime
        begin
          update rtlprcadjdtl set note = '本行不生效，调价单' 
            	+ @lastadjnum + '上同种商品已生效并在本调价单生效日期之后'
            where num = @p_num and line = @d_line
	  select @ret1 = 0
        end else
          update gdprcadj set lstadjtime = @launch, prcadjnum = @p_num, prcadjfildate = @fildate
          where gdgid = @d_gdgid and cls = @cls2
        end 
      else
      begin
        if @lastfildate is not null and (@fildate <  @lastfildate) 
        begin
            update rtlprcadjdtl set note = '本行不生效，调价单' 
            	+ @lastadjnum + '上同种商品已生效并在本调价单生效日期之后'
            where num = @p_num and line = @d_line
	  select @ret1 = 0
        end else
          update gdprcadj set lstadjtime = getdate(), prcadjnum = @p_num, prcadjfildate = @fildate
          where gdgid = @d_gdgid and cls = @cls2
      end
    end else
    begin
      if @launch is not null
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate)
        values(@d_gdgid, @cls2, @launch, @p_num, @fildate)
      else
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate)
        values(@d_gdgid, @cls2, getdate(), @p_num, @fildate)
    end   
  end
  if @cls3 is not null
  begin
    if exists(select 1 from gdprcadj(nolock) where gdgid = @d_gdgid and cls = @cls3)
    begin
      select
        @lastadjtime = lstadjtime, @lastadjnum = prcadjnum, @lastfildate = prcadjfildate
      from gdprcadj(nolock) where gdgid = @d_gdgid and cls = @cls3
          
      if @launch is not null
      begin
        if @launch < @lastadjtime
        begin
          update rtlprcadjdtl set note = '本行不生效，调价单' 
            	+ @lastadjnum + '上同种商品已生效并在本调价单生效日期之后'
            where num = @p_num and line = @d_line
	  select @ret1 = 0
        end else
          update gdprcadj set lstadjtime = @launch, prcadjnum = @p_num, prcadjfildate = @fildate
          where gdgid = @d_gdgid and cls = @cls3
        end 
      else
      begin
        if @lastfildate is not null and (@fildate <  @lastfildate) 
        begin
            update rtlprcadjdtl set note = '本行不生效，调价单' 
            	+ @lastadjnum + '上同种商品已生效并在本调价单生效日期之后'
            where num = @p_num and line = @d_line
	  select @ret1 = 0
        end else
          update gdprcadj set lstadjtime = getdate(), prcadjnum = @p_num, prcadjfildate = @fildate
          where gdgid = @d_gdgid and cls = @cls3
      end
    end else
    begin
      if @launch is not null
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate)
        values(@d_gdgid, @cls3, @launch, @p_num, @fildate)
      else
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate)
        values(@d_gdgid, @cls3, getdate(), @p_num, @fildate)
    end         
  end
  return 0
End
GO
