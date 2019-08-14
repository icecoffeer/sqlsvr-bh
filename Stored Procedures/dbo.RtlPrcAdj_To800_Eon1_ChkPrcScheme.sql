SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RtlPrcAdj_To800_Eon1_ChkPrcScheme]
(
  @StoreGid int,
  @p_cls varchar(10),
  @p_num varchar(14),
  @d_gdgid int,
  @d_line int,
  @msg varchar(255) output
) with encryption as
begin
  declare
    @usergid int,
    @userproperty int,
    @prcadjctrl int,
    @prcschemedtlcls varchar(10),
    @ctrmode int,
    @ret int,
  --ShenMin
    @TopMbrPrc money,
    @LowMbrPrc money,
    @MbrPrc money,
    @LaunchByStore smallint,
    @TmpStr varchar(255),
    @src int

  select @usergid = usergid, @userproperty = userproperty from system(nolock)
  select @prcadjctrl= optionvalue from hdoption(nolock)
    where moduleno = 0 and optioncaption ='PRCADJCTRL'
  select @src = src from rtlprcadj where num = @p_num

  set @ret = 0
  set @TmpStr = ''  --ShenMin

  if @prcadjctrl <> 0
  begin
    if @userproperty & 16 = 16
    --总部
    begin
      if exists (select 1 from PRCSCHEMEDTl,STOREPRCSCHEME where STOREPRCSCHEME.Code = PrcSchemeDtl.Code
        and PrcSchemeDtl.GDGID= @d_gdgid and PrcSchemeDtl.PRCCLS= @p_cls
        and StorePrcScheme.StoreGid = @usergid)
      begin
        select @ctrmode = ctrmode from PRCSCHEMEDTl(nolock),STOREPRCSCHEME(nolock)  --ShenMin
        where STOREPRCSCHEME.Code = PrcSchemeDtl.Code and PrcSchemeDtl.GDGID= @d_gdgid
        and PrcSchemeDtl.PRCCLS= @p_cls and StorePrcScheme.StoreGid = @usergid
        if @ctrmode = 0 set @ret = 1
      end
      else
        if @prcadjctrl = 1 set @ret = 1
    --ShenMin
      if @p_cls = '会员价'
        begin
          select @MbrPrc = newmbrprc from rtlprcadjdtl(nolock)
          where num = @p_num and line = @d_line and gdgid = @d_gdgid

          select @TopMbrPrc = isnull(TOPPRC, 0), @LowMbrPrc = isnull(LOWPRC, 0) from PRCSCHEMEDTl,STOREPRCSCHEME where STOREPRCSCHEME.Code = PrcSchemeDtl.Code
            and PrcSchemeDtl.GDGID= @d_gdgid and PrcSchemeDtl.PRCCLS= @p_cls
            and StorePrcScheme.StoreGid = @usergid
          if (@TopMbrPrc <> 0) and (@TopMbrPrc < @MbrPrc)
            begin
              set @ret = 1
              set @TmpStr = '新会员价不能高于调价方案中规定的上限'
            end
          if (@LowMbrPrc <> 0) and (@LowMbrPrc > @MbrPrc)
            begin
              set @ret = 1
              set @TmpStr = '新会员价不能低于调价方案中规定的下限'
            end
        end
    end
    else
    --门店
    begin
      if exists (select 1 from PRCSCHEMEDTl where GDGID= @d_gdgid and PRCCLS = @p_cls)
      begin
        select @ctrmode = ctrmode from PRCSCHEMEDTl(nolock) where GDGID= @d_gdgid and PRCCLS = @p_cls
        if @ctrmode = 0 and (@src in (1, @usergid))
          set @ret = 1
      end
      else
        if @prcadjctrl = 1 and (@src in (1, @usergid))
          set @ret = 1
    --ShenMin
      if @p_cls = '会员价'
        begin
          select @MbrPrc = newmbrprc from rtlprcadjdtl(nolock)
          where num = @p_num and line = @d_line and gdgid = @d_gdgid
          select @TopMbrPrc = isnull(TOPPRC, 0), @LowMbrPrc = isnull(LOWPRC, 0) from PRCSCHEMEDTl
          where GDGID= @d_gdgid and PRCCLS = @p_cls
          if (@TopMbrPrc <> 0) and (@TopMbrPrc < @MbrPrc)
            begin
              set @ret = 1
              set @TmpStr = '新会员价不能高于调价方案中规定的上限'
            end
          if (@LowMbrPrc <> 0) and (@LowMbrPrc > @MbrPrc)
            begin
              set @ret = 1
              set @TmpStr = '新会员价不能低于调价方案中规定的下限'
            end
        end
      select @LaunchByStore = LaunchByStore  from PRCSCHEMEDTl
      where GDGID= @d_gdgid and PRCCLS = @p_cls
      if @LaunchByStore = 1 and (@src not in (1, @usergid))
        begin
          set @ret = 1
          set @TmpStr = @TmpStr + '调价方案设置为仅允许门店调价生效，本行来自总部，不生效'
        end
    end
  end
  if @ret = 1
    set @msg = '该商品' + @p_cls + '被限制调价'
    if @TmpStr <> ''
      set @msg = @TmpStr
  return @ret
end
GO
