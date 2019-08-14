CREATE TABLE [dbo].[INV]
(
[NUM] [int] NOT NULL IDENTITY(1, 1),
[WRH] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL CONSTRAINT [DF__INV__QTY__38D0D6E4] DEFAULT (0),
[TOTAL] [money] NOT NULL CONSTRAINT [DF__INV__TOTAL__39C4FB1D] DEFAULT (0),
[ORDQTY] [money] NOT NULL CONSTRAINT [DF__INV__ORDQTY__3AB91F56] DEFAULT (0),
[VALIDDATE] [datetime] NULL,
[STORE] [int] NOT NULL,
[DSPQTY] [money] NULL CONSTRAINT [DF__INV__DSPQTY__3BAD438F] DEFAULT (0),
[BCKQTY] [money] NULL CONSTRAINT [DF__INV__BCKQTY__3CA167C8] DEFAULT (0),
[RSVALCQTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__INV__RSVALCQTY__260A7D38] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE trigger [dbo].[inv_UPD] on [dbo].[INV] for update as
begin
  declare @gdgid int,@qty int,@wrh int,@isltd int
 DECLARE C CURSOR FOR
    SELECT a.GdgID,a.qty,a.wrh,b.isltd FROM INSERTED a ,goods b(nolock)  where a.gdgid=b.gid 
and b.sale=1  and b.f1 not like  's020201%'
  OPEN C
  FETCH NEXT FROM C INTO @gdGID,@qty,@wrh,@isltd
  WHILE @@FETCH_STATUS=0
  BEGIN
      if @qty <=0 and @wrh=1 and @isltd=0
      begin
      update GOODS
        set isltd = 4
        from inserted
        where GOODS.GID = inserted.gdGID  
       update GOODS
        set isltd = 4
        from inserted 
        where  GID =(select pgid from pkg(nolock) where egid= inserted.gdGID )
     end
  if @qty>0 and @isltd=4 and @wrh=1
     update GOODS
        set isltd = 0
        from inserted
        where GOODS.GID = inserted.gdGID 
        update GOODS
        set isltd = 0
        from inserted 
        where  GID =(select pgid from pkg(nolock) where egid= inserted.gdGID )
     FETCH NEXT FROM C INTO @gdGID,@qty,@wrh,@isltd
  END
  CLOSE C
  DEALLOCATE C   
end





GO
ALTER TABLE [dbo].[INV] WITH NOCHECK ADD CONSTRAINT [商品库存数量不足] CHECK (([VALIDDATE] IS NULL OR [QTY]>=(0)))
GO
ALTER TABLE [dbo].[INV] ADD CONSTRAINT [PK__INV__75785BC3] PRIMARY KEY NONCLUSTERED  ([NUM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IDX_1] ON [dbo].[INV] ([WRH], [GDGID], [STORE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
