SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[STKOUTWRITETOORD]
  @PINUM CHAR(10),
  @PIGDGID INT,
  @PIALCQTY MONEY
AS
BEGIN
	DECLARE @SRCBILL CHAR(10),@SRCNUM CHAR(10),@SRCLINE INT, @SRCQTY MONEY

	declare c_orddtl cursor for
		SELECT SRCBILL, SRCNUM, SRCLINE, SRCQTY FROM ALCPOOLH(nolock) WHERE GENCLS = '配货出货单' and
			GENNUM = @PINUM AND GDGID = @PIGDGID ORDER BY SRCBILL DESC , SRCNUM,SRCLINE
					--这样排序是为了让连锁定单排在最前面。
	open c_orddtl
	fetch next from c_orddtl into @srcbill, @srcnum, @srcline, @srcqty
	while @@fetch_status = 0
	begin
		if @SRCBILL = '连锁定单'
		begin
			IF @PIALCQTY > @SRCQTY
			BEGIN
				UPDATE ORDDTL SET ASNQTY = isnull(ASNQTY, 0) + @SRCQTY where NUM = @srcnum and line = @srcline
				SELECT @PIALCQTY = @PIALCQTY - @SRCQTY
			END
			ELSE
				IF @PIALCQTY <> 0
				BEGIN
					UPDATE ORDDTL SET ASNQTY = isnull(ASNQTY, 0) + @PIALCQTY where NUM = @srcnum and line = @srcline
					SELECT @PIALCQTY = 0
				END
		END
		ELSE IF @SRCBILL = '采配按门店'
		BEGIN
			IF @PIALCQTY > @SRCQTY
			BEGIN
				UPDATE ALCBYSTOREDTL SET ASNQTY = isnull(ASNQTY, 0) + @SRCQTY where NUM = @SRCNUM AND LINE = @SRCLINE
				SELECT @PIALCQTY = @PIALCQTY - @SRCQTY
			END
			ELSE
			BEGIN
				UPDATE ALCBYSTOREDTL SET ASNQTY = isnull(ASNQTY, 0) + @PIALCQTY where NUM = @SRCNUM AND LINE = @SRCLINE
				SELECT @PIALCQTY = 0
			END
		END
		ELSE if @srcbill = '采配按商品'--Modified by hxs 2004.05.08 for task 1923
		BEGIN
			IF @PIALCQTY > @SRCQTY
			BEGIN
				UPDATE ALCBYGOODSDTL SET ASNQTY = isnull(ASNQTY, 0) + @SRCQTY WHERE NUM = @SRCNUM AND LINE = @SRCLINE
				SELECT @PIALCQTY = @PIALCQTY - @SRCQTY
			END
			ELSE
			BEGIN
				UPDATE ALCBYGOODSDTL SET ASNQTY = isnull(ASNQTY, 0) + @PIALCQTY WHERE NUM = @SRCNUM AND LINE = @SRCLINE
				SELECT @PIALCQTY = 0
			END
		END
		fetch next from c_orddtl into @srcbill, @srcnum, @srcline, @srcqty
	end
	CLOSE c_orddtl
	DEALLOCATE c_orddtl
END
GO
