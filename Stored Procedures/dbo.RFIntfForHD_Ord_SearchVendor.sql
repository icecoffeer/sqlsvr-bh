SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Ord_SearchVendor](
  @piType int, --1：定货，2：叫货申请
  @piWrhGid int,
  @piGdGid int,
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @vSingleVdr int,
    @vUserGid int,
    @vZBGid int,
    @vAlc varchar(10),
    @vToday datetime,
    @optUseVdrAgmt int

  --获取一般变量的值。

  set @vToday = convert(datetime, convert(varchar, getdate(), 102))

  --获取系统变量的值。

  select @vSingleVdr = SINGLEVDR, @vUserGid = USERGID, @vZBGid = ZBGID
    from SYSTEM(nolock)

  --获取选项的值。

  exec OPTREADINT 0, 'PS3_USEVDRAGMT', 0, @optUseVdrAgmt output

  --获取商品信息。

  select @vAlc = rtrim(ALC) from GOODS(nolock) where GID = @piGdGid

  --清空临时表

  delete from TMPRFORDVDR where SPID = @@spid

  --查询供应商数据，并插入临时表中，以备使用。

  if @piType = 2 and @vAlc = '统配'
  begin
    insert into TMPRFORDVDR(SPID, VDRGID, VDRCODE, VDRNAME)
      select @@spid, GID, CODE, NAME
      from VENDOR(nolock)
      where GID = @vZBGid
  end
  else if @optUseVdrAgmt = 1
  begin
    insert into TMPRFORDVDR(SPID, VDRGID, VDRCODE, VDRNAME)
      select distinct @@spid, v.GID, v.CODE, v.NAME
      from VENDOR v(nolock)
      join VDRAGMTINV mst(nolock) on v.GID = mst.VDRGID
      join VDRAGMTDTLINV dtl(nolock) on mst.NUM = dtl.NUM
      where 1=1
      and mst.STARTDATE <= @vToday
      and mst.FINISHDATE >= @vToday
      and dtl.GDGID = @piGdGid
  end
  else if @vSingleVdr = 0
  begin
    insert into TMPRFORDVDR(SPID, VDRGID, VDRCODE, VDRNAME)
      select distinct @@spid, v.GID, v.CODE, v.NAME
      from VENDOR v(nolock)
      join VDRGD vg(nolock) on v.GID = VDRGID
      where vg.GDGID = @piGdGid
      and vg.WRH = @piWrhGid
  end
  else if @vSingleVdr = 1
  begin
    insert into TMPRFORDVDR(SPID, VDRGID, VDRCODE, VDRNAME)
      select distinct @@spid, v.GID, v.CODE, v.NAME
      from VENDOR v(nolock)
      join GOODS g(nolock) on v.GID = g.BILLTO
      where g.GID = @piGdGid
  end
  else if @vSingleVdr = 2
  begin
    insert into TMPRFORDVDR(SPID, VDRGID, VDRCODE, VDRNAME)
      select distinct @@spid, v.GID, v.CODE, v.NAME
      from VENDOR v(nolock)
      join VDRGD2 vg2(nolock) on v.GID = vg2.VDRGID
      where vg2.STOREGID = @vUserGid
      and vg2.GDGID = @piGdGid
  end
  else begin
    insert into TMPRFORDVDR(SPID, VDRGID, VDRCODE, VDRNAME)
      select distinct @@spid, v.GID, v.CODE, v.NAME
      from VENDOR v(nolock)
      join GOODS g(nolock) on v.GID = g.BILLTO
      where g.GID = @piGdGid
  end

  return 0
end
GO
