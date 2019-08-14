SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CntrPayCashDoChk] (
  @num char(14)
)
as
begin
  declare @vendor int
  declare @return_status int
  declare @chgtype char(20)
  declare @ivccode char(14)
  declare @ivcstat int
  declare @ivcvdr int
  declare @paytotal money
  declare @billtotal money
  declare @Amt Money
  --zz 090512
  declare @AllowLocalPay int
  declare @Clecent int
  declare @Usergid int

  --zz 090512
  EXEC OPTREADINT 3108, 'CNTR_AllowLocalPay', 0, @AllowLocalPay OUTPUT
  select @Usergid = usergid from system

  select @return_status = 0
  select @vendor = vdrgid, @billtotal = paytotal from CntrPayCash where num = @num
  --if @billtotal <= 0
  --begin
  -- raiserror('单据总金额必须大于0', 16, 1, @num)
  -- return 1
  --end

  declare c_paycash cursor for
  select chgtype, ivccode, paytotal, IvcAmt from CntrPayCashDtl
  where num = @num
  open c_paycash
  fetch next from c_paycash into @chgtype, @ivccode, @paytotal, @Amt
  while @@fetch_status = 0
  begin
        if @paytotal <> 0
        begin
          if @Amt / @paytotal < 0
          begin
            raiserror('%s%s应付金额与付款金额不是同号', 16, 1, @chgtype,@ivccode)
           select @return_status = 1
           break
          end
        end
   if @chgtype = '供应商结算单'
   begin
      select
        @ivcstat = stat,
        @ivcvdr = billto,
        @Clecent = isnull(Clecent, @Usergid)--zz 090424
      from pay(nolock) where num = @ivccode
     if @@rowcount = 0
     begin
       raiserror('供应商结算单%s不存在', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if @ivcvdr <> @vendor
      begin
       raiserror('供应商结算单%s不是该供应商的结算单', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if (@ivcstat <> 1)
      begin
       raiserror('供应商结算单%s不是已审核单据', 16, 1, @ivccode)
       select @return_status = 1
       break
      end
      --added by zhangzhen 090512
      if @AllowLocalPay = 1 and @Clecent <> @Usergid
      begin
        raiserror('供应商结算单有所属结算中心,不能在本店审核', 16, 1)
        select @return_status = 1
        break
      end
      --added end
    end else if @chgtype = '代销结算单'
    begin
      select
        @ivcstat = stat,
        @ivcvdr = billto
      from svi(nolock) where num = @ivccode and cls= '代销'
     if @@rowcount = 0
     begin
       raiserror('代销结算单%s不存在', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if @ivcvdr <> @vendor
      begin
       raiserror('代销结算单%s不是该供应商的结算单', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if @ivcstat <> 1
      begin
       raiserror('代销结算单%s不是已审核单据', 16, 1, @ivccode)
       select @return_status = 1
       break
      end
    end else if @chgtype = '联销结算单'
    begin
      select
        @ivcstat = stat,
        @ivcvdr = billto
      from svi(nolock) where num = @ivccode and cls= '联销'
     if @@rowcount = 0
     begin
       raiserror('联销结算单%s不存在', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if @ivcvdr <> @vendor
      begin
       raiserror('联销结算单%s不是该供应商的结算单', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if @ivcstat <> 1
      begin
       raiserror('联销结算单%s不是已审核单据', 16, 1, @ivccode)
       select @return_status = 1
       break
      end
     --ShenMin
    end else if @chgtype = '发票'
    begin
      select
        @ivcstat = stat,
        @ivcvdr = billto
      from INVOICE(nolock) where NUM = @ivccode and STAT in (600, 904)
     if @@rowcount = 0
     begin
       raiserror('发票%s不存在', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if @ivcvdr <> @vendor
      begin
       raiserror('发票%s不是该供应商的发票', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if (@ivcstat <> 600) and (@ivcstat <> 904)
      begin
       raiserror('发票%s不是已复核或付款中的单据', 16, 1, @ivccode)
       select @return_status = 1
       break
      end
    end else if @chgtype = '费用单'
    begin
      select
        @ivcstat = stat,
        @ivcvdr = vendor,
        @Clecent = isnull(CASHCENTER, @Usergid)--zz 090512
      from chgbook(nolock) where num = @ivccode
     if @@rowcount = 0
     begin
       raiserror('费用单%s不存在', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if @ivcvdr <> @vendor
      begin
       raiserror('费用单%s不是该供应商的费用单', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if @ivcstat <> 500
      begin
       raiserror('费用单%s不是已审核单据', 16, 1, @ivccode)
       select @return_status = 1
       break
      end
      --added by zhangzhen 090512
      if @AllowLocalPay = 1 and @Clecent <> @Usergid
      begin
        raiserror('费用单有所属结算中心,不能在本店审核', 16, 1)
        select @return_status = 1
        break
      end
      --added end
    end else if @chgtype = '预付款单'
    begin
      select
        @ivcstat = stat,
        @ivcvdr = vendor,
        @Clecent = isnull(CLECENT, @Usergid)--zz 090512
      from cntrprepay(nolock) where num = @ivccode
     if @@rowcount = 0
     begin
       raiserror('预付款单%s不存在', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if @ivcvdr <> @vendor
      begin
       raiserror('预付款单%s不是该供应商的预付款单', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if @ivcstat <> 900
      begin
       raiserror('预付款单%s不是已付款单据', 16, 1, @ivccode)
       select @return_status = 1
       break
      end
      --added by zhangzhen 090512
      if @AllowLocalPay = 1 and @Clecent <> @Usergid
      begin
        raiserror('预付款单有所属结算中心,不能在本店审核', 16, 1)
        select @return_status = 1
        break
      end
      --added end
     end else if @chgtype = '压库金额收款单'
      begin
      select
        @ivcstat = stat,
        @ivcvdr = vendor
      from CNTRDPTBILL(nolock) where num = @ivccode and cls = '收'
     if @@rowcount = 0
     begin
       raiserror('压库金额收款单%s不存在', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if @ivcvdr <> @vendor
      begin
       raiserror('压库金额收款单%s不是该供应商的压库金额收款单', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if @ivcstat <> 1800
      begin
       raiserror('压库金额收款单%s不是已收款单据', 16, 1, @ivccode)
       select @return_status = 1
       break
      end
    end

   fetch next from c_paycash into @chgtype, @ivccode, @paytotal, @Amt
  end
  close c_paycash
  deallocate c_paycash

  return @return_status
end
GO
