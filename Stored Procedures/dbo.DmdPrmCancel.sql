SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DmdPrmCancel](
    @num char(10),
    @operater int
) as
begin
    declare
    @stat smallint,
    @src int,
    @user_gid int,
    @sndtime datetime
    
    select @user_gid = UserGid from System

    select @stat = stat, @src = src,@sndtime=sndtime from DMDPRM where Num = @num
    if @stat <> 1
    begin
        raiserror('不是已提交单据', 16, 1)
        return(1)
    end
    if @sndtime is not null 
    begin
        raiserror('单据已发送', 16, 1)
        return(2)
    end
    update DMDPRM set stat = 2, canceldate = getdate(), canceler = @operater where Num = @num     
    if @src <> @user_gid         
    begin
      exec DMDPRMSND @num    
    end          
    return(@@error)
end
GO
