SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[TaxSortAdj_To100]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @MSG VARCHAR(255) OUTPUT
)
As
Begin
  declare @stat int,
          @eon int,
          @launch datetime,
          @ret int

  set @ret = 0
  select @stat = stat, @launch = launch, @eon = eon from TaxSortAdj where num = @Num
  if @stat <> 0
  begin
    set @MSG = '不能审核不是未审核的单据'
    return 1
  end

  update TaxSortAdj set stat = 100,LstUpdTime = Getdate(), checker = @oper,
    chkdate = getdate()
  where num = @num

  exec TaxSortAdj_ADD_LOG @num, 100, @OPER

  if (@launch is null or @launch < getdate())
    exec @ret = TaxSortAdj_To800 @num, @OPER, @msg output
  if @ret <> 0 set @msg = @msg + ',无法审核生效该单据'
  return @ret
End
GO
