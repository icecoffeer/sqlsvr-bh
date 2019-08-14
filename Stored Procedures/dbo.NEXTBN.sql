SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[NEXTBN] ( @ABN varchar(10), @NEWBN varchar(10) output) as
begin
  declare @len integer, @i integer, @carry integer

  select @ABN = reverse(rtrim(@ABN))
  select @len = datalength( @ABN ), @i = 1, @carry = 1
  while (@carry = 1) and (@i <= @len) begin
    if substring( @ABN, @i, 1 ) = 'Z' begin
      select @ABN = stuff( @ABN, @i, 1, 'A' )
      select @i = @i + 1
    end
    else if substring( @ABN, @i, 1 ) = '9' begin
      select @ABN = stuff( @ABN, @i, 1, '0' )
      select @i = @i + 1
    end
    else begin
      select @ABN = stuff( @ABN, @i, 1, char( ascii(substring(@ABN, @i, 1)) + 1 ) )
      select @carry = 0
    end
  end
  if @i > @len begin
    if substring( @ABN, @len, 1 ) = 'A'
      select @ABN = @ABN + 'A'
    else
      select @ABN = @ABN + '1'
    select @len = @len + 1
  end
  if @len > 10 select @ABN = substring( @ABN, 1, 10 )
  select @NEWBN = reverse( @ABN )
end
GO
