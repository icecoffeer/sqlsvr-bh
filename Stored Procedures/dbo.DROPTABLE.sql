SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DROPTABLE](
	@piTableName sysname,		--数据表名
	@piLmtRecCnt int = 0,		--表记录数限制，如果表的记录数<=这个数量则删除该数据表。
	@piForce smallint = 0		--是否强制删除。取值：1=是，Other=否，缺省为0，
) as
begin
	declare @sql varchar(255), @msg varchar(255), @tname sysname
	if left(ltrim(@piTableName),1) = '[' and right(rtrim(@piTableName),1) = ']'
		select @tname = substring(@piTableName, 2, len(@piTableName) - 2)
	else
		select @tname = @piTableName, @piTableName = '[' + @piTableName + ']'
	if not exists (select 1 from sysobjects 
		where name = @tname and xtype = 'U')
		return 0
	if @piForce = 0 
	begin	
		if object_id('v_drop') is not null drop view v_drop
		set @sql = 'create view v_drop as select count(*) cnt from ' 
			+ rtrim(@piTableName)
		exec (@sql)
		if (select cnt from v_drop) > @piLmtRecCnt
		begin
--2003-10-17 Ysp 1166			set @msg = '警告：数据表' + rtrim(@piTableName) + '中包含数据，删除动作被禁止。'
--2003-10-17 Ysp 1166			raiserror (@msg, 16, 1)
			return 1
		end
	end

	set @sql = 'drop table ' + rtrim(@piTableName)
	exec (@sql)
	
	return 0
end
GO
