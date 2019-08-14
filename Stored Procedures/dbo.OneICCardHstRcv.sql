SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OneICCardHstRcv]
	@SRC int,
	@ID int,
	@Msg varchar(200) output
as
begin
  declare @UserProperty int, @Count int, @Rcv int
  declare @Action char(10), @FilDate datetime, @Store int,
    @CardNum char(20), @OldCardNum char(20), @OldBal money,
    @Occur money, @OldScore money, @Score money,
    @OldByDate datetime, @NewByDate datetime, @Oper varchar(30),
    @Note varchar(255), @Carrier int, @CardCost money,
    @CardType char(20), @LstSndTime datetime, @Sender int,
    @Charge money,@srccheckid INT/*增加记录接收 added by zhangxb 2003.1.10*/
  declare @MBRID int,@usergid int 
  declare @userid varchar(10)


    select @Action = Action, @Fildate = FilDate, @Store = Store, 
	@CardNum = CardNum, @OldCardNum = OldCardNum, @OldBal = OldBal, 
	@Occur = Occur, @OldScore = OldScore, @Score = Score, 
	@OldByDate = OldByDate, @NewByDate = NewByDate, @Oper = Oper, 
	@Note = Note, @Carrier = Carrier, @CardCost = CardCost, @CardType = CardType, 
	@LstSndTime = LstSndTime, @Sender = Sender, @Charge = Charge,@srccheckid=checkid/*增加记录接收 added by zhangxb 2003.1.10*/
    from NICCardHst
    where Src = @Src and ID = @ID


  select @UserProperty = UserProperty,@userid = userid,@usergid=usergid from System(nolock)--added nolock by hxs 2003.03.02任务单号2003030243129
  if @UserProperty < 16 return -1 

    /*处理会员资料: 如果@Carrier在MEMBER中不存在, 且在NMEMBER中存在,
      则将NMEMBER中的相应记录插入MEMBER表; 否则不做任何操作*/
    if not exists(select 1 from MEMBER where GID = @Carrier)
    begin
	select @MBRID = isnull(ID,0) from NMEMBER where GID = @Carrier and Src = @Src
      if @MBRID <> 0
      begin
	    exec NMemberRcv @Src, @MBRID
      end else begin
		--如果是总部产生的持卡人，则自动在总部系统增加
		if @carrier > 1000000 and @carrier < 2000000  and @userid = 'szmr'
		begin
			if exists(select 1 from memberh where gid = @carrier)
			begin
				select * into #rcv_member_tmp from memberh where gid=@carrier
				delete from memberh where gid = @carrier
				insert into member select * from #rcv_member_tmp
				drop table #rcv_member_tmp
			end
			else
			begin
				insert into member(gid,code,name,src) values (@carrier,'Z01' + convert(varchar(7),@carrier)
					,'Z01' + convert(varchar(7),@carrier),@usergid)
			end
		end
		else
		begin
		    update NICCardHst set NStat = 1, NNote = '对应持卡人不存在，请门店发送对应会员资料。'
			 where Src = @Src and ID = @ID
			select @Msg = '对应持卡人不存在，请门店发送对应会员资料。'
			return -1 
		end
      end
    end
    if @userid = 'szmr'
	    if not exists(select 1 from iccardh where cardnum = @cardnum)
	    begin
		insert into iccard(cardnum,cardtype,carrier) values(@cardnum,'管家卡',@carrier)
		insert into iccardh(cardnum,cardtype,carrier) values(@cardnum,'管家卡',@carrier)
	    end

    select @Count = count(1) from ICCardHst
      where CardNum = @CardNum and Store = @Store and Carrier = @Carrier
        and convert(datetime,convert(varchar(19),FilDate,120)) = @FilDate/*考虑到毫秒问题*/ and Action = @Action
    if @Count = 0  
    begin
      insert into ICCardHst(Action, FilDate, Store, CardNum, OldCardNum,
        OldBal, Occur, OldScore, Score, OldByDate, NewByDate, Oper, Note,
        Carrier, CardCost, CardType, LstSndTime, Sender, Src, Charge,srccheckid/*增加记录接收 added by zhangxb 2003.1.10*/)
      values(@Action, @FilDate, @Store, @CardNum, @OldCardNum, @OldBal,
        @Occur, @OldScore, @Score, @OldByDate, @NewByDate, @Oper, @Note,
        @Carrier, @CardCost, @CardType, @LstSndTime, @Sender, @Src, @Charge,@srccheckid/*增加记录接收 added by zhangxb 2003.1.10*/)
      delete from NICCardHst where Src = @Src and ID = @ID
      return 0
    end
    else if @Count >= 1  
    begin --重复接收处理zhangxb 2003.01.14
       if @srccheckid<>0 
         begin
           update ICCardHst set srccheckid=@srccheckid 
                where CardNum = @CardNum and Store = @Store and Carrier = @Carrier
                 and convert(datetime,convert(varchar(19),FilDate,120)) = @FilDate and Action = @Action and isnull(srccheckid,0)<>@srccheckid
           delete from Niccardhst where src = @src and id = @id
           return 0
        end
       else
   	begin
         delete from Niccardhst where src = @src and id = @id
         return 0 
       end
   end
 /*	deleted by hxs 2002.04.22	
      update NICCardHst set NStat = 1, NNote = '已经接收'
        where Src = @Src and ID = @ID
	select @msg = '已经接收'
	return -1
*/  
       	
end
GO
