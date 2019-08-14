SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_WEB_RCVCRMCARDHSTWEBPOOL]
(
 @poErrMsg varchar(255) output        --出错信息
 )
as
begin  
  declare @vHstNum varchar(26)
  declare @vPosNo varchar(10)
  declare @nCount int
  declare @vPayTotal decimal(24,2)--消费总额
  declare @vScoTotal decimal(24,2)--积分总额

  declare @vFilDate datetime 
  declare @vAction varchar(10)
  declare @vStore int
  declare @vCardNum varchar(20)
  declare @vOldCardNum varchar(20)
  declare @vOldByDate datetime
  declare @vNewByDate datetime
  declare @vOper varchar(30)
  declare @vNote varchar(255)
  declare @vCarrier int
  declare @vCardCost decimal(24, 2)
  declare @vCardType varchar(10)
  declare @vLstSndTime datetime
  declare @vSender int
  declare @vSrc int
  declare @vCharge decimal(24,2)
  declare @vSaveType varchar(10)
  declare @vCheckNo varchar(30)
  declare @vVersion varchar(9)
  declare @vSendStat smallint

  declare @vDesCardNum varchar(20)
  declare @vDesCarrier varchar(20)
  declare @vDesOldBal decimal(24,2)
  declare @vDesOccur decimal(24,2)
  declare @vDesHstNum varchar(26)

  declare @vScoCardNum varchar(20)
  declare @vScoCarrier int
  declare @vScoScoreSubject varchar(20)
  declare @vScoOldScore decimal(24, 2)
  declare @vScoScore decimal(24, 2)
  declare @vScoFgStat smallint
  declare @vScoHstNum varchar(26)
  declare @vScoScoreSort varchar(20)   
  
  declare curHst cursor for 
    select distinct top 5000 Action, FilDate, Store, CardNum, OldCardNum,
      OldByDate, NewByDate, Oper, Note, Carrier,
      CardCost, CardType, Lstsndtime, Sender, Charge,
      SaveType, CheckNo, Version, Num, Src, PosNo
    from CRMCardHstWebPool(nolock)    
  open curHst
  fetch next from curHst into
    @vAction, @vFilDate, @vStore, @vCardNum, @vOldCardNum,
    @vOldByDate, @vNewByDate, @vOper, @vNote, @vCarrier,
    @vCardCost, @vCardType, @vLstsndtime, @vSender, @vCharge,
    @vSaveType, @vCheckNo, @vVersion, @vHstNum, @vSrc, @vPosNo 
  while @@fetch_status = 0
  begin        
    --检查卡是否在当前表中存在,并且是正常的状态
    select @nCount = count(1) from CRMCard(nolock) where CardNum = @vCardNum and Stat = 0
    begin transaction
    if @nCount = 0 
    begin        
      insert into CRMCardAlert(OPERTIME, OPER, CARDNUM, ALERTTYPE, NOTE, STORE, POSNO)
      values(@vFilDate, @vOper, @vCardNum, 'A0', '卡不存在或卡状态不正确。记录流水号:' + @vHstNUm, @vStore, @vPosNo)
    end else  
    begin  ---卡在当前表中存在
      select @nCount = count(1) from CRMCardHst(nolock) where Num = @vHstNum
      if @nCount = 0       ---数据未接收
      begin              
        ---处理储值明细
        declare curDesHst cursor for 
          select distinct CardNum, Carrier, OldBal, Occur, Num
          from CRMCardDesHstWebPool(nolock)
          where Num = @vHstNum
        select @vPayTotal = 0
        open curDesHst
        fetch next from curDesHst into
          @vDesCardNum, @vDesCarrier, @vDesOldBal, @vDesOccur, @vDesHstNum
        while @@fetch_status = 0 
        begin
          insert into CRMCardDesHst(CardNum, Carrier, OldBal, Occur, Num)
          values(@vDesCardNum, @vDesCarrier, @vDesOldBal, @vDesOccur, @vDesHstNum)
          
          select @vPayTotal = @vPayTotal + @vDesOccur
          
          fetch next from curDesHst into
            @vDesCardNum, @vDesCarrier, @vDesOldBal, @vDesOccur, @vDesHstNum
        end
        close curDesHst
        deallocate curDesHst

        ---处理积分明细
        declare curScoHst cursor for
          select distinct CardNum, Carrier, ScoreSubject, OldScore, Score, FgStat, Num, ScoreSort
          from CRMCardScoHstWebPool(nolock)
          where Num = @vHstNum
          
        select @vScoTotal = 0

        open curScoHst
        fetch next from curScoHst into
          @vScoCardNum, @vScoCarrier, @vScoScoreSubject, @vScoOldScore, @vScoScore, @vScoFgStat, @vScoHstNum, @vScoScoreSort
        while @@fetch_status = 0 
        begin
          insert into CRMCardScoHst(CardNum, Carrier, ScoreSubject, OldScore, Score, FgStat, Num, ScoreSort)
          values(@vScoCardNum, @vScoCarrier, @vScoScoreSubject, @vScoOldScore, @vScoScore, @vScoFgStat, @vScoHstNum, @vScoScoreSort)
          
          select @vScoTotal = @vScoTotal + @vScoScore
          
          fetch next from curScoHst into
            @vScoCardNum, @vScoCarrier, @vScoScoreSubject, @vScoOldScore, @vScoScore, @vScoFgStat, @vScoHstNum, @vScoScoreSort
        end
        
        close curScoHst
        deallocate curScoHst
     
        ---总表
        insert into CRMCardHst(Action, FilDate, Store, CardNum, OldCardNum,
                 OldByDate, NewByDate, Oper, Note, Carrier,
                 CardCost, CardType, Lstsndtime, Sender, Charge,
                 SaveType, CheckNo, Version, Num, Src)
        values(@vAction, @vFilDate, @vStore, @vCardNum, @vOldCardNum,
          @vOldByDate, @vNewByDate, @vOper, @vNote, @vCarrier,
          @vCardCost, @vCardType, @vLstsndtime, @vSender, @vCharge,
          @vSaveType, @vCheckNo, @vVersion, @vHstNum, @vSrc) 
        
        ---更新日报表      
        select @nCount = count(1) 
        from CRMPosWebRcvDataDRpt(nolock) 
        where Store = @vStore and PosNo = @vPosNo and RcvDate = convert(char(10), @vFilDate, 102)      
        
        if @nCount = 0 
        begin        
          insert into CRMPosWebRcvDataDRpt(Store, PosNo, RcvDate, RecCount, PayTotal, ScoTotal)
          values(@vStore, @vPosNo, convert(char(10), @vFilDate, 102), 1, IsNull(@vPayTotal, 0), IsNull(@vScoTotal, 0))        
        end else
        begin        
          update CRMPosWebRcvDataDRpt
          set RecCount = RecCount + 1, PayTotal = PayTotal + IsNull(@vPayTotal, 0), ScoTotal = ScoTotal + IsNull(@vScoTotal, 0), Checked = 0
          where Store = @vStore and PosNo = @vPosNo and RcvDate = convert(char(10), @vFilDate, 102)        
        end
      end
    end   
    
    --删除WebPool中有数据
    delete from CRMCardDesHstWebPool where Num = @vHstNum    
    delete from CRMCardScoHstWebPool where Num = @vHstNum    
    delete from CRMCardHstWebPool where Num = @vHstNum    
    commit transaction   
             
    fetch next from curHst into     
      @vAction, @vFilDate, @vStore, @vCardNum, @vOldCardNum,
      @vOldByDate, @vNewByDate, @vOper, @vNote, @vCarrier,
      @vCardCost, @vCardType, @vLstsndtime, @vSender, @vCharge,
      @vSaveType, @vCheckNo, @vVersion, @vHstNum, @vSrc, @vPosNo     
  end
  close curHst
  deallocate curHst    
  return (0)  
end
GO
