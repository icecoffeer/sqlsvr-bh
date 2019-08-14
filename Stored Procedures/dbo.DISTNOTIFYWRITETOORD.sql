SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DISTNOTIFYWRITETOORD]
  @PINUM CHAR(10),
  @PIORDNUM CHAR(10), 
  @PIGDGID INT,
  @PIALCQTY MONEY
AS
BEGIN
	DECLARE @SRCBILL CHAR(10),@SRCNUM CHAR(10),@SRCLINE INT, @SRCQTY MONEY

	if ISNULL(@PIORDNUM,'')  <>  ''
	BEGIN
		UPDATE ORDDTL SET ASNQTY = ASNQTY + @PIALCQTY WHERE NUM = @PIORDNUM AND GDGID = @PIGDGID	
	END
	ELSE
	BEGIN
		declare c_orddtl cursor for							
			SELECT SRCBILL, SRCNUM, SRCLINE, SRCQTY FROM ALCPOOLH WHERE GENCLS = '配货通知单' and 
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
			ELSE if @srcbill = '采配按商品' --modified by hxs 2004.05.09 for task 1923
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
	
END
GO
