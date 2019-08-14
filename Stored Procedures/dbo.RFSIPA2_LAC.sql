SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFSIPA2_LAC](
  @p_cls char(10),
  @p_num char(10),
  @p_subwrh int,
  @p_src int,
  @err_msg varchar(200) = '' output
) as
begin
  declare @usergid int
  
  select @usergid = USERGID from SYSTEM
  
  delete from IPA2LACDTL 
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh
    and STAT = 0
    
  if @p_src <> @usergid
    insert into IPA2LACDTL (CLS, NUM, SUBWRH, STORE, STAT, ADJCOST)
      values (@p_cls, @p_num, @p_subwrh, @usergid, 0, 0)
  else
    insert into IPA2LACDTL (CLS, NUM, SUBWRH, STORE, STAT, ADJCOST)
      select @p_cls, @p_num, @p_subwrh, GID, 0, 0
      from STORE
      where (IPAFLAG = 1 or GID = @usergid)
        and GID not in (select STORE from IPA2LACDTL
          where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh)
  
  return(0)
end
GO
