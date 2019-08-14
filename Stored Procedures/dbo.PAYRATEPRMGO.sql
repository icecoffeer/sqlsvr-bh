SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PAYRATEPRMGO](
  @num char(14),
  @OPER VARCHAR(30)
)as
begin
  declare
    @return_status int,
    @eon smallint,
    @storegid int,
    @usergid int,
    @cur_settleno int

    select @cur_settleno = max(NO) from MONTHSETTLE

    select @eon = EON from PAYRATEPRM where NUM = @num
    if @eon = 1
    	begin
           select @usergid = USERGID from SYSTEM
           execute @return_status = PAYRATEPRMDTLCHK
               @num, @usergid
           if @return_status <> 0 return(@return_status)
    	end

    declare c_lac cursor for
        select STOREGID from PAYRATEPRMLACDTL
           where NUM = @num
           for read only
   open c_lac
   fetch next from c_lac into @storegid
   while @@fetch_status = 0
   begin
       execute @return_status = PAYRATEPRMDTLCHK
          @num, @storegid
       if @return_status <> 0 break
       fetch next from c_lac into @storegid
   end
   close c_lac
   deallocate c_lac
   if @return_status = 0
     begin
       -- 记录日志
       INSERT INTO PAYRATEPRMLOG (NUM, MODIFIER, TIME, ACT)
       VALUES (@NUM, @OPER, GETDATE(), '生效成功')

       update PAYRATEPRM set STAT = 800, FILDATE = getdate(), SETTLENO = @cur_settleno where NUM = @num
       
       --Added by Zhuhaohui 2007.12.14 生效消息提醒    
         declare @title varchar(500)
         declare @usercode varchar(10),
                 @username varchar(20)
                 
         --提取信息
         select @usercode=CHECKER from PAYRATEPRM where NUM=@num
         execute PFA_GET_OPERINFO_BYFILLER @usercode, @usergid output, @usercode output, @username output    
         --触发提醒
         set @title = '联销率促销单[' + RTRIM(@num) + ']在' + Convert(varchar, getdate(), 20) + '生效了。'
         execute PAYRATEPRMPROMPT @num, @title, '联销率促销单生效提醒'
       
       --end of 联销率促销单生效提醒
          
       
     end
   else
   	 -- 记录日志
     INSERT INTO PAYRATEPRMLOG (NUM, MODIFIER, TIME, ACT)
     VALUES (@NUM, @OPER, GETDATE(), '生效失败')
end
print 'Done.'
GO
