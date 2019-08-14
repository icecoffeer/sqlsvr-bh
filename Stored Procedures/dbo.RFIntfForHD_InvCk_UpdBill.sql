SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_InvCk_UpdBill](
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status int,
    @vBillName varchar(10),
    @vNum varchar(14),
    @vRecCnt int

  set @return_status = 0

  if exists(select * from master..syscursors where cursor_name = 'c_RFPCkGenBills')
    deallocate c_RFPCkGenBills
  declare c_RFPCkGenBills cursor for
    select BILLNAME, NUM
    from RFPCKGENBILLS(nolock)
    where SPID = @@spid
  open c_RFPCkGenBills
  fetch next from c_RFPCkGenBills into @vBillName, @vNum
  while @@fetch_status = 0
  begin
    if @vBillName = '盘点单'
    begin
      select @vRecCnt = count(*) from PCKDTL(nolock)
        where NUM = @vNum
      if @vRecCnt = 0
      begin
        delete from PCK where NUM = @vNum
        delete from PCKDTL where NUM = @vNum
      end
      else begin
        --修改汇总的明细数
        update PCK set RECCNT = @vRecCnt where NUM = @vNum
        --执行过程PCKCHK
        exec @return_status = PCKCHK @vNum
        if @return_status <> 0
        begin
          set @poErrMsg = '针对新生成的盘点单（单号' + @vNum + '）执行过程PCKCHK时出现异常。'
          goto LABEL_AFTER_LOOP
        end
      end
    end
    fetch next from c_RFPCkGenBills into @vBillName, @vNum
  end
LABEL_AFTER_LOOP:
  close c_RFPCkGenBills
  deallocate c_RFPCkGenBills
  if @return_status is null or @return_status <> 0
    return @return_status

  return 0
end
GO
