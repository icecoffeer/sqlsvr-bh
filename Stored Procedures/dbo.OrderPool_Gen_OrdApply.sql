SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_Gen_OrdApply](
  @piOperGid int,
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @zbgid int,
    @vUserGid int,
    @vGdGid int,
    @vVdrGid int,
    @vWrh int,
    @vCombineType char(10),
    @vSendDate datetime,
    @vQty decimal(24,4),
    @vPrice decimal(24,4),
    @vRoundType char(10),
    @vSplitDays int,
    @vDept varchar(20),
    @vTaxrate money,
    @tempvdrgid int,
    @STOREORDAPPLYTYPE int,
    @STOREORDAPPLYSTAT int,
    @asettleno int,
    @NEWNUM VARCHAR(20),@line int,
    @orderapplystat int,
    @DefaultApplyDGid int,
    @deptlimit int,
    @taxratelimit int,
    @tempdept varchar(20),@temptaxrate money,@tempSTOREORDAPPLYTYPE int

  select @vUserGid = USERGID,@zbgid=zbgid from SYSTEM(nolock)
  select @asettleno=max(no) from monthsettle(nolock)

  ---根据选项调整生成叫货申请单的状态
  exec OptReadInt 8183, 'OrderApplyStat', 0, @orderapplystat output    --读取选项  整型
  update orderpooltemp set  STOREORDAPPLYSTAT= @orderapplystat
  update orderpoolhtemp set STOREORDAPPLYSTAT= @orderapplystat
  ---editbydxm

  ---取叫货申请单的各个选项
  exec OptReadInt 700, 'DefaultApplyDGid',@zbgid, @DefaultApplyDGid output
  exec OptReadInt 700, 'deptlimit',0, @deptlimit output
  exec OptReadInt 700, 'taxratelimit',0, @taxratelimit output

  ----先按申请类型分单
  declare cur_type cursor for select  distinct o.STOREORDAPPLYTYPE from ORDERPOOLTEMP o(nolock)
  open cur_type
  fetch next from cur_type into @STOREORDAPPLYTYPE
  while @@fetch_status=0
  begin

  set @line=1
  if object_id('c_OrderPoolTemp') is not null deallocate c_OrderPoolTemp
  declare c_OrderPoolTemp cursor for
    select g.f1 dept,g.taxrate,case when g.alc='统配' then @zbgid else o.VDRGID end vdrgid, o.WRH, o.COMBINETYPE, o.SENDDATE, o.GDGID,
      o.QTY, o.PRICE, o.SPLITDAYS,o.ROUNDTYPE,o.STOREORDAPPLYTYPE,o.STOREORDAPPLYSTAT
    from ORDERPOOLTEMP o(nolock),goods g(nolock)
    where SPID = @@spid and o.gdgid=g.gid and o.STOREORDAPPLYTYPE=@STOREORDAPPLYTYPE
    order by g.f1,g.taxrate,case when g.alc='统配' then @zbgid else o.VDRGID end, o.WRH, o.COMBINETYPE, o.SENDDATE,o.GDGID
  open c_OrderPoolTemp
  fetch next from c_OrderPoolTemp
    into @vDept,@vTaxrate,@vVdrGid, @vWrh, @vCombineType, @vSendDate, @vGdGid, @vQty, @vPrice, @vSplitDays,@vRoundType,@STOREORDAPPLYTYPE,@STOREORDAPPLYSTAT

   --抢占单号
  EXEC GENNEXTBILLNUM '','StoreOrdApply',@NEWNUM OUTPUT
  while @@fetch_status=0
  begin

    if @vQty > 0
    begin
    insert into storeordapplydtl(num,line,gdgid,gdcode,qpc,qpcstr,qty,applyqty,note,excgqty)
    select @newnum,@line,@vGdGid,g.code,g.qpc,'',@vqty,@vqty,'',-1
    from goods g(nolock)
    where g.gid=@vGdGid
  end

  set @tempvdrgid=@vVdrGid
  set @tempdept=@vDept
  set @temptaxrate=@vTaxrate


  fetch next from c_OrderPoolTemp
    into @vDept,@vTaxrate,@vVdrGid, @vWrh, @vCombineType, @vSendDate, @vGdGid, @vQty, @vPrice, @vSplitDays,@vRoundType,@STOREORDAPPLYTYPE,@STOREORDAPPLYSTAT
       ---select newid(),@@fetch_status,@tempvdrgid,@vVdrGid      ---dxm

    if @deptlimit=1
    begin
    if @taxratelimit=1 ----按部门和税率分单开始
    begin
      if (@tempdept<>@vDept) or (@@fetch_status<>0)
      begin
           ---单据汇总
           insert into storeordapply(NUM, storegid,vendorgid,reccnt,stat,filler,filldate,
             opdate,gennum,memo,type,taxratelmt,deptlmt,checker,gennum2,settleno,applydgid/*,LstUpdTime*/)
           select @newnum,@vUserGid,@tempvdrgid,@line,@STOREORDAPPLYSTAT,rtrim(e.name)+'['+rtrim(e.code)+']',getdate(),
             null,'定货池','由定货池生成;',@STOREORDAPPLYTYPE,@temptaxrate,@tempdept,'',null,@asettleno,@DefaultApplyDGid/*,GetDate()*/
           from employee e(nolock)
           where e.gid=@piOperGid

           --在生成单据表中记录
           insert into ORDERPOOLGENBILLS(BILLNAME, NUM, DTLCNT, FLAG, VDRGID, WRH, COMBINETYPE, SENDDATE)
           values('叫货申请单', @newnum, @line, 2, @tempvdrgid, @vWrh, @vCombineType, getdate())
            --抢占单号
           if @@fetch_status=0
           begin
              EXEC GENNEXTBILLNUM '','StoreOrdApply',@NEWNUM OUTPUT
              set @line=1
           end
           continue
      end
      else
      begin
        if (@temptaxrate<>@vTaxrate) or (@@fetch_status<>0)
        begin
             ---单据汇总
             insert into storeordapply(NUM, storegid,vendorgid,reccnt,stat,filler,filldate,opdate,gennum,
               memo,type,taxratelmt,deptlmt,checker,gennum2,settleno,applydgid/*,LstUpdTime*/)
             select @newnum,@vUserGid,@tempvdrgid,@line,@STOREORDAPPLYSTAT,rtrim(e.name)+'['+rtrim(e.code)+']',getdate(),null,'定货池',
               '由定货池生成;',@STOREORDAPPLYTYPE,@temptaxrate,@tempdept,'',null,@asettleno,@DefaultApplyDGid/*,Getdate()*/
             from employee e(nolock)
             where e.gid=@piOperGid

             --在生成单据表中记录
             insert into ORDERPOOLGENBILLS(BILLNAME, NUM, DTLCNT, FLAG, VDRGID, WRH, COMBINETYPE, SENDDATE)
             values('叫货申请单', @newnum, @line, 2, @tempvdrgid, @vWrh, @vCombineType, getdate())
            --抢占单号
             if @@fetch_status=0
             begin
                EXEC GENNEXTBILLNUM '','StoreOrdApply',@NEWNUM OUTPUT
                set @line=1
             end
             continue
        end
        else
        begin
          if (@tempvdrgid<>@vVdrGid) or (@@fetch_status<>0)
          begin
             ---单据汇总
             insert into storeordapply(NUM, storegid,vendorgid,reccnt,stat,filler,filldate,opdate,gennum,
               memo,type,taxratelmt,deptlmt,checker,gennum2,settleno,applydgid/*,LstUpdTime*/)
             select @newnum,@vUserGid,@tempvdrgid,@line,@STOREORDAPPLYSTAT,rtrim(e.name)+'['+rtrim(e.code)+']',getdate(),null,'定货池',
               '由定货池生成;',@STOREORDAPPLYTYPE,@temptaxrate,@tempdept,'',null,@asettleno,@DefaultApplyDGid/*,GetDate()*/
             from employee e(nolock)
             where e.gid=@piOperGid

             --在生成单据表中记录
             insert into ORDERPOOLGENBILLS(BILLNAME, NUM, DTLCNT, FLAG, VDRGID, WRH, COMBINETYPE, SENDDATE)
             values('叫货申请单', @newnum, @line, 2, @tempvdrgid, @vWrh, @vCombineType, getdate())
            --抢占单号
             if @@fetch_status=0
             begin
                EXEC GENNEXTBILLNUM '','StoreOrdApply',@NEWNUM OUTPUT
                set @line=1
             end
             continue
          end
        end
      end
    end   ---按部门和税率分单结束
    else  ----按部门，不按税率分单开始
    begin
      if (@tempdept<>@vDept) or (@@fetch_status<>0)
      begin
           ---单据汇总
           insert into storeordapply(NUM, storegid,vendorgid,reccnt,stat,filler,filldate,opdate,gennum,
             memo,type,taxratelmt,deptlmt,checker,gennum2,settleno,applydgid/*,LstUpdTime*/)
           select @newnum,@vUserGid,@tempvdrgid,@line,@STOREORDAPPLYSTAT,rtrim(e.name)+'['+rtrim(e.code)+']',getdate(),null,'定货池',
             '由定货池生成;',@STOREORDAPPLYTYPE,@temptaxrate,@tempdept,'',null,@asettleno,@DefaultApplyDGid/*,GetDate()*/
           from employee e(nolock)
           where e.gid=@piOperGid

           --在生成单据表中记录
           insert into ORDERPOOLGENBILLS(BILLNAME, NUM, DTLCNT, FLAG, VDRGID, WRH, COMBINETYPE, SENDDATE)
           values('叫货申请单', @newnum, @line, 2, @tempvdrgid, @vWrh, @vCombineType, getdate())
            --抢占单号
           if @@fetch_status=0
           begin
              EXEC GENNEXTBILLNUM '','StoreOrdApply',@NEWNUM OUTPUT
              set @line=1
           end
           continue
      end
      else
      begin
          if (@tempvdrgid<>@vVdrGid) or (@@fetch_status<>0)
          begin
             ---单据汇总
             insert into storeordapply(NUM, storegid,vendorgid,reccnt,stat,filler,filldate,opdate,gennum,
               memo,type,taxratelmt,deptlmt,checker,gennum2,settleno,applydgid/*,LstUpdTime*/)
             select @newnum,@vUserGid,@tempvdrgid,@line,@STOREORDAPPLYSTAT,rtrim(e.name)+'['+rtrim(e.code)+']',getdate(),null,'定货池',
               '由定货池生成;',@STOREORDAPPLYTYPE,@temptaxrate,@tempdept,'',null,@asettleno,@DefaultApplyDGid/*,GetDate()*/
             from employee e(nolock)
             where e.gid=@piOperGid

             --在生成单据表中记录
             insert into ORDERPOOLGENBILLS(BILLNAME, NUM, DTLCNT, FLAG, VDRGID, WRH, COMBINETYPE, SENDDATE)
             values('叫货申请单', @newnum, @line, 2, @tempvdrgid, @vWrh, @vCombineType, getdate())
            --抢占单号
             if @@fetch_status=0
             begin
                EXEC GENNEXTBILLNUM '','StoreOrdApply',@NEWNUM OUTPUT
                set @line=1
             end
             continue
          end
      end
    end  ---按部门，不按税率分单结束
  end
  else
  begin
    if @taxratelimit=1 ----不按部门，按税率分单开始
    begin
      if (@temptaxrate<>@vTaxrate) or (@@fetch_status<>0)
      begin
             ---单据汇总
             insert into storeordapply(NUM, storegid,vendorgid,reccnt,stat,filler,filldate,opdate,gennum,
               memo,type,taxratelmt,deptlmt,checker,gennum2,settleno,applydgid/*,LstUpdTime*/)
             select @newnum,@vUserGid,@tempvdrgid,@line,@STOREORDAPPLYSTAT,rtrim(e.name)+'['+rtrim(e.code)+']',getdate(),null,'定货池',
               '由定货池生成;',@STOREORDAPPLYTYPE,@temptaxrate,@tempdept,'',null,@asettleno,@DefaultApplyDGid/*,GetDate()*/
             from employee e(nolock)
             where e.gid=@piOperGid

             --在生成单据表中记录
             insert into ORDERPOOLGENBILLS(BILLNAME, NUM, DTLCNT, FLAG, VDRGID, WRH, COMBINETYPE, SENDDATE)
             values('叫货申请单', @newnum, @line, 2, @tempvdrgid, @vWrh, @vCombineType, getdate())
            --抢占单号
             if @@fetch_status=0
             begin
                EXEC GENNEXTBILLNUM '','StoreOrdApply',@NEWNUM OUTPUT
                set @line=1
             end
             continue
      end
      else
      begin
          if (@tempvdrgid<>@vVdrGid) or (@@fetch_status<>0)
          begin
             ---单据汇总
             insert into storeordapply(NUM, storegid,vendorgid,reccnt,stat,filler,filldate,opdate,gennum,
               memo,type,taxratelmt,deptlmt,checker,gennum2,settleno,applydgid/*,LstUpdTime*/)
             select @newnum,@vUserGid,@tempvdrgid,@line,@STOREORDAPPLYSTAT,rtrim(e.name)+'['+rtrim(e.code)+']',getdate(),null,'定货池',
               '由定货池生成;',@STOREORDAPPLYTYPE,@temptaxrate,@tempdept,'',null,@asettleno,@DefaultApplyDGid/*,GetDate()*/
             from employee e(nolock)
             where e.gid=@piOperGid

             --在生成单据表中记录
             insert into ORDERPOOLGENBILLS(BILLNAME, NUM, DTLCNT, FLAG, VDRGID, WRH, COMBINETYPE, SENDDATE)
             values('叫货申请单', @newnum, @line, 2, @tempvdrgid, @vWrh, @vCombineType, getdate())
            --抢占单号
             if @@fetch_status=0
             begin
                EXEC GENNEXTBILLNUM '','StoreOrdApply',@NEWNUM OUTPUT
                set @line=1
             end
             continue
          end
      end
    end   -------不按部门，按税率分单结束
    else  ----不按部门，也不按税率分单
    begin
      if (@tempvdrgid<>@vVdrGid) or (@@fetch_status<>0)
      begin
           ---单据汇总
           insert into storeordapply(NUM, storegid,vendorgid,reccnt,stat,filler,filldate,opdate,gennum,
             memo,type,taxratelmt,deptlmt,checker,gennum2,settleno,applydgid/*,LstUpdTime*/)
           select @newnum,@vUserGid,@tempvdrgid,@line,@STOREORDAPPLYSTAT,rtrim(e.name)+'['+rtrim(e.code)+']',getdate(),null,'定货池',
             '由定货池生成;',@STOREORDAPPLYTYPE,17,null,'',null,@asettleno,@DefaultApplyDGid/*,GetDate()*/
           from employee e(nolock)
           where e.gid=@piOperGid

           --在生成单据表中记录
           insert into ORDERPOOLGENBILLS(BILLNAME, NUM, DTLCNT, FLAG, VDRGID, WRH, COMBINETYPE, SENDDATE)
           values('叫货申请单', @newnum, @line, 2, @tempvdrgid, @vWrh, @vCombineType, getdate())
         --抢占单号
           if @@fetch_status=0
           begin
              EXEC GENNEXTBILLNUM '','StoreOrdApply',@NEWNUM OUTPUT
              set @line=1
           end
           continue
      end
    end
  end

  ---未执行到分单时，行号加1
  set @line=@line+1

  end
  close c_OrderPoolTemp
  deallocate c_OrderPoolTemp

    fetch next from cur_type into @STOREORDAPPLYTYPE
  end
  close cur_type
  deallocate cur_type

  return 0
end
GO
