CREATE TABLE [dbo].[MAGCARDHST]
(
[ACTION] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__MAGCARDHS__FILDA__426462BF] DEFAULT (getdate()),
[STORE] [int] NOT NULL,
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OLDBAL] [money] NULL,
[OCCUR] [money] NOT NULL,
[OPER] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[MagCardHst_Ins] on [dbo].[MAGCARDHST] WITH ENCRYPTION for insert as
begin
  declare @CardNum char(20), @Action char(10), @Occur money, @Note varchar(20), @Count int
  declare ins_cursor cursor for select Action, CardNum, Occur, Note from inserted

  open ins_cursor
  fetch next from ins_cursor into @Action, @CardNum, @Occur, @Note
  while @@fetch_status = 0
  begin
    --充值: 余额增加
    if @Action = '充值'
      update MagCard set MagCard.Balance = MagCard.Balance + @Occur 
      where MagCard.CardNum = @CardNum
    --消费: 余额减少, 消费额增加
    else if @Action = '消费'
      update MagCard set MagCard.Balance = MagCard.Balance - @Occur, 
        MagCard.Consume = MagCard.Consume + @Occur
      where MagCard.CardNum = @CardNum  
    --作废: 状态 = 2
    else if @Action = '作废'
      update MagCard set MagCard.Status = 2
      where MagCard.CardNum = @CardNum
    --挂失: 状态 = 1
    else if @Action = '挂失'
      update MagCard set MagCard.Status = 1 
      where MagCard.CardNum = @CardNum    
    --恢复: 状态 = 0
    else if @Action = '恢复'
      update MagCard set MagCard.Status = 0 
      where MagCard.CardNum = @CardNum
    --取消: 如果存在相同的Note(FlowNo + PosNo)并且Action = ’消费’的记录,
    --并且不存在相同的Note并且Action = ’取消’的记录(避免第二次接受时的处理),
    --则执行MagCard.Balance += MagCardHst.Occur, MagCard.Consume -= MagCardHst.Occur
    else if @Action = '取消'
    begin
      select @Count = count(*) from MagCardHst where CardNum = @CardNum and Action = '取消' and Note = @Note
      if @Count = 1--第一次发送: trigger被触发时, 数据已插到表中, 所以表中已有一条Action='取消'的记录
        update MagCard set Balance = C.Balance + @Occur, Consume = C.Consume - @Occur
        from MagCard C, MagCardHst CH
        where C.CardNum = CH.CardNum and CH.Note = @Note and CH.Action = '消费' and CH.CardNum = @CardNum
    end
    fetch next from ins_cursor into @Action, @CardNum, @Occur, @Note
  end
  close ins_cursor
  deallocate ins_cursor
end
GO
ALTER TABLE [dbo].[MAGCARDHST] ADD CONSTRAINT [PK__MAGCARDHST__41703E86] PRIMARY KEY CLUSTERED  ([FILDATE], [CARDNUM], [ACTION], [STORE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [MagCardHst_FidDate] ON [dbo].[MAGCARDHST] ([FILDATE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
