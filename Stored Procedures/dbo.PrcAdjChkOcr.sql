SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PrcAdjChkOcr] (
	@p_cls	char(10),
	@p_num	char(10),
	@d_line		int,
	@d_gdgid	int,
	@d_gdQpcStr     char(15),
	@launch	datetime,
	@fildate datetime,
	@canoccur int	output
)
with encryption as
begin
  declare @lastadjtime datetime,
          @lastadjnum char(10),
          @lastfildate datetime,
          @usergid int,
          @userproperty int,
          @src int,
          @prcadjctrl int,
          @ctrmode int,
          @rtlprc money,
          @lwtprc money,
          @topprc money,
          @ret int

  select @usergid = usergid, @userproperty = userproperty from system
  select @src = src from prcadj where cls = @p_cls and num = @p_num
  select @prcadjctrl= optionvalue from hdoption
    where moduleno = 0 and optioncaption ='PRCADJCTRL'
  select @canoccur = 1
  set @ret = 0
  /*判断此行商品调价是否生效*/
  if exists(select 1 from gdprcadj(nolock) where gdgid = @d_gdgid and cls = @p_cls and GDQPCSTR = @d_gdQpcStr)
  begin
    select
      @lastadjtime = lstadjtime, @lastadjnum = prcadjnum, @lastfildate = prcadjfildate
    from gdprcadj(nolock) where gdgid = @d_gdgid and cls = @p_cls and GDQPCSTR = @d_gdQpcStr

    if @launch is not null
    begin
      if @launch < @lastadjtime
      begin
        if @p_cls = '量贩价'
          update prcadjdtl set note = '本行不生效，调价单'
          	+ @lastadjnum + '上同种商品已生效并在本调价单生效日期之后'
          where cls = @p_cls and num = @p_num and gdgid = @d_gdgid and QPCSTR = @d_gdQpcStr
        else
          update prcadjdtl set note = '本行不生效，调价单'
          	+ @lastadjnum + '上同种商品已生效并在本调价单生效日期之后'
          where cls = @p_cls and num = @p_num and line = @d_line
          select @canoccur = 0
      end
    end
    else
    begin
      if @lastfildate is not null and (@fildate <  @lastfildate)
      begin
        if @p_cls = '量贩价'
          update prcadjdtl set note = '本行不生效，调价单'
          	+ @lastadjnum + '上同种商品已生效并在本调价单生效日期之后'
          where cls = @p_cls and num = @p_num and gdgid = @d_gdgid and QPCSTR = @d_gdQpcStr
        else
          update prcadjdtl set note = '本行不生效，调价单'
          	+ @lastadjnum + '上同种商品已生效并在本调价单生效日期之后'
          where cls = @p_cls and num = @p_num and line = @d_line
	        select @canoccur = 0
      end
    end
  end
  --增加对调价方案的检查
  declare --2006.5.29, ShenMin, Q6676
    @LaunchByStore smallint,
    @tmpStr varchar(255)
  if (@prcadjctrl <> 0) --and ((@src = 1) or (@src = @usergid))  Deleted by ShenMin
  begin
    if @userproperty & 16 = 16
    begin
      if exists (select 1 from PRCSCHEMEDTl,STOREPRCSCHEME where STOREPRCSCHEME.Code = PrcSchemeDtl.Code
        and PrcSchemeDtl.GDGID= @d_gdgid and PrcSchemeDtl.PRCCLS= @p_cls
        and StorePrcScheme.StoreGid = @usergid)
      begin
        select @ctrmode = ctrmode from PRCSCHEMEDTl,STOREPRCSCHEME
        where STOREPRCSCHEME.Code = PrcSchemeDtl.Code and PrcSchemeDtl.GDGID= @d_gdgid
        and PrcSchemeDtl.PRCCLS= @p_cls and StorePrcScheme.StoreGid = @usergid
        if @ctrmode = 0 set @canoccur = 0
      end
      else
        if @prcadjctrl = 1 set @canoccur = 0
    end
    else
    begin
      if exists (select 1 from PRCSCHEMEDTl where GDGID= @d_gdgid and PRCCLS = @p_Cls)
      begin
        select @ctrmode = ctrmode, @LaunchByStore = LaunchByStore from PRCSCHEMEDTl where GDGID= @d_gdgid and PRCCLS = @p_Cls
        if @ctrmode = 0 and (@src in (1, @usergid))
          set @canoccur = 0
        if (@LaunchByStore = 1) and (@src not in (1, @usergid))
          begin
            set @canoccur = 0
            set @TmpStr = '调价方案设置为仅允许门店调价生效，本行来自总部，不生效'
          end
      end
      else
        if @prcadjctrl = 1 and (@src in (1, @usergid))
          set @canoccur = 0
    end
    if @canoccur = 0
      update prcadjdtl set note = '本行不生效,该商品在调价方案中被限制调价'
        where cls = @p_cls and num = @p_num and line = @d_line
      --2006.5.29, ShenMin, Q6676
      if not @TmpStr = ''
        update prcadjdtl set note = note + @TmpStr
        where cls = @p_cls and num = @p_num and line = @d_line
  end

  --检查价格逻辑
  if @p_cls ='最低售价'
  begin
    select @lwtprc = newprc from prcadjdtl(nolock)
      where cls = @p_cls and num = @p_num and line = @d_line and gdgid = @d_gdgid
    select @topprc = isnull(qpctoprtlprc,900000000000000),@rtlprc = qpcrtlprc from V_QPCGOODS(nolock)
      where gid = @d_gdgid and QpcQpcStr = @d_gdQpcStr
    if @lwtprc > @rtlprc
    begin
      update prcadjdtl set note = '最低售价不能高于核算售价'
        where cls = @p_cls and num = @p_num and line = @d_line
      set @canoccur = 0
      set @ret = 4
    end
  end
  if @p_cls ='核算售价'
  begin
    select @rtlprc = newprc from prcadjdtl(nolock)
      where cls = @p_cls and num = @p_num and line= @d_line and gdgid= @d_gdgid
    select @lwtprc = isnull(Qpclwtrtlprc,-900000000000000),
      @topprc=isnull(Qpctoprtlprc,900000000000000) from V_QPCGOODS(nolock)
      where gid = @d_gdgid and QpcQpcStr = @d_gdQpcStr
    if @rtlprc < @lwtprc
    begin
      update prcadjdtl set note = '核算售价不能低于最低售价'
        where cls = @p_cls and num = @p_num and line = @d_line
      set @canoccur = 0
      set @ret = 5
    end
    if @rtlprc > @topprc
    begin
      update prcadjdtl set note = '核算售价不能高于最高售价'
        where cls = @p_cls and num = @p_num and line = @d_line
      set @canoccur = 0
      set @ret = 6
    end
  end
 --2006.5.29, ShenMin, Q6676
  if @p_cls ='会员价'
  begin
    DECLARE
      @TopMbrPrc MONEY,
      @LowMbrPrc MONEY,
      @MbrPrc MONEY
    if @userproperty & 16 = 16
      begin
        select @MbrPrc = newprc from prcadjdtl(nolock)
          where cls = @p_cls and num = @p_num and line= @d_line and gdgid= @d_gdgid
          select @TopMbrPrc = isnull(TOPPRC, 0), @LowMbrPrc = isnull(LOWPRC, 0) from PRCSCHEMEDTl,STOREPRCSCHEME where STOREPRCSCHEME.Code = PrcSchemeDtl.Code
            and PrcSchemeDtl.GDGID= @d_gdgid and PrcSchemeDtl.PRCCLS= @p_cls
            and StorePrcScheme.StoreGid = @usergid
          if (@TopMbrPrc <> 0) and (@TopMbrPrc < @MbrPrc)
            begin
              update prcadjdtl set note = '新会员价不能高于调价方案中规定的上限'
              where cls = @p_cls and num = @p_num and line = @d_line
              set @canoccur = 0
              set @ret = 7
            end
          if (@LowMbrPrc <> 0) and (@LowMbrPrc > @MbrPrc)
            begin
              update prcadjdtl set note = '新会员价不能低于调价方案中规定的下限'
              where cls = @p_cls and num = @p_num and line = @d_line
              set @canoccur = 0
              set @ret = 8
            end
      end
    else
      begin
        select @MbrPrc = newprc from prcadjdtl(nolock)
          where cls = @p_cls and num = @p_num and line= @d_line and gdgid= @d_gdgid
          select @TopMbrPrc = isnull(TOPPRC, 0), @LowMbrPrc = isnull(LOWPRC, 0) from PRCSCHEMEDTl where GDGID= @d_gdgid and PRCCLS = @p_Cls
          if (@TopMbrPrc <> 0) and (@TopMbrPrc < @MbrPrc)
            begin
              update prcadjdtl set note = '新会员价不能高于调价方案中规定的上限'
              where cls = @p_cls and num = @p_num and line = @d_line
              set @canoccur = 0
              set @ret = 7
            end
          if (@LowMbrPrc <> 0) and (@LowMbrPrc > @MbrPrc)
            begin
              update prcadjdtl set note = '新会员价不能低于调价方案中规定的下限'
              where cls = @p_cls and num = @p_num and line = @d_line
              set @canoccur = 0
              set @ret = 8
            end
      end
  end
  --允许生效的商品做记录
  if @canoccur = 1
  begin
    delete from gdprcadj where gdgid = @d_gdgid and cls = @p_cls and GDQPCSTR = @d_gdQpcStr
    if @launch is not null
    begin
      insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate, GDQPCSTR)
      values(@d_gdgid, @p_cls, @launch, @p_num, @fildate, @d_gdQpcStr)
      insert into PRCADJDTLHST(gdgid, cls, line, lstadjtime, prcadjnum, prcadjfildate, GDQPCSTR, oldprc, newprc)
      select @d_gdgid, @p_cls, @d_line, @launch, @p_num, @fildate, @d_gdQpcStr, oldprc, newprc 
      from prcadjdtl
         where cls = @p_cls and num = @p_num and line = @d_line
    end else
    begin
      insert into gdprcadj(gdgid, cls, lstadjtime, prcadjnum, prcadjfildate, GDQPCSTR)
      values(@d_gdgid, @p_cls, getdate(), @p_num, @fildate, @d_gdQpcStr)
      insert into PRCADJDTLHST(gdgid, cls, line, lstadjtime, prcadjnum, prcadjfildate, GDQPCSTR, oldprc, newprc)
      select @d_gdgid, @p_cls, @d_line, getdate(), @p_num, @fildate, @d_gdQpcStr, oldprc, newprc 
      from prcadjdtl
         where cls = @p_cls and num = @p_num and line = @d_line
    end
  end
  return (@ret)
end
GO
