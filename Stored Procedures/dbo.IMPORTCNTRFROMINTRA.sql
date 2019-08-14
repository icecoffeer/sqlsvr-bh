SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[IMPORTCNTRFROMINTRA]
(@storecode varchar(20),
 @f1 varchar(30),
 @vdrcode varchar(20),
 @begindate datetime,
 @enddate datetime,
 @AREA  decimal(24,2),     --经营面积
 @GUARDRATE decimal(24,2), --提点
 @SALECLS char(32),        --营销类型
 @AGENTMODE int,  --0:否(非独家) ,1:是(独家) ,2:专卖(专卖店)
 @BRANDNAME varchar(64),   --品牌
 @MINMONEY  decimal(24,2), --年保底
 @MONMONEY1 decimal(24,2),
 @MONMONEY2 decimal(24,2),
 @MONMONEY3 decimal(24,2),
 @MONMONEY4 decimal(24,2),
 @MONMONEY5 decimal(24,2),
 @MONMONEY6 decimal(24,2),
 @MONMONEY7 decimal(24,2),
 @MONMONEY8 decimal(24,2),
 @MONMONEY9 decimal(24,2),
 @MONMONEY10 decimal(24,2),
 @MONMONEY11 decimal(24,2),
 @MONMONEY12 decimal(24,2),
 @EMPMANAGENUM decimal(24,2),  --职工人数
 @NEMPMANAGENUM decimal(24,2), --外用工人数
 @STORAGECHARGE decimal(24,2), --仓储费
 @INCHARGE decimal(24,2),      --进场费
 @ECCHARGEOPTION varchar(32),  --是否有电子商务费
 @CARDPAYOPTION varchar(32),   --是否有银联卡手续费
 @EMPMANAGECHARGE decimal(24,2), --企业员工工资
 @MANAGECHARGE decimal(24,2),   --外用工管理费
 @PRIZE decimal(24,2)         --奖金系数
)
as 
begin
 declare  @storegid int, 
          @usercode varchar(10),
          @vdrgid int,   
          @dept char(10),
          @cntrnum char(14), 
          @cntrversion int,
          @cntrgroupnum char(14), 
          @cntrgroupversion int,
          @PICLS varchar(200),
          @PIBILL varchar(200),
          @PONEWNUM varchar(200),
          @exstore int,
          @realenddate datetime,
          @error varchar(255),
          @flag int

select @usercode=usercode from system(nolock)
select @storegid=gid from store(nolock) where code=@storecode
select @vdrgid=gid from vendor(nolock) where code=@vdrcode
select @dept=b.code from dept a(nolock),settledeptdept b(nolock) where a.code=b.deptcode and a.code=@f1
select @exstore=zbgid from system(nolock)
select @flag=1

  if @storegid is null or @vdrgid is null or @dept is null
  begin 
    select @error='待导入的合约的所在门店'+@storecode+'或供应商'+@vdrcode+'或部门'+@f1 +'等基本资料在HDPOS系统中找不到'

    insert into IMPORTCNTRFROMINTRALOG(time,content) 
    values(getdate(),@error)   
  
    set @flag=0  
  end

  if @storecode<>@usercode
  begin
    select @error='待导入的供应商'+@vdrcode+'的合同门店是'+@storecode+',非本门店合同无法导入'

    insert into IMPORTCNTRFROMINTRALOG(time,content) 
    values(getdate(),@error)

    set @flag=0
  end

  if exists(select 1 from ctcntr(nolock) where tag=1 and vendor=@vdrgid and dept=@dept)
  begin 
    select @error='供应商'+@vdrcode+'在结算组'+@dept+'下已经签了一份合约,违反了一个供应商在一个结算组下只能签一份合约的规则'

    insert into IMPORTCNTRFROMINTRALOG(time,content)
    values(getdate(),@error)

    set @flag=0
  end
  if not exists(select 1 from CNTRGROUP(nolock) where vendor=@vdrgid and stat=100 and tag=1)
  begin
    select @error='待导入的供应商' +@vdrcode+'没有合约组,请先维护其合约组'
    insert into IMPORTCNTRFROMINTRALOG(time,content) 
    values(getdate(),@error)

    set @flag=0
  end
   
 if @flag=1
 begin
  --获取合约组单号和版本号
  select @cntrgroupnum=num,@cntrgroupversion=version,@realenddate=realenddate from CNTRGROUP(nolock) where vendor=@vdrgid and stat=100 and tag=1
  
  --获取合约单号
  select @cntrnum=max(num) from ctcntr(nolock) 
  EXEC GENNEXTBILLNUMEX @PICLS = NULL, @PIBILL = 'CTCNTR', @PONEWNUM = @cntrnum OUTPUT

  --合约汇总
  insert into ctcntr(num,version,vendor,dept,signdate,stat,modifier,signer,exstore,begindate,enddate,realenddate,salesq,GUARDRATE,SALECLS,AGENTMODE,tag,filetext)
  select 
         @cntrnum,1,@vdrgid,@dept,@begindate,0,
         '未知[-]',                      --修改人，不能为空
         1,                              --签约人，不能为空，默认为未知
         @exstore,                       --生效门店
         @begindate,                     --合约开始时间
         @enddate,                       --合约结束时间
         @realenddate,                   --实际截止日期
         @AREA,                          --经营面积
         @GUARDRATE,                     --提点
         @SALECLS,                       --营销类型
         case @AGENTMODE when 0 then '非独家' when 1 then '独家' when 2 then '专卖店' else '' end,   --代理方式
         1, 
         '一、品牌: ' + @BRANDNAME + ' /N二、年保底(万): ' + convert(varchar(30), @MINMONEY) + ' /N三、月保底销售(万): ' + ' /N1月：'  + convert(varchar(30), @MONMONEY1) + ' /N2月：'  + convert(varchar(30), @MONMONEY2)  + ' /N3月：'  + convert(varchar(30), @MONMONEY3)   + ' /N4月：'  + convert(varchar(30), @MONMONEY4)   + ' /N5月: '  + convert(varchar(30), @MONMONEY5) + ' /N6月：'  + convert(varchar(30), @MONMONEY6) + ' /N7月：'  + convert(varchar(30), @MONMONEY7)  + ' /N8月：'  + convert(varchar(30), @MONMONEY8) + ' /N9月：'  + convert(varchar(30), @MONMONEY9) + ' /N10月：'  + convert(varchar(30), @MONMONEY10) + ' /N11月：'  + convert(varchar(30), @MONMONEY11) + ' /N12月：' + convert(varchar(30), @MONMONEY12) + ' /N四、职工人数:'   + convert(varchar(30), @EMPMANAGENUM)  + ' /N五、外用工人数:' + convert(varchar(30), @NEMPMANAGENUM) + ' /N六、仓储费'  + convert(varchar(30), @STORAGECHARGE)

  --合约组子合约对照关系
  delete from GROUPCNTR where num=@cntrgroupnum and version=@cntrgroupversion and cntrnum=@cntrnum and cntrversion=1
  insert into GROUPCNTR(num,version,cntrnum,cntrversion)
  select @cntrgroupnum,@cntrgroupversion,@cntrnum,1

  --合约明细
  declare @line int
  select @line=1

  if @INCHARGE>0
  begin
    --合约明细
    insert into ctcntrdtl(num,version,line,chgcode,genunit,gencycle,gendayoffset,gatheringmode,fstgendate,nextgendate)
    select @cntrnum,1,@line,(select code from CTCHGDEF(nolock) where name='进场费'),'月',1,25,'立即交款',
    convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102),dateadd(mm,1,convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102))
    --固定类明细
    insert into CTCntrFixDtl(Num, Version, Line, FeeUnit, FeeCycle, FstFeeDate,  NextBeginDate, NextEndDate, Amount)
    select @cntrnum,1,@line,'月',1, convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102),null,null,@INCHARGE    

    select @line=@line+1
  end
  
  if @ECCHARGEOPTION='有' --EC费用默认为100
  begin 
    --合约明细
    insert into ctcntrdtl(num,version,line,chgcode,genunit,gencycle,gendayoffset,gatheringmode,fstgendate,nextgendate)
    select @cntrnum,1,@line,(select code from CTCHGDEF(nolock) where name='电子商务费'),'月',1,25,'立即交款',
    convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102),dateadd(mm,1,convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102))

    --固定类明细
    insert into CTCntrFixDtl(Num, Version, Line, FeeUnit, FeeCycle, FstFeeDate,  NextBeginDate, NextEndDate, Amount)
    select @cntrnum,1,@line,'月',1, convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102),null,null,100

    select @line=@line+1
  end

  if @CARDPAYOPTION='有'
  begin 
    --合约明细
    insert into ctcntrdtl(num,version,line,chgcode,genunit,gencycle,gendayoffset,gatheringmode,fstgendate,nextgendate)
    select @cntrnum,1,@line,(select code from CTCHGDEF(nolock) where name='银联卡手续费'),'月',1,25,'立即交款',
    convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102),dateadd(mm,1,convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102))

    --固定类明细
    insert into CTCntrFixDtl(Num, Version, Line, FeeUnit, FeeCycle, FstFeeDate,  NextBeginDate, NextEndDate, Amount)
    select @cntrnum,1,@line,'月',1, convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102),null,null,0

    select @line=@line+1
  end

  if @EMPMANAGECHARGE>0
  begin
    --合约明细
    insert into ctcntrdtl(num,version,line,chgcode,genunit,gencycle,gendayoffset,gatheringmode,fstgendate,nextgendate)
    select @cntrnum,1,@line,(select code from CTCHGDEF(nolock) where name='企业员工工资'),'月',1,25,'立即交款',
    convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102),dateadd(mm,1,convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102))

    --固定类明细
    insert into CTCntrFixDtl(Num, Version, Line, FeeUnit, FeeCycle, FstFeeDate,  NextBeginDate, NextEndDate, Amount)
    select @cntrnum,1,@line,'月',1, convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102),null,null,@EMPMANAGECHARGE

    select @line=@line+1
  end

  if @MANAGECHARGE>0
  begin
    --合约明细
    insert into ctcntrdtl(num,version,line,chgcode,genunit,gencycle,gendayoffset,gatheringmode,fstgendate,nextgendate)
    select @cntrnum,1,@line,(select code from CTCHGDEF(nolock) where name='外用工管理费'),'月',1,25,'立即交款',
    convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102),dateadd(mm,1,convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102))

    --固定类明细
    insert into CTCntrFixDtl(Num, Version, Line, FeeUnit, FeeCycle, FstFeeDate,  NextBeginDate, NextEndDate, Amount)
    select @cntrnum,1,@line,'月',1, convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102),null,null,@MANAGECHARGE

    select @line=@line+1
  end

  if @PRIZE>0
  begin
    --合约明细
    insert into ctcntrdtl(num,version,line,chgcode,genunit,gencycle,gendayoffset,gatheringmode,fstgendate,nextgendate)
    select @cntrnum,1,@line,(select code from CTCHGDEF(nolock) where name='员工奖金1'),'月',1,25,'立即交款',
    convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102),dateadd(mm,1,convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102))

    --提成类明细
    INSERT INTO CTCNTRRATEDTL (NUM, VERSION, LINE, FEEUNIT, FEECYCLE,  FEEDAYOFFSET, FSTFEEDATE, NEXTBEGINDATE, NEXTENDDATE, FIXCOST,                                                  RATEMODE,  CALCMODE, FEEPREC, ROUNDTYPE, STORESCOPE, GDSCOPE, GDSCOPESQL, GDSCOPETEXT) 
    select @cntrnum,1,@line,'月',1,24,convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102),
    convert(char(10),dateadd(dd, - day(@begindate) + 25, @begindate),102),
    dateadd(mm,1,convert(char(10),dateadd(dd, - day(@begindate) + 24, @begindate),102)),0,
           '数值分段','合计',1,'四舍五入','全部','全部','',''

    --提成类数据源
    insert into CTCNTRDTLDATASRC (NUM, VERSION, LINE, DSCODE)
    select @cntrnum,1,@line,'0101'
    insert into CTCNTRDTLDATASRC (NUM, VERSION, LINE, DSCODE)
    select @cntrnum,1,@line,'0102'
    insert into CTCNTRDTLDATASRC (NUM, VERSION, LINE, DSCODE)
    select @cntrnum,1,@line,'0103'
    insert into CTCNTRDTLDATASRC (NUM, VERSION, LINE, DSCODE)
    select @cntrnum,1,@line,'0104'

    --合约提成提成率
    insert into CTCntrRateDisc(Num, Version, Line, ItemNo,  Rate, LowAmt, HighAmt, QBase) 
    select @cntrnum,1,@line,1,@PRIZE,0,999999999,0
    
    select @line=@line+1
  end
 end
end

GO
