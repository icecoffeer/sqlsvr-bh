SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTAGMABOLISH](
    @p_num char(10)
)as
begin
                declare
    @p_autosend int,
    @p_frcchk smallint,
    @return_status int

                if not exists(select 1 from gftagm(nolock) where num = @p_num and stat = 1)
                begin
                                raiserror('中止的单据不存在或不是已审核单据', 16, 1)
                                return(1)
                end

                /*写到历史表中*/                
                insert into GIFTHST(LSTID, STOREGID, VENDOR, START, FINISH, GDGID, INQTY,
                                GFTGID, GFTQTY, SRCNUM, SRCLINE, CANCELDATE, GFTWRH)
                select lstid, storegid, vendor, start, finish, gdgid, inqty, gftgid, gftqty,
                                srcnum, srcline, getdate(), GFTWRH
                from gift(nolock)
                where lstid in (select lstid from gftagmdtl(nolock) 
                                where num = @p_num and finish > getdate() and STAT = 1)

                /*删除Gift表中记录*/
                delete from gift
                where lstid in (select lstid from gftagmdtl(nolock) 
                                where num = @p_num and finish > getdate() and STAT = 1)
                
    /*来源单位为本单位的自动发送*/
                if (select src from gftagm(nolock) where num = @p_num)
                                = (select usergid from system(nolock))
                begin
                exec OptReadInt 448, 'AutoSend', 0, @p_autosend output
                if @p_autosend <> 0             
                begin
                                exec OptReadInt 448, 'ForceCheck', 1, @p_frcchk output
                                exec @return_status = GftAgmSnd @p_num, @p_frcchk
                                if @return_status <> 0 return @return_status
                end
    end
    
    /*检查是否已结束*/
    if not exists(select 1 from gftagmdtl(nolock) where num = @p_num and stat = 0)
                update gftagm set finished = 1 where num = @p_num
    
    return(0)
end
GO
