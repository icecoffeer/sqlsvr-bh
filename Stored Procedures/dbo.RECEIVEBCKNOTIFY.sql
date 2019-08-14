SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RECEIVEBCKNOTIFY]
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
	from NBCKNOTIFY where ID = @bill_id and SRC = @src_id

	if @@rowcount = 0 or @net_num is null
	begin
		SET @MSG = '该单据不存在'
		return(1)
	end

	if exists(select 1 from BCKNOTIFY where num = @net_num and stat = @net_stat)
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

	if (SELECT COUNT(*) FROM BCKNOTIFY A,NBCKNOTIFY B WHERE A.NUM = B.NUM
		AND B.ID = @bill_id and B.SRC = @src_id) = 0
	begin
		insert into BCKNOTIFY (STOREGID, NUM, SETTLENO, RECCNT,
          		NOTE, FILDATE, FILLER, CHKDATE, CHECKER, EXPDATE, --sz
			STAT, LSTUPDTIME, SNDDATE)
          	select  SRC, NUM, SETTLENO, RECCNT,
                 	NOTE, FILDATE, FILLER, CHKDATE, CHECKER, EXPDATE,
			STAT,getdate(), getdate()
          	from NBCKNOTIFY
		where SRC = @src_id AND ID = @bill_id

   		if @@error <> 0
		BEGIN
			SET @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		END

   		insert into BCKNOTIFYDTL (NUM, LINE, GDGID, NOTE)
          	select NUM, LINE, GDGID, NOTE
          	from NBCKNOTIFYDTL
		where SRC = @src_id AND ID = @bill_id

   		if @@error <> 0
		BEGIN
			SET @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		END
	end

	delete from NBCKNOTIFY where ID = @bill_id and SRC = @src_id
	delete from NBCKNOTIFYDTL where ID = @bill_id and SRC = @src_id

	RETURN(0)

END
GO
