SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PAYCHGBOOKDLT]
  @PINUM VARCHAR(14),--结算单单号
  @PIOPER INT,
  @POMSG VARCHAR(255) OUTPUT
AS
BEGIN
  DECLARE @PayConstractWithChgBook int,
          @CHGBOOKSTAT INT,
          @CHGBOOKNUM VARCHAR(14),
          @PAYCASHNUM VARCHAR(14),
          @VDRPAYNUM VARCHAR(14),
          @VRET INT,
          @OPER CHAR(30)

  DECLARE C_CHGBOOK CURSOR FOR
    SELECT NUM FROM CHGBOOK
    WHERE (SRCNUM LIKE @PINUM AND SRCCLS LIKE '供应商结算单' AND BTYPE = 3) OR
          (SRCNUM LIKE @PINUM AND SRCCLS LIKE '结算单' AND BTYPE = 2)

  EXEC OPTREADINT 55, 'PayConstractWithChgBook', 0 , @PayConstractWithChgBook OUTPUT

  IF @PayConstractWithChgBook = 0 RETURN 0

  SELECT @CHGBOOKSTAT = STAT FROM CHGBOOK WHERE SRCNUM LIKE @PINUM AND SRCCLS LIKE '供应商结算单'
  SELECT @OPER = '[' + RTRIM(CODE) + ']' + RTRIM(NAME) FROM EMPLOYEE WHERE GID = @PIOPER
  OPEN C_CHGBOOK
  FETCH NEXT FROM C_CHGBOOK INTO @CHGBOOKNUM
  WHILE @@FETCH_STATUS = 0
  BEGIN
      IF @CHGBOOKSTAT = 0
      BEGIN
            DELETE FROM CHGBOOK WHERE SRCNUM LIKE @PINUM AND SRCCLS LIKE '供应商结算单'
      END
      ELSE
      IF @CHGBOOKSTAT = 500
      BEGIN
            Select @PAYCASHNUM = b.num From cntrPAYCASHDTL a, CNTRPAYCASH b
            Where a.Num = b.Num
              and a.chgType='费用单'
              and a.ivccode =@CHGBOOKNUM --and b.stat in (0,100)

            SELECT @VDRPAYNUM = b.NUM FROM VDRPAY A, VDRPAYDTL B
            WHERE A.NUM = B.NUM 
                AND B.CHGNUM = @CHGBOOKNUM

            IF (@PAYCASHNUM IS NOT NULL) OR (@VDRPAYNUM IS NOT NULL)
            BEGIN
              SET @POMSG = '存在该结算单 ['+@PINUM+']'+CHAR(13)+
                  '相关费用单 [' + CONVERT(VARCHAR(14), @CHGBOOKNUM) + ']'+ CHAR(13) +
                  '的付款单:['+ @PAYCASHNUM +']' + CHAR(13) +
                  '或者交款单:[' + @VDRPAYNUM + ']' + CHAR(13)+ 
                  '所以不能删除！'

              CLOSE C_CHGBOOK
              DEALLOCATE C_CHGBOOK
              RETURN -1
            END
            EXEC @VRET = ChgBookDlt @CHGBOOKNUM, @OPER, '', -1, @POMSG OUTPUT
            IF @VRET>0
            BEGIN
              SET @POMSG = '删除费用单错误[ChgBookDlt]:'+@POMSG

              CLOSE C_CHGBOOK
              DEALLOCATE C_CHGBOOK
              RETURN -2  --ChgBookDlt wrong
            END
      END
      ELSE
      IF (@CHGBOOKSTAT = 300) OR (@CHGBOOKSTAT = 400)
      BEGIN
            IF @CHGBOOKSTAT = 300
              SET @POMSG = @POMSG + '该结算单 ['+@PINUM+']'+CHAR(13)+
                                  + '存在费用单 [' + CONVERT(VARCHAR(14), @CHGBOOKNUM) + '] '+CHAR(13)
                                  + '该费用单的状态是：已完成！'+ CHAR(13)
                                  + '是否继续作废？如果继续，需要手工处理该费用单。'
            ELSE
              SET @POMSG = @POMSG + '该结算单 ['+@PINUM+']'+CHAR(13)+
                                  + '存在费用单 [' + CONVERT(VARCHAR(14), @CHGBOOKNUM) + '] '+CHAR(13)
                                  + '该费用单的状态是：请求总部批准！'+ CHAR(13)
                                  + '是否继续作废？如果继续，需要手工处理该费用单。'
            CLOSE C_CHGBOOK
            DEALLOCATE C_CHGBOOK
            RETURN 1 --客户端判断是否继续删除，如果否则认为作废失败，如果是需要手工处理该费用单。
      END
      ELSE
      BEGIN
        SET @POMSG =  @POMSG + '该结算单 ['+@PINUM+']'+CHAR(13)+
                                  + '存在费用单 [' + CONVERT(VARCHAR(14), @CHGBOOKNUM) + '] '+CHAR(13)
                                  + '该费用单的状态是：未知！'+ CHAR(13)
                                  + '不能继续，请手工确认费用单状态。'
        CLOSE C_CHGBOOK
        DEALLOCATE C_CHGBOOK
        RETURN -3
      END

      FETCH NEXT FROM C_CHGBOOK INTO @CHGBOOKNUM
  END

  CLOSE C_CHGBOOK
  DEALLOCATE C_CHGBOOK

  RETURN 0
END

GO
