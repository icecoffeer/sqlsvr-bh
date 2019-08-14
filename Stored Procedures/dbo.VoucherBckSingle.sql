SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherBckSingle]
(
    @num varchar(32),
    @storeGid int,
    @operator varchar(30),
    @errorMessage varchar(256) OUTPUT
) AS
BEGIN
    DECLARE @currentState int;
    declare @vouchertype int;

    select @currentState = V.State, @vouchertype = VT.TYPE from Voucher V(nolock), VOUCHERTYPE VT(nolock)
    where V.Num = @num
      and V.VOUCHERTYPE = VT.CODE;

    if @@Rowcount = 0
    begin
        SET @errorMessage = '当前数据库中不存在编号为 ' + @num + ' 的购物券。';
        RETURN(1);
    end;

    IF NOT EXISTS(SELECT 1 FROM Store WHERE Gid = @storeGid)
    BEGIN
        SET @errorMessage = '编号为 ' + CONVERT(varchar(16), @storeGid) + ' 的门店不存在。';
        RETURN(1);
    END;


    if @currentState <> 4
    begin
        set @errorMessage = '购物券 ' + @num + ' 的状态不是已发售，不能进行回退。';
        return(1);
    end;

    if @vouchertype = 0
      update Voucher
      set State = 1,
          SellAmount = 0.00,
          SellStore = null,
          SellOperator = null,
          SellTime = null
      where Num = @num
     else
      update Voucher
      set STATE = 1,
          AMOUNT = 0.00,
          SELLAMOUNT = 0.00,
          SELLSTORE = NULL,
          SELLOPERATOR = NULL,
          SELLTIME = NULL
      where Num = @num;

    delete from VOUCHERCASHAUTHOR
    WHERE Num = @num;
    delete from VOUCHERCASHSTORE
    WHERE Num = @num;
    delete from VOUCHERCASHSPAN where NUM = @num
    -- 插入日志
    EXEC VoucherWriteLog @num, @currentState, 1, @operator, @storeGid, '回退购物券成功。';
    SET @errorMessage = NULL;

    RETURN(0);
END;
GO
