CREATE TABLE [dbo].[ICCARDHST]
(
[ACTION] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__ICCARDHST__FILDA__5D227A9C] DEFAULT (getdate()),
[STORE] [int] NOT NULL,
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OLDCARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[OLDBAL] [decimal] (24, 2) NULL,
[OCCUR] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__ICCARDHST__OCCUR__5E169ED5] DEFAULT (0),
[OLDSCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__ICCARDHST__OLDSC__5F0AC30E] DEFAULT (0),
[Score] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__ICCARDHST__Score__5FFEE747] DEFAULT (0),
[OLDBYDATE] [datetime] NULL,
[NEWBYDATE] [datetime] NULL,
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[CARRIER] [int] NOT NULL CONSTRAINT [DF__ICCARDHST__CARRI__60F30B80] DEFAULT (1),
[CARDCOST] [decimal] (24, 2) NULL,
[CardType] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[LstSndTime] [datetime] NULL,
[Sender] [int] NULL,
[Src] [int] NOT NULL,
[CHARGE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__ICCARDHST__CHARG__61E72FB9] DEFAULT (0),
[SAVETYPE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__ICCARDHST__SAVET__19EC5D11] DEFAULT ('现金'),
[CHECKNO] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CHECKID] [int] NOT NULL IDENTITY(1, 1),
[SRCCHECKID] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[ICCardHst_Ins] on [dbo].[ICCARDHST] for insert
as begin
  declare @UserProperty int, @Rcv int, @Count int --符合条件的记录数, 0表示没有
  declare @ID int, @Action char(10), @FilDate datetime, @Store int,
    @CardNum char(20), @OldCardNum char(20), @OldBal money,
    @Occur money, @OldScore money, @Score money,
    @OldByDate datetime, @NewByDate datetime, @Oper varchar(30),
    @Note varchar(255), @Carrier int, @CardCost money,
    @CardType char(20), @LstSndTime datetime, @Sender int,
    @Src int, @Charge money

  declare cur_ICCardHst cursor for
    select Action, FilDate, Store, CardNum, OldCardNum, OldBal,
      Occur, OldScore, Score, OldByDate, NewByDate, Oper, Note,
      Carrier, CardCost, CardType, LstSndTime, Sender, Src, Charge
    from inserted

  select @UserProperty = UserProperty,@Rcv = zbgid from System(nolock)--added nolock by hxs 2003.03.02任务单号2003030243129
--modify by hxs 2001.09.27
--  select @Rcv = GID from STORE where property >= 16


  open cur_ICCardHst
  fetch next from cur_ICCardHst into
    @Action, @FilDate, @Store, @CardNum, @OldCardNum, @OldBal, @Occur,
    @OldScore, @Score, @OldByDate, @NewByDate, @Oper, @Note, @Carrier,
    @CardCost, @CardType, @LstSndTime, @Sender, @Src, @Charge
  while @@fetch_status = 0
  begin
    if @Action = '制卡'
    begin
      insert into ICCard(CardNum, ByTime, Balance, Consume, Score,
        BanTotal, ScrTotal, CardType, Carrier, Stat)
        values(@CardNum, 0, 0, 0, 0, 0, 0, @CardType, 1, 0)

      insert into ICCardH(CardNum, ByTime, Balance, Consume, Score,
        BanTotal, ScrTotal, CardType, Carrier, Stat)
      select CardNum, ByTime, Balance, Consume, Score, BanTotal,
        ScrTotal, CardType, Carrier, Stat
      from ICCard where CardNum = @CardNum
    end
    else if @Action = '发卡'
    begin
      select @Count = count(*) from ICCard where CardNum = @CardNum
      if @Count = 0
      begin
        insert into ICCard(CardNum, ByTime, Balance, Consume, Score,
          BanTotal, ScrTotal, CardType, Carrier, Stat)
        values(@CardNum, @NewByDate, @Occur, 0, @Score, @Occur, @Score,
          @CardType, @Carrier, 0)
        insert into ICCardH(CardNum, ByTime, Balance, Consume, Score,
          BanTotal, ScrTotal, CardType, Carrier, Stat)
        select CardNum, ByTime, Balance, Consume, Score, BanTotal,
          ScrTotal, CardType, Carrier, Stat
        from ICCard where CardNum = @CardNum
      end
      else begin
        update ICCard set ByTime = @NewByDate, Carrier = @Carrier,
          Balance = @Occur, Score = @Score, BanTotal = @Occur,
          ScrTotal = @Score,/*2003.06.05 hxs */lstupdtime = getdate() where CardNum = @CardNum
        --如果退卡后的卡重新发给同一个人使用, 则将ICCardH中的记录删除
        delete from ICCardH where CardNum = @CardNum and Carrier = @Carrier
        update ICCardH set ByTime = @NewByDate, Carrier = @Carrier,
          Balance = @Occur, Score = @Score, BanTotal = @Occur,
          ScrTotal = @Score,/*2003.06.05 hxs */lstupdtime = getdate()
        where CardNum = @CardNum and Carrier = 1
      end
    end
    else if (@Action = '充值') or (@Action = '退货充值')
    begin
      select @Count = count(*) from ICCard where CardNum = @CardNum
      if @Count = 0
      begin
      /* modify by hxs 20010925
        insert into ICCard(CardNum, ByTime, Balance, Consume, Score,
          BanTotal, ScrTotal, CardType, Carrier, Stat)
        values(@CardNum, @NewByDate, @Occur, 0, @Score, @Occur,
          @Score, @CardType, @Carrier, 0)
        insert into ICCardH(CardNum, ByTime, Balance, Consume, Score,
          BanTotal, ScrTotal, CardType, Carrier, Stat)
        select CardNum, ByTime, Balance, Consume, Score, BanTotal,
          ScrTotal, CardType, Carrier, Stat
        from ICCard where CardNum = @CardNum
	*/
	if @userProperty >= 16 
	begin
		close cur_ICCardHst
		deallocate cur_ICCardHst

		raiserror('该卡在总部不存在。',16,1)
		return 
	end
	
      end
      else begin
        update ICCard set Balance = Balance + @Occur,
          Score = Score + @Score, BanTotal = BanTotal + @Occur,
          ScrTotal = ScrTotal + @Score,/*2003.06.05 hxs */lstupdtime = getdate()
        where CardNum = @CardNum
        update ICCardH set Balance = Balance + @Occur,
          Score = Score + @Score, BanTotal = BanTotal + @Occur,
          ScrTotal = ScrTotal + @Score,/*2003.06.05 hxs */lstupdtime = getdate()
        where CardNum = @CardNum and Carrier = @Carrier
      end
    end
    else if @Action = '修正' /* added by hxs 2001.11.16*/
    begin
      select @Count = count(*) from ICCard where CardNum = @CardNum
      if @Count = 0
      begin
	if @userProperty >= 16
	begin
		close cur_ICCardHst
		deallocate cur_ICCardHst

		raiserror('该卡在总部不存在。',16,1)
		return 
	end
      end
      else begin
        update ICCard set Balance = Balance + @Occur,
          Score = Score + @Score, BanTotal = BanTotal + @Occur,
          ScrTotal = ScrTotal + @Score,/*2003.06.05 hxs */lstupdtime = getdate()
        where CardNum = @CardNum
        update ICCardH set Balance = Balance + @Occur,
          Score = Score + @Score, BanTotal = BanTotal + @Occur,
          ScrTotal = ScrTotal + @Score,/*2003.06.05 hxs */lstupdtime = getdate()
        where CardNum = @CardNum and Carrier = @Carrier
      end
    end
    else if @Action = '挂失'
    begin
      select @Carrier = Carrier from ICCard
        where CardNum = @CardNum and Stat = 0
      if not exists(select 1 from ICCardBlkLst where CardNum = @CardNum)
      begin
        insert into ICCardBlkLst values(@CardNum)
      end
      update ICCard set Stat = 1,/*2003.06.05 hxs */lstupdtime = getdate() where CardNum = @CardNum 
      update ICCardH set Stat = 1,/*2003.06.05 hxs */lstupdtime = getdate()
        where CardNum = @CardNum and Carrier = @Carrier
    end
    else if @Action = '作废'
    begin
      if not exists(select 1 from ICCardBlkLst where CardNum = @CardNum)
      begin
        insert into ICCardBlkLst values(@CardNum)
      end
      delete from ICCard where CardNum = @CardNum
      update ICCardH set Stat = 2,/*2003.06.05 hxs */lstupdtime = getdate()
        where CardNum = @CardNum and Carrier = @Carrier
    end
    else if @Action = '恢复'
    begin
      delete from ICCardBlkLst where CardNum = @CardNum
      update ICCard set Stat = 0,/*2003.06.05 hxs */lstupdtime = getdate() where CardNum = @CardNum
      update ICCardH set Stat = 0,/*2003.06.05 hxs */lstupdtime = getdate()
        where CardNum = @CardNum and Carrier = @Carrier
    end
    else if @Action = '消费'
    begin
    /*
	modified by hxs 2001.09.25
      select @Count = count(*) from ICCard where CardNum = @CardNum
      if @Count = 0
      begin
        insert into ICCard(CardNum, ByTime, Balance, Consume, Score,
          BanTotal, ScrTotal, CardType, Carrier, Stat)
        values(@CardNum, @NewByDate, -@Occur, @Occur, @Score, -@Occur,
          @Score, @CardType, @Carrier, 0)
        insert into ICCardH(CardNum, ByTime, Balance, Consume, Score,
          BanTotal, ScrTotal, CardType, Carrier, Stat)
        select CardNum, ByTime, Balance, Consume, Score, BanTotal,
          ScrTotal, CardType, Carrier, Stat
        from ICCard where CardNum = @CardNum
      end
      else begin
        update ICCard set Consume = Consume + @Occur,
          Balance = Balance - @Occur, Score = Score + @Score,
          ScrTotal = ScrTotal + @Score
        where CardNum = @CardNum
        update ICCardH set Consume = Consume + @Occur,
          Balance = Balance - @Occur, Score = Score + @Score,
          BanTotal = BanTotal - @Occur, ScrTotal = ScrTotal + @Score
        where CardNum = @CardNum and Carrier = @Carrier
      end
*/
      select @Count = count(*) from ICCard where CardNum = @CardNum
      if @Count = 0
      begin
	if @userProperty >=16 
	begin
		--总部不存在，则报错
		close cur_ICCardHst
		deallocate cur_ICCardHst

		raiserror('该卡在总部不存在。',16,1)
		return 

	end
      end
      else begin
        update ICCard set Consume = Consume + @Occur,
          Balance = Balance - @Occur, Score = Score + @Score,
          ScrTotal = ScrTotal + @Score,/*2003.06.05 hxs */lstupdtime = getdate()
        where CardNum = @CardNum
        update ICCardH set Consume = Consume + @Occur,
          Balance = Balance - @Occur, Score = Score + @Score,
          ScrTotal = ScrTotal + @Score,/*2003.06.05 hxs */lstupdtime = getdate()
        where CardNum = @CardNum and Carrier = @Carrier
      end

    end
    else if @Action = '续卡'
    begin
      select @Count = count(*) from ICCard where CardNum = @CardNum
      if @Count = 0
      begin
        insert into ICCard(CardNum, ByTime, Balance, Consume, Score,
          BanTotal, ScrTotal, CardType, Carrier, Stat)
        values(@CardNum, @NewByDate, @OldBal, 0, @OldScore, 0,
          0, @CardType, @Carrier, 0)
        insert into ICCardH(CardNum, ByTime, Balance, Consume, Score,
          BanTotal, ScrTotal, CardType, Carrier, Stat)
        select CardNum, ByTime, Balance, Consume, Score, BanTotal,
          ScrTotal, CardType, Carrier, Stat
        from ICCard where CardNum = @CardNum
      end
      else begin
        update ICCard set ByTime = @NewByDate,/*2003.06.05 hxs */lstupdtime = getdate() where CardNum = @CardNum
        update ICCardH set ByTime = @NewByDate,/*2003.06.05 hxs */lstupdtime = getdate()
          where CardNum = @CardNum and Carrier = @Carrier
      end
    end
    else if @Action = '退卡'
    begin
      update ICCardH set Stat = 4
        where CardNum = @CardNum and Carrier = @Carrier
      update ICCard set ByTime = 0, Balance = 0, Consume = 0, Score = 0,
        BanTotal = 0, ScrTotal = 0, CardType = @CardType, Carrier = 1,
        Stat = 0,/*2003.06.05 hxs */lstupdtime = getdate() where CardNum = @CardNum
      insert into ICCardH(CardNum, ByTime, Balance, Consume, Score,
        BanTotal, ScrTotal, CardType, Carrier, Stat)
        select CardNum, ByTime, Balance, Consume, Score, BanTotal,
          ScrTotal, CardType, Carrier, Stat
        from ICCard where CardNum = @CardNum
    end
    else if @Action = '转储' /* added by hxs 2002.02.04*/
    begin
      select @Count = count(*) from ICCard where CardNum = @CardNum
      if @Count = 0
      begin
	if @userProperty >= 16
	begin
		close cur_ICCardHst
		deallocate cur_ICCardHst
		raiserror('该卡在总部不存在。',16,1)
		return 
	end
      end
      else begin
        update ICCard set Balance = Balance + @Occur,
          Score = Score + @Score, BanTotal = BanTotal + @Occur,/*2003.06.05 hxs */lstupdtime = getdate()
        where CardNum = @CardNum

        update ICCardH set Balance = Balance + @Occur,
          Score = Score + @Score, BanTotal = BanTotal + @Occur ,/*2003.06.05 hxs */lstupdtime = getdate()         
        where CardNum = @CardNum and Carrier = @Carrier
      end
    end
    else if @Action = '转化' /* added by hxs 2003.07.03*/
    begin
      select @Count = count(*) from ICCard where CardNum = @CardNum and Carrier = @Carrier
      if @Count = 0
      begin
	if @userProperty >= 16
	begin
		close cur_ICCardHst
		deallocate cur_ICCardHst
		raiserror('该卡在总部不存在,或持卡人和转化记录中不一致，不能转化。',16,1)
		return 
	end
      end
      else begin
        update ICCard set Balance = Balance + @Occur,
          Score = Score + @Score, BanTotal = BanTotal + @Occur,
	  lstupdtime = getdate(),cardtype = @cardtype,ByTime = @NewByDate
        where CardNum = @CardNum

        update ICCardH set Balance = Balance + @Occur,
          Score = Score + @Score, BanTotal = BanTotal + @Occur ,
	  lstupdtime = getdate(),cardtype = @cardtype,ByTime = @NewByDate
        where CardNum = @CardNum and Carrier = @Carrier
      end
    end
    else if @Action = '补发卡'
    begin
	--modified by hxs 2002.1.15
      --旧卡状态设为2(作废)
      update ICCard set Stat = 2,/*2003.06.05 hxs */lstupdtime = getdate() where CardNum = @OldCardNum
      update ICCardH set Stat = 2,/*2003.06.05 hxs */lstupdtime = getdate()
        where CardNum = @OldCardNum and Carrier = @Carrier
	if not exists(select 1 from iccardhst where cardnum = @cardnum)
	begin
		close cur_ICCardHst
		deallocate cur_ICCardHst

		raiserror('补发的新卡在总部不存在',16,1)
		return 


	end
	else
	begin
		update iccard set ByTime = @OldByDate,Balance = @OldBal,Score=@OldScore,
			carrier = @carrier,stat = 0,/*2003.06.05 hxs */lstupdtime = getdate()
		where cardnum = @cardnum
		update iccardh set ByTime = @OldByDate,Balance = @OldBal,Score=@OldScore,
			carrier = @carrier,stat = 0,/*2003.06.05 hxs */lstupdtime = getdate()
		where cardnum = @cardnum
	end
      if not exists(select 1 from ICCardBlkLst where CardNum = @OldCardNum)
        insert into ICCardBlkLst values(@OldCardNum)
    end
    /*2002.07.20 by hxs
    set @LstSndTime = GetDate()
    update ICCardHst set LstSndTime = @LstSndTime
    where FilDate = @FilDate and CardNum = @CardNum and Carrier = @Carrier
      and Action = @Action and Store = @Store
    if @UserProperty < 16 --如果是门店, 则将记录发送到总部
    begin
      execute @ID = SEQNEXTVALUE 'NICCARDHST'
      insert into NICCardHst(ID, Action, FilDate, Store, CardNum, OldCardNum,
        OldBal, Occur, OldScore, Score, OldByDate, NewByDate, Oper, Note,
        Carrier, CardCost, CardType, LstSndTime, Sender, Src, Charge,
        NNote, Rcv, RcvTime, FrcChk, NType, NStat)
      values(@ID, @Action, @FilDate, @Store, @CardNum, @OldCardNum, @OldBal,
        @Occur, @OldScore, @Score, @OldByDate, @NewByDate, @Oper, @Note,
        @Carrier, @CardCost, @CardType, @LstSndTime, @Sender, @Src, @Charge,
        null, @Rcv, null, 1, 0, 0)
    end
	*/
    fetch next from cur_ICCardHst into
      @Action, @FilDate, @Store, @CardNum, @OldCardNum,
      @OldBal, @Occur, @OldScore, @Score, @OldByDate,
      @NewByDate, @Oper, @Note, @Carrier, @CardCost,
      @CardType, @LstSndTime, @Sender, @Src, @Charge
  end
  close cur_ICCardHst
  deallocate cur_ICCardHst
end
GO
ALTER TABLE [dbo].[ICCARDHST] ADD CONSTRAINT [PK__ICCARDHST__5C2E5663] PRIMARY KEY CLUSTERED  ([FILDATE], [CARDNUM], [CARRIER], [ACTION], [STORE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
