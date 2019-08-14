SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RTLRCV]
(
  @bill_id int,
  @src_id int,
  @oper char(30),
  @msg varchar(255) output
)
AS
BEGIN
	declare
		--Sys info
		@UserProperty int,		@UserGid int,
		@Message varchar(255),		@ret smallint,
		--Bill Info
		@cur_settleno int,		@stat smallint,
		@rcv_gid int,			@net_stat smallint,
		@net_type smallint,		@new_num char(14),
		@net_num char(14),		@max_num char(14),
		@net_billid int,		@net_dmdstore int,
		@net_Fillergid int,		@loc_Fillergid int,
		@net_Checkergid int,		@loc_Checkergid int,
		@net_Assistantgid int,		@loc_Assistantgid int

	select @UserProperty = USERPROPERTY, @UserGid = USERGID from system
	select @cur_settleno = max(no) from monthsettle(nolock)

        select @max_num = max(NUM) from rtl(nolock)

        exec NextBn @max_num, @new_num output

	select  @net_num = NUM,   @rcv_gid = RCV,
		@net_stat = STAT, @net_type = NTYPE
		from NRTL(nolock)
	  where ID = @bill_id and SRC = @src_id
	--Check
	if @@rowcount = 0 or @net_num is null
	begin
		SET @MSG = '该单据不存在'
		return(1)
	end

	if exists(select 1 from rtl where SRCNUM = @net_num and stat = @net_stat)
	begin
		set @msg = '该单据已经被接收'
		return(1)
	end
	if (select max(USERGID) from SYSTEM(nolock) ) <>  @rcv_gid
	begin
		SET @MSG = '该单据的接收单位不是本单位'
		return(1)
	end
	if @net_type <> 1
	begin
		SET @MSG = '该单据不在接收缓冲区中'
		return(1)
	end

	--检查员工对照表 MST
	SELECT @net_Checkergid = CHECKER FROM NRTL(nolock) WHERE SRC = @SRC_ID AND ID = @BILL_ID
	IF NOT EXISTS( SELECT CODE FROM EMPLOYEE(nolock) WHERE GID = @net_Checkergid )
	BEGIN
	  IF EXISTS( SELECT LGID FROM EMPXLATE(nolock) WHERE NGID = @net_Checkergid )
	  	SELECT @loc_Fillergid = LGID FROM EMPXLATE(nolock) WHERE NGID = @net_Checkergid
	  ELSE
	  BEGIN
	  	UPDATE NRTL SET NSTAT = 1 ,NNOTE = '本地找不到填单人对应的员工(对照表中也不存在)'
	  					WHERE SRC = @SRC_ID AND ID = @BILL_ID
	  	SET @MSG = '本地找不到填单人对应的员工(对照表中也不存在)'
		RETURN(1)
	  END
	END
	SELECT @net_Fillergid = FILLER FROM NRTL(nolock) WHERE SRC = @SRC_ID AND ID = @BILL_ID
	IF NOT EXISTS( SELECT CODE FROM EMPLOYEE(nolock) WHERE GID = @net_Fillergid )
	BEGIN
	  IF EXISTS( SELECT LGID FROM EMPXLATE(nolock) WHERE NGID = @net_Fillergid )
	  	SELECT @loc_Checkergid = LGID FROM EMPXLATE(nolock) WHERE NGID = @net_Fillergid
	  ELSE
	  BEGIN
	  	UPDATE NRTL SET NSTAT = 1 ,NNOTE = '本地找不到审核人对应的员工(对照表中也不存在)'
	  					WHERE SRC = @SRC_ID AND ID = @BILL_ID
	  	SET @MSG = '本地找不到审核人对应的员工(对照表中也不存在)'
		RETURN(1)
	  END
	END
	SELECT @net_Assistantgid = ASSISTANT FROM NRTL(nolock) WHERE SRC = @SRC_ID AND ID = @BILL_ID
	SET @loc_Assistantgid  =  @net_Assistantgid
	IF (@net_Assistantgid IS NOT NULL) AND (NOT EXISTS( SELECT CODE FROM EMPLOYEE(nolock) WHERE GID = @net_Assistantgid ))
	BEGIN
	  IF EXISTS( SELECT LGID FROM EMPXLATE(nolock) WHERE NGID = @net_Assistantgid )
	  	SELECT @loc_Assistantgid = LGID FROM EMPXLATE(nolock) WHERE NGID = @net_Assistantgid
	  ELSE
	  BEGIN
	  	UPDATE NRTL SET NSTAT = 1 ,NNOTE = '本地找不到营业员对应的员工(对照表中也不存在)'
	  					WHERE SRC = @SRC_ID AND ID = @BILL_ID
	  	SET @MSG = '本地找不到营业员对应的员工(对照表中也不存在)'
		RETURN(1)
	  END
	END


	--Receive Process

		insert into rtl (SRC, PRNTIME, NUM, SETTLENO, FILDATE, STAT,
          		TOTAL, TAX, CHANGE, FILLER, UNDERTAKER, WARRANTOR, WRH, DSPUNIT,
			DSPWRH, PROVIDER, MODNUM, INVNO, NOTE, RECCNT, SENDER, CHECKER, ASSISTANT, PAYSTAT, SRCNUM)
          	select  SRC, PRNTIME, @new_num, SETTLENO, FILDATE, STAT,
                 	TOTAL, TAX, CHANGE, @loc_Fillergid, UNDERTAKER, WARRANTOR, WRH, DSPUNIT,
			DSPWRH, PROVIDER, MODNUM, INVNO, NOTE, RECCNT, SENDER, @loc_Checkergid, @loc_Assistantgid, PAYSTAT, @NET_NUM
          	from nrtl
		where SRC = @src_id AND ID = @bill_id

		if @@error <> 0
		BEGIN
			SET @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		END

		delete nrtl where SRC = @src_id AND ID = @bill_id

 --插入明细
	insert into rtldtl (NUM, LINE, SETTLENO, GDGID, CASES, QTY, PRICE, DISCOUNT, INPRICE, ALCPRC, AMOUNT, RTLPRC, INPRC, SUBWRH,
	                    DSPSUBWRH, TAX, LXGDNAME, LXGDSPEC, LXGDMUNIT, LXGDTM, INVAMT, COST, RedCardCost, BlueCardCost, VouAmt)
	     select    @new_num, LINE, SETTLENO, GDGID, CASES, QTY, PRICE, DISCOUNT, INPRICE, ALCPRC, AMOUNT, RTLPRC, INPRC, SUBWRH,
	                    DSPSUBWRH, TAX, LXGDNAME, LXGDSPEC, LXGDMUNIT, LXGDTM, INVAMT, COST, RedCardCost, BlueCardCost, VouAmt
	     from nrtldtl
	     where SRC = @src_id AND ID = @bill_id

	     if @@error <> 0
		BEGIN
			SET @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		END

	     delete nrtldtl where SRC = @src_id AND ID = @bill_id

        --插入付款明细

             insert into RTLCURDTL (NUM, ITEMNO, CURRENCY, AMOUNT, CARDNUM)
	     select    @new_num, ITEMNO, CURRENCY, AMOUNT, CARDNUM
	     from NRTLCURDTL
	     where ID = @bill_id

	     if @@error <> 0
		BEGIN
			SET @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		END

	     delete NRTLCURDTL where ID = @bill_id

END
GO
