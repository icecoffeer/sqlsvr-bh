SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[Utils_GetOperGid](
  @Oper varchar(30),
  @OperGid int output
)
as
begin
  declare @OperCode varchar(10)
  declare @StartIndex int
  declare @Length int

  set @OperGid = null

  if @Oper is not null and charindex('[', @Oper) > 0 and charindex(']', @Oper) > 0 and charindex('[', @Oper) < charindex(']', @Oper)
  begin
    set @StartIndex = charindex('[', @Oper) + 1
    set @Length = charindex(']', @Oper) - charindex('[', @Oper) - 1
    set @OperCode = substring(@Oper, @StartIndex, @Length)
    set @OperCode = ltrim(rtrim(@OperCode))
    select @OperGid = GID from EMPLOYEEH(nolock)
      where CODE = @OperCode
  end

  if @OperGid is null
    set @OperGid = 1

  return(0)
end
GO
