SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetIndex]
@objname varchar(30), 		/* the table to check for indexes */
@indexkey varchar(255) output
/* return string to show key */
as
begin
   declare @objid int		/* the object id of the table */
   declare @indid int		/* the index id of an index */
   declare @Msg varchar(255)
   declare @name varchar(40)

   select @indexkey = ''
   select @objid = object_id(@objname)
   if @objid is NULL
   begin
    	select @Msg = '表' + @objname + '不存在'
    	raiserror(@Msg,16, 1)
    	return (1)
   end

   select @indid = i.indid
   	from master.dbo.spt_values v, sysindexes i
		where i.status & v.number = v.number
			and v.type = 'I'
			and v.number = 2048
 			and i.id = @objid
                                                                                                                                                                                                                                                         
   if @indid is NULL
   begin
   	return (0)
   end
                                                                                                                                                                                                                                                        
   declare @i int
   declare @thiskey varchar(30)
   declare @lastindid int
   declare @colid int
                                                                                                                                                                                                                                         
   select @i = 1
   while @i <= 16
   begin
   	select @thiskey = index_col(@objname, @indid, @i)
   	if @thiskey is null
        begin
   		break
        end
	if @i = 1
        begin
   		select @indexkey = RTrim(index_col(@objname, @indid, @i))
                select @colid = colid from sysColumns
                       where id = @objid and name = @thiskey
                select @indexkey = @indexkey + ' ' + Rtrim(convert(varchar(2),@colid))
        end
   	else
        begin
   		select @indexkey = @indexkey + ' ' + RTrim(index_col(@objname, @indid, @i))
                select @colid = colid from sysColumns
                       where id = @objid and name = @thiskey
                select @indexkey = @indexkey + ' ' + RTrim(convert(varchar(2),@colid))
        end
	select @i = @i + 1
   end
   select @indexKey = Rtrim(@indexKey) + ';'
end
GO
