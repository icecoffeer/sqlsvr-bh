SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DIRCONFIRMPO](
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

        if (@supplierorderTime is null) and (@rcvtype = '本店送货至顾客处' or @rcvtype = '顾客至本店自提')
        	and (@BuyerOrderType = 0)
        begin
          select @Msg = '送店日期没有填写'
          return(1)
        end

        if @supplierorderTime >= @BuyerOrderTime
        begin
          select @Msg = '送店日期必须小于交货日期'
          return(1)
      	end

	update PURCHASEORDER set STAT = @toStat, CONFIRMER = @oper, CONFIRMDATE = getdate(),
	  SellerRemark = SellerRemark + '，该单据直接确认'
	where NUM = @num and CLS = @cls
	exec PURCHASEORDADDLOG @NUM, @CLS, @TOSTAT, '直接确认', @OPER

	--确认后自动发送到总部
	select @autosend = OPTIONVALUE from HDOPTION(NOLOCK) where
	  MODULENO = 662 and OPTIONCAPTION = 'AutoSendAfterConfirm'
	if @autoSend = 'Y'
	  exec SENDPOORD @NUM, @oper, @CLS, @ToStat, @Msg output
	return (0)
end
GO
