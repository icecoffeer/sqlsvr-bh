SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PayGenChgBook] (
  @piNum varchar(14),         /* 供应商结算单号 */
  @piCls varchar(16),         /* 单据类型，这里是：供应商结算单 */
  @piOperator int,            /* 操作人GID*/
  @poMsg varchar(255) output  /* 返回信息 */
) as
begin
  declare @vRet integer
  declare @vVdrGid integer
  declare @vChgBookStat integer
  declare @vChgBookNum varchar(14)
  declare @vOper varchar(50)

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperator
  if @piCls = '供应商结算单'
  begin
    select @vVdrGid = BILLTO from PAY where NUM = @piNum
    exec @vRet = PCT_CHGBOOK_OCCUR_GEN @vVdrGid, '供应商结算单', @piNum, @piOperator, @poMsg output
    if @vRet <> 0 return(@vRet)

    exec OPTREADSTR 3004, 'PayGenChgBookStat', '0', @vChgBookStat output
    if @vChgBookStat <> '0'
    begin
      --自动审核费用单
      if object_id('c_ChgBook') is not null deallocate c_ChgBook
      declare c_ChgBook cursor for
        select NUM from TMPGENBILLS where SPID = @@spid and OWNER = '生成费用单'
      open c_ChgBook
      fetch next from c_ChgBook into @vChgBookNum
      while @@fetch_status = 0
      begin
        exec @vRet = ChgBookChk @vChgBookNum, @vOper, '', @vChgBookStat, @poMsg output
        if @vRet <> 0 
        begin
          close c_ChgBook
          deallocate c_ChgBook
          return(@vRet)
        end

        fetch next from c_ChgBook into @vChgBookNum
      end
      close c_ChgBook
      deallocate c_ChgBook
    end
  end

  return(0)
end
GO
