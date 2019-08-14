SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[LmtPrmChk](
    @num char(10)
) with encryption as
begin
    declare
        @return_status int,
        @eon smallint,
        @stat smallint,
        @storegid int,
        @usergid int,
        @src int

    select @return_status = 0
    

    select @usergid = USERGID from [SYSTEM]
    select @eon = EON, @stat = STAT,@src = SRC from LmtPrm where NUM = @num
    if @stat <> 0
    begin
        raiserror('审核的不是未审核的单据.', 16, 1)
        return(1)
    end
    update LmtPrm set STAT = 1 where NUM = @num

    if @eon = 1/*本店启用*/
    begin
        execute @return_status = LmtPrmDtlChk  --审核明细
            @num, @usergid
        if @return_status <> 0 return(@return_status)
    end

    declare c_lac cursor for
        select STOREGID from LmtPrmLacDtl /*生效单位*/
        where NUM = @num
        for read only
    open c_lac
    fetch next from c_lac into @storegid
    while @@fetch_status = 0
    begin
        execute @return_status = LmtPrmDtlChk
            @num, @storegid
        if @return_status <> 0 break
        fetch next from c_lac into @storegid
    end
    close c_lac
    deallocate c_lac
    
    --Added by Zhuhaohui 2007.12.14 审核消息提醒    
      declare @title varchar(500),
              @event varchar(100)
      --触发提醒
      set @title = '限量促销单[' + @NUM + ']在' + Convert(varchar, getdate(), 20) + '被审核了。'
      set @event = '限量促销单审核提醒'
      execute LMTPRMCHKPROMPT @NUM, @title, @event
    --end of 促销单审核提醒
    
    return(@return_status)
end
GO
