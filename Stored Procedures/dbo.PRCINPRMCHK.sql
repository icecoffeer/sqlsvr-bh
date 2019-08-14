SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCINPRMCHK](
    @p_num char(10)
)as
begin
    declare
	@s_storegid int,
	@s_vdrgid int,
	@s_gdgid int,
        @m_usergid int,
        @s_eon smallint
    select @m_usergid = usergid from system
    select @s_vdrgid = VDRGID,@s_eon = eon from INPRCPRM where NUM = @p_num

    if @s_eon = 1 begin
        Delete INPRICE where vdrgid = @s_vdrgid and storegid = @m_usergid and gdgid in (select gdgid from inprcprmdtl where num = @p_num)        
	Insert into INPRICE(VDRGID,STOREGID,GDGID,ASTART,AFINISH,PRICE,SRCNUM)
	  SELECT @s_vdrgid,@m_usergid,gdgid,Astart,Afinish,Price,@p_num 
            from INPRCPRMDTL where NUM = @p_num and PRICE >= 0   
    end

    Delete INPRICE 
     where vdrgid = @s_vdrgid 
       and storegid in (select storegid from INPRCPRMlacdtl where num = @p_num)
       and gdgid in (select gdgid from INPRCPRMdtl where num = @p_num)

    Insert into INPRICE(VDRGID,STOREGID,GDGID,ASTART,AFINISH,PRICE,SRCNUM)
	SELECT @s_vdrgid,storegid,gdgid,Astart,Afinish,Price,@p_num 
          from INPRCPRMlacdtl,INPRCPRMDTL 
         where INPRCPRMlacdtl.NUM = @p_num and INPRCPRMDTL.NUM = @p_num and Price >=0 
	
    
    Update INPRCPRM set STAT = 1 where NUM = @p_num  	
    execute PRCINPRMPROMPT @p_num
    return(0)
end
GO
