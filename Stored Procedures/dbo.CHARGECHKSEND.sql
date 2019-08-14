SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CHARGECHKSEND]
(
	@num	 varchar(14),
	@Frcchk int,
	@oper	  varchar(30),
	@msg  varchar(255) output
)
as
begin
  declare
	  @vret int,
	  @vstore int,
	  @vstat	int,
	  @saletype int,
	  @user_gid int,
	  @zb_gid int,
	  @id int

	set @vret = 0;
	select @vstore = usergid from system

	select @saletype = saletype, @vstat = stat from CHARGECHK where num = @num
		if @vstat = 0
		  begin
			  set @msg = '不是已审核单据，不能发送';
			  return(1);
		  end;
		if @saletype <> 2
		  begin
			  set @msg = '不是已合并核单据，不能发送';
			  return(2);
		  end;

	select @user_gid = USERGID, @zb_gid = ZBGID from System;
	execute getnetbillid @id output

  insert into NCHARGECHKDTLDTL(SRC, ID, NUM, LINE, DTLDTLLINE, DTLCLS, CODE, NAME, CHKNO, TOTAL, NOTE)
  select @user_gid, @id, @num, LINE, DTLDTLLINE, DTLCLS, CODE, NAME, CHKNO, TOTAL, NOTE
  from   CHARGECHKDTLDTL
  where  num = @num

	insert into NCHARGECHKDTL(SRC, ID, NUM, LINE, PAYTYPE, SHOULDRCVTOTAL, RCVTOTAL, NOTE)
  select @user_gid, @id, @num, LINE, PAYCLS, SHOULDRCVTOTAL, RCVTOTAL, NOTE
  from CHARGECHKDTL(nolock)
  where  num = @num

  insert into NCHARGECHKDTL2DTL(SRC, ID, NUM, LINE, DTLDTLLINE, DTLCLS, CODE, NAME, CHKNO, TOTAL, NOTE)
  select @user_gid, @id, @num, LINE, DTLDTLLINE, DTLCLS, CODE, NAME, CHKNO, TOTAL, NOTE
  from   CHARGECHKDTL2DTL
  where  num = @num

	insert into NCHARGECHKDTL2(SRC, ID, NUM, LINE, PAYCLS, TOTAL, NOTE)
  select @user_gid, @id, @num, LINE, PAYCLS, TOTAL, NOTE
  from CHARGECHKDTL2(nolock)
  where  num = @num

  insert into NCHARGECHK(ID, NUM, CHARGEDATE, SALETYPE, STAT, FILLER, FILDATE, CHECKER, CHKDATE, SHOULDRCVTOTALT0, SHOULDRCVTOTALT1, RCVTOTAL, OTHERTOTAL, NOTE, NSTAT, NNOTE, SRC, RCV, SNDTIME, RCVTIME, FRCCHK, TYPE)
  select @id, @num, CHARGEDATE, SALETYPE, STAT, FILLER, FILDATE, CHECKER, CHKDATE, SHOULDRCVTOTALT0, SHOULDRCVTOTALT1, RCVTOTAL, OTHERTOTAL, NOTE, 0, '', @user_gid, @zb_gid, getdate(), NULL, @Frcchk, 0
  from CHARGECHK(nolock)
  where  num = @num

	update CHARGECHK set sndtime = getdate(), lstupdtime = getdate()
		where num = @num;
	return(0)
end
GO
