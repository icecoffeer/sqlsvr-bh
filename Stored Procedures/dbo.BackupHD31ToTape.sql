SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[BackupHD31ToTape]
as
select getdate()

declare @name char(8)
select @name = convert(char(8), getdate(), 112)
backup database hd31 to tape = '\\.\TAPE0'
with nounload, name = @name, init

select getdate()

GO
