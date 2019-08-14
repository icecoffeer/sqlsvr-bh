SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CntrPayCashDoPay] (
  @num char(14),
  @oper varchar(30)
)
as
begin
  declare @return_status int
  declare @vendor int
  declare @chgtype char(20)
  declare @ivccode char(14)
  declare @paytotal money/*付款金额*/
  declare @ivctotal money/*结算单应付金额*/
  declare @ivcpaytotal money/*结算单已付金额*/
  declare @ivcstat int/*结算单状态*/
  declare @ivcvdr int/*结算单供应商*/
  declare @transactor int
  declare @transactorname char(30)
  declare @paydirect int
  declare @billtotal money
  declare @vOperGid int
  declare @vMsg varchar(255)
  declare @vOperCode varchar(20)
  DECLARE @ShenpiVisible INT --zhangzhen
  declare @astat int--zz
  declare @sstat varchar--zz
  --zz 090424
  declare @AllowLocalPay int
  declare @Clecent int
  declare @Usergid int

  EXEC OPTREADINT 0,'ShenpiVisible', 0, @ShenpiVisible OUTPUT --zhangzhen
  --zz 090424
  EXEC OPTREADINT 3108, 'CNTR_AllowLocalPay', 0, @AllowLocalPay OUTPUT
  select @Usergid = usergid from system

  --added by zz
  if @ShenpiVisible = 0
  begin
   select @astat = 1
   select @sstat = '审核'
  end else
  begin
   select @astat = 4100
   select @sstat = '营运审核'
  end
  --added end

  select @return_status = 0
  select @vendor = vdrgid, @transactor = transactor, @billtotal = paytotal
  from CntrPayCash where num = @num
  --if @billtotal <= 0
  --begin
  -- raiserror('单据总金额必须大于0', 16, 1, @num)
  -- return 1
  --end
  select @transactorname = rtrim(name) + '[' + rtrim(code) + ']'
  from employee(nolock) where gid = @oper

  /*回写*/
  declare c_paycash cursor for
  select chgtype, ivccode, paytotal from CntrPayCashDtl
  where num = @num
  open c_paycash
  fetch next from c_paycash into @chgtype, @ivccode, @paytotal
  while @@fetch_status = 0
  begin
   if @chgtype = '供应商结算单'
   begin
      select
        @ivctotal = amt,
        @ivcpaytotal = pytotal,
        @ivcstat = stat,
        @ivcvdr = billto,
        @Clecent = isnull(Clecent, @Usergid)--zz 090424
      from pay(nolock) where num = @ivccode
     if @@rowcount = 0
     begin
       raiserror('供应商结算单%s不存在', 16, 1, @ivccode)
       select @return_status = 1
       break
      end
      if @paytotal <> 0
      begin
        if @ivctotal / @paytotal < 0
        begin
          raiserror('供应商结算单%s应付金额与付款金额不是同号', 16, 1, @ivccode)
         select @return_status = 1
         break
        end
      end
     /* if @ivcpaytotal <> 0
      begin
        if @ivctotal / @ivcpaytotal< 0
        begin
          raiserror('供应商结算单%s应付金额与与已付款金额不是同号', 16, 1, @ivccode)
         select @return_status = 1
         break
        end
      end */  -- sz del 20040224
      --added by zhangzhen 090424
      if @AllowLocalPay = 1 and @Clecent <> @Usergid
      begin
        raiserror('供应商结算单有所属结算中心,不能在本店付款', 16, 1)
        select @return_status = 1
        break
      end
      --added end
      if @ivcvdr <> @vendor
      begin
       raiserror('供应商结算单%s不是该供应商的结算单', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if @ivcstat <> @astat
      begin
       raiserror('供应商结算单%s不是已%s单据', 16, 1, @ivccode, @sstat)--zz
       select @return_status = 1
       break
      end
      else if ABS(@ivcpaytotal + @paytotal) > ABS(@ivctotal)
      begin
       raiserror('付款单%s中的供应商结算单%s的付款金额超过剩余应付金额', 16, 1, @num, @ivccode)
       select @return_status = 1
       break
      end else
      begin
        update pay set pytotal = @ivcpaytotal + @paytotal
        where num = @ivccode
      end
    end else if @chgtype = '代销结算单'
    begin
      select
        @ivctotal = amt,
        @ivcstat = stat,
        @ivcpaytotal = paytotal,
        @ivcvdr = billto
      from svi(nolock) where num = @ivccode and cls= '代销'
     if @@rowcount = 0
     begin
       raiserror('代销结算单%s不存在', 16, 1, @ivccode)
       select @return_status = 1
       break
      end
      if @paytotal <> 0
      begin
        if @ivctotal / @paytotal < 0
        begin
          raiserror('代销结算单%s应付金额与付款金额不是同号', 16, 1, @ivccode)
         select @return_status = 1
         break
        end
      end
      /* if @ivcpaytotal <> 0
      begin
        if @ivctotal / @ivcpaytotal < 0
        begin
          raiserror('代销结算单%s应付金额与已付款金额不是同号', 16, 1, @ivccode)
         select @return_status = 1
         break
        end
      end */  -- sz del 20040224
      if @ivcvdr <> @vendor
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
      else if ABS(@ivcpaytotal + @paytotal) > ABS(@ivctotal)
      begin
       raiserror('付款单%s中的代销结算单%s的付款金额超过剩余应付金额', 16, 1, @num, @ivccode)
       select @return_status = 1
       break
      end else
      begin
        update svi set paytotal = @ivcpaytotal + @paytotal
        where num = @ivccode and cls = '代销'
      end
    end else if @chgtype = '联销结算单'
    begin
      select
        @ivctotal = amt,
        @ivcpaytotal = paytotal,
        @ivcstat = stat,
        @ivcvdr = billto
      from svi(nolock) where num = @ivccode and cls= '联销'
     if @@rowcount = 0
     begin
       raiserror('联销结算单%s不存在', 16, 1, @ivccode)
       select @return_status = 1
       break
      end
      if @paytotal <> 0
      begin
        if @ivctotal / @paytotal < 0
        begin
          raiserror('联销结算单%s应付金额与付款金额不是同号', 16, 1, @ivccode)
         select @return_status = 1
         break
        end
      end
    /*  if @ivcpaytotal <> 0
      begin
        if @ivctotal / @ivcpaytotal < 0
        begin
          raiserror('联销结算单%s应付金额与已付款金额不是同号', 16, 1, @ivccode)
         select @return_status = 1
         break
        end
      end */  -- sz del 20040224
      if @ivcvdr <> @vendor
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
      else if ABS(@ivcpaytotal + @paytotal) > ABS(@ivctotal)
      begin
       raiserror('付款单%s中的联销结算单%s的付款金额超过剩余应付金额', 16, 1, @num, @ivccode)
       select @return_status = 1
       break
      end else
      begin
        update svi set paytotal = @ivcpaytotal + @paytotal
        where num = @ivccode and cls = '联销'
      end
   --ShenMin
    end else if @chgtype = '发票'
    begin
      select
        @ivctotal = INVTOTAL,
        @ivcstat = STAT,
        @ivcpaytotal = INVPAIDAMT,
        @ivcvdr = BILLTO
      from INVOICE(nolock) where num = @ivccode
     if @@rowcount = 0
     begin
       raiserror('发票%s不存在', 16, 1, @ivccode)
       select @return_status = 1
       break
      end
      if @paytotal <> 0
      begin
        if @ivctotal / @paytotal < 0
        begin
          raiserror('发票%s应付金额与付款金额不是同号', 16, 1, @ivccode)
         select @return_status = 1
         break
        end
      end
      if @ivcvdr <> @vendor
      begin
       raiserror('发票%s不是该供应商的发票', 16, 1, @ivccode)
       select @return_status = 1
       break
      end else if (@ivcstat <> 600) and (@ivcstat <> 904)
      begin
       raiserror('发票%s不是已复核或付款中的发票', 16, 1, @ivccode)
       select @return_status = 1
       break
      end
      else if ABS(@ivcpaytotal + @paytotal) > ABS(@ivctotal)
      begin
       raiserror('付款单%s中的发票%s的付款金额超过剩余应付金额', 16, 1, @num, @ivccode)
       select @return_status = 1
       break
      end
      else if @paytotal > (select SUM(LFTTOTAL) from SHOULDPAYCURRENT where NUM = @ivccode and CLS = 0)
      begin
       raiserror('付款单%s中的发票%s的付款金额超过了该发票在财务应付款报表中应付金额的总和', 16, 1, @num, @ivccode)
       select @return_status = 1
       break
      end
      else
      begin
        declare
          @IvcLine int,
          @ShouldPayCls varchar(30),
          @ShouldPayNum varchar(14),
          @LeftTotal money,
          @ShouldPayStat int,
          @ShouldPayTotal money,
          @ShouldPayPayTotal money,
          @IvcShouldPayTotal money

        select @IvcShouldPayTotal = @paytotal;
        declare c_paycashInvoice cursor for
          select LINE, SHOULDPAYCLS, SHOULDPAYNUM, LFTTOTAL from SHOULDPAYCURRENT
          where NUM = @ivccode and CLS = 0
          order by LINE;
          open c_paycashInvoice;
          fetch next from c_paycashInvoice into @IvcLine, @ShouldPayCls, @ShouldPayNum, @LeftTotal;
          while @@fetch_status = 0
            begin
              if @LeftTotal > @IvcShouldPayTotal
                select @LeftTotal = @IvcShouldPayTotal;
              if @ShouldPayCls = '供应商结算单'
                begin
                  select
                    @ShouldPayTotal = amt,
                    @ShouldPayPayTotal = pytotal,
                    @ShouldPayStat = stat,
                    @Clecent = isnull(Clecent, @Usergid)--zz 090424
                  from pay(nolock) where num = @ShouldPayNum;
                 if @@rowcount = 0
                 begin
                   raiserror('供应商结算单%s不存在', 16, 1, @ShouldPayNum);
                   select @return_status = 1;
                   break;
                  end;
                  if @ShouldPayTotal <> 0
                  begin
                    if @ivctotal / @LeftTotal < 0
                    begin
                      raiserror('供应商结算单%s应付金额与付款金额不是同号', 16, 1, @ShouldPayNum);
                     select @return_status = 1;
                     break;
                    end;
                  end;
                  if @ShouldPayStat <> @astat
                  begin
                   raiserror('供应商结算单%s不是已%s单据', 16, 1, @ShouldPayNum, @sstat);--zz
                   select @return_status = 1;
                   break;
                  end;
                  if ABS(@LeftTotal + @ShouldPayPayTotal) > ABS(@ShouldPayTotal)
                  begin
                   raiserror('发票%s中的供应商结算单%s的付款金额超过剩余应付金额', 16, 1, @ivccode, @ShouldPayNum);
                   select @return_status = 1;
                   break;
                  end;
                  --added by zhangzhen 090424
                  if @AllowLocalPay = 1 and @Clecent <> @Usergid
                  begin
                    raiserror('发票%s中的供应商结算单%s有所属结算中心,不能在本店付款', 16, 1, @ivccode, @ShouldPayNum);
                    select @return_status = 1;
                    break;
                  end
                  --added end
                  update PAY set PYTOTAL = PYTOTAL + @LeftTotal
                  where num = @ShouldPayNum;

                  update SHOULDPAYRPT
                  set PYTOTAL = PYTOTAL + @LeftTotal
                  where NUM = @ivccode and CLS = 0 and LINE = @IvcLine;

                  update INVOICEDTL
                  set PYTOTAL = PYTOTAL + @LeftTotal
                  where NUM = @ivccode and LINE = @IvcLine;
                end;
              else if @ShouldPayCls = '代销结算单'
                begin
                  select
                    @ShouldPayTotal = amt,
                    @ShouldPayPayTotal = paytotal,
                    @ShouldPayStat = stat
                  from SVI(nolock)
                  where NUM = @ShouldPayNum and CLS = '代销';
                 if @@rowcount = 0
                 begin
                   raiserror('代销结算单%s不存在', 16, 1, @ShouldPayNum);
                   select @return_status = 1;
                   break;
                  end;
                  if @ShouldPayTotal <> 0
                  begin
                    if @ivctotal / @LeftTotal < 0
                    begin
                      raiserror('代销结算单%s应付金额与付款金额不是同号', 16, 1, @ShouldPayNum);
                     select @return_status = 1;
                     break;
                    end;
                  end;
                  if @ShouldPayStat <> 1
                  begin
                   raiserror('代销结算单%s不是已审核单据', 16, 1, @ShouldPayNum);
                   select @return_status = 1;
                   break;
                  end;
                  if ABS(@LeftTotal + @ShouldPayPayTotal) > ABS(@ShouldPayTotal)
                  begin
                   raiserror('发票%s中的代销结算单%s的付款金额超过剩余应付金额', 16, 1, @ivccode, @ShouldPayNum);
                   select @return_status = 1;
                   break;
                  end;
                  update SVI set PAYTOTAL = PAYTOTAL + @LeftTotal
                  where NUM = @ShouldPayNum and CLS = '代销';

                  update SHOULDPAYRPT
                  set PYTOTAL = PYTOTAL + @LeftTotal
                  where NUM = @ivccode and CLS = 0 and LINE = @IvcLine;

                  update INVOICEDTL
                  set PYTOTAL = PYTOTAL + @LeftTotal
                  where NUM = @ivccode and LINE = @IvcLine;
                end;
              else if @ShouldPayCls = '联销结算单'
                begin
                  select
                    @ShouldPayTotal = amt,
                    @ShouldPayPayTotal = paytotal,
                    @ShouldPayStat = stat
                  from SVI(nolock)
                  where NUM = @ShouldPayNum and CLS = '联销';
                 if @@rowcount = 0
                 begin
                   raiserror('联销结算单%s不存在', 16, 1, @ShouldPayNum);
                   select @return_status = 1;
                   break;
                  end;
                  if @ShouldPayTotal <> 0
                  begin
                    if @ivctotal / @LeftTotal < 0
                    begin
                      raiserror('联销结算单%s应付金额与付款金额不是同号', 16, 1, @ShouldPayNum);
                     select @return_status = 1;
                     break;
                    end;
                  end
                  if @ShouldPayStat <> 1
                  begin
                   raiserror('联销结算单%s不是已审核单据', 16, 1, @ShouldPayNum);
                   select @return_status = 1;
                   break;
                  end
                  else if ABS(@LeftTotal + @ShouldPayPayTotal) > ABS(@ShouldPayTotal)
                  begin
                   raiserror('发票%s中的联销结算单%s的付款金额超过剩余应付金额', 16, 1, @ivccode, @ShouldPayNum);
                   select @return_status = 1;
                   break;
                  end else
                  begin
                    update SVI set PAYTOTAL = PAYTOTAL + @LeftTotal
                    where NUM = @ShouldPayNum and CLS = '联销';

                    update SHOULDPAYRPT
                    set PYTOTAL = PYTOTAL + @LeftTotal
                    where NUM = @ivccode and CLS = 0 and LINE = @IvcLine;

                    update INVOICEDTL
                    set PYTOTAL = PYTOTAL + @LeftTotal
                    where NUM = @ivccode and LINE = @IvcLine;
                  end
                end;
              select @IvcShouldPayTotal = @IvcShouldPayTotal - @LeftTotal;
              if @IvcShouldPayTotal <= 0
                break;
              fetch next from c_paycashInvoice into @IvcLine, @ShouldPayCls, @ShouldPayNum, @LeftTotal;
            end;
            close c_paycashInvoice;
            deallocate c_paycashInvoice;

        update INVOICE set INVPAIDAMT = INVPAIDAMT + @paytotal - @IvcShouldPayTotal, STAT = 904
        where NUM = @ivccode;

        if (select count(1) from INVOICE(nolock) where NUM = @ivccode and INVPAIDAMT = INVTOTAL) > 0
          begin
            exec @return_status = INVOICECHK @ivccode, 900, @oper, @vMsg output;
            if @return_status <> 0
            begin
              raiserror(@vMsg, 16, 1);
              break;
            end;
          end;
      end;

    end else if @chgtype = '费用单'
    begin
      exec PCT_Utils_ExtractCode @Oper, @vOperCode output
      select @vOperGid = GID from EMPLOYEE where CODE = @vOperCode
      if @vOperGid is null set @vOperGid = 1
      exec @return_status = PCT_CHGBOOK_DEDUCT @IvcCode, @PayTotal, @vOperGid, @vMsg output
      if @return_status <> 0
      begin
        raiserror(@vMsg, 16, 1)
        break
      end
    end else if @chgtype = '预付款单'
    begin
      select
        @ivctotal = total,
        @ivcstat = stat,
        @ivcvdr = vendor,
        @ivcpaytotal = totaloff,
        @Clecent = isnull(CLECENT, @Usergid)--zz 090424
      from cntrprepay(nolock) where num = @ivccode

      --added by zhangzhen 090424
      if @AllowLocalPay = 1 and @Clecent <> @Usergid
      begin
        raiserror('预付款单有所属结算中心,不能在本店付款', 16, 1)
        select @return_status = 1
        break
      end
      --added end
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
      end else if @ivcpaytotal + @paytotal > @ivctotal
      begin
       raiserror('付款单%s中的预付款单%s的付款金额超过剩余应付金额', 16, 1, @num, @ivccode)
       select @return_status = 1
       break
      end else if @ivcpaytotal + @paytotal = @ivctotal
      begin
       update cntrprepay set totaloff = @ivctotal, stat = 300
       where num = @ivccode
      end else
      begin
       update cntrprepay set totaloff = @ivcpaytotal + @paytotal
       where num = @ivccode
      end
    end else if @chgtype = '压库金额收款单'
    begin
      select
        @ivctotal = total,
        @ivcstat = stat,
        @ivcvdr = vendor,
        @ivcpaytotal = TOTALOFF
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
      end else if @ivcpaytotal + @paytotal > @ivctotal
      begin
       raiserror('付款单%s中的压库金额收款单%s的付款金额超过剩余应付金额', 16, 1, @num, @ivccode)
       select @return_status = 1
       break
      end else if @ivcpaytotal + @paytotal = @ivctotal
      begin
       update CNTRDPTBILL set totaloff = @ivctotal, stat = 2400
       where num = @ivccode and cls = '收'

       if not exists(select 1 from cntrdpt(nolock) where vendor = @vendor)
          insert into cntrdpt(vendor, total, lstupdtime, lstupdcls, lstupdnum)
          values(@vendor, - @paytotal, getdate(), '付款单', @num)
        else
          update cntrdpt set
            total = total - @paytotal,
            lstupdtime = getdate(),
            lstupdcls = '付款单',
            lstupdnum = @num
          where vendor = @vendor
      end else
      begin
       update CNTRDPTBILL set totaloff = @ivcpaytotal + @paytotal
       where num = @ivccode and cls = '收'

       if not exists(select 1 from cntrdpt(nolock) where vendor = @vendor)
          insert into cntrdpt(vendor, total, lstupdtime, lstupdcls, lstupdnum)
          values(@vendor, - @paytotal, getdate(), '付款单', @num)
        else
          update cntrdpt set
            total = total - @paytotal,
            lstupdtime = getdate(),
            lstupdcls = '付款单',
            lstupdnum = @num
          where vendor = @vendor
      end
    end else if @chgtype = '抵扣货款单'
    begin
      exec PCT_Utils_ExtractCode @Oper, @vOperCode output
      select @vOperGid = GID from EMPLOYEE where CODE = @vOperCode
      if @vOperGid is null set @vOperGid = 1
      exec @return_status = PCT_PGFBOOK_DEDUCT @IvcCode, @PayTotal, @vOperGid, @vMsg output
      if @return_status <> 0
      begin
        raiserror(@vMsg, 16, 1)
        break
      end
    end

   fetch next from c_paycash into @chgtype, @ivccode, @paytotal
  end
  close c_paycash
  deallocate c_paycash

  if @return_status <> 0 return @return_status

  exec @return_status = CntrPayCashSend @num, @vMsg output
  if @return_status <> 0 return @return_status

  --付款时生成费用单
  declare @ioper int
  declare @poMsg varchar(255)
  select @ioper = isnull(gid, 1) from employee(nolock) where code = substring(@oper, charindex('[', @oper) + 1, len(@oper) - charindex('[', @oper) - 1)
  set @ioper = isnull(@ioper, 1)
  exec @return_status = PCT_CHGBOOK_OCCUR_GEN @vendor, '付款单', @Num, @ioper, @poMsg output

  return @return_status
end
GO
