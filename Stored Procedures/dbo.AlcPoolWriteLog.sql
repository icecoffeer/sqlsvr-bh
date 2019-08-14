SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcPoolWriteLog](
	@atype		smallint,	/*0: Info; 1: Warning; 2: Error*/
	@acaller	varchar(50),
	@acontent	text
)
as
begin
	declare @settleno smallint
	select @settleno = isnull(max(no), 0)
	from monthsettle(nolock)

	insert into alcpoollog(atime, settleno, atype, acaller, content)
	values(getdate(), @settleno, @atype, @acaller, @acontent)

	return 0
end
GO
