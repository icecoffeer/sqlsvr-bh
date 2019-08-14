SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ScoreMoneyRcv]
  @RcvID  int,
  @Src    int
as
begin
  declare @UserGid int, @FrcChk int, @LstModifier int, @RCV int, @NType int
  declare @Score money, @CurMoney money
  declare @LstUpdTime datetime
  declare @boolsuccess int
  declare @Msg   varchar(50)

  select @Msg = '' 
  select @boolsuccess = 0
  select @UserGid = UserGID from system(nolock)--added nolock by hxs 2003.03.02任务单号2003030243129
  if not exists(select 1 from NScoreMoney where ID = @RcvID and Src = @Src) 
  begin
     select @Msg = '该记录已经从网络缓冲中删除'
     select @boolsuccess = -1
  end
  select @Score = Score, @CurMoney = CurMoney, @FrcChk = FrcChk, @RCV = RCV, @NType = NType,
         @LstUpdTime = LstUpdTime, @LstModifier = LstModifier from NScoreMoney where ID = @RcvID and Src = @Src
  if @NType <> 1  
  begin
     select @Msg = '该记录处于发送缓冲中'
     select @boolsuccess = -1
  end
  if (@boolsuccess = 0) and ( @RCV <> @UserGid ) 
  begin
     select @Msg = '该记录的接收单位不是本单位'
     select @boolsuccess = -1
  end
  if (@boolsuccess = 0) and (@SRC = @UserGid)
  begin
     select @Msg = '不能接收来源单位是本单位的记录'
     select @boolsuccess = -1
  end
  if (@boolsuccess = 0) and (not exists(select 1 from Employeeh where gid in (select LGid from empxlate where NGid = @LstModifier) ) )
  begin
     select @msg = '本地员工:'+str(@LstModifier)+'的资料尚未转入'
     select @boolsuccess = -1
  end
  if (@boolsuccess = 0) and (exists(select 1 from ScoreMoney where Score = @Score and CurMoney = @CurMoney) )
  begin
     select @msg = '该积分的对应金额关系已经接收过了'
     select @boolsuccess = -1
  end
  if @boolsuccess = 0
  begin
    if not exists(select 1 from ScoreMoney where Score = @Score)
       insert into ScoreMoney(Score, CurMoney, SRC, LstUpdTime, LstModifier)
       select Score, CurMoney, SRC, LstUpdTime, LstModifier
         from NScoreMoney
       where ID = @RcvID and Src =@Src
    else begin
       if @FrcChk = 1 
         update ScoreMoney set CurMoney = @Curmoney, SRC = @SRC, LstUpdTime = @LstUpdTime, LstModifier = @LstModifier
	 where Score = @Score        
    end
    if @@RowCount = 0  
    begin
       select @boolsuccess = -1
       select @Msg = '操作数据库失败'
    end
  end
  if @boolsuccess = 0
     delete from NScoreMoney where ID = @RcvID and Src = @Src
  else
  begin
     update NScoreMoney set NStat = 1, NNote = @Msg where ID = @RcvID and Src = @Src
     raiserror(@Msg, 16, 1)
  end
end
GO
