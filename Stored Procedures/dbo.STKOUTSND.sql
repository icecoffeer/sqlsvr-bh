SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[STKOUTSND]
@CLS char(10),
@NUM char(10),
@RCV int,
@FRCCHK smallint
as
begin
	declare @Stat smallint, @Id int, @CurNum char(10)
	declare @UserGID int, @CurrentTime datetime, @BatchFlag smallint, @optvalue smallint


	select @UserGID = max(USERGID), @BatchFlag = max(BATCHFLAG) from SYSTEM
	select @CurrentTime = getdate()

	select @Stat = STAT from STKOUT where CLS = @CLS and NUM = @NUM

	if @Stat <> 1 and @Stat <> 4 and @Stat <> 6
	begin
		raiserror('该单据不是已审核单据或冲单(负单), 不能发送', 16, 1)
		return(1)
	end

	if (select SRC from STKOUT where CLS = @CLS and NUM = @NUM) <> @UserGID
	begin
		raiserror('该单据不是本单位生成的单据,不能发送', 16, 1)
		return(1)
	end

	if @FRCCHK = 2
		select @FRCCHK = 7

	select @CurNum = @NUM

        exec OPTREADINT 70, 'GetWrhMode', 0, @optvalue output  /*2002-05-09*/

	while @CurNum is not null and @CurNum <> ''
	begin
		execute GETNETBILLID @Id = @Id output

		insert into NSTKOUT (ID, CLS, NUM, CLIENT, BILLTO, OCRDATE, TOTAL, TAX, FILDATE,
			CHECKER, STAT, MODNUM, RECCNT, NSTAT, NOTE, NNOTE, SRC, RCV, SNDTIME, RCVTIME,
			FRCCHK, TYPE, SRCORDNUM, PAYDATE, OTHERSIDENUM)
		select @Id, CLS, NUM, CLIENT, BILLTO, OCRDATE, TOTAL, TAX, FILDATE,
			CHECKER, STAT, MODNUM, RECCNT, 0, NOTE, null, @UserGID, @RCV, @CurrentTime,
			null, @FRCCHK, 0, SRCORDNUM, PAYDATE, OTHERSIDENUM
		from STKOUT
		where CLS = @CLS and NUM = @CurNum

                if @cls = '配货'
  		   insert into NSTKOUTDTL (SRC, ID, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX,
			   VALIDDATE, WRH, SUBWRH, NOTE/*2002-01-22*/, COST)
  		   select @UserGID, @Id, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX,
			   VALIDDATE,
			   (CASE WHEN @optvalue = 1 THEN WRH ELSE 1 END), /*2002-05-09*/
			   (CASE WHEN @BATCHFLAG = 1 THEN SUBWRH ELSE NULL END),
			   NOTE, COST
		   from STKOUTDTL
		   where CLS = @CLS and NUM = @CurNum
		else
  		   insert into NSTKOUTDTL (SRC, ID, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX,
			   VALIDDATE, WRH, SUBWRH, NOTE/*2002-01-22*/, COST)
  		   select @UserGID, @Id, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX,
			   VALIDDATE, 1,  (CASE WHEN @BATCHFLAG = 1 THEN SUBWRH ELSE NULL END), NOTE, COST
		   from STKOUTDTL
		   where CLS = @CLS and NUM = @CurNum

		--added by wang xin 2003.02.13
		insert into NSTKOUTDTL2(SRC, ID, LINE, GDGID, SUBWRH, WRH, QTY, COST)
		select @usergid, @id, LINE, GDGID, SUBWRH, WRH , QTY ,COST
		from STKOUTDTL2
		where CLS = @cls and NUM = @curNum

		update STKOUT
		set SNDTIME = @CurrentTime
		where CLS = @CLS and NUM = @CurNum

        -- Added by zhourong, 2006.05.10
        -- Q6669: 增加数据完整性校验
        IF @Cls = '配货'
        BEGIN
          DECLARE @err_msg VARCHAR(256)
          DECLARE @fromBillRecordCount int
          DECLARE @netBillRecordCount int
          SELECT @fromBillRecordCount = RECCNT FROM STKOUT WHERE NUM = @curnum AND CLS = @cls

          SELECT @netBillRecordCount = Count(1) FROM NSTKOUTDTL WHERE ID = @id

          IF @fromBillRecordCount <> @netBillRecordCount
          BEGIN
            SELECT @err_msg = '发送的来源单据中的明细数与网络表中的明细数不符。'
            RAISERROR (@err_msg, 16, 1)
          END
        END
		select @CurNum = MODNUM from STKOUT where CLS = @CLS and NUM = @CurNum
	end

end
GO
