CREATE TABLE [dbo].[MagSystem]
(
[ckUpdDate] [datetime] NULL,
[ckInsDate] [datetime] NULL,
[bkDate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[MagSystem_DEL] on [dbo].[MagSystem] with ENCRYPTION for Insert, Delete
as
begin
	rollback
	raiserror('Please Call Heading Now, 86-21-64104486-810(MagSystem Del/New Deny)', 16, 1)
end


GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[MagSystem_UPD] on [dbo].[MagSystem] with ENCRYPTION for Update
as
begin
	declare @bResult smallint
	if update(ckUpdDate)
	begin
		select @bResult = (case when ckUpdDate > getdate() then 1 else 0 end) from inserted
		if @bResult = 1
		begin
			rollback
			raiserror('Please Call Heading Now, 86-21-64104486-810(MagSystem Upddate over now)', 16, 1)
		end
	end
	if update(ckInsDate)
	begin
		select @bResult = (case when ckInsDate > getdate() then 1 else 0 end) from inserted
		if @bResult = 1
		begin
			rollback
			raiserror('Please Call Heading Now, 86-21-64104486-810(MagSystem Insdate over now)', 16, 1)
		end
	end
end

GO
