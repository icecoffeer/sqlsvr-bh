SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_UPDATE_GENDATE] (
  @piNum char(14),
  @piVersion int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vChgCode varchar(20)
  declare @vChgCls varchar(10)
  declare @vFixMethod varchar(10)
  declare @vGenDate datetime
  declare @vLine integer

  if object_id('c_cntr') is not null deallocate c_cntr
  declare c_cntr cursor for
    select LINE, CHGCODE
    from CTCNTRDTL where NUM = @piNum and VERSION = @piVersion
  open c_cntr
  fetch next from c_cntr into @vLine, @vChgCode
  while @@fetch_status = 0
  begin
    select @vChgCls = CHGCLS from CTCHGDEF where CODE = @vChgCode
    if @vChgCls = '固定'
    begin
      select @vFixMethod = FIXMETHOD from CTCHGDEFFIX where CODE = @vChgCode
      if @vFixMethod = '按日期'
      begin
        --对于指定日期的固定类项目，更新CTCNTRDTL的生成日期
        select @vGenDate = min(GENDATE)
        from CTCNTRFIXDATE 
        where NUM = @piNum and VERSION = @piVersion and LINE = @vLine
          and isnull(CHGBOOKNUM, '') = ''
        update CTCNTRDTL set FSTGENDATE = @vGenDate, NEXTGENDATE = @vGenDate
        where NUM = @piNum and VERSION = @piVersion and LINE = @vLine
      end
    end

    fetch next from c_cntr into @vLine, @vChgCode
  end
  close c_cntr
  deallocate c_cntr

  return(0)
end
GO
