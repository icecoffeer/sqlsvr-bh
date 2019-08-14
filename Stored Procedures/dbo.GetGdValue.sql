SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGdValue](
  @client int,
  @gdgid int,
  @column varchar(20),
  @ColumnValue money output
) as
begin
  DECLARE @OptRd VARCHAR(100)
  EXEC OPTREADSTR 195, 'USEGDSTOREVALUE', '0', @OptRd OUTPUT
  if @column = 'alcqty'
    begin
      if SUBSTRING(@OptRd, len(@OptRd),1) = '1'
        begin
          select
            @ColumnValue = ISNULL(S.ALCQTY, G.ALCQTY)
          from GDSTORE S(NOLOCK), GOODSH G(nolock)
        	where G.GID = @gdgid
        	  AND S.GDGID =* G.GID
        	  AND S.STOREGID = @client
        end
      else
        begin
          select @ColumnValue = ALCQTY
          FROM GOODSH(NOLOCK)
          where GID = @gdgid
        end
    end
end
GO
