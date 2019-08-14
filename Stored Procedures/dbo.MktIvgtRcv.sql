SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MktIvgtRcv]
(
  @bill_id int,
  @src_id int,
  @OPER CHAR(30),
  @MSG VARCHAR(255) OUTPUT
) 
AS
BEGIN
	declare
		@cur_settleno int,
		@stat smallint,
		@rcv_gid int,
		@net_stat smallint,
		@net_type smallint,
		@net_num char(14),
		@pre_num char(14),
		@net_billid int,
		@net_billto int,	
		@net_client int

	select  @rcv_gid = RCV, @net_stat = STAT,
			@net_type = NTYPE, @net_num = NUM
	from PSNMKTIVGT where ID = @bill_id and SRC = @src_id

	if @@rowcount = 0 or @net_num is null 
	begin
		SET @MSG = '该单据不存在'
		return(1)
	end

	if exists(select 1 from PSMKTIVGT where num = @net_num and stat = @net_stat) 
	begin
		SET @MSG = '该单据已经被接收'
		return(1)
	end

	if (select max(USERGID) from SYSTEM ) <>  @rcv_gid
	begin
		SET @MSG = '该单据的接收单位不是本单位'
		return(1)
	end

	if @net_type <> 1
	begin
		SET @MSG = '该单据不在接收缓冲区中'
		return(1)
	end

	if (SELECT COUNT(*) FROM PSMKTIVGT A,PSNMKTIVGT B WHERE A.NUM = B.NUM 
		AND B.ID = @bill_id and B.SRC = @src_id) = 0  
	begin
		insert into PSMKTIVGT (Num, Stat, RATIFIER, SRC, Ivgtor,
                        FILDATE, FILLER, REQOPER, REQDATE,CHECKER, CHKDATE,
                        BEGINDATE, LSTUPDTIME, PRNTIME, SNDTIME, SETTLENO, 
                        NOTE, RECCNT, OCRSTORE, ADDR)
          	select  Num, Stat, RATIFIER, SRC, Ivgtor,
                        FILDATE, FILLER, REQOPER, REQDATE,CHECKER, CHKDATE,
                        BEGINDATE, GetDate(), PRNTIME, GetDate(), SETTLENO, 
                        NOTE, RECCNT, OCRSTORE, ADDR
          	from PSNMKTIVGT
		where SRC = @src_id AND ID = @bill_id

   		if @@error <> 0 
		BEGIN
			SET @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		END

   		insert into PSMKTIVGTDTL (NUM, LINE, FLAG, OBJCODE, OBJNAME,
                        TYPECODE, TYPENAME, NOTE)
          	select NUM, LINE, FLAG, OBJCODE, OBJNAME,
                        TYPECCODE, TYPENAME, NOTE
          	from PSNMKTIVGTDTL
		where SRC = @src_id AND ID = @bill_id
		
   		if @@error <> 0 
		BEGIN
			SET @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		END
		
		insert into PSMKTIVGTDTLDTL (NUM, LINE, ITEMNO, PROPCODE, PROPNAME, VALUE )
          	select NUM, LINE, ITEMNO, PROPCODE, PROPNAME, VALUE 
          	from PSNMKTIVGTDTLDTL
		where SRC = @src_id AND ID = @bill_id
		
   		if @@error <> 0 
		BEGIN
			SET @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		END 
	end

	delete from PSNMKTIVGT where ID = @bill_id and SRC = @src_id
	delete from PSNMKTIVGTDTL where ID = @bill_id and SRC = @src_id
	delete from PSNMKTIVGTDTLDTL where ID = @bill_id and SRC = @src_id

	RETURN(0)

END
GO
