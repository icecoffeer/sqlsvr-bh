SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_SeasonLtd]
--with encryption
as
begin
  declare
    @vDate datetime,    @nCount integer,
    @vSort varchar(13),
    @vSSStart datetime, @vSSEnd datetime,
    @nGDCount integer,  @vGid integer
  begin
    select @vDate = getdate()
    --取消限制定货
    declare
      isltd_goods cursor for
      select Gid, Sort, SSStart, SSEnd from Goods(nolock)
        where isltd&2 = 2 and keeptype&2 = 2 and isltd&8 <> 8
    open isltd_goods
    fetch next from isltd_goods into @vGid, @vSort,  @vSSStart, @vSSEnd
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 1, '开始检查限制定货的季节品是否可以取消限制定货' )
    while @@fetch_status = 0
    begin
        select @nCount = count(1) from Goods(nolock) where (isltd&2 <> 2) and (isltd&8 <> 8) and (sort = @vSort)
        select @nGDCount = GDCount from Sort(nolock) where code = @vSort
        if (@vSSStart is not null) and (@vSSEnd is not null)
          if (@vSSStart <= @vDate) and (@vSSEnd > @vDate)
          begin
            if (@nCount < @nGDCount)
            begin
              insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
                values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 1, '限制定货的季节品(' + Convert(varchar(30), @vGid) + ')取消限制定货' )
              update Goods set isltd = isltd - 2 where gid = @vGid and isltd&2 = 2
            end else
            begin
              insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
                values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 1, Convert(varchar(30), @vGid) + '不能取消限制定货,超过类别允许商品数' )
            end
          end
        fetch next from isltd_goods into @vGid, @vSort, @vSSStart, @vSSEnd
    end
    close isltd_goods
    deallocate isltd_goods

    --添加限制定货
    declare
      keeptype_goods cursor for
      select  Gid, SSEnd from Goods(nolock)
        where keeptype&2 = 2
    open keeptype_goods
    fetch next from keeptype_goods into @vGid, @vSSEnd
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 1, '开始检查非限制定货的季节品是否改为限制定货' )
    while @@fetch_status = 0
    begin
      if @vSSEnd <= @vDate
      begin
        insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
          values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 1, '非限制定货的季节品(' + Convert(varchar(30), @vGid) + ')限制定货')
        update Goods set isltd = (isltd|2)  where gid=@vGid
      end
      fetch next from keeptype_goods into @vGid, @vSSEnd
    end
    close keeptype_goods
    deallocate keeptype_goods
  end
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_SeasonLtd', 0, ''   --合并日结
  return(0)
end

GO
