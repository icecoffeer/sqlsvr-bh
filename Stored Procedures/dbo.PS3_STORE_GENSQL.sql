SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_STORE_GENSQL] (
  @piSpName varchar(500),
  @piGid int,
  @piOper varchar(40),
  @poErrMsg varchar(255) output
) with encryption as
begin
    declare 
      @execSql nvarchar(1000),
      @params nvarchar(1000),
      @ret int
    set @piSpName = rtrim(@piSpName)
    set @execsql = 'exec @returnstatus =  @spname @storeGid, @Oper, @ErrMsg output '
    set @params = N'@returnstatus int output, @spname varchar(500), @storeGid int, @oper varchar(40), @errMsg varchar(255) output '
    exec sp_executesql @execsql, @params, @ret output, @piSpName, @piGid, @piOper, @poErrMsg output 	   
	return @ret   
end
GO
