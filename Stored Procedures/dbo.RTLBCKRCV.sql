SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RTLBCKRCV]
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
		@net_type smallint,		@new_num char(10),
		@net_num char(10),		@max_num char(10),
		@net_billid int,		@net_dmdstore int,
		@net_Fillergid int,		@loc_Fillergid int,
		@net_Checkergid int,		@loc_Checkergid int,
		@net_Assistantgid int,		@loc_Assistantgid int

	select @UserProperty = USERPROPERTY, @UserGid = USERGID from system
	select @cur_settleno = max(no) from monthsettle(nolock)

        select @max_num = max(NUM) from rtlbck(nolock)

        exec NextBn @max_num, @new_num output

	select  @net_num = NUM,   @rcv_gid = RCV,
		@net_stat = STAT, @net_type = NTYPE
	from  NRTLBCK(nolock)
	  where ID = @bill_id and SRC = @src_id
	--Check
	if @@rowcount = 0 or @net_num is null
	begin
		SET @MSG = '该单据不存在'
		return(1)
	end

	if exists(select 1 from rtlbck(nolock) where SRCNUM = @net_num and stat = @net_stat)
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
	SELECT @net_Fillergid = CHECKER FROM NRTLBCK(nolock) WHERE SRC = @SRC_ID AND ID = @BILL_ID
	SET @loc_Fillergid = @net_Fillergid
	IF NOT EXISTS( SELECT CODE FROM EMPLOYEE(nolock) WHERE GID = @net_Fillergid )
	BEGIN
	  IF EXISTS( SELECT LGID FROM EMPXLATE(nolock) WHERE NGID = @net_Fillergid )
	  	SELECT @loc_Fillergid = LGID FROM EMPXLATE(nolock) WHERE NGID = @net_Fillergid
	  ELSE
	  BEGIN
	  	UPDATE NRTLBCK SET NSTAT = 1 ,NNOTE = '本地找不到填单人对应的员工(对照表中也不存在)'
	  					WHERE SRC = @SRC_ID AND ID = @BILL_ID
	  	SET @MSG = '本地找不到填单人对应的员工(对照表中也不存在)'
		RETURN(1)
	  END
	END
	SELECT @net_Checkergid = FILLER FROM NRTLBCK(nolock) WHERE SRC = @SRC_ID AND ID = @BILL_ID
	SET @loc_Checkergid = @net_Checkergid
	IF NOT EXISTS( SELECT CODE FROM EMPLOYEE(nolock) WHERE GID = @net_Checkergid )
	BEGIN
	  IF EXISTS( SELECT LGID FROM EMPXLATE(nolock) WHERE NGID = @net_Checkergid )
	  	SELECT @loc_Checkergid = LGID FROM EMPXLATE(nolock) WHERE NGID = @net_Checkergid
	  ELSE
	  BEGIN
	  	UPDATE NRTLBCK SET NSTAT = 1 ,NNOTE = '本地找不到审核人对应的员工(对照表中也不存在)'
	  					WHERE SRC = @SRC_ID AND ID = @BILL_ID
	  	SET @MSG = '本地找不到审核人对应的员工(对照表中也不存在)'
		RETURN(1)
	  END
	END
	SELECT @net_Assistantgid = ASSISTANT FROM NRTLBCK(nolock) WHERE SRC = @SRC_ID AND ID = @BILL_ID
	SET @loc_Assistantgid  =  @net_Assistantgid
	IF (@net_Assistantgid IS NOT NULL) AND (NOT EXISTS( SELECT CODE FROM EMPLOYEE(nolock) WHERE GID = @net_Assistantgid ))
	BEGIN
	  IF EXISTS( SELECT LGID FROM EMPXLATE(nolock) WHERE NGID = @net_Assistantgid )
	  	SELECT @loc_Assistantgid = LGID FROM EMPXLATE(nolock) WHERE NGID = @net_Assistantgid
	  ELSE
	  BEGIN
	  	UPDATE NRTLBCK SET NSTAT = 1 ,NNOTE = '本地找不到营业员对应的员工(对照表中也不存在)'
	  					WHERE SRC = @SRC_ID AND ID = @BILL_ID
	  	SET @MSG = '本地找不到营业员对应的员工(对照表中也不存在)'
		RETURN(1)
	  END
	END


	--Receive Process

	insert into rtlbck (SRC, PRNTIME, NUM, SETTLENO, FILDATE, STAT,
          	TOTAL, FILLER, WRH, MODNUM, INVNO, NOTE, RECCNT, CHECKER,
		TAX, DSPWRH, PROVIDER, ASSISTANT, SRCNUM)
        select  SRC, PRNTIME, @new_num, SETTLENO, FILDATE, STAT,
                TOTAL, @loc_Fillergid, WRH, MODNUM, INVNO, NOTE, RECCNT, @loc_Checkergid,
		TAX, DSPWRH, PROVIDER, @loc_Assistantgid, @NET_NUM
        from nrtlbck
	where SRC = @src_id AND ID = @bill_id

	if @@error <> 0
	BEGIN
		SET @MSG = '接收'+@NET_NUM+'单据失败'
		return(1)
	END

	delete nrtlbck where SRC = @src_id AND ID = @bill_id

 --插入明细
	insert into rtlbckdtl (NUM, LINE, SETTLENO, GDGID, CASES, QTY, PRICE, DISCOUNT, AMOUNT, RTLPRC, INPRC, SUBWRH, ALCPRC,
	                    DSPSUBWRH, TAX, LXGDNAME, LXGDSPEC, LXGDMUNIT, LXGDTM, COST, COSTPRC, BlueCardCost, RedCardCost, VouAmt)
	     select    @new_num, LINE, SETTLENO, GDGID, CASES, QTY, PRICE, DISCOUNT, AMOUNT, RTLPRC, INPRC, SUBWRH, ALCPRC,
	                    DSPSUBWRH, TAX, LXGDNAME, LXGDSPEC, LXGDMUNIT, LXGDTM, COST, COSTPRC, BlueCardCost, RedCardCost, VouAmt
	     from nrtlbckdtl
	     where SRC = @src_id AND ID = @bill_id

	     if @@error <> 0
		BEGIN
			SET @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		END

	     delete nrtlbckdtl where ID = @bill_id

	  --插入付款明细

             insert into RTLBCKCURDTL (NUM, ITEMNO, CURRENCY, AMOUNT)
	     select    @new_num, ITEMNO, CURRENCY, AMOUNT
	     from NRTLBCKCURDTL
	     where ID = @bill_id

	     if @@error <> 0
		BEGIN
			SET @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		END

	     delete NRTLBCKCURDTL where ID = @bill_id

END
GO
