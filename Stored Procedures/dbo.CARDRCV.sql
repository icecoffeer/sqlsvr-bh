SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CARDRCV]
@SRC int,
@ID int
as
begin
	declare @N_GID int, @N_Code char(10), @N_PCode char(128), @N_NType smallint,
		@N_FrcUpd smallint, @N_CSTGID int, @L_CSTGID int

	select @N_GID = GID, @N_Code = CODE, @N_PCode = PCODE, @N_NType = NTYPE,
		@N_FrcUpd = FRCUPD, @N_CSTGID = CSTGID
	from NCARD where SRC = @SRC and ID = @ID

	if @N_NType <> 1
	begin
		raiserror('该消费卡不在接收缓冲中，无法接收', 16, 1)
		return(1)
	end

	select @L_CSTGID = LGID from CLNXLATE where NGID = @N_CSTGID
	if @L_CSTGID is null
	begin
		raiserror('消费卡所属的客户资料未被转入。', 16, 1)
		return(1)
	end

	if exists (select 1 from CARD where GID = @N_GID)
	begin
		
		if @N_FrcUpd = 1
			if exists (select 1 from CARD where CODE = @N_Code and GID<>@N_GID)
			begin
				raiserror('被接收的消费卡和本单位的其它消费卡的卡号重复，无法接收', 16, 1)
				return(1)
			end

			if exists (select 1 from CARD where PCODE = @N_PCode and GID<>@N_GID)
			begin
				raiserror('被接收的消费卡和本单位的其它消费卡的设备卡号重复，无法接收', 16, 1)
				return(1)
			end

			update CARD
			set 	Code = a.Code,
				PCode = a.PCode,                /* 2002-10-31 */
				CREATEDATE = a.CREATEDATE,
				VALIDDATE = a.VALIDDATE,
				SRC = a.SRC,
				CSTGID = a.CSTGID,
				CARDTYPE = a.CARDTYPE,
				SALEDATE = a.SALEDATE,
				STATE = a.STATE,
				SndTime = null,			/* 2001-04-02 */
				LstUpdTime = getdate()
			from NCARD a
			where CARD.GID = @N_GID
			and a.SRC = @SRC
			and a.ID = @ID

		delete from NCARD where SRC = @SRC and ID = @ID
	end
	else
	begin
		if exists (select 1 from CARD where CODE = @N_Code)
		begin
			raiserror('被接收的消费卡和本单位的其它消费卡的卡号重复，无法接收', 16, 1)
			return(1)
		end

		if exists (select 1 from CARD where PCODE = @N_PCode)
		begin
			raiserror('被接收的消费卡和本单位的其它消费卡的设备卡号重复，无法接收', 16, 1)
			return(1)
		end

		insert into CARD (GID, CODE, PCODE, CREATEDATE, VALIDDATE, LSTUPDTIME, BALANCE,
			CSTGID, CARDTYPE, SALEDATE, FILLER, MODIFIER, STATE, SRC)
		select GID, CODE, PCODE, CREATEDATE, VALIDDATE, CREATEDATE, BALANCE, @L_CSTGID,
			CARDTYPE, SALEDATE, 1, 1, STATE, @SRC
		from NCARD
		where SRC = @SRC and ID = @ID

		delete from NCARD where SRC = @SRC and ID = @ID
	end
end
GO
