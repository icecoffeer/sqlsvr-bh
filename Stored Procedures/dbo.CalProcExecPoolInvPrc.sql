SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[CalProcExecPoolInvPrc]
(
  @Spid  int,
  @SplitType smallint,  --操作模式 0-分解型, 1-组合型
  @msg  varchar(255) output
)
As
Begin
  Declare
    @ProcTaskNum varchar(14),
    @PscpGid int,
    @Algavgtag varchar(255), --成本分摊方式
    @ProdWrh int, --产品仓位
    @ProdCount int,  --产品数
    @ProdQty decimal(24, 4),  --产品数量
    @ProdGid int,  --产品
    @CostAmt decimal(24, 4),  --产品总成本
    @inprc decimal(24, 4),
    @rtlprc decimal(24, 4),
    @cstprc decimal(24, 4),
    @cntinprc decimal(24, 4),
    @lwtrtlprc decimal(24, 4),
    @RawCount decimal(24, 4),  --原料数
    @RawGid int,   --产品
    @RawQty decimal(24, 4),  --原料数量
    @RawAmount decimal(24, 4), --原料总成本
    @ProdAmount decimal(24, 4),  --产品总成本
    @Ret smallint,
    @RawWrhCode varchar(20),
    @RawWrh int

  set @Ret = 0;

  select @RawWrhCode = optionvalue from hdoption(nolock) where moduleno = 647 and optioncaption = 'RAWWRHDEFAULT';
  if @RawWrhCode = ''
    begin
      set @msg = '未配置加工原料仓位';
      set @Ret = 1;
    end;
  select @RawWrh = Gid from Warehouse(nolock) where Code = @RawWrhCode;
  select @ProdWrh = W.GID from System s(nolock), Warehouse w(nolock) where s.dftwrh = w.Gid;

  delete from TMPPROCEXECPOOLCOST where SPID = @Spid;

  Declare c_ProcExecPoolInvPrc cursor for
    select distinct PROCTASKNUM, PSCPGID
    from TMPPROCEXECPOOL
    where SPID = @SPID;

  open c_ProcExecPoolInvPrc;
  fetch next from c_ProcExecPoolInvPrc into @ProcTaskNum, @PscpGid;
  while @@fetch_status = 0
    begin
      select @Algavgtag = Algavgtag from ProcTask(nolock) where Num = @ProcTaskNum;

      if @SplitType = 1 --组合型
        begin
          select @ProdCount = count(distinct(PRODGID))
          from TMPPROCEXECPOOL(nolock)
          where SPID = @Spid
            and PROCTASKNUM = @ProcTaskNum
            and PSCPGID = @PscpGid;
          if @ProdCount > 1
            begin
              set @msg = '组合型任务单中，同一配方不能包含多个产品！';
              set @Ret = 1;
            end;
          select @ProdGid = PRODGID, @ProdQty = PRODQTY
          from TMPPROCEXECPOOL
          where SPID = @Spid
            and PROCTASKNUM = @ProcTaskNum
            and PSCPGID = @PscpGid;
          if @Algavgtag = '预期售价额分摊原料总成本'
            begin
              set @msg = '组合任务单不能使用预期售价额分摊原料总成本的成本分摊算法';
              set @Ret = 2;
            end;
          if @Algavgtag = '配方原料总成本/配方产品系数'
            begin
              select @CostAmt = sum(IsNull(G.INVPRC,0) * T.RAWQTY)
              from TMPPROCEXECPOOL T(nolock), GDWRH G(nolock)
              where T.SPID = @Spid
                and T.PROCTASKNUM = @ProcTaskNum
                and T.PSCPGID = @PscpGid
                and T.PRODGID = @ProdGid
                and T.RAWGID = G.GDGID
                and G.WRH = @RawWrh
              select @cstprc = ROUND(@CostAmt/@ProdQty, 4);
            end;
          else
            begin
              select  @rtlprc = RtlPrc, @cntinprc = IsNull(CntInPrc, 0), @lwtrtlprc = IsNull(LwtRtlPrc, 0)
              from goods(nolock)
              where GID = @ProdGid;

              if @Algavgtag = '核算价'
                select @inprc = IsNull(InvPrc, 0)
                from GDWRH(nolock)
                where GDGID = @ProdGid
                  and WRH = @RawWrh;

              select @cstprc = (case @Algavgtag
                      when '核算价' then @inprc
                      when '合同价' then @cntinprc
                      when '最低售价' then @lwtrtlprc
                    end);
              select @CostAmt = @cstprc * @ProdQty;
            end;
          insert into TMPPROCEXECPOOLCOST(SPID, PROCTASKNUM, PSCPGID, PRODGID, PRODQTY, PRODCOSTAMT, PRODCOSTPRC)
          values(@Spid, @ProcTaskNum, @PscpGid, @ProdGid, @ProdQty, @CostAmt, @cstprc);
        end;
      else if @SplitType = 0 --分解型
      	begin
          select @RawCount = count(distinct(RAWGID))
          from TMPPROCEXECPOOL(nolock)
          where SPID = @Spid
            and PROCTASKNUM = @ProcTaskNum
            and PSCPGID = @PscpGid;
          if @RawCount > 1
            begin
              set @msg = '分解型任务单中，同一配方不能包含多个原料！';
              set @Ret = 2;
            end;
          select @RawGid = RAWGID, @RawQty = RAWQTY
          from TMPPROCEXECPOOL
          where SPID = @Spid
            and PROCTASKNUM = @ProcTaskNum
            and PSCPGID = @PscpGid;
          if @Algavgtag = '配方原料总成本/配方产品系数'
            begin
              set @msg = '组合任务单不能使用配方原料总成本/配方产品系数的成本分摊算法';
              set @Ret = 2;
            end;
         if @Algavgtag = '预期售价额分摊原料总成本'
            begin
              select @RawAmount = sum(IsNull(INVPRC, 0) * @RawQty)
              from GDWRH (nolock)
              where WRH = @RawWrh
                and GDGID = @RawGid;

              select @ProdAmount = SUM(P.ExpectPrc * T.PRODQTY)
              from TMPPROCEXECPOOL T(nolock), PSCPDTL P(nolock)
              where SPID = @Spid
                and T.PROCTASKNUM = @ProcTaskNum
                and T.PSCPGID = @PscpGid
                and T.RAWGID = @RawGid
                and P.GID = @PscpGid
                and T.PRODGID = P.GDGID
                and P.RAW = 0

              insert into TMPPROCEXECPOOLCOST(SPID, PROCTASKNUM, PSCPGID, PRODGID, PRODQTY, PRODCOSTAMT, PRODCOSTPRC)
              select @Spid, @ProcTaskNum, @Pscpgid, T.PRODGID, T.PRODQTY, @RawAmount*T.PRODQTY*P.ExpectPrc/@ProdAmount, @RawAmount*P.ExpectPrc/@ProdAmount
              from TMPPROCEXECPOOL T(nolock), PSCPDTL P(nolock)
              where SPID = @Spid
                and T.PROCTASKNUM = @ProcTaskNum
                and T.PSCPGID = @PscpGid
                and T.RAWGID = @RawGid
                and P.GID = @PscpGid
                and T.PRODGID = P.GDGID
                and P.RAW = 0
              group by T.PRODGID, T.PRODQTY, P.EXPECTPRC;
           --消除因除不尽产生的总金额与分摊金额和之间的误差
            /*  select @ProdAmount = sum(PRODCOSTAMT)
              from TMPPROCEXECPOOLCOST(nolock)
              where SPID = @Spid
                and PROCTASKNUM = @ProcTaskNum
                and PSCPGID = @PscpGid; */
            end;
          else
            begin
              Declare c_ProcExecPoolProd cursor for
              select distinct PRODGID, PRODQTY
              from TMPPROCEXECPOOL
              where SPID = @SPID
                and PROCTASKNUM = @ProcTaskNum
                and PSCPGID = @PscpGid
                and RAWGID = @RawGid;
              open c_ProcExecPoolProd;
              fetch next from c_ProcExecPoolProd into @ProdGid, @ProdQty;
              while @@fetch_status = 0
                begin
                  select @rtlprc = RtlPrc, @cntinprc = IsNull(CntInPrc, 0), @lwtrtlprc = IsNull(LwtRtlPrc, 0)
                  from goods(nolock)
                  where GID = @ProdGid;

                  if @Algavgtag = '核算价'
                    select @inprc = IsNull(InvPrc, 0)
                    from GDWRH(nolock)
                    where GDGID = @ProdGid
                      and WRH = @RawWrh;

                  select @cstprc = (case @Algavgtag
                          when '核算价' then @inprc
                          when '合同价' then @cntinprc
                          when '最低售价' then @lwtrtlprc
                        end);
                  insert into TMPPROCEXECPOOLCOST(SPID, PROCTASKNUM, PSCPGID, PRODGID, PRODQTY, PRODCOSTAMT, PRODCOSTPRC)
                  values(@Spid, @ProcTaskNum, @Pscpgid, @ProdGid, @ProdQty, @cstprc * @ProdQty, @cstprc);
                	fetch next from c_ProcExecPoolProd into @ProdGid, @ProdQty;
                end;
              close c_ProcExecPoolProd;
              deallocate c_ProcExecPoolProd;
            end;
      	end;
      fetch next from c_ProcExecPoolInvPrc into @ProcTaskNum, @PscpGid;
    end;
  close c_ProcExecPoolInvPrc;
  deallocate c_ProcExecPoolInvPrc;
  return @Ret;
End;
GO
