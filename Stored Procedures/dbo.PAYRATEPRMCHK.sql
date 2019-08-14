SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PAYRATEPRMCHK](
  @NUM CHAR(14),
  @OPER VARCHAR(30),
  @MSG VARCHAR(255) OUTPUT
) as
begin
    declare
        @return_status int,
        @stat smallint,
	@m_launch datetime

    select @return_status = 0

    select @stat = STAT, @m_launch = LAUNCH from PAYRATEPRM where NUM = @num
    if @stat <> 0
    begin
        raiserror('审核的不是未审核的单据.', 16, 1)
        return(1)
    end
    update PAYRATEPRM set STAT = 100, CHECKER = @OPER, CHKDATE = getdate() where NUM = @num    

   -- 记录日志
    INSERT INTO PAYRATEPRMLOG (NUM, MODIFIER, TIME, ACT)
    VALUES (@NUM, @OPER, GETDATE(), '审核')
    
    --Added by Zhuhaohui 2007.12.14 审核消息提醒    
      declare @title varchar(500)
      declare @usergid int,
              @usercode varchar(10),
              @username varchar(20)
              
      --提取信息
      select @usercode=CHECKER from PAYRATEPRM where NUM=@num
      execute PFA_GET_OPERINFO_BYFILLER @usercode, @usergid output, @usercode output, @username output    
      --触发提醒
      set @title = '联销率促销单[' + @num + ']在' + Convert(varchar, getdate(), 20) + '被审核了'
      execute PAYRATEPRMPROMPT @num, @title, '联销率促销单审核提醒'
    
    --end of 联销率促销单审核提醒
    
    if (@m_launch is null or @m_launch < getdate())--2002-09-02
    	execute @return_status = PAYRATEPRMGO @num, @OPER
    return(@return_status)
end
GO
