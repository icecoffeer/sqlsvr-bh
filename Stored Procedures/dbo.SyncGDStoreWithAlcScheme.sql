SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SyncGDStoreWithAlcScheme]
(
    @code varchar(10),                                   -- [入] 方案代码
    @oper varchar(30) = '未知[-]',                   -- [入] 操作人
    @errorMessage varchar(256) OUTPUT      -- [出] 消息
) AS
BEGIN
    -- 方案必须存在
    IF NOT EXISTS (SELECT 1 FROM AlcScheme WHERE Code = @code)
    BEGIN
        SET @errorMessage = '方案 ' + CHAR(39) + @code + CHAR(39) + ' 不存在。';
        RETURN -1;
    END;

    -- 所有用到该配送方案的门店商品游标
    DECLARE StoreGoodsCursor CURSOR FOR
        SELECT g.GDGid, g.StoreGid FROM GDStore AS g, Store AS s, AlcSchemeDtl AS d
        WHERE s.Gid = g.StoreGid AND d.GDGid = g.GDGid AND s.AlcScheme = d.Code AND s.AlcScheme = @code;
    DECLARE @c_gdGid int, @c_storeGid int;

    OPEN StoreGoodsCursor;
    fETCH NEXT FROM StoreGoodsCursor INTO @c_gdGid, @c_storeGid;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE GDStore
        SET GDStore.Alc = d.Alc, GDStore.AlcQty = d.AlcQty, GDStore.SuggestedQtyLowBound = d.SuggestedQtyLowBound,
               GDStore.SuggestedQtyHighBound = d.SuggestedQtyHighBound, GDStore.SuggestedQty = d.SuggestedQty,
                GDStore.OrdQtyMin = d.OrdQtyMin, GDStore.BillTo = d.VdrGid, GDStore.IsLtd = d.Limit, GDStore.InPrc = d.InPrc
        FROM AlcSchemeDtl AS d
        WHERE d.GDGid = @c_gdGid AND d.Code = @code;

        FETCH NEXT FROM StoreGoodsCursor INTO @c_gdGid, @c_storeGid;
    END;

    CLOSE StoreGoodsCursor;
    DEALLOCATE StoreGoodsCursor;
    RETURN 0;
END;
GO
