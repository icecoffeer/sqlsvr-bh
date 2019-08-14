SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherSellSingle]
(
    @num varchar(32),
    @type varchar(64),
    @amount decimal(24, 4),
    @sellAmount decimal(24, 4),
    @storeGid int,
    @operator varchar(30),
    @errorMessage varchar(256) OUTPUT
) AS
BEGIN
    DECLARE @UUID VARCHAR(32), @storeGidCount int, @storeGidTemp int, --zhujie
            @ret int,
            @AutoaddtoNumLen int,
            @encryptKey varchar(64),
            @OptnumLength int,
            @NumLen int,
            @VoucherType_Type int; --券种

    IF NOT EXISTS(SELECT 1 FROM Voucher WHERE Num = @num)
    BEGIN
        EXEC OptReadInt 721, 'AutoaddtoNumLen', 0, @AutoaddtoNumLen OUTPUT;
        IF @AutoaddtoNumLen = 0
        BEGIN
          SET @errorMessage = '当前数据库中不存在编号为 ' + @num + ' 的购物券。';
          RETURN(1);
        END;
        ELSE BEGIN
          EXEC OptReadInt 721, 'VoucherNumLength', 0, @OptnumLength OUTPUT;
          SELECT @NumLen = LEN(@num);
          IF @NumLen > @OptnumLength
          BEGIN
            SET @errorMessage = '请求处理的购物券编号 ' + @num + ' 的长度大于规定长度(' + CONVERT(varchar(16), @OptnumLength) + '，无法自动补齐)。';
            RETURN(1);
          END;
          EXEC VoucherNumEncrypt @num, @encryptKey OUTPUT;
          SELECT @num = @num + SUBSTRING(@encryptKey, 1, @OptnumLength - @NumLen);
        END;
    END;

    IF NOT EXISTS(SELECT 1 FROM Voucher WHERE Num = @num)
    BEGIN
        SET @errorMessage = '当前数据库中不存在编号为 ' + @num + ' 的购物券。';
        RETURN(1);
    END;

    IF (SELECT State FROM Voucher WHERE Num = @num) <> 1
    BEGIN
        SET @errorMessage = '购物券 ' + @num + ' 的状态不是已发放，不能进行发售。';
        RETURN(1);
    END;

    if (select VOUCHERTYPE from Voucher where Num = @Num) <> @type
    begin
      set @errorMessage = '购物券' + @num + '的类型不是指定的类型' + @type + '，不能进行发售。';
      return(1);
    end;

    EXEC @ret = VoucherCheckInLmtScope @num, @errormessage output
    if @ret <> 0 return(@ret)

    select @VoucherType_Type = TYPE from VOUCHERTYPE(nolock) where CODE = rtrim(@Type)
    if @VoucherType_Type = 2
      select @sellAmount = @amount
    UPDATE Voucher
    SET State = 4, SellAmount = @sellAmount, AMOUNT = @amount, SellStore = @storeGid, SellOperator = @operator,
           SellTime = GETDATE()
    WHERE Num = @num;
    insert into VOUCHERCASHAUTHOR(NUM, LINE, CODE, FLAG, CODE2, FLAG2, GDGID)
    select @NUM, LINE, CODE, FLAG, CODE2, FLAG2, GDGID from VOUCHERCASHAUTHORTEMP(NOLOCK)
     where ID = @@spid;

    select @storeGidCount = count(1) from VOUCHERCASHSTORETEMP(NOLOCK) where SPID = @@spid;               --zhujie
    if @storeGidCount <> 0
    begin
      declare c_StoreGid cursor for select StoreGid from VOUCHERCASHSTORETEMP(NOLOCK) where SPID = @@spid;
      open c_StoreGid;
      fetch next from c_StoreGid into @storegidTemp;
      while @@fetch_status = 0
      begin
        select @UUID = replace(newid(), '-', '');
        insert into VOUCHERCASHSTORE(UUID, NUM, STOREGID) select @UUID, @NUM, @storeGidTemp;
        fetch next from c_StoreGid into @storegidTemp;
      end;
      close c_StoreGid;
      deallocate c_StoreGid;
    end;

  --购物券时间范围
    insert into vouchercashspan(NUM, astart, afinish)
    select @num, astart, afinish
    from vouchercashspantemp(nolock)
    where spid = @@spid;

    -- 插入日志
    EXEC VoucherWriteLog @num, 1, 4, @operator, @storeGid, '发售购物券成功。';
    SET @errorMessage = NULL;
    RETURN(0);
END;
GO
