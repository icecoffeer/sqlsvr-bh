SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[StoreScoSchemeSnd]
(
  @SCode CHAR(4),
  @StoreGid INT,			--负数表示发送所有门店
  @Gdgid INT				--负数表示发送所有商品,目前客户必须为负值传入
) with encryption
AS
BEGIN
  	declare @id int,
		@USERGID INT
		
	select 	@SCode = rtrim(@SCode)
	
	SELECT @USERGID = USERGID FROM SYSTEM
	
	if not exists(select 1 from StoreScoScheme where code = @SCode)  
	begin
		raiserror('该方案不存在，不能发送！', 16, 1)
		return(1)
	end
	if not exists(select 1 from StoreScoSchemeDtl where code = @SCode)  
	begin
		raiserror('该方案明细记录为空，不能发送！', 16, 1)
		return(2)
	end
	if @USERGID = @STOREGID  
	begin
		raiserror('该方案不能发送给本店！', 16, 1)
		return(4)
	end


	--取得ID号
	EXECUTE  GETNETBILLID @ID OUTPUT
	IF @ID IS NULL
		SELECT @ID = 1

	if @StoreGid >= 0   --发送到指定门店
	begin
		if not exists(select 1 from Store where gid = @StoreGid)  
		begin
			raiserror('没有该门店，不能发送！', 16, 1)
			return(3)
		end
		if not exists(select 1 from Store s, StoreScoScheme m where s.ScoScheme = m.code and m.code = @SCode and s.gid = @StoreGid)  
		begin
			raiserror('门店和方案不匹配，不能发送！', 16, 1)
			return(5)
		end

		IF @GDGID<0 
			INSERT INTO NSCOSCHEMEDTL(ID, CODE, GDGID, GDQPCSTR, SCORATE,  
						    SRC, SNDTIME, RCV, TYPE, NSTAT)
				SELECT @ID, '-', GDGID, GDQPCSTR, SCORATE, 
					@USERGID, GETDATE(), @STOREGID, 0, 0
		                FROM STORESCOSCHEMEDTL
		                WHERE CODE = @SCODE
		ELSE BEGIN 
			IF NOT EXISTS(SELECT 1 FROM GOODS WHERE GID = @GDGID)  
			begin
				raiserror('该商品不存在，不能发送！', 16, 1)
				return(11)
			end
			INSERT INTO NSCOSCHEMEDTL(ID, CODE, GDGID, GDQPCSTR, SCORATE,  
						    SRC, SNDTIME, RCV, TYPE, NSTAT)
				SELECT @ID, '-', GDGID, GDQPCSTR, SCORATE, 
					@USERGID, GETDATE(), @STOREGID, 0, 0
		                FROM STORESCOSCHEMEDTL
		                WHERE CODE = @SCODE AND GDGID = @GDGID
		END
	                
		if @@error <> 0 
		BEGIN
			raiserror('发送插入失败！', 16, 1)
			return(6)
		END
	END ELSE BEGIN	--发送到所有生效门店
		IF @GDGID<0 
			INSERT INTO NSCOSCHEMEDTL(ID, CODE, GDGID, GDQPCSTR, SCORATE,  
						    SRC, SNDTIME, RCV, TYPE, NSTAT)
				SELECT @ID, '-', D.GDGID, D.GDQPCSTR, D.SCORATE, 
					@USERGID, GETDATE(), S.GID, 0, 0
		                FROM StoreScoSchemeDtl D INNER JOIN STORE S ON S.SCOSCHEME = D.CODE
		                WHERE D.CODE = @SCODE AND S.GID <> @USERGID
	        ELSE BEGIN
			IF NOT EXISTS(SELECT 1 FROM GOODS WHERE GID = @GDGID)  
			begin
				raiserror('该商品不存在，不能发送！', 16, 1)
				return(11)
			end
			INSERT INTO NSCOSCHEMEDTL(ID, CODE, GDGID, GDQPCSTR, SCORATE,  
						    SRC, SNDTIME, RCV, TYPE, NSTAT)
				SELECT @ID, '-', D.GDGID, D.GDQPCSTR, D.SCORATE, 
					@USERGID, GETDATE(), S.GID, 0, 0
		                FROM StoreScoSchemeDtl D INNER JOIN STORE S 
				ON S.SCOSCHEME = D.CODE
		                WHERE D.CODE = @SCODE AND S.GID <> @USERGID AND D.GDGID = @GDGID
	        END        
		if @@error <> 0 
		BEGIN
			raiserror('发送插入失败！', 16, 1)
			return(7)
		END
	END
	RETURN(0)
		
END
GO
