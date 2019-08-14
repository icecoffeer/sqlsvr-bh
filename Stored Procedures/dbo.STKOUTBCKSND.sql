SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[STKOUTBCKSND]
@CLS char(10),
@NUM char(10),
@RCV int,
@FRCCHK smallint
as
begin
	declare @Stat smallint, @Id int, @CurNum char(10)
	declare @UserGID int, @CurrentTime datetime

	select @UserGID = max(USERGID) from SYSTEM
	select @CurrentTime = getdate()

	select @Stat = STAT from STKOUTBCK where CLS = @CLS and NUM = @NUM

	if @Stat <> 1 and @Stat <> 4 and @Stat <> 6
	begin
		raiserror('该单据不是已审核单据或冲单(负单), 不能发送', 16, 1)
		return(1)
	end

	if (select SRC from STKOUTBCK where CLS = @CLS and NUM = @NUM) <> @UserGID
	begin
		raiserror('该单据不是本单位生成的单据,不能发送', 16, 1)
		return(1)
	end

	select @CurNum = @NUM

	while @CurNum is not null and @CurNum <> ''
	begin
		execute GETNETBILLID @Id = @Id output

		insert into NSTKOUTBCK (ID, CLS, NUM, CLIENT, BILLTO, OCRDATE, TOTAL, TAX, FILDATE,
			CHECKER, STAT, MODNUM, RECCNT, NSTAT, NOTE, NNOTE, SRC, RCV, SNDTIME, RCVTIME,
			FRCCHK, TYPE, GENCLS, GENNUM)
		select @Id, CLS, NUM, CLIENT, BILLTO, OCRDATE, TOTAL, TAX, FILDATE,
			CHECKER, STAT, MODNUM, RECCNT, 0, NOTE, null, @UserGID, @RCV, @CurrentTime,
			null, @FRCCHK, 0, GENCLS, GENNUM
		from STKOUTBCK
		where CLS = @CLS and NUM = @CurNum

		insert into NSTKOUTBCKDTL (SRC, ID, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX,
			VALIDDATE, WRH,NOTE,COST)
		select @UserGID, @Id, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX,
			VALIDDATE, 1,NOTE,COST
		from STKOUTBCKDTL
		where CLS = @CLS and NUM = @CurNum

		--added by wang xin 2003.02.13
		insert into NSTKOUTBCKDTL2(SRC, ID, LINE, GDGID, SUBWRH, WRH, QTY, COST)
		select @usergid, @id, LINE, GDGID, SUBWRH, WRH , QTY ,COST
		from STKOUTBCKDTL2
		where CLS = @cls and NUM = @curNum

		update STKOUTBCK
		set SNDTIME = @CurrentTime
		where CLS = @CLS and NUM = @CurNum

        -- Added by zhourong, 2006.05.10
        -- Q6669: 增加数据完整性校验
        IF @Cls = '配货'
        BEGIN
          DECLARE @fromBillRecordCount int
          DECLARE @netBillRecordCount int
          DECLARE @errormsg VARCHAR(256)
          SELECT @fromBillRecordCount = RECCNT FROM STKOUTBCK WHERE NUM = @curnum AND CLS = @cls

          SELECT @netBillRecordCount = Count(1) FROM NSTKOUTBCKDTL WHERE ID = @id

          IF @fromBillRecordCount <> @netBillRecordCount
          BEGIN
            SELECT @errormsg = '发送的来源单据中的明细数与网络表中的明细数不符。'
            RAISERROR (@errormsg, 16, 1)
          END
        END

		select @CurNum = MODNUM from STKOUTBCK where CLS = @CLS and NUM = @CurNum
	end
end
GO
