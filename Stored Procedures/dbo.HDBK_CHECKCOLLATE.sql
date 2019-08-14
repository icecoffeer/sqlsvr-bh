SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[HDBK_CHECKCOLLATE]
AS
BEGIN
	declare @tablename varchar(32),
		@fieldname	varchar(32),
		@no		int
	
/* 检查Collate表有无重复数据 */
	if exists(select tablename from [collate] group by tablename having count(*) > 1)
	begin
		PRINT '以下表在COLLATE中重复：'
		declare c cursor for
		select tablename from [collate] group by tablename having count(*) > 1
		open c
		fetch next from c into @tablename
		while @@fetch_status = 0
		begin
			PRINT @tablename
			fetch next from c into @tablename
		end
		close c
		deallocate c
	end
	
/* 与标准表的比较 */
	if exists(select 1 from sysobjects where name='STDCOLLATE' and xtype='U')
	begin
		if exists(select A.no, A.tablename from STDCOLLATE A 
		left outer join [COLLATE] B on A.no = B.no and A.tablename = B.tablename
		and A.master = B.master
		where B.no is null)
		begin
			PRINT '下列表在[COLLATE]不存在或编号与标准表[STDCOLLATE]不一致：'
			declare c cursor for
			select A.no, A.tablename from STDCOLLATE A 
			left outer join [COLLATE] B on A.no = B.no and A.tablename = B.tablename
			and A.master = B.master
			where B.no is null
			open c
			fetch next from c into @no, @tablename
			while @@fetch_status = 0
			begin
				PRINT 'No: ' + ltrim(rtrim(str(@no))) + ', Tablename: ' + @tablename
				fetch next from c into @no, @tablename
			end
			close c
			deallocate c
		end

		if exists(select B.no, B.tablename from [COLLATE] B 
		left outer join STDCOLLATE A on A.no = B.no and A.tablename = B.tablename
		and A.master = B.master	where A.no is null)
		begin
			PRINT '下列表为标准表[STDCOLLATE]中没有或不一致的：'
			declare c cursor for
			select B.no, B.tablename from [COLLATE] B 
			left outer join STDCOLLATE A on A.no = B.no and A.tablename = B.tablename
			and A.master = B.master	where A.no is null
			open c
			fetch next from c into @no, @tablename
			while @@fetch_status = 0
			begin
				PRINT 'No: ' + ltrim(rtrim(str(@no))) + ', Tablename: ' + @tablename
				fetch next from c into @no, @tablename
			end
			close c
			deallocate c
		end
	end

	/* 比较COLLATEITEM */
	if exists(select 1 from sysobjects where name='STDCOLLATEITEM' and xtype='U')
	begin
		if exists(select A.collateno, A.fieldname from STDCOLLATEITEM A 
		left outer join COLLATEITEM B on A.collateno = B.collateno 
		and A.fieldname = B.fieldname where B.collateno is null)
		begin
			PRINT '下列字段在[COLLATEITEM]不存在或编号与标准表[STDCOLLATEITEM]不一致：'
			declare c cursor for
			select A.collateno, A.fieldname from STDCOLLATEITEM A 
			left outer join COLLATEITEM B on A.collateno = B.collateno 
			and A.fieldname = B.fieldname where B.collateno is null
			open c
			fetch next from c into @no, @fieldname
			while @@fetch_status = 0
			begin
				PRINT 'No: ' + ltrim(rtrim(str(@no))) + ', Fieldname: ' + @fieldname
				fetch next from c into @no, @fieldname
			end
			close c
			deallocate c
		end

		if exists(select B.collateno, B.fieldname from COLLATEITEM B 
		left outer join STDCOLLATEITEM A on A.collateno = B.collateno 
		and A.fieldname = B.fieldname where A.collateno is null)
		begin
			PRINT '下列字段在[STDCOLLATEITEM]中不存在或不一致：'
			declare c cursor for
			select B.collateno, B.fieldname from COLLATEITEM B 
			left outer join STDCOLLATEITEM A on A.collateno = B.collateno 
			and A.fieldname = B.fieldname where A.collateno is null			
			open c
			fetch next from c into @no, @fieldname
			while @@fetch_status = 0
			begin
				PRINT 'No: ' + ltrim(rtrim(str(@no))) + ', Fieldname: ' + @fieldname
				fetch next from c into @no, @fieldname
			end
			close c
			deallocate c
		end
	end
END
GO
