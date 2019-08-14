SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CHECKPO_TO3200](
  @num char(14),
  @cls char(10),
  @oper varchar(100),
  @ToStat smallInt,
  @Msg varchar(200) output
) with encryption as
begin
    declare
      @sellerApproveOperator varchar(100),
      @sellerApproveTime datetime,
      @supplierorderTime dateTime,
      @sellerRefNum varchar(255),
      @autosend varchar(10),
      @rcvtype varchar(255),
      @BuyerOrderType int,
      @BuyerOrderTime datetime

	    select @sellerApproveOperator = SellerApproveOperator, @sellerApproveTime = SELLERAPPROVETIME, @SellerRefNum = SELLERREFNUMBER,
        @supplierorderTime = SUPPLIERORDERTIME,
        @BuyerOrderType = BuyerOrderType,
        @rcvtype = rcvtype,
        @BuyerOrderTime = BuyerOrderTime
        from PURCHASEORDER(NOLOCK) where NUM = @NUM and CLS = @CLS

        if (@sellerApproveOperator is null) or (@sellerApproveOperator = '')
        begin
            select @msg = '供应商确认人没有填写'
            return(1)
        end
        if (@sellerApproveTime is null)
        begin
          select @Msg = '供应商确认日期没有填写'
          return(1)
        end

        if (@supplierorderTime is null) and (@rcvtype = '本店送货至顾客处' or @rcvtype = '顾客至本店自提')
        	and (@BuyerOrderType = 0)
        begin
          select @Msg = '送店日期没有填写'
          return(1)
        end

        /*if @supplierorderTime >= @BuyerOrderTime
        begin
          select @Msg = '送店日期必须小于交货日期'
          return(1)
      	end*/

	update PURCHASEORDER set STAT = @toStat, CONFIRMER = @oper, CONFIRMDATE = getdate() where NUM = @num and CLS = @cls
	exec PURCHASEORDADDLOG @NUM, @CLS, @TOSTAT, '', @OPER

	--确认后自动发送到总部
	select @autosend = OPTIONVALUE from HDOPTION(NOLOCK) where
	  MODULENO = 662 and OPTIONCAPTION = 'AutoSendAfterConfirm'
	if @autoSend = 'Y'
	  exec SENDPOORD @NUM, @oper, @CLS, @ToStat, @Msg output
	return (0)
end
GO
