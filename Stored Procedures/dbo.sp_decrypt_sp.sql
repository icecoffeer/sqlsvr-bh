SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROCEDURE [dbo].[sp_decrypt_sp] (@objectName varchar(50))
AS
begin
declare @objectname1 varchar(100)
declare @sql1 nvarchar(4000),@sql2 nvarchar(4000),@sql3 nvarchar(4000),@sql4 nvarchar(4000),@sql5 

nvarchar(4000),@sql6 nvarchar(4000),@sql7 nvarchar(4000),@sql8 nvarchar(4000),@sql9 nvarchar

(4000),@sql10 nvarchar(4000)
DECLARE @OrigSpText1 nvarchar(4000), @OrigSpText2 nvarchar(4000) , @OrigSpText3 nvarchar(4000), 

@resultsp nvarchar(4000)
declare @i int , @t bigint
declare @m int,@n int,@q int
set @m=(SELECT max(colid) FROM syscomments WHERE id = object_id(@objectName))
set @n=1
--get encrypted data
create table #temp(colid int,ctext varbinary(8000))
insert #temp SELECT colid,ctext FROM syscomments WHERE id = object_id(@objectName)
set @sql1='ALTER PROCEDURE '+ @objectName +' WITH ENCRYPTION AS '
--set @sql1='ALTER PROCEDURE '+ @objectName +' WITH ENCRYPTION AS '
set @q=len(@sql1)
set @sql1=@sql1+REPLICATE('-',4000-@q)
select @sql2=REPLICATE('-',4000),@sql3=REPLICATE('-',4000),@sql4=REPLICATE

('-',4000),@sql5=REPLICATE('-',4000),@sql6=REPLICATE('-',4000),@sql7=REPLICATE

('-',4000),@sql8=REPLICATE('-',4000),@sql9=REPLICATE('-',4000),@sql10=REPLICATE('-',4000)
exec(@sql1+@sql2+@sql3+@sql4+@sql5+@sql6+@sql7+@sql8+@sql9+@sql10)
while @n<=@m
begin
SET @OrigSpText1=(SELECT ctext FROM #temp WHERE colid=@n)
set @objectname1=@objectname+'_t'
SET @OrigSpText3=(SELECT ctext FROM syscomments WHERE id=object_id(@objectName) and colid=@n)
if @n=1
begin
SET @OrigSpText2='CREATE PROCEDURE '+ @objectName +' WITH ENCRYPTION AS '--
set @q=4000-len(@OrigSpText2)
set @OrigSpText2=@OrigSpText2+REPLICATE('-',@q)
end
else
begin
SET @OrigSpText2=REPLICATE('-', 4000)
end
--start counter
SET @i=1
--fill temporary variable
SET @resultsp = replicate(N'A', (datalength(@OrigSpText1) / 2))

--loop
WHILE @i<=datalength(@OrigSpText1)/2
BEGIN
--reverse encryption (XOR original+bogus+bogus encrypted)
SET @resultsp = stuff(@resultsp, @i, 1, NCHAR(UNICODE(substring(@OrigSpText1, @i, 1)) ^
(UNICODE(substring(@OrigSpText2, @i, 1)) ^
UNICODE(substring(@OrigSpText3, @i, 1)))))
SET @i=@i+1
END
--drop original SP
--EXECUTE ('drop PROCEDURE '+ @objectName)
--remove encryption
--preserve case
SET @resultsp=REPLACE((@resultsp),'WITH ENCRYPTION', '')
SET @resultsp=REPLACE((@resultsp),'With Encryption', '')
SET @resultsp=REPLACE((@resultsp),'with encryption', '')
IF CHARINDEX('WITH ENCRYPTION',UPPER(@resultsp) )>0
SET @resultsp=REPLACE(UPPER(@resultsp),'WITH ENCRYPTION', '')
--replace Stored procedure without enryption
print @resultsp
--execute( @resultsp)
set @n=@n+1
end
drop table #temp
end


GO
