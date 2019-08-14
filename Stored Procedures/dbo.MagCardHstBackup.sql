SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[MagCardHstBackup]
as
begin

declare @bkDate datetime, @bk2Date datetime

select @bkDate = bkDate, @bk2Date = getdate() from MagSystem

insert into hd31Backup..MagCardHstBackup
select *
from magcardhst (nolock)
where fildate > @bkDate
and fildate <= @bk2Date

insert into hd31Backup..MagCardBckBackup
select *
from magcardbck (nolock)
where fildate > @bkDate
and fildate <= @bk2Date

update MagSystem
set bkDate = @bk2Date

end




GO
