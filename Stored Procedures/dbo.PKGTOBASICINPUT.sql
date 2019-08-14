SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PKGTOBASICINPUT]
(
  @strInputCode varchar(40),
  @strBasicGdCode varchar(40) OUTPUT,
  @intBasicGdGid int OUTPUT,
  @strErrMsg  varchar(4000) OUTPUT
) AS
BEGIN
  DECLARE
    @intGdGid int,
    @GdCode varchar(40),
    @intIsPkg smallint;

  SELECT @intGdGid = GID
  FROM GDINPUT(NOLOCK)
  WHERE CODE = @strInputCode;
  IF @@ROWCOUNT = 0
  BEGIN
    SELECT @strErrMsg = '条码为 ' + @strInputCode + ' 的商品不存在';
    RETURN (1);
  END;

  SELECT @intIsPkg = ISPKG, @strBasicGdCode = CODE
  FROM GOODS(NOLOCK)
  WHERE GID = @intGdGid;

  IF @intIsPkg = 0  --基本商品，不需转换
  BEGIN
    SELECT @intBasicGdGid = @intGdGid;
    RETURN(0);
  END;
  ELSE BEGIN   --大包装商品
    SELECT @intBasicGdGid = EGID
    FROM PKG(NOLOCK)
    WHERE PGID = @intGdGid;
    IF @@ROWCOUNT = 0
    BEGIN
      SELECT @strErrMsg = '该商品标记为大包装商品，但在PKG表中没有对应的基本商品';
      RETURN(2);
    END;

    SELECT @strBasicGdCode = CODE
    FROM GOODS(NOLOCK)
    WHERE GID = @intBasicGdGid;
    IF @@ROWCOUNT = 0
    BEGIN
      SELECT @strErrMsg = '该商品对应的基本商品不存在';
      RETURN(3);
    END;
  END;
  RETURN(0);
END;
GO
