SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[Voucher_NextNum]
(
  @piCurNum Char(32), --当前券号
  @poNewNum Char(32) Output, --新的券号
  @poErrMsg Char(255) Output --错误信息
) as
begin
  declare
    @v_TailNum varchar(10),
    @v_MiddleNum varchar(10),
    @v_HeaderNum varchar(32)

  -- 由于 NextBn 函数只能产生 5 到 10 位的序号，所以必须根据长度判断
  -- 应该获取 @v_TailNum 的方式。
  IF LEN(@piCurNum) > 10
  BEGIN
    SET @v_TailNum = SubString(@piCurNum, LEN(@piCurNum) - 10 + 1, 10)
    SET @v_HeaderNum = SubString(@piCurNum, 1, LEN(@piCurNum) - 10)
  END
  ELSE BEGIN
    SET @v_TailNum = SubString(@piCurNum, LEN(@piCurNum) - 5 + 1, 5)
    SET @v_HeaderNum = SubString(@piCurNum, 1, LEN(@piCurNum) - 5)
  END

  EXEC NextBN @v_TailNum, @v_MiddleNum OUTPUT
  IF LEN(@v_MiddleNum) > LEN(@v_TailNum)
  BEGIN
    SET @v_TailNum = @v_MiddleNum
    IF LEN(@v_HeaderNum) > 10
    BEGIN
      SET @v_MiddleNum = SubString(@v_HeaderNum, LEN(@v_HeaderNum) - 10 + 1, 10)
      SET @v_HeaderNum = SubString(@v_HeaderNum, 1, LEN(@v_HeaderNum) - 10)
      EXEC NextBN @v_MiddleNum, @v_MiddleNum OUTPUT
      SET @v_HeaderNum = @v_HeaderNum + @v_MiddleNum
      SET @v_TailNum = SubString(@v_TailNum, 2, LEN(@v_TailNum) - 1)
      SET @poNewNum = @v_HeaderNum + @v_TailNum
    END ELSE
    BEGIN
      EXEC NextBN @v_HeaderNum, @v_HeaderNum OUTPUT
      SET @v_TailNum = SubString(@v_TailNum, 2, LEN(@v_TailNum) - 1)
      SET @poNewNum = @v_HeaderNum + @v_TailNum
    END
  END
  ELSE BEGIN
    SET @v_TailNum = @v_MiddleNum
    SET @poNewNum = @v_HeaderNum + @v_TailNum
  END

  RETURN 0
end
GO
