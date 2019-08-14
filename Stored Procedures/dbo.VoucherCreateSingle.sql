SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherCreateSingle]
(
    @num varchar(32),
    @type varchar(64),
    @amount decimal(24, 4),
    @operator varchar(30),
    @storeGid int,
    @errorMessage varchar(256) OUTPUT
) AS
BEGIN
    DECLARE
        @enableEncryption int, @numLength int,
        @encryptKey varchar(64),
        @ret int;

    IF EXISTS(SELECT 1 FROM Voucher WHERE Num = @num)
    BEGIN
        SET @errorMessage = '当前数据库中已经存在编号为 ' + @num + ' 的购物券。';
        RETURN(1);
    END;

    EXEC OptReadInt 721, 'VoucherNumLength', 0, @numLength OUTPUT;
    IF LEN(@num) <> @numLength
    BEGIN
        SET @errorMessage = '请求处理的购物券编号 ' + @num + ' 的长度不是规定长度(' + CONVERT(varchar(16), @numLength) + ')。';
        RETURN(1);
    END;

    EXEC @ret = VoucherCheckInLmtScope @num, @errormessage output
    if @ret <> 0 return(@ret)

    EXEC OptReadInt 721, 'EncryptVoucher', 0, @enableEncryption OUTPUT;
    IF @enableEncryption = 1
        EXEC VoucherEncrypt @num, @encryptKey OUTPUT;
    ELSE
        SET @encryptKey = NULL;

    -- 已经加密，插入数据库
    INSERT INTO Voucher(Num, State, Phase, CreateTime, Creator, Amount, EncryptKey, VOUCHERTYPE)
    VALUES(@num, 0, 0, GETDATE(), @operator, @amount, @encryptKey, @type);
    -- 插入日志
    EXEC VoucherWriteLog @num, 0, 0, @operator, @storeGid, '创建购物券成功。';
    SET @errorMessage = NULL;
    RETURN(0);
END;
GO
