SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DROPOBJ](
	@piObjName sysname,		--对象名
	@piLmtRecCnt int = 0,		--表记录数限制，如果表的记录数<=这个数量则删除该数据表。仅当对象类型为表时有效。
	@piForce smallint = 0		--是否强制删除。取值：1=是，Other=否，缺省为0。仅当对象类型为表时有效。
) as
begin
	declare @xtype char(2), @ret int, @tname sysname
	if left(ltrim(@piObjName),1) = '[' and right(rtrim(@piObjName),1) = ']'
		select @tname = substring(@piObjName, 2, len(@piObjName) - 2)
	else
		select @tname = @piObjName, @piObjName = '[' + @piObjName + ']'
	set @ret = 0
	select @xtype = xtype from sysobjects where name = @piObjName
	if @@rowcount = 0
	begin
		if @xtype = 'U'
			exec @ret = DROPTABLE @piObjName, @piLmtRecCnt, @piForce
		else if @xtype = 'V'
			exec @ret = DROPVIEW @piObjName
		else if @xtype = 'TR'
			exec @ret = DROPTRIGGER @piObjName
		else if @xtype = 'P'
			exec @ret = DROPPROC @piObjName
	end
	
	return @ret
end
GO
