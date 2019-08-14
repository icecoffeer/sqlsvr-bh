SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[OneICCardHstSnd]
  @Action varchar(10),
  @Fildate datetime,
  @cardnum varchar(20),
  @carrier int,
  @store int,
  @Rcv int,
  @Sender int, 
  @Msg varchar(200) output
as begin
  declare @Count int, @UserGID int, @UserProperty int

  declare @ID int, @OldCardNum char(20), @OldBal money,
    @Occur money, @OldScore money, @Score money,
    @OldByDate datetime, @NewByDate datetime, @Oper varchar(30),
    @Note varchar(255), @CardCost money,
    @CardType char(20), @LstSndTime datetime, 
    @Src int, @Charge money

  declare @RealFildate datetime

  declare @SaveType varchar(10),@CheckNO varchar(30)
  
  declare @checkid INT /*增加记录发送 added by zhangxb 2003.1.10*/
  select @UserGID = UserGID,@UserProperty = UserProperty from System(nolock)--added nolock by hxs 2003.03.02任务单号2003030243129
  --总部 or null
  if (@UserProperty >= 16) or (@UserProperty is null)
  begin
	select @msg = '在总部不能发送IC卡记录'
	return -1
  end


    select @RealFilDate = Fildate, @OldCardNum = OldCardNum, 
	@OldBal = OldBal,
	@Occur = Occur, @OldScore = OldScore, @Score = Score, 
	@OldByDate = OldByDate, @NewByDate = NewByDate, @Oper = Oper,
	@Note = Note, @CardCost = CardCost, @CardType = CardType, 
	@Charge = Charge,@SaveType = SaveType ,@CheckNo = CheckNO,@checkid=checkid/*增加记录发送 added by zhangxb 2003.1.10*/
    from ICCardHst(nolock) 
    where 
 --convert(varchar(10),Fildate,102) = convert(varchar(10), @Fildate, 102)
	--and convert(varchar(8),fildate,108) = convert(varchar(8), @fildate,108)
Fildate = @Fildate
	and Action = @Action and Cardnum = @cardnum
	and carrier = @carrier and Store = @Store
    if @@Rowcount = 0
    begin
	select @Msg = '发生时间:' + convert(varchar(20),@fildate)
		+' 动作:' + @action +' 卡号:' + @cardnum 
		+' 持卡人:' + convert(varchar(20),@carrier) 
		+' 店表:' + convert(varchar(20),@store) + '对应记录不存在'
	return -1
    end

    select @LstSndtime = Getdate()
    
    select @Count = count(1) from NICCardHst(nolock)
    where CardNum = @CardNum and FilDate = @RealFilDate
      and Action = @Action and Store = @Store and Carrier = @Carrier
    if @Count = 0
    begin
      execute @ID = SEQNEXTVALUE 'NICCARDHST'
      insert into NICCardHst(ID, Action, FilDate, Store, CardNum, OldCardNum,
        OldBal, Occur, OldScore, Score, OldByDate, NewByDate, Oper, Note,
        Carrier, CardCost, CardType, LstSndTime, Sender, Src, Charge,
        NNote, Rcv, RcvTime, FrcChk, NType, NStat,SaveType,CheckNo,checkid/*增加记录发送 added by zhangxb 2003.1.10*/)
      values(@ID, @Action, @RealFilDate, @Store, @CardNum, @OldCardNum, @OldBal,
        @Occur, @OldScore, @Score, @OldByDate, @NewByDate, @Oper, @Note,
        @Carrier, @CardCost, @CardType, @LstSndTime, @Sender, @Store, @Charge,
        null, @Rcv, null, 1, 0, 0,@SaveType,@CheckNO,@checkid/*增加记录发送 added by zhangxb 2003.1.10*/)
    end    
    if exists(select 1 from Member where GID = @Carrier)
    begin
      if not exists(select 1 from NMember where GID = @Carrier)
      begin
	exec SendOneMbr @Carrier, @Rcv , 1
      end
    end
  update ICCardHst set LstSndTime = @LstSndTime ,Sender = @Sender
    where Fildate = @Fildate and Action = @Action and Cardnum = @cardnum
	and carrier = @carrier and Store = @Store
end
GO
