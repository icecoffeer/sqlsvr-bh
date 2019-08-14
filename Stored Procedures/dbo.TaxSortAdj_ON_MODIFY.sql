SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[TaxSortAdj_ON_MODIFY]
(
  @num char(14),
  @tostat int,
  @oper varchar(30),
  @msg varchar(255) output
)
as
begin
  declare
    @return_status int
  set @return_status = 0
  if @tostat = 0
  begin
    update TaxSortADJ set LSTUPDTIME = getdate(), checker = @oper
      where NUM = @num
    exec TaxSortAdj_ADD_LOG @num, @tostat, @oper 
  end
  else if @tostat = 100
  begin
    exec @return_status = TaxSortAdj_To100 @num, @oper, @msg output
  end
  else
  begin
    set @msg = '未定义的目标状态：' + ltrim(str(@tostat))
    set @return_status = 1
  end
  return(@return_status)
end
GO
