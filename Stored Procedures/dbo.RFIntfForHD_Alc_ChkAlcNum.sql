SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Alc_ChkAlcNum]
(
  @strEmpCode varchar(10),        --员工工号
  @strAlcNum varchar(10),         --总部发出的配货出货单的单号（STKOUT.NUM），也就是本店的配货进货单的来源单号（STKIN.SRCNUM）。
  @strErrMsg varchar(255) output  --返回错误信息，当返回值不等于0时有效
) as
begin
  declare
    @Return_Status smallint,
    @ZBGid int,
    @UserGid int,
    @ID int,
    @Src int,
    @EmpGid int,
    @StkInNum varchar(10),
    @StkInStat smallint,
    @GdGid int,
    @AlcQty money,
    @Fildate datetime

  select @ZBGid = ZBGID, @UserGid = USERGID from SYSTEM(nolock)
  if @ZBGid = @UserGid
  begin
    set @strErrMsg = '在总部不能使用“统配收货”这项业务。'
    return(1)
  end

  select @EmpGid = GID from EMPLOYEE(nolock) where CODE = @strEmpCode
  if @@rowcount = 0
  begin
    set @strErrMsg = '员工代码 ' + rtrim(@strEmpCode) + ' 在员工表中不存在。'
    return(1)
  end

  /*根据传入的配货出货单号@strAlcNum，寻找对应的配货进货单。如果配货出货
  单还在网络表中（注意是NSTKOUT，而不是NSTKIN）尚未接收，则先将其接收。*/

  if not exists(select 1 from STKIN(nolock) where CLS = '配货' and SRCNUM = @strAlcNum and SRC = @ZBGid)
    and not exists(select 1 from NSTKOUT(nolock) where CLS = '配货' and MODNUM = @strAlcNum and SRC = @ZBGid)
    and exists(select 1 from NSTKOUT(nolock) where CLS = '配货' and NUM = @strAlcNum and SRC = @ZBGid)
  begin
    select top 1 @ID = ID, @Src = SRC
      from NSTKOUT(nolock)
      where CLS = '配货'
      and NUM = @strAlcNum
      and SRC = @ZBGid
      order by RCV, RCVTIME
    exec @Return_Status = ReceiveStkin @ID, @Src, @EmpGid
    if @Return_Status is null or @Return_Status <> 0
    begin
      return(1)
    end
  end

  --检查配货进货单合法性。

  select @StkInNum = NUM, @StkInStat = STAT, @Fildate = FILDATE
    from STKIN(nolock)
    where CLS = '配货'
    and SRCNUM = @strAlcNum
    and SRC = @ZBGid

  if @@rowcount = 0
  begin
    set @strErrMsg = '不存在此配货单。'
    return(1)
  end
  if not @StkInStat in (1,6)
  begin
    set @strErrMsg = '对应的配货进货单不是已审核或已复核状态。'
    return(1)
  end
  if exists (select 1 from RF_ALCGOODS(nolock) where ALCNUM = @strAlcNum)
  begin
    set @strErrMsg = '当前配货单正在收货中。'
    return(1)
  end
  if exists (select * from ALCDIFFDTL(nolock) where SRCNUM = @strAlcNum)
  begin
    set @strErrMsg = '当前配货单已生成过差异单。'
    return(1)
  end
  if datediff(day, @Fildate, getdate()) >= 10
  begin
    set @strErrMsg = '配货日期距离今天已超过10天。'
    return(1)
  end

  --将配货进货单的所有商品都导入到“待收商品临时表”，根据SRCNUM和GDGID进行归并。

  insert into RF_ALCGOODS(ALCNUM, GDGID, ALCQTY)
    select s.SRCNUM, sd.GDGID, sum(sd.QTY)
    from STKIN s(nolock), STKINDTL sd(nolock)
    where s.CLS = sd.CLS
    and s.NUM = sd.NUM
    and s.CLS = '配货'
    and s.NUM = @StkInNum
    group by s.SRCNUM, sd.GDGID

  return(0)
end
GO
