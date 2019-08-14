SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[StoreOrdApplyRcv]
(
  @id int,
  @msg varchar(50) OUTPUT
) AS
BEGIN
  DECLARE
    -- 门店代码
    @userGid int,
    -- 单据目前的状态
    @currentStat int,
    -- 是否总部标识
    @userProperty int,
    -- 单号
    @num varchar(14);

  SELECT @userGid = UserGid FROM System;
  SELECT @currentStat = Stat FROM NStoreOrdApply WHERE ID = @id;
  SELECT @userProperty = UserProperty FROM System;
  SELECT @num = Num FROM NStoreOrdApply WHERE ID = @id;

   -- 发送时，如果本店是总部，则不能接收。
  IF @userProperty & 16 = 16 AND @currentStat <> 401
  BEGIN
    SET @msg = '本店是总部，不能接收非请求总部批准的单据。';
    RETURN 1;
  END;

  -- 如果是门店，则不能接收未完成单据。
  IF (@userProperty & 4 = 4 OR @userProperty & 2 = 2) AND NOT (@currentStat IN (300, 410, 400))
  BEGIN
    SET @msg = '本店是门店，但是不能接收未完成的单据。';
    RETURN 1;
  END; 

  -- 本单位生成的单据不能接收
  IF (@userProperty & 4 = 4 OR @userProperty & 2 = 2) AND
    (EXISTS (SELECT Num FROM NStoreOrdApply WHERE Num = @num AND StoreGid = @userGid AND (NOT Stat IN (300, 400, 410))))
  BEGIN
    SET @msg = '本店是门店，但试图接收本单位生成的未处理单据。';
    RETURN 1;
  END

  -- 不是请求总部批准和已完成的单据不能接收
  IF NOT (@currentStat IN (401, 410, 400, 300)) 
  BEGIN
    SET @msg = '非请求总部批准和/或已完成单据不能接收。';
    RETURN 1;
  END;

  -- 存在的单据不能重复接收
  IF EXISTS(SELECT 1 FROM StoreOrdApply WHERE Num = @num)
  BEGIN
    IF @userProperty & 16 = 16
    BEGIN
      SET @msg = '该单据已被接收，不能重复接收。';
      RETURN 1;
    END;
    
    IF @userProperty & 4 = 4 OR @userProperty & 2 = 2
    BEGIN
      DELETE StoreOrdApply WHERE Num = @num;
      DELETE StoreOrdApplyDtl WHERE Num = @num;
    END;
  END;

  -- 准备接收。有两种情况：
  -- 1、总部接受门店将请求总部批准的单据，
  -- 2、门店接收总部已完成的单据。
  IF (@userProperty & 4 = 4 OR @userProperty & 2 = 2) AND @currentStat IN (300, 410, 400)
  BEGIN
    -- 插入汇总
    INSERT StoreOrdApply(Num, StoreGid, VendorGid, RecCnt, Stat, Filler, FillDate, OpDate, GenNum, Memo, Type, TaxRateLmt, DeptLmt, Checker, GenNum2, SettleNo, ApplyDGid) 
    SELECT Num, StoreGid, VendorGid, RecCnt, Stat, Filler, FillDate, GETDATE(), GenNum, Memo, Type, TaxRateLmt, DeptLmt, Checker, GenNum2, SettleNo, ApplyDGid
    FROM NStoreOrdApply
    WHERE ID = @id AND StoreGid = @userGid AND Stat IN (300, 410, 400) AND NType = 1;

    -- 插入明细
    INSERT StoreOrdApplyDtl(Num, Line, GDGid, GDCode, QPC, QpcStr, Qty, ApplyQty, Note, ExcgQty)
    SELECT d.Num, d.Line, d.GDGid, d.GDCode, d.Qpc, d.QpcStr, d.Qty, d.ApplyQty, d.Note, d.ExcgQty
    FROM NStoreOrdApplyDtl d, NStoreOrdApply m
    WHERE d.ID = @id AND m.ID = d.ID AND m.StoreGid = @userGid AND m.Stat IN (300, 410, 400) AND m.NType = 1;

    -- 删除
    DELETE NStoreOrdApply WHERE ID = @id;
    DELETE NStoreOrdApplyDtl WHERE ID = @id;
  
    RETURN 0;
  END;

  -- 总部回发
  IF @userProperty & 16 = 16 AND @currentStat = 401
  BEGIN
    -- 插入汇总
    INSERT StoreOrdApply(Num, StoreGid, VendorGid, RecCnt, Stat, Filler, FillDate, OpDate, GenNum, Memo, Type, TaxRateLmt, DeptLmt, Checker, GenNum2, SettleNo, ApplyDGid) 
    SELECT Num, StoreGid, VendorGid, RecCnt, Stat, Filler, FillDate, GETDATE(), GenNum, Memo, Type, TaxRateLmt, DeptLmt, Checker, GenNum2, SettleNo, ApplyDGid
    FROM NStoreOrdApply
    WHERE ID = @id AND StoreGid <> @userGid AND Stat = 401 AND NType = 1;

    -- 插入明细
    INSERT StoreOrdApplyDtl(Num, Line, GDGid, GDCode, QPC, QpcStr, Qty, ApplyQty, Note, ExcgQty)
    SELECT d.Num, d.Line, d.GDGid, d.GDCode, d.Qpc, d.QpcStr, d.Qty, d.ApplyQty, d.Note, d.ExcgQty
    FROM NStoreOrdApplyDtl d, NStoreOrdApply m
    WHERE d.ID = @id AND m.Stat = 401 AND m.ID = d.ID AND m.StoreGid <> @userGid AND m.NType = 1;

    -- 删除
    DELETE NStoreOrdApply WHERE ID = @id;
    DELETE NStoreOrdApplyDtl WHERE ID = @id;

    RETURN 0;
  END;
  
  SET @msg = '未知错误，请联系您的系统管理员。';
  RETURN 1;
END;
GO
