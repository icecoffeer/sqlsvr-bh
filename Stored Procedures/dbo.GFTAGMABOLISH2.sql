SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTAGMABOLISH2](
    @p_num char(10)
)as
begin
                declare 
                                @return_status int
                
                if not exists(select 1 from GFTAGMDTL where NUM = @p_num and FINISH > getdate()
                                and STAT = 0)
                begin
                                raiserror('此协议已失效，无法再中止', 16, 1)
                                return(1)
                end

                update GFTAGMDTL set STAT = 1 where NUM =  @p_num and FINISH > getdate()
                exec @return_status = GFTAGMABOLISH @p_num
                
                return @return_status
end
GO
