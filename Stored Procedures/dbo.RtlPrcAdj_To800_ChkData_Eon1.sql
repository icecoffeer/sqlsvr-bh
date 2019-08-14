SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RtlPrcAdj_To800_ChkData_Eon1]
(
 @p_cls int,
 @p_num varchar(14),
 @d_line int,
 @d_gdgid int,
 @d_QpcStr varchar(15),
 @launch datetime,
 @fildate datetime,
 @msg varchar(255) output
)
With Encryption
As
Begin
  declare @lastadjtime datetime,
          @lastadjnum char(14),
          @lastfildate datetime,
          @cls1 varchar(10),
          @cls2 varchar(10),
          @cls3 varchar(10),
          @cls4 varchar(10),
          @cls5 varchar(10),
          @src int,
          @usergid int,
          @ret int


  set @cls1 = null
  set @cls2 = null
  set @cls3 = null
  set @cls4 = null
  set @cls5 = null
  set @ret = 0
  select @src = src from rtlprcadj(nolock) where num = @p_num
  select @usergid = usergid from system(nolock)
  if @p_cls & 16 = 16
    set @cls5 = '批发价'
  if @p_cls & 8 = 8
    set @cls4 = '会员价'
  if @p_cls & 4 = 4
    set @cls3 = '最高售价'
  if @p_cls & 2 = 2
    set @cls2 = '最低售价'
  if @p_cls & 1 = 1
    set @cls1 = '核算售价'

  --判断本行商品是否生效
  if (@cls1 is not null) and (@ret = 0)
    exec @ret = RtlPrcAdj_To800_Eon1_ChkGdPrcAdj @cls1,@p_num,@d_gdgid,@d_line,@launch,@fildate,@msg output
  if (@cls2 is not null) and (@ret = 0)
    exec @ret = RtlPrcAdj_To800_Eon1_ChkGdPrcAdj @cls2,@p_num,@d_gdgid,@d_line,@launch,@fildate,@msg output
  if (@cls3 is not null) and (@ret = 0)
    exec @ret = RtlPrcAdj_To800_Eon1_ChkGdPrcAdj @cls3,@p_num,@d_gdgid,@d_line,@launch,@fildate,@msg output
  if (@cls4 is not null) and (@ret = 0)
    exec @ret = RtlPrcAdj_To800_Eon1_ChkGdPrcAdj @cls4,@p_num,@d_gdgid,@d_line,@launch,@fildate,@msg output
  if (@cls5 is not null) and (@ret = 0)
    exec @ret = RtlPrcAdj_To800_Eon1_ChkGdPrcAdj @cls5,@p_num,@d_gdgid,@d_line,@launch,@fildate,@msg output

  --调价方案控制门店，不检查异地单据
  /*if (@src = 1) or (@src = @usergid)
  begin*/  --Deleted by ShenMin
    --调价方案检查
    if (@cls1 is not null) and (@ret = 0)
      exec @ret = RtlPrcAdj_To800_Eon1_ChkPrcScheme @usergid, @cls1, @p_num, @d_gdgid, @d_line, @msg output
    if (@cls2 is not null) and (@ret = 0)
      exec @ret = RtlPrcAdj_To800_Eon1_ChkPrcScheme @usergid, @cls2, @p_num, @d_gdgid, @d_line, @msg output
    if (@cls3 is not null) and (@ret = 0)
      exec @ret = RtlPrcAdj_To800_Eon1_ChkPrcScheme @usergid, @cls3, @p_num, @d_gdgid, @d_line, @msg output
    if (@cls4 is not null) and (@ret = 0)
      exec @ret = RtlPrcAdj_To800_Eon1_ChkPrcScheme @usergid, @cls4, @p_num, @d_gdgid, @d_line, @msg output
    if (@cls5 is not null) and (@ret = 0)
      exec @ret = RtlPrcAdj_To800_Eon1_ChkPrcScheme @usergid, @cls5, @p_num, @d_gdgid, @d_line, @msg output
  --end

  --价格检查
  if @ret = 0
    exec @ret = RtlPrcAdj_To800_Eon1_ChkPrc @p_cls, @p_num, @d_line, @d_gdgid, @d_QpcStr, @msg output

  --检查成功
  if @ret = 0
  begin
    if @cls1 is not null
    begin
      delete from gdprcadj where gdgid = @d_gdgid and cls = @cls1
      if @launch is not null
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate, GDQPCSTR)
          values(@d_gdgid, @cls1, @launch, @p_num, @fildate, @d_QpcStr)
      else
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate, GDQPCSTR)
          values(@d_gdgid, @cls1, getdate(), @p_num, @fildate, @d_QpcStr)
    end
    if @cls2 is not null
    begin
      delete from gdprcadj where gdgid = @d_gdgid and cls = @cls2
      if @launch is not null
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate, GDQPCSTR)
          values(@d_gdgid, @cls2, @launch, @p_num, @fildate, @d_QpcStr)
      else
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate, GDQPCSTR)
          values(@d_gdgid, @cls2, getdate(), @p_num, @fildate, @d_QpcStr)
    end
    if @cls3 is not null
    begin
      delete from gdprcadj where gdgid = @d_gdgid and cls = @cls3
      if @launch is not null
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate, GDQPCSTR)
          values(@d_gdgid, @cls3, @launch, @p_num, @fildate, @d_QpcStr)
      else
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate, GDQPCSTR)
         values(@d_gdgid, @cls3, getdate(), @p_num, @fildate, @d_QpcStr)
    end
    if @cls4 is not null
    begin
      delete from gdprcadj where gdgid = @d_gdgid and cls = @cls4
      if @launch is not null
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate, GDQPCSTR)
          values(@d_gdgid, @cls4, @launch, @p_num, @fildate, @d_QpcStr)
      else
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate, GDQPCSTR)
         values(@d_gdgid, @cls4, getdate(), @p_num, @fildate, @d_QpcStr)
    end
    if @cls5 is not null
    begin
      delete from gdprcadj where gdgid = @d_gdgid and cls = @cls5
      if @launch is not null
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate, GDQPCSTR)
          values(@d_gdgid, @cls5, @launch, @p_num, @fildate, @d_QpcStr)
      else
        insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate, GDQPCSTR)
         values(@d_gdgid, @cls5, getdate(), @p_num, @fildate, @d_QpcStr)
    end
  end
  return @ret
End
GO
