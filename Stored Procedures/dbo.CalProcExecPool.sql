SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[CalProcExecPool]
(
  @SplitType smallint  --操作模式 0-分解型, 1-组合型
)
As
Begin
  Declare
    @RawGid int,
    @RawQty Decimal(24, 4),
    @SumRawQty Decimal(24, 4),
    @SumRawRealQty Decimal(24, 4),
    @SumProdQty  Decimal(24, 4),
    @SumProdRealQty Decimal(24, 4),
    @msg varchar(255),
    @ret smallint

  set @Ret = 0;
  Declare c_ProcExecRawPool cursor for
    select GDGID, QTY
    from TMPPROCEXECRAWDTL
    where SPID = @@SPID
      and RAW = @SplitType;

  open c_ProcExecRawPool
  fetch next from c_ProcExecRawPool into
    @RawGid, @RawQty;
  while @@fetch_status = 0
    begin
    	if @SplitType = 1
    	  begin
          select @SumRawQty = Sum(T.PSCPQTY * P.QTY)
          from TMPPROCEXECPOOL T(nolock), PSCPDTL P(nolock)
          where T.SPID = @@SPID
            and T.PSCPGID = P.GID
            and T.RAWGID = @RawGid
            and P.GDGID = @RawGid
            and P.RAW = 1;
          update TMPPROCEXECPOOL
          set RAWQTY = @RawQty * TMPPROCEXECPOOL.PSCPQTY * PSCPDTL.QTY/@SumRawQty
          from TMPPROCEXECPOOL, PSCPDTL
          where SPID = @@SPID
            and TMPPROCEXECPOOL.PSCPGID = PSCPDTL.GID
            and TMPPROCEXECPOOL.RAWGID = @RawGid
            and PSCPDTL.GDGID = @RawGid
            and PSCPDTL.RAW = 1;

         --消除因除不尽产生的总数量与分摊数量和之间的误差
          select @SumRawRealQty = sum(RAWQTY)
          from TMPPROCEXECPOOL(nolock)
          where SPID = @@SPID
          and RAWGID = @RawGid
          if @SumRawRealQty <> @RawQty
            update TMPPROCEXECPOOL
            set RAWQTY = RAWQTY + (@RawQty - @SumRawRealQty)
            where id = (select top 1 id from TMPPROCEXECPOOL
                        where SPID = @@SPID
                        and RAWGID = @RawGid
                        order by RAWQTY desc)
        end;
      else if @SplitType = 0
      	begin
          select @SumProdQty = Sum(T.PSCPQTY * P.QTY)
          from TMPPROCEXECPOOL T(nolock), PSCPDTL P(nolock)
          where T.SPID = @@SPID
            and T.PSCPGID = P.GID
            and T.PRODGID = @RawGid
            and P.GDGID = @RawGid
            and P.RAW = 0;
          update TMPPROCEXECPOOL
          set PRODQTY = @RawQty * TMPPROCEXECPOOL.PSCPQTY * PSCPDTL.QTY/@SumProdQty
          from TMPPROCEXECPOOL, PSCPDTL
          where SPID = @@SPID
            and TMPPROCEXECPOOL.PSCPGID = PSCPDTL.GID
            and TMPPROCEXECPOOL.PRODGID = @RawGid
            and PSCPDTL.GDGID = @RawGid
            and PSCPDTL.RAW = 0;

         --消除因除不尽产生的总数量与分摊数量和之间的误差
          select @SumProdRealQty = sum(PRODQTY)
          from TMPPROCEXECPOOL(nolock)
          where SPID = @@SPID
          and PRODGID = @RawGid
          if @SumProdRealQty <> @RawQty
            update TMPPROCEXECPOOL
            set PRODQTY = RAWQTY + (@RawQty - @SumProdRealQty)
            where id = (select top 1 id from TMPPROCEXECPOOL
                        where SPID = @@SPID
                        and PRODGID = @RawGid
                        order by PRODQTY desc)
        end;
      fetch next from c_ProcExecRawPool into @RawGid, @RawQty;
    end;
  close c_ProcExecRawPool;
  deallocate c_ProcExecRawPool;
  exec @ret = CalProcExecPoolInvPrc @@Spid, @SplitType, @msg output;
  if @ret <> 0 return(@ret);
  return(0);
End;
GO
