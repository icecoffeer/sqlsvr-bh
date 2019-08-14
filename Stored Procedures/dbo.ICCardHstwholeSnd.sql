SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ICCardHstwholeSnd]  
  @Rcv int,@endtime datetime,@sendcount int output  
as begin  
  declare @Count int, @UserGID int, @UserProperty int  
  declare @ID int, @Action char(10), @FilDate datetime, @Store int,  
    @CardNum char(20), @OldCardNum char(20), @OldBal money,  
    @Occur money, @OldScore money, @Score money,  
    @OldByDate datetime, @NewByDate datetime, @Oper varchar(30),  
    @Note varchar(255), @Carrier int, @CardCost money,  
    @CardType char(20), @LstSndTime datetime, @Sender int,  
    @Src int, @Charge money,  
    @Savetype char(10),  
    @CheckNo char(30),  
    @Version char(9)  
  select @sendcount=0  
  declare cur_ch cursor for  
    select Action, FilDate, Store, CardNum, OldCardNum, OldBal,  
      Occur, OldScore, Score, OldByDate, NewByDate, Oper, Note,  
      Carrier, CardCost, CardType, LstSndTime, Sender, Src, Charge, SaveType, CheckNo  
    from ICCardHst(nolock) where FilDate < @EndTime and LstSndTime is null  
  select @UserGID = UserGID from System(nolock)  
  open cur_ch  
  fetch next from cur_ch into  
    @Action, @FilDate, @Store, @CardNum, @OldCardNum, @OldBal, @Occur,  
    @OldScore, @Score, @OldByDate, @NewByDate, @Oper, @Note, @Carrier,  
    @CardCost, @CardType, @LstSndTime, @Sender, @Src, @Charge, @SaveType, @CheckNo 
  while @@fetch_status = 0  
  begin  
    select @Count = count(1) from NICCardHst(nolock)  
    where CardNum = @CardNum and FilDate = @FilDate  
      and Action = @Action and Store = @Store and Carrier = @Carrier  
    if @Count = 0  
    begin  
      execute @ID = SEQNEXTVALUE 'NICCARDHST'  
      select @LstSndTime=getdate()  
      insert into NICCardHst(ID, Action, FilDate, Store, CardNum, OldCardNum,  
        OldBal, Occur, OldScore, Score, OldByDate, NewByDate, Oper, Note,  
        Carrier, CardCost, CardType, LstSndTime, Sender, Src, Charge,  
        NNote, Rcv, RcvTime, FrcChk, NType, NStat, SaveType, CheckNo )  
      values(@ID, @Action, @FilDate, @Store, @CardNum, @OldCardNum, @OldBal,  
        @Occur, @OldScore, @Score, @OldByDate, @NewByDate, @Oper, @Note,  
        @Carrier, @CardCost, @CardType, @LstSndTime, @Sender, @Src, @Charge,  
        null, @Rcv, null, 1, 0, 0, @SaveType, @CheckNo )  
      select @sendcount=@sendcount+1  
      update ICCardHst set LstSndTime=@LstSndTime where CardNum = @CardNum and FilDate = @FilDate  
        and Action = @Action and Store = @Store and Carrier = @Carrier  --add by qyx 2003.9.15  
    end      
    fetch next from cur_ch into  
      @Action, @FilDate, @Store, @CardNum, @OldCardNum, @OldBal, @Occur,  
      @OldScore, @Score, @OldByDate, @NewByDate, @Oper, @Note, @Carrier,  
      @CardCost, @CardType, @LstSndTime, @Sender, @Src, @Charge, @SaveType, @CheckNo
  end  
  close cur_ch  
  deallocate cur_ch  
end  
  
GO
