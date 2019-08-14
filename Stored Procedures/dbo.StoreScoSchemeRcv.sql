SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[StoreScoSchemeRcv]
with encryption
AS
BEGIN
	declare
		@USERGID int, @id int,
		@errmsg varchar(255)
		
	SELECT @USERGID = USERGID FROM SYSTEM

	if exists(select 1 from NSCOSCHEMEDTL where type = 1 and rcv = @USERGID)
	begin
		select @id = max(id) from NSCOSCHEMEDTL where type = 1 and rcv = @USERGID
	
		delete from STORESCOSCHEMEDTL

		INSERT INTO STORESCOSCHEMEDTL(CODE, GDGID, GDQPCSTR, SCORATE)
		SELECT CODE, GDGID, GDQPCSTR, SCORATE
		FROM NSCOSCHEMEDTL
		WHERE RCV = @USERGID AND ID = @id

		if @@error <> 0 
		BEGIN
			raiserror('接收网络商品积分失败！', 16, 1)
			return(1)
		END

		DELETE FROM NSCOSCHEMEDTL where RCV = @USERGID

		if @@error <> 0 
		BEGIN
			raiserror('删除网络商品积分失败！', 16, 1)
			return(2)
		END
	end
	return(0)
END
GO
