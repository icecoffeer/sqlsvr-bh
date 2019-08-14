SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[GETPKG]
-- if found return 1 else return 2
@PGID int, --大包装商品
@EGID int output, --查询到的基本单位商品
@QTY money output --查询到的关联个数
with encryption as
begin
	declare @Found int
	select @QTY = QTY from PKG where PGID = @PGID
	select @EGID = EGID from PKG where PGID = @PGID
	if @@ROWCOUNT = 0
		return(2)
	else
		select @Found = 1
	while @Found = 1
	begin
		select @QTY = @QTY * ISNULL((select QTY from PKG where PGID = @EGID), 1)
		select @EGID = EGID from PKG where PGID = @EGID
		if @@ROWCOUNT > 0
			select @Found = 1
		else
			select @Found = 0
	end
	return(1)
end

GO
