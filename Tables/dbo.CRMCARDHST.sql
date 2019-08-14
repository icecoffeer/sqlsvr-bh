CREATE TABLE [dbo].[CRMCARDHST]
(
[ACTION] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__CRMCARDHS__FILDA__6CC6478D] DEFAULT (getdate()),
[STORE] [int] NOT NULL,
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OLDCARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[OLDBYDATE] [datetime] NULL,
[NEWBYDATE] [datetime] NULL,
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CARRIER] [int] NOT NULL CONSTRAINT [DF__CRMCARDHS__CARRI__6DBA6BC6] DEFAULT (1),
[CARDCOST] [decimal] (24, 2) NULL,
[CARDTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[LSTSNDTIME] [datetime] NULL,
[SENDER] [int] NULL,
[SRC] [int] NOT NULL,
[CHARGE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDHS__CHARG__6EAE8FFF] DEFAULT (0),
[SAVETYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMCARDHS__SAVET__6FA2B438] DEFAULT ('现金'),
[CHECKNO] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CHECKID] [int] NOT NULL IDENTITY(1, 1),
[SRCCHECKID] [int] NULL,
[VERSION] [char] (9) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMCARDHS__VERSI__7096D871] DEFAULT ('030000000'),
[NUM] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SENDSTAT] [int] NOT NULL CONSTRAINT [DF__CRMCARDHS__SENDS__718AFCAA] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create trigger [dbo].[CRMCardHst_Ins] on [dbo].[CRMCARDHST] for insert
as begin
  declare 
    @UserProperty int, 
    @Rcv int, 
    @Count int --符合条件的记录数, 0表示没有
  declare 
    @ID int, 
    @Num varchar(26),
    @Action char(10), 
    @FilDate datetime, 
    @Store int,
    @CardNum char(20), 
    @OldCardNum char(20), 
    @OldBal money,
    @Occur money, 
    @OldScore money, 
    @Score money,
    @IncScore money, ---增加的积分
    @OldByDate datetime, 
    @NewByDate datetime, 
    @Oper varchar(30),
    @Note varchar(255), 
    @Carrier int, 
    @CardCost money,
    @DesBalance money,
    @CardType char(20), 
    @LstSndTime datetime, 
    @Sender int,
    @Src int, 
    @Charge money,
    @Version char(9),       ---卡格式版本号
    @AdjMoneyTime DateTime, ---余额调整时间
    @AdjScoreTime DateTime, ---积分调整时间
    @ScoreSubject char(10),  ---积分科目
    @ScoreSubjectDirect int, ---积分科目方向
    @FgStat int,             ---前台消费
    @ScoreSort char(20),      ---积分类别
    @nOptionInv int,
    @nOptionBackAccount int,
    @nRet int,
    @nConsume int
    declare cur_CRMCardHst cursor for
    select Num, Action, FilDate, Store, CardNum, OldCardNum, 
           OldByDate, NewByDate, Oper, Note, Carrier, CardCost, 
           CardType, LstSndTime, Sender, Src, Charge, Version
    from inserted
     
    select @UserProperty = UserProperty from FASystem(nolock)
    select @nRet = Count(1) from HDOption where ModuleNo = 0 and OptionCaption = 'CRM_INV'
    if @nRet = 1 
      select @nOptionInv = Cast(OptionValue as int) from HDOption where ModuleNo = 0 and OptionCaption = 'CRM_INV'
    else
      set @nOptionInv = 0
    select @nRet = Count(1) from HDOption where ModuleNo = 0 and OptionCaption = 'CRM_BACKACCOUNT'
    if @nRet = 1 
      select @nOptionBackAccount = Cast(OptionValue as int) from HDOption where ModuleNo = 0 and OptionCaption = 'CRM_BACKACCOUNT'
    else
      set @nOptionBackAccount = 0  
    
        
    open Cur_CRMCardHst
    fetch next from cur_CRMCardHst into
      @Num, @Action, @FilDate, @Store, @CardNum, @OldCardNum, 
      @OldByDate, @NewByDate, @Oper, @Note, @Carrier, @CardCost, 
      @CardType, @LstSndTime, @Sender, @Src, @Charge, @Version
    while @@fetch_status = 0      
    begin
      declare cur_Score cursor for 
      select ScoreSubject, Score, FgStat, ScoreSort
      from CRMCardScoHst(noLock) 
      where Num = @Num     
    
      ---取得储值明细
      set @Occur = 0 
      select @Occur = Occur from CRMCardDesHst(nolock) where Num = @Num       
     
      --打开积分明细游标    
      open cur_Score
       
      if @Action = '制卡'
      begin 
        insert into CRMCard(CardNum, ByTime, CardType, Carrier, Stat, 
                            MakeTime, Version, LstUpdTime)
        values(@CardNum, 0, @CardType, 1, 0, 
               @FilDate, @Version, GetDate())

        insert into CRMCardH(CardNum, ByTime, Balance, Consume, Score,
                             BanTotal, ScrTotal, CardType, Carrier, Stat, 
                             MakeTime, Version, LstUpdTime)
        select CardNum, ByTime, 0, 0, 0, 
               0, 0, CardType, Carrier, Stat, 
               MakeTime, Version, LstUpdTime
        from CRMCard(nolock) where CardNum = @CardNum
      end
      else if @Action = '发卡'
      begin 
        select @Count = count(1) from CRMCard(nolock) where CardNum = @CardNum
        if @Count = 0
        begin
 	      if @userProperty >= 16 
	      begin
	        close cur_Score
	        deallocate cur_Score
	        
	        close cur_CRMCardHst
	        deallocate cur_CRMCardHst
            raiserror('该卡在总部不存在。', 16, 1)
	        return 
	      end	
        end
        else begin
          select @Count = count(1) from CRMCardH(nolock) where CardNum = @CardNum and Carrier = @Carrier
          if @Count <> 0 
          begin
            close cur_Score
            deallocate cur_Score
            
	        close cur_CRMCardHst
	        deallocate cur_CRMCardHst
            raiserror('卡是当前会员退过的卡，同一张卡不能发给一个会员两次，请换一张进行操作', 16, 1)
	        return 
          end
          
          --更新卡库存信息
          if @nOptionInv = 1
          begin
            select @nRet = Count(1) from CRMCardInv where CardNum = @CardNum and Stat = 0
            if @nRet = 0
              insert into CRMCardInv(CardNum, Stat) values(@CardNum, 0)
          end
          update CRMCard set ByTime = @NewByDate, Carrier = @Carrier, LstUpdTime = GetDate()
          where CardNum = @CardNum
           
          if @Occur <> 0 
          begin
            select @count = count(1) from CRMCardDesDtl(nolock) where CardNum = @CardNum  
            if @count <> 0 
              --update CRMCardDesDtl set Balance = @Occur, Consume = 0, Bantotal = 0, AdjMoney = 0, AdjMoneyTime = null
              update CRMCardDesDtl set Balance = @Occur, AdjMoney = 0, AdjMoneyTime = null
              where CardNum = @CardNum
            else
              insert into CRMCardDesDtl(CardNum, Balance, BanTotal)
--              values(@CardNum, @Occur, @Occur) 
              values(@CardNum, @Occur, 0) 
          end   
          --update CRMCardH set ByTime = @NewByDate, Carrier = @Carrier, Balance = @Occur, Score = 0, BanTotal = @Occur, LstUpdTime = GetDate()
          update CRMCardH set ByTime = @NewByDate, Carrier = @Carrier, Balance = @Occur, Score = 0, LstUpdTime = GetDate()
          where CardNum = @CardNum and Carrier = 1
        end
      end
      else if (@Action = '充值') or (@Action = '退货充值')
      begin
        select @count = count(1) from CRMCard(nolock) where CardNum = @CardNum
        if @count = 0
        begin
	      if @userProperty >= 16 
	      begin
	        close cur_Score
	        deallocate cur_Score
	        
	        close cur_CRMCardHst
	        deallocate cur_CRMCardHst
            raiserror('该卡在总部不存在。', 16, 1)
	        return 
	      end	
        end
        else begin         
          fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort            
          while @@Fetch_status = 0 
          begin
            if @Score <> 0 ---对积分的处理
            begin
              select @Count = count(1) from CRMScoreSubject(nolock) where Code = @ScoreSubject
              if @Count = 0 
              begin
                close cur_Score
                deallocate cur_Score
                  
   	            close cur_CRMCardHst
	            deallocate cur_CRMCardHst
                raiserror('产生积分科目不存在。', 16, 1)
	            return   
              end
              --取得积分方向
              select @ScoreSubjectDirect = Direct from CRMScoreSubject(nolock) where Code = @ScoreSubject
              --判断积分科目是否在卡积分表中存在
              select @Count = count(1) from CRMCardScore(nolock) where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
              if @Count <> 0 
              begin
                update CRMCardScore set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
                update CRMCardScoreH set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
              end else
              begin
                insert into CRMCardScore(CardNum, ScoreSort, ScoreSubject, Score)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score)

                insert into CRMCardSCoreH(CardNum, ScoreSort, ScoreSubject, Score, Carrier)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score, @Carrier)
              end
              ---取得积分
              set @IncScore = @Score * @ScoreSubjectDirect
              if @IncScore < 0 
                set @IncSCore = 0
              select @count = count(1) from CRMCardScoDtl(nolock) where CardNum = @CardNum
              if @count <> 0             
                --update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore
                update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect
                where CardNum = @CardNum
              else
                insert into CRMCardScoDtl(CardNum, Score, ScrTotal)
                --values(@CardNum, @Score * @ScoreSubjectDirect, @IncScore)  
                values(@CardNum, @Score * @ScoreSubjectDirect, 0)  
            
              update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum

              --update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore, LstUpdTime = GetDate()
              update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, LstUpdTime = GetDate()
              where CardNum = @CardNum and Carrier = @Carrier
            end
            fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
          end
          ---对金额处理
       
          if @Occur <> 0 
          begin
            select @count = count(1) from CRMCardDesDtl(nolock) where CardNum = @CardNum
            if @count <> 0   
              --update CRMCardDesDtl set Balance = Balance + @Occur, BanTotal = BanTotal + @Occur
              update CRMCardDesDtl set Balance = Balance + @Occur
              where CardNum = @CardNum
            else
              insert into CRMCardDesDtl(CardNum, Balance, BanTotal)
              --values(@CardNum, @Occur, @Occur)  
              values(@CardNum, @Occur, 0)            
            update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum

            --update CRMCardH set Balance = Balance + @Occur, BanTotal = BanTotal + @Occur, LstUpdTime = GetDate()
            update CRMCardH set Balance = Balance + @Occur, LstUpdTime = GetDate()
            where CardNum = @CardNum and Carrier = @Carrier
          end
        end
      end
      else if @Action = '修正' 
      begin
        select @Count = count(1) from CRMCard(nolock) where CardNum = @CardNum
        if @Count = 0
        begin
	      if @userProperty >= 16
	      begin      
	        close cur_Score
	        deallocate cur_Score
	        
	        close cur_CRMCardHst
	        deallocate Cur_CRMCardHst
            raiserror('该卡在总部不存在。',16,1)
	        return 
	      end
        end
        else begin           
          fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
          while @@Fetch_status = 0       
          begin
            if @Score <> 0 ---对积分的处理
            begin
              select @Count = count(1) from CRMScoreSubject(nolock) where Code = @ScoreSubject
              if @Count = 0 
              begin
                close cur_Score
                deallocate cur_Score
                
   	            close cur_CRMCardHst
	            deallocate cur_CRMCardHst
                raiserror('产生积分科目不存在。', 16, 1)
	            return   
              end
              --取得积分方向
              select @ScoreSubjectDirect = Direct from CRMScoreSubject(nolock) where Code = @ScoreSubject
              --判断积分科目是否在卡积分表中存在
              select @Count = count(1) from CRMCardScore(nolock) where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
              if @Count <> 0 
              begin
                update CRMCardScore set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
                update CRMCardScoreH set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
              end else
              begin
                insert into CRMCardScore(CardNum, ScoreSort, ScoreSubject, Score)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score)
              
                insert into CRMCardSCoreH(CardNum, ScoreSort, ScoreSubject, Score, Carrier)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score, @Carrier)
              end
              ---取得积分
              set @IncScore = @Score * @ScoreSubjectDirect
              if @IncScore < 0 
                set @IncSCore = 0
              select @count = count(1) from CRMCardScoDtl(nolock) where CardNum = @CardNum
              if @count <> 0      
                --update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore
                update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect --, ScrTotal = ScrTotal + @IncScore
                where CardNum = @CardNum
              else
                insert into CRMCardScoDtl(CardNum, Score, ScrTotal)
                --values(@CardNum, @Score * @ScoreSubjectDirect, @IncScore)  
                values(@CardNum, @Score * @ScoreSubjectDirect, 0)  
              
              update CRMCard set  LstUpdTime = GetDate() where CardNum = @CardNum
              --update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore, LstUpdTime = GetDate() 
              update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, LstUpdTime = GetDate() 
              where CardNum = @CardNum and Carrier = @Carrier
            end
            fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
          end            
        
          if @Occur <> 0 
          begin
            select @count = count(1) from CRMCardDesDtl(nolock) where CardNum = @CardNum
            if @count <> 0  
              update CRMCardDesDtl set Balance = Balance + @Occur
              where CardNum = @CardNum
            else 
              insert into CRMCardDesDtl(CardNum, Balance, BanTotal)
              ---values(@CardNum, @Occur, @Occur)  
              values(@CardNum, @Occur, 0)  
            
            update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum

            update CRMCardH set Balance = Balance + @Occur, LstUpdTime = GetDate() 
            where CardNum = @CardNum and Carrier = @Carrier
          end
        end
      end
      else if @Action = '挂失'
      begin
        select @Carrier = Carrier from CRMCard(nolock) where CardNum = @CardNum and Stat = 0
        if not exists(select 1 from CRMCardBlkLst(nolock) where CardNum = @CardNum)
        begin
          insert into CRMCardBlkLst(CardNum, Grade) values(@CardNum, '正常处理')
        end
        update CRMCard set Stat = 1, LstUpdTime = GetDate() where CardNum = @CardNum 
        update CRMCardH set Stat = 1, LstUpdTime = GetDate() where CardNum = @CardNum and Carrier = @Carrier
      end
      else if @Action = '冻结'
      begin
        select @Carrier = Carrier from CRMCard(nolock) where CardNum = @CardNum and Stat = 0
        if not exists(select 1 from CRMCardBlkLst(nolock) where CardNum = @CardNum)
        begin
          insert into CRMCardBlkLst(CardNum, Grade) values(@CardNum, '正常处理')
        end
        update CRMCard set Stat = 5, LstUpdTime = GetDate() where CardNum = @CardNum 
        update CRMCardH set Stat = 5, LstUpdTime = GetDate() where CardNum = @CardNum and Carrier = @Carrier
      end
      else if (@Action = '作废') or (@Action = '清卡')
      begin
        select @nConsume = Count(1) from CRMCardHst(nolock) where CardNum = @CardNum and Carrier = @Carrier and (Action not in('制卡', '发卡', '清卡'))
        fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
        while @@Fetch_status = 0       
        begin         
          if @Score <> 0 ---对积分的处理
          begin
            select @Count = count(1) from CRMScoreSubject(nolock) where Code = @ScoreSubject
            if @Count = 0 
            begin
              close cur_Score
              deallocate cur_Score
            
   	          close cur_CRMCardHst
	          deallocate cur_CRMCardHst
              raiserror('产生积分科目不存在。', 16, 1)
	          return   
            end
            --取得积分方向
            select @ScoreSubjectDirect = Direct from CRMScoreSubject(nolock) where Code = @ScoreSubject
            --判断积分科目是否在卡积分表中存在
            select @Count = count(1) from CRMCardScoreH(nolock) where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
            if @Count <> 0 
            begin
              update CRMCardScoreH set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
            end else
            begin
              insert into CRMCardSCoreH(CardNum, ScoreSort, ScoreSubject, Score, Carrier)
              values(@CardNum, @ScoreSort, @ScoreSubject, @Score, @Carrier)
            end
  
            update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, LstUpdTime = GetDate() 
            where CardNum = @CardNum and Carrier = @Carrier
          end
          fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
        end
      
        if @Occur <> 0 
        begin
          update CRMCardH set Balance = Balance + @Occur, LstUpdTime = GetDate() 
          where CardNum = @CardNum and Carrier = @Carrier
        end
        
        --更新卡库存信息
        if @nOptionInv = 1 
          delete from CRMCardInv where CardNum = @CardNum
          
        delete from CRMCard where CardNum = @CardNum
        delete from CRMCardScore where CardNum = @CardNum
        delete from CRMCardScoDtl where CardNum = @CardNum
        delete from CRMCardDesDtl where CardNum = @CardNum
        update CRMCardH set Stat = 2, LstUpdTime = GetDate()
        where CardNum = @CardNum and Carrier = @Carrier
        if  not (@Action = '清卡' and @nConsume = 0)
        begin
          if not exists(select 1 from CRMCardBlkLst(nolock) where CardNum = @CardNum)  
            insert into CRMCardBlkLst(CardNum, Grade) values(@CardNum, '正常处理')
        end else
        begin
          delete from CRMCardH where CardNum = @CardNum
          delete from CRMCardScoreH where CardNum = @CardNum and Carrier = @Carrier  
        end
      end
      else if @Action = '恢复'
      begin
        delete from CRMCardBlkLst where CardNum = @CardNum
        update CRMCard set Stat = 0, LstUpdTime = GetDate() where CardNum = @CardNum
        update CRMCardH set Stat = 0, LstUpdTime = GetDate() where CardNum = @CardNum and Carrier = @Carrier
      end
      else if (@Action = '消费') or (@Action = '后台消费')
      begin
        select @Count = count(1) from CRMCard(nolock) where CardNum = @CardNum
        if @Count = 0
        begin
	      if @userProperty >=16 
	      begin
	        --总部不存在，则报错
	        close cur_Score
	        deallocate cur_Score
	        
	        close cur_CRMCardHst
	        deallocate cur_CRMCardHst
            raiserror('该卡在总部不存在。',16,1)
	        return 
	      end
        end
        else begin
          -- 对上次金额调整和积分调整时间检查
          select @AdjMoneyTime = AdjMoneyTime from CRMCardDesDtl(nolock) where CardNum = @CardNum
          
          select @AdjScoreTime = AdjScoreTime from CRMCardScoDtl(nolock) where CardNum = @CardNum
          if @Occur <> 0 
          begin
            ---没有进行过金额调整或调整日期小于消费日期,用余额减去消费金额
            if (@AdjMoneyTime is null)  or (@AdjMoneyTime <= @FilDate) --正常消费
            begin            
              --update CRMCardDesDtl set Consume = Consume + @Occur , Balance = Balance - @Occur               
              update CRMCardDesDtl set Balance = Balance - @Occur               
              where CardNum = @CardNum
              update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum
            
              --update CRMCardH set Consume = Consume + @Occur , Balance = Balance - @Occur, LstUpdTime = GetDate()               
              update CRMCardH set Balance = Balance - @Occur, LstUpdTime = GetDate()               
              where CardNum = @CardNum and Carrier = @Carrier                
            end
            else begin --只调整调整金额
              --update CRMCardDesDtl set Consume = Consume + @Occur , AdjMoney = AdjMoney - @Occur
              update CRMCardDesDtl set AdjMoney = AdjMoney - @Occur
              where CardNum = @CardNum                      
              update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum            
            end
          end
        
          
          fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
          while @@Fetch_status = 0 
          begin     
            if @Score <> 0 and @FGStat = 0 ---对积分的处理
            begin
              select @Count = count(1) from CRMScoreSubject(nolock) where Code = @ScoreSubject
              if @Count = 0 
              begin
                close cur_Score
                deallocate cur_Score
                 
   	            close cur_CRMCardHst
	            deallocate cur_CRMCardHst
                raiserror('产生积分科目不存在。', 16, 1)
	            return   
              end
              --取得积分方向
              select @ScoreSubjectDirect = Direct from CRMScoreSubject(nolock) where Code = @ScoreSubject
              --判断积分科目是否在卡积分表中存在
              select @Count = count(1) from CRMCardScore(nolock) where CardNum = @CardNum and ScoreSubject = @ScoreSubject
              if @Count <> 0 
              begin
                update CRMCardScore set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
                update CRMCardScoreH set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
              end else
              begin
                insert into CRMCardScore(CardNum, ScoreSort, ScoreSubject, Score)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score)

                insert into CRMCardSCoreH(CardNum, ScoreSort, ScoreSubject, Score, Carrier)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score, @Carrier)
              end
              ---取得积分
              set @IncScore = @Score * @ScoreSubjectDirect
              if @IncScore < 0 
                set @IncSCore = 0
            
              ---没有进行积分调整或调整日期小于消费日期 
              if (@AdjScoreTime is null)  or (@AdjScoreTime <= @FilDate) --正常
              begin
                select @count = count(1) from CRMCardScoDtl(nolock) where CardNum = @CardNum
                if @count <> 0 
                  --update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore                               
                  update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect
                  where CardNum = @CardNum
                else
                  insert into CRMCardScoDtl(CardNum, Score, ScrTotal)
                  --values(@CardNum, @Score * @ScoreSubjectDirect, @IncScore)   
                  values(@CardNum, @Score * @ScoreSubjectDirect, 0)   
              
                update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum              
            
                --update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore,
                update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, LstUpdTime = GetDate()               
                where CardNum = @CardNum and Carrier = @Carrier                
              end
              else begin --只调整调整积分
                --update CRMCardScoDtl set ScrToTal = ScrToTal + @IncScore , AdjScore = AdjScore - @Score * @ScoreSubjectDirect              
                update CRMCardScoDtl set AdjScore = AdjScore - @Score * @ScoreSubjectDirect              
                where CardNum = @CardNum
              
                update CRMCard set LstUpdTime = GetDate()  where CardNum = @CardNum 
                           
                --update CRMCardH set ScrTotal = ScrTotal + @IncScore, LstUpdTime = GetDate()
                update CRMCardH set LstUpdTime = GetDate()
                where CardNum = @CardNum and Carrier = @Carrier
              end
            end
            fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
          end  
        end 
      end
      else if @Action = '续卡'
      begin
        select @Count = count(1) from CRMCard(nolock) where CardNum = @CardNum
        if @Count = 0
        begin 
	      if @userProperty >=16 
	      begin
	        --总部不存在，则报错
	        close cur_Score
	        deallocate cur_Score
	        
	        close cur_CRMCardHst
	        deallocate cur_CRMCardHst
            raiserror('该卡在总部不存在。',16,1)
	        return 
	      end
        end else
        begin            
          fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
          while @@Fetch_status = 0 
          begin            
            if @Score <> 0 ---对积分的处理
            begin
              select @Count = count(1) from CRMScoreSubject(nolock) where Code = @ScoreSubject
              if @Count = 0 
              begin
                close cur_Score
                deallocate cur_Score
                
   	            close cur_CRMCardHst
	            deallocate cur_CRMCardHst
                raiserror('产生积分科目不存在。', 16, 1)
	            return   
              end
              --取得积分方向
              select @ScoreSubjectDirect = Direct from CRMScoreSubject(nolock) where Code = @ScoreSubject
              --判断积分科目是否在卡积分表中存在
              select @Count = count(1) from CRMCardScoreH(nolock) where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
              if @Count <> 0 
              begin
                update CRMCardScore set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject 
                update CRMCardScoreH set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
              end else
              begin
                insert into CRMCardSCore(CardNum, ScoreSort, ScoreSubject, Score)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score)
                insert into CRMCardSCoreH(CardNum, ScoreSort, ScoreSubject, Score, Carrier)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score, @Carrier)
              end
              ---取得积分
              set @IncScore = @Score * @ScoreSubjectDirect
              if @IncScore < 0 
                set @IncSCore = 0
              --update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore
              update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect
              where CardNum = @CardNum
              
              update CRMCard set LstUpdTime = GetDate()
              where CardNum = @CardNum         

              --update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore, LstUpdTime = GetDate() 
              update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, LstUpdTime = GetDate() 
              where CardNum = @CardNum and Carrier = @Carrier
            end
            fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort              
          end  
          update CRMCard set ByTime = @NewByDate, LstUpdTime = GetDate() where CardNum = @CardNum
          update CRMCardH set ByTime = @NewByDate, LstUpdTime = GetDate() where CardNum = @CardNum and Carrier = @Carrier         
        end         
      end
      else if @Action = '退卡'
      begin ---2004.07.30 add by tianlei  add  AdjMoney , AdjMoneyTime,AdjScore,AdjScoreTime, version        
        select @Count = count(1) from CRMCard(nolock) where CardNum = @CardNum
        if @Count = 0
        begin 
	      if @userProperty >=16 
	      begin
	        --总部不存在，则报错
	        close cur_Score
	        deallocate cur_Score
	        
	        close cur_CRMCardHst
	        deallocate cur_CRMCardHst
            raiserror('该卡在总部不存在。',16,1)
	        return 
	      end
        end else
        begin          
          fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
          while @@Fetch_status = 0 
          begin     
            if @Score <> 0 ---对积分的处理
            begin
              select @Count = count(1) from CRMScoreSubject(nolock) where Code = @ScoreSubject
              if @Count = 0 
              begin
                close cur_Score
                deallocate cur_Score
                 
   	            close cur_CRMCardHst
	            deallocate cur_CRMCardHst
                raiserror('产生积分科目不存在。', 16, 1)
	            return   
              end
              --取得积分方向
              select @ScoreSubjectDirect = Direct from CRMScoreSubject(nolock) where Code = @ScoreSubject
              --判断积分科目是否在卡积分表中存在
              select @Count = count(1) from CRMCardScoreH(nolock) where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
              if @Count <> 0 
              begin
                update CRMCardScoreH set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and  ScoreSubject = @ScoreSubject and Carrier = @Carrier
              end else
              begin
                insert into CRMCardSCoreH(CardNum, ScoreSort, ScoreSubject, Score, Carrier)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score, @Carrier)
              end
  
              update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, LstUpdTime = GetDate() 
              where CardNum = @CardNum and Carrier = @Carrier
            end
            fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
          end  
          
          if @Occur <> 0 
          begin
            update CRMCardH set Balance = Balance + @Occur, LstUpdTime = GetDate() 
            where CardNum = @CardNum and Carrier = @Carrier
          end
          
          --更新卡库存信息
          if @nOptionInv = 1 
          begin
            select @nRet = Count(1) from CRMCardInv where CardNum = @CardNum
            if @nRet = 1 
              update CRMCardInv set Stat = 0 where CardNum = @CardNum
            else
              insert into CRMCardInv(CardNum, Stat) values(@CardNum, 0)
          end
          --更新退卡账户 
          if @nOptionBackAccount = 1 
          begin
            select @nRet = Count(1) from CRMCardDesDtl where CardNum = @CardNum
            if @nRet = 1
              select @OldBal = Balance from CRMCardDesDtl where CardNum = @CardNum
            else
              set @OldBal = 0
              
            select @nRet = Count(1) from CRMCardScoDtl where CardNum = @CardNum
            if @nRet = 1
              select @OldScore = Score from CRMCardScoDtl where CardNum = @CardNum
            else
              set @OldScore = 0  
            
            if (@OldScore > 0) or (@OldBal > 0)
            begin
              select @nRet = Count(1) from CRMCardBackAccount where CardNum = @CardNum and Carrier = @Carrier
              if @nRet = 0
                insert into CRMCardBackAccount(CardNum, Carrier, Score, Balance)
                  values(@CardNum, @Carrier, @OldScore, @OldBal)
              else
                update CRMCardBackAccount set Score = @OldScore, Balance = @OldBal where CardNum = @CardNum and Carrier = @Carrier
            end 
          end
          ---更新卡的状态
          update CRMCardH set Stat = 4
          where CardNum = @CardNum and Carrier = @Carrier

          update CRMCard set ByTime = 0, CardType = @CardType, Carrier = 1, Stat = 0
          where CardNum = @CardNum
          --清除当前卡积分
          delete from CRMCardScore where CardNum = @CardNum
          delete from CRMCardScoDtl where CardNum = @CardNum
          delete from CRMCardDesDtl where CardNum = @CardNum
          --从黑名单中删除
          delete from CRMCardBlkLst where CardNum = @CardNum
          --插入历史表中一条新的记录
          select @Count = count(1) from CRMCardH(nolock) where CardNum = @CardNum and Carrier = 1
          if @Count = 0 
          begin
            insert into CRMCardH(CardNum, ByTime, Balance, Consume, Score,
                                 BanTotal, ScrTotal, CardType, Carrier, Stat, 
                                 MakeTime, Version)
            select CardNum, ByTime, 0, 0, 0, 
                   0, 0, CardType, Carrier, Stat, 
                   MakeTime, Version
            from CRMCard(nolock) where CardNum = @CardNum
          end
        end 
      end
      else if @Action = '卡回收'
      begin
        --更新卡库存信息
        if @nOptionInv = 1 
        begin
          select @nRet = Count(1) from CRMCardInv where CardNum = @CardNum
          if @nRet = 1 
            update CRMCardInv set Stat = 4 where CardNum = @CardNum
          else
            insert into CRMCardInv(CardNum, Stat) values(@CardNum, 4)
        end
      end
      else if @Action = '转储' 
      begin
        select @Count = count(1) from CRMCard(nolock) where CardNum = @CardNum
        if @Count = 0
        begin
	      if @userProperty >= 16
	      begin
	        close cur_Score
	        deallocate cur_Score
	        
	        close cur_CRMCardHst
	        deallocate cur_CRMCardHst
            raiserror('该卡在总部不存在。',16,1)
	        return 
	      end
        end
        else begin
          fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
          while @@Fetch_status = 0 
          begin      
            if @Score <> 0 ---对积分的处理
            begin
              select @Count = count(1) from CRMScoreSubject(nolock) where Code = @ScoreSubject
              if @Count = 0 
              begin
                close cur_Score
                deallocate cur_Score
                
   	            close cur_CRMCardHst
	            deallocate cur_CRMCardHst
                raiserror('产生积分科目不存在。', 16, 1)
	            return   
              end
            
              --取得积分方向
              select @ScoreSubjectDirect = Direct from CRMScoreSubject(nolock) where Code = @ScoreSubject
              --判断积分科目是否在卡积分表中存在
              select @Count = count(1) from CRMCardScore(nolock) where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
              if @Count <> 0 
              begin
                update CRMCardScore set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
                update CRMCardScoreH set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
              end else
              begin
                insert into CRMCardScore(CardNum, ScoreSort, ScoreSubject, Score)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score)

                insert into CRMCardSCoreH(CardNum, ScoreSort, ScoreSubject, Score, Carrier)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score, @Carrier)
              end
            
              set @IncScore = @Score * @ScoreSubjectDirect
              if @IncScore < 0 
                set @IncSCore = 0
              
              set @count = 0
              select @count = count(1) from CRMCardScoDtl(nolock) where CardNum = @CardNum
              if @count <> 0 
                --update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore
                update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect
                where CardNum = @CardNum                                      
              else 
                insert into CRMCardScoDtl(CardNum, Score, ScrTotal)
                --values(@CardNum, @Score * @ScoreSubjectDirect, @IncScore)
                values(@CardNum, @Score * @ScoreSubjectDirect, 0)
              update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum  
              --update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore, LstUpdTime = GetDate()
              update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, LstUpdTime = GetDate()
              where CardNum = @CardNum and Carrier = @Carrier
            end
            fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
          end 
        
          if @Occur <> 0 
          begin
            set @count = 0
            select @count = count(1) from CRMCardDesDtl(nolock) where CardNum = @CardNum
            if @Count <> 0 
              --update CRMCardDesDtl set Balance = Balance + @Occur, BanTotal = BanTotal + @Occur
              update CRMCardDesDtl set Balance = Balance + @Occur
              where CardNum = @CardNum
            else
              insert into CRMCardDesDtl(CardNum, Balance, BanTotal)
              --values(@CardNUm, @Occur, @Occur)
              values(@CardNUm, @Occur, 0)
          
            update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum  
            --update CRMCardH set Balance = Balance + @Occur, BanTotal = BanTotal + @Occur, LstUpdTime = GetDate()
            update CRMCardH set Balance = Balance + @Occur, LstUpdTime = GetDate()
            where CardNum = @CardNum and Carrier = @Carrier
          end
        end 
      end
      else if @Action = '转出'
      begin
        select @Count = count(1) from CRMCard(nolock) where CardNum = @CardNum
        if @Count = 0
        begin
	      if @userProperty >= 16
	      begin
	        close cur_Score
	        deallocate cur_Score
	        
	        close cur_CRMCardHst
	        deallocate cur_CRMCardHst
            raiserror('该卡在总部不存在。',16,1)
	        return 
	      end
        end
        else begin
          if @Occur <> 0 
          begin
            set @count = 0
            select @Count = Count(1), @DesBalance = d.Balance from CRMCardInv i(nolock), CRMCardDesDtl d(nolock)  
            where i.CardNum = d.CardNum and i.CardNum = @CardNum and Stat = 2 group by d.Balance
            if @Count = 0 
              raiserror('此充值卡状态不正常。', 16, 1);
            if @DesBalance <> @Occur 
              raiserror('此充值卡金额不等于数据库金额，请检查！', 16, 1) 

            set @Count = 0
            select @Count = count(1) from CRMCardDesDtl(nolock) where CardNum = @CardNum
            if @Count <> 0
            begin
              update CRMCardDesDtl set Balance = Balance - @Occur where CardNum = @CardNum
            end
            
            update CRMCardInv set Stat = 3 where CardNum = @CardNum
            update CRMCard set Stat = 2, LstUpdTime = getdate() where CardNum = @CardNum
            update CRMCardH set Stat = 2, Balance = Balance - @Occur, LstUpdTime = getdate()
            where CardNum = @CardNum and Carrier = @Carrier
          end
        end
      end
      else if @Action = '吃卡修正'       
      begin
        select @Count = count(1) from CRMCard(nolock) where CardNum = @CardNum
        if @Count = 0
        begin
	      if @userProperty >= 16
	      begin
	        close cur_Score
	        deallocate cur_Score
	        
	        close cur_CRMCardHst
	        deallocate cur_CRMCardHst
  	        raiserror('该卡在总部不存在。',16,1)
	        return 
	      end
        end
        else begin --2004.07.30 add by tianlei add version           
          fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
          while @@Fetch_status = 0 
          begin              
            if @Score <> 0 ---对积分的处理
            begin
              select @Count = count(1) from CRMScoreSubject(nolock) where Code = @ScoreSubject
              if @Count = 0 
              begin
                close cur_Score
                deallocate cur_Score
                
   	            close cur_CRMCardHst
	            deallocate cur_CRMCardHst
                raiserror('产生积分科目不存在。', 16, 1)
	            return   
              end
              --取得积分方向
              select @ScoreSubjectDirect = Direct from CRMScoreSubject(nolock) where Code = @ScoreSubject
              --判断积分科目是否在卡积分表中存在
              select @Count = count(1) from CRMCardScore(nolock) where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
              if @Count <> 0 
              begin
                update CRMCardScore set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
                update CRMCardScoreH set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
              end else
              begin
                insert into CRMCardScore(CardNum, ScoreSort, ScoreSubject, Score)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score)

                insert into CRMCardSCoreH(CardNum, ScoreSort, ScoreSubject, Score, Carrier)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score, @Carrier)
              end
              ---取得积分
              set @IncScore = @Score * @ScoreSubjectDirect
              if @IncScore < 0 
                set @IncSCore = 0
              
              set @count = 0
              select @count = count(1) from CRMCardScoDtl(nolock) where CardNum = @CardNum
              if @count <> 0        
                --update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore
                update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect
                where CardNum = @CardNum
              else
                insert into CRMCardScoDtl(CardNum, Score, ScrTotal)
                --values(@CardNum, @Score * @ScoreSubjectDirect, @IncScore)
                values(@CardNum, @Score * @ScoreSubjectDirect, 0)
              
              update CRMCard set LstUpdTime = GetDate()
              where CardNum = @CardNum
              --update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore, LstUpdTime = GetDate() 
              update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect,  LstUpdTime = GetDate()               
              where CardNum = @CardNum and Carrier = @Carrier
            end
            fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
          end  
          
          if @Occur <> 0 
          begin
            set @count = 0
            select @count = count(1) from CRMCardDesDtl(nolock) where CardNum = @CardNum
            if @count <> 0    
              update CRMCardDesDtl set Balance = Balance + @Occur
              where CardNum = @CardNum
            else
              insert into CRMCardDesDtl(CardNum, Balance)
              values(@CardNum, @Occur)            
          
            update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum
            update CRMCardH set Balance = Balance + @Occur, LstUpdTime = GetDate() 
            where CardNum = @CardNum and Carrier = @Carrier
          end
        end
      end
      else if @Action = '修正账面'---2004.07.30 add by tianlei 
      begin      
        if @Occur <> 0  ---调整金额
        begin
          set @count = 0 
          select @count = count(1) from CRMCardDesDtl(nolock) where CardNum = @CardNum 
          if @count <> 0 
            update CRMCardDesDtl set Balance  = Balance - @Occur, AdjMoney = AdjMoney + @Occur , AdjMoneyTime = @FilDate where CardNum = @CardNum
          else
            insert into CRMCardDesDtl(CardNum, Balance, AdjMoney, AdjMoneyTime)
            values(@CardNum, 0 - @Occur, @Occur, @FilDate)
          update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum   
          update CRMCardH set Balance = Balance - @Occur , lstUPdTime = @FilDate where CardNum = @CardNum and Carrier = @Carrier 
        end    
        
        fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
        while @@Fetch_status = 0 
        begin
          if @Score <> 0 ---调整积分
          begin
            select @Count = count(1) from CRMScoreSubject(nolock) where Code = @ScoreSubject
            if @Count = 0 
            begin
              close cur_Score
              deallocate cur_Score
            
   	          close cur_CRMCardHst
	          deallocate cur_CRMCardHst
              raiserror('产生积分科目不存在。', 16, 1)
	          return   
            end
            --取得积分方向
            select @ScoreSubjectDirect = Direct from CRMScoreSubject(nolock) where Code = @ScoreSubject
            --判断积分科目是否在卡积分表中存在
            select @Count = count(1) from CRMCardScore(nolock) where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
            if @Count <> 0 
            begin
              update CRMCardScore set Score = Score + @Score where CardNum = @CardNum  and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
              update CRMCardScoreH set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
            end else
            begin
              insert into CRMCardScore(CardNum, ScoreSort, ScoreSubject, Score)
              values(@CardNum, @ScoreSort, @ScoreSubject, @Score)

              insert into CRMCardSCoreH(CardNum, ScoreSort, ScoreSubject, Score, Carrier)
              values(@CardNum, @ScoreSort, @ScoreSubject, @Score, @Carrier)
            end
          
            set @count = 0
            select @count = count(1) from CRMCardScoDtl(nolock) where CardNum = @CardNum
            if @count <> 0 
              update CRMCardScoDtl set Score  = Score - @Score * @ScoreSubjectDirect, AdjScore = AdjScore + @Score* @ScoreSubjectDirect , AdjScoreTime = @FilDate where CardNum = @CardNum
            else
              insert into CRMCardScoDtl(CardNum, Score, AdjScore, AdjScoreTime)
              values(@CardNum, 0 - @Score * @ScoreSubjectDirect, @Score * @ScoreSubjectDirect, @FilDate)  
            update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum   
            update CRMCardH set Score = Score - @Score * @ScoreSubjectDirect, lstUPdTime = @FilDate where CardNum = @CardNum and Carrier = @Carrier       
          end
          fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
        end  
      end
      else if @Action = '补发卡'
      begin
        if not exists(select 1 from CRMCard(nolock) where cardnum = @cardnum)
        begin
          close cur_Score
          deallocate cur_Score
          
	  close cur_CRMCardHst
	  deallocate cur_CRMCardHst
          raiserror('补发的新卡在总部不存在',16,1)
	  return 
        end
        else begin
          if @OldCardNum = ''   --对旧卡的处理
          begin
            --更新卡库存信息
            if @nOptionInv = 1 
              delete from CRMCardInv where CardNum = @CardNum
            
            --旧卡状态设为3（已补发卡）
            update CRMCard set Stat = 3, LstUpdTime = GetDate() where CardNum = @CardNum
            update CRMCardH set Stat = 3, LstUpdTime = GetDate()  where CardNum = @CardNum and Carrier = @Carrier

            
            if not Exists(select 1 from CRMCardBlkLst(nolock) where CardNum = @CardNum)
              insert into CRMCardBlkLst(CardNum) values(@CardNum) 	
          end        	
          
          if @OldCardNum <> '' --对新卡的处理
          begin
            select @Count = count(1) from CRMCardH(nolock) where CardNum = @CardNum and Carrier = @Carrier
            if @Count <> 0 
            begin
              close cur_Score
              deallocate cur_Score
            
	      close cur_CRMCardHst
	      deallocate cur_CRMCardHst
              raiserror('卡是当前会员退过的卡，同一张卡不能发给一个会员两次，请换一张进行操作', 16, 1)
	      return 
            end 
            
            --更新卡库存信息
            if @nOptionInv = 1
            begin
              select @nRet = Count(1)  from CRMCardInv where CardNum = @CardNum
              if @nRet = 0
                insert into CRMCardInv(CardNum, Stat) values(@CardNum, 2)
              else
                update CRMCardInv set Stat = 2 where CardNum = @CardNum
            end	
            update CRMCard set ByTime = @OldByDate, Carrier = @Carrier, Stat = 0, LstUpdTime = GetDate()		           
	      where CardNum = @CardNum
		
	    update CRMCardH set ByTime = @OldByDate, Carrier = @Carrier, Stat = 0, LstUpdTime = GetDate()
              where CardNum = @CardNum and Carrier = 1
          end        

          fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort             
          while @@Fetch_status = 0 
          begin
            if @Score <> 0 ---对积分的处理
            begin
              select @Count = count(1) from CRMScoreSubject(nolock) where Code = @ScoreSubject
              if @Count = 0 
              begin
                close cur_Score
                deallocate cur_Score
                
   	        close cur_CRMCardHst
	        deallocate cur_CRMCardHst
                raiserror('产生积分科目不存在。', 16, 1)
	        return   
              end
              
              select @Count = count(1) from CRMScoreSort(nolock) where Code = @ScoreSort
              if @Count = 0 
              begin
                close cur_Score
                deallocate cur_Score
                
   	        close cur_CRMCardHst
	        deallocate cur_CRMCardHst
                raiserror('产生积分科目不存在。', 16, 1)
	        return   
              end


              --取得积分方向
              select @ScoreSubjectDirect = Direct from CRMScoreSubject(nolock) where Code = @ScoreSubject
              --判断积分科目是否在卡积分表中存在
              --对新卡的处理
              select @Count = count(1) from CRMCardScore(nolock) where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
              if @Count <> 0 
              begin
                update CRMCardScore set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and  ScoreSubject = @ScoreSubject
                update CRMCardScoreH set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
              end else
              begin
                insert into CRMCardScore(CardNum, ScoreSort, ScoreSubject, Score)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score)

                insert into CRMCardSCoreH(CardNum, ScoreSort, ScoreSubject, Score, Carrier)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score, @Carrier)
              end
            
              set @count = 0
              select @count = count(1) from CRMCardScoDtl(nolock) where CardNum = @CardNum
              if @count <> 0 
                --update CRMCardScoDtl set Score = @Score * @ScoreSubjectDirect, ScrTotal = @Score * @ScoreSubjectDirect
                update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect
                where CardNum = @CardNum
              else
                insert into CRMCardScoDtl(CardNum, Score, ScrTotal)
                --values(@CardNum, @Score * @ScoreSubjectDirect, @Score * @ScoreSubjectDirect)
                values(@CardNum, @Score * @ScoreSubjectDirect, 0)
            
              update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum    
            
              --update CRMCardH set Score = @Score * @ScoreSubjectDirect, ScrTotal = @Score * @ScoreSubjectDirect, LstUpdTime = GetDate()
              update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, LstUpdTime = GetDate()
              where CardNum = @CardNum and Carrier = @Carrier
              --判断积分科目是否在卡积分表中存在
              --对旧卡的处理
              /*select @Count = count(1) from CRMCardScore(nolock) where CardNum = @OldCardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
              if @Count <> 0 
              begin
                update CRMCardScore set Score = Score - @Score where CardNum = @OldCardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
                update CRMCardScoreH set Score = Score - @Score where CardNum = @OldCardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
              end else
              begin
                insert into CRMCardScore(CardNum, ScoreSort, ScoreSubject, Score)
                values(@OldCardNum, @ScoreSort, @ScoreSubject, -@Score)

                insert into CRMCardSCoreH(CardNum, ScoreSort, ScoreSubject, Score, Carrier)
                values(@OldCardNum, @ScoreSort, @ScoreSubject, -@Score, @Carrier)
              end
              set @count = 0
              select @count = count(1) from CRMCardScoDtl(nolock) where CardNum = @CardNum
              if @count <> 0             
                update CRMCardScoDtl set Score = Score - @Score * @ScoreSubjectDirect
                where CardNum = @OldCardNum
              else
                insert into CRMCardScoDtl(CardNum, Score)
                values(@CardNum, 0 - @Score * @ScoreSubjectDirect)
            
              update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum   
              update CRMCardH set Score = Score - @Score * @ScoreSubjectDirect, LstUpdTime = GetDate() 
              where CardNum = @OldCardNum and Carrier = @Carrier*/
            end
            fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort            
          end  
          if @Occur <> 0 
          begin
            set @count = 0
            select @count = count(1) from CRMCardDesDtl(nolock) where CardNum = @CardNum  
            if @count <> 0              
              --update CRMCardDesDtl set Balance = @Occur, BanTotal = @Occur where CardNum = @CardNum
              update CRMCardDesDtl set Balance = Balance + @Occur where CardNum = @CardNum
            else
              insert into CRMCardDesDtl(CardNum, Balance, BanTotal)
              --values(@CardNum, @Occur, @Occur)            
              values(@CardNum, @Occur, 0)            
            --update CRMCardH set Balance = @Occur, BantoTal = @Occur where CardNum = @CardNum and Carrier = @Carrier
            update CRMCardH set Balance = Balance + @Occur where CardNum = @CardNum and Carrier = @Carrier
          
            update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum
          
            /*set @count = 0 
            select @count = count(1) from CRMCardDesDtl(nolock) where CardNum = @OldCardNum
            if @count <> 0
              update CRMCardDesDtl set Balance = Balance - @Occur where CardNum = @OldCardNum
            else
              insert into CRMCardDesDtl(CardNum, Balance)
              values(@OldCardNum,  0 - @Occur)  
            update CRMCardH set Balance = Balance - @Occur where CardNum = @OldCardNum and Carrier = @Carrier 
            update CRMCard set LstUpdTime = GetDate() where CardNum = @OldCardNum*/
          end
        end
      end
      else if @Action = '修正卡号'
      begin
        update CRMCard set CardNum = @CardNum, LstUpdTime = GetDate() where CardNum = @OldCardNum
        update CRMCardDesDtl set CardNum = @CardNum where CardNum = @OldCardNum
        update CRMCardScoDtl set CardNum = @CardNum where CardNum = @OldCardNum
        update CRMCardH set CardNum = @CardNum, LstUpdTime = getdate() where CardNum = @OldCardNum
 
        update CRMCardHst set cardNum = @CardNum, OldCardNum = @oldCardNum, Note = Note + '卡号修改' where CardNum = @OldCardNum
        update CRMCardDesHst set CardNum = @CardNum where CardNum = @OldCardNum 
        update CRMCardScoHst set CardNum = @CardNum where CardNum = @OldCardNum
        update CRMCardScore set CardNum = @CardNum where CardNum = @OldCardNum
        update CRMCardScoreH set CardNum = @CardNum where CardNum = @OldCardNum             
      end
      else if @Action = '积分转移'
      begin
        select @Count = count(1) from CRMCard(nolock) where CardNum = @CardNum
        if @Count = 0
        begin
   	      if @userProperty >= 16 
	      begin
	        close cur_Score
	        deallocate cur_Score
	        
	        close cur_CRMCardHst
	        deallocate cur_CRMCardHst
                raiserror('该卡在总部不存在。', 16, 1)
	        return 
	      end	
        end
        else begin
          fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort
          while @@Fetch_status = 0 
          begin            
            if @Score <> 0 ---对积分的处理
            begin
              select @Count = count(1) from CRMScoreSubject(nolock) where Code = @ScoreSubject
              if @Count = 0 
              begin
                close cur_Score
                deallocate cur_Score            
   	            close cur_CRMCardHst
	            deallocate cur_CRMCardHst
                raiserror('产生积分科目不存在。', 16, 1)
	            return   
              end
              --取得积分方向
              select @ScoreSubjectDirect = Direct from CRMScoreSubject(nolock) where Code = @ScoreSubject
              --判断积分科目是否在卡积分表中存在
              select @Count = count(1) from CRMCardScore(nolock) where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
              if @Count <> 0 
              begin
                update CRMCardScore set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
                update CRMCardScoreH set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
              end else
              begin
                insert into CRMCardScore(CardNum, ScoreSort, ScoreSubject, Score)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score)

                insert into CRMCardSCoreH(CardNum, ScoreSort, ScoreSubject, Score, Carrier)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score, @Carrier)
              end
              ---取得积分
              set @IncScore = @Score * @ScoreSubjectDirect
              if @IncScore < 0 
                set @IncSCore = 0
                
              select @Count = count(1) from CRMCardScoDtl(nolock) where CardNum = @CardNum   
              --update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore
              if @Count = 0 
                insert into CRMCardScoDtl(CARDNUM, SCORE)
                values(@CardNum, @Score * @ScoreSubjectDirect)
              else 
                update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect
                where CardNum = @CardNum
              
              update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum


              --update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore, LstUpdTime = GetDate()
              update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, LstUpdTime = GetDate()
              where CardNum = @CardNum and Carrier = @Carrier
            end 
            fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort                     
          end          
        end
      end 
      else if @Action = '卡升级'
      begin
        select @Count = count(1) from CRMCard(nolock) where CardNum = @CardNum
        if @Count = 0
        begin
   	      if @userProperty >= 16 
	      begin
	        close cur_Score
	        deallocate cur_Score
	        
	        close cur_CRMCardHst
	        deallocate cur_CRMCardHst
                raiserror('该卡在总部不存在。', 16, 1)
	        return 
	      end	
        end
        else begin
          fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort
          while @@Fetch_status = 0 
          begin            
            if @Score <> 0 ---对积分的处理
            begin
              select @Count = count(1) from CRMScoreSubject(nolock) where Code = @ScoreSubject
              if @Count = 0 
              begin
                close cur_Score
                deallocate cur_Score            
   	            close cur_CRMCardHst
	            deallocate cur_CRMCardHst
                raiserror('产生积分科目不存在。', 16, 1)
	            return   
              end
              --取得积分方向
              select @ScoreSubjectDirect = Direct from CRMScoreSubject(nolock) where Code = @ScoreSubject
              --判断积分科目是否在卡积分表中存在
              select @Count = count(1) from CRMCardScore(nolock) where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
              if @Count <> 0 
              begin
                update CRMCardScore set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject
                update CRMCardScoreH set Score = Score + @Score where CardNum = @CardNum and ScoreSort = @ScoreSort and ScoreSubject = @ScoreSubject and Carrier = @Carrier
              end else
              begin
                insert into CRMCardScore(CardNum, ScoreSort, ScoreSubject, Score)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score)

                insert into CRMCardSCoreH(CardNum, ScoreSort, ScoreSubject, Score, Carrier)
                values(@CardNum, @ScoreSort, @ScoreSubject, @Score, @Carrier)
              end
              ---取得积分
              set @IncScore = @Score * @ScoreSubjectDirect
              if @IncScore < 0 
                set @IncSCore = 0
                
              select @Count = count(1) from CRMCardScoDtl(nolock) where CardNum = @CardNum   
              --update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore
              if @Count = 0 
                insert into CRMCardScoDtl(CARDNUM, SCORE)
                values(@CardNum, @Score * @ScoreSubjectDirect)
              else 
                update CRMCardScoDtl set Score = Score + @Score * @ScoreSubjectDirect
                where CardNum = @CardNum
              
              update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum


              --update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, ScrTotal = ScrTotal + @IncScore, LstUpdTime = GetDate()
              update CRMCardH set Score = Score + @Score * @ScoreSubjectDirect, LstUpdTime = GetDate()
              where CardNum = @CardNum and Carrier = @Carrier
            end 
            fetch next from cur_Score into @ScoreSubject, @Score, @FgStat, @ScoreSort                     
          end          
        end
        
        if @Occur <> 0 
        begin
          select @count = count(1) from CRMCardDesDtl(nolock) where CardNum = @CardNum
          if @count <> 0  
            update CRMCardDesDtl set Balance = Balance + @Occur
            where CardNum = @CardNum
          else 
            insert into CRMCardDesDtl(CardNum, Balance, BanTotal)
            ---values(@CardNum, @Occur, @Occur)  
            values(@CardNum, @Occur, 0)  
          
          update CRMCard set LstUpdTime = GetDate() where CardNum = @CardNum

          update CRMCardH set Balance = Balance + @Occur, LstUpdTime = GetDate() 
          where CardNum = @CardNum and Carrier = @Carrier
        end
      end 
      close cur_Score
      deallocate cur_Score
    
      fetch next from cur_CRMCardHst into
        @Num, @Action, @FilDate, @Store, @CardNum, @OldCardNum, 
        @OldByDate, @NewByDate, @Oper, @Note, @Carrier, @CardCost, 
        @CardType, @LstSndTime, @Sender, @Src, @Charge, @Version
  end
  close cur_CRMCardHst
  deallocate cur_CRMCardHst
end
GO
ALTER TABLE [dbo].[CRMCARDHST] ADD CONSTRAINT [PK__CRMCARDHST__7F53D026] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
