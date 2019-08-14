SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[RFSIPALACDTL](
  @p_cls char(10),
  @p_num char(10),
  @err_msg varchar(200) = '' output
) as
begin
  declare
    @usergid int
    
  select @usergid = USERGID from SYSTEM
  
  delete from INPRCADJLACDTL
    where CLS = @p_cls and NUM = @p_num and STAT = 0

  insert into INPRCADJLACDTL(
    CLS, NUM, STORE, STAT)
    select @p_cls, @p_num, GID, 0
    from STORE 
    where (IPAFLAG = 1 or GID = @usergid)
      and GID not in (select STORE from INPRCADJLACDTL where CLS = @p_cls and NUM = @p_num)
    
  return(0)
end

GO
