SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[StartupPhase2]              
--with Encryption              
as              
begin              
  declare              
    @settleno int,              
    @return_status int,              
    @OptionValue smallint,              
    @msg varchar(255),              
    @poMsg varchar(255),              
    @usergid int,              
    @userproperty int  
       
              
  select @settleno = max(NO) from MONTHSETTLE              
  select @usergid = USERGID, @userproperty = userproperty from SYSTEM(nolock)              
    
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)                        
  values (getdate(), 'STARTUP', 'HDSVC',              
  'SETTLEDAY', 101, '进入执行日结转单据生效及终止等日结过程。。。' )   
     
    
  if exists (select 1 from HDOPTION where MODULENO = 0 and OPTIONCAPTION = '上一结转日' and OPTIONVALUE=CONVERT(char(10),getdate(),102))  
  begin  
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)                        
    values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '已完成所有日结过程，无需在重复执行' )   
    return 0  
  end   
    
    
  waitfor delay '0:0:0.010'            
  exec zhps_autoocrweekdate            
            
  waitfor delay '0:0:0.010'            
  exec zhps_cleartmppay            
              
  -- 自动调价(调价单) 2000-06-07              
  waitfor delay '0:0:0.010'              
  exec StartUp_Step_PrcAdj              
              
  -- 自动调价2(售价调整单) 2004-07-25              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_Rtlprcadj              
              
  -- 自动生效调整营销方式(营销方式调整单) 2004-09-27              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_GdSaleAdj              
              
  -- 促销标志 2000-06-07              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_Promote              
              
  -- 定单取消              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_OrdCancel              
              
  -- 促销单生效  2002-09-02              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_PrcPrm              
              
  -- 限制业务调整单生效  2003-06-02              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_Ltdadj              
              
  -- 配货方式调整单生效  2006-7-14              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_AlcAdj              
              
  -- 赠品协议(过期自动清除)              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_GftAgmClear              
              
  -- 限量促销单              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_LmtprmClear 
  
  -- 税务分类调整单              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_TaxSortAdj 
              
  /*合约管理自动生成费用单*/              
  /*2004.01.09 SUIZHE ADD 先作废合约再生成费用单*/              
  select @OptionValue = null              
  select @OptionValue = 1 from hdoption where moduleno = 0 and upper(optioncaption) = 'USECNTR'              
    and ltrim(rtrim(optionvalue))='1'              
  if @OptionValue = 1              
  begin              
    -- sz add 自动作废过期合约              
    select @OptionValue = null              
    select @OptionValue = 1 from hdoption where moduleno = 3004 and upper(optioncaption) = '自动作废过期合约'              
      and ltrim(rtrim(optionvalue))='是'              
    if @OptionValue = 1              
    begin              
      waitfor delay '0:0:0.010'              
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)              
        values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '合约管理自动作废过期合约')              
      execute @return_status = CNTRAUTODLT              
      if @return_status <> 0              
      begin              
        waitfor delay '0:0:0.010'              
        insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)              
                values (getdate(), 'STARTUP', 'HDSVC', 'CNTRAUTODLT', 202, '')              
      end              
    end -- 自动作废过期合约              
    waitfor delay '0:0:0.010'              
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)              
        values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '合约管理自动生成费用单')              
    execute @return_status = CNTRAUTOGENCHGBOOK              
    if @return_status <> 0              
    begin              
        waitfor delay '0:0:0.010'              
        insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)              
                values (getdate(), 'STARTUP', 'HDSVC', 'CNTRAUTOGENCHGBOOK', 202, '')              
    end              
  waitfor delay '0:0:0.010'                        
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)                        
        values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '合约管理自动生成补差单')                        
    declare @calcdate datetime                      
    select @calcdate =convert(char(10),getdate())                       
    execute @return_status = ZHPS_PCT_PRMOFFSET_ON_SETTLEDAY  @calcdate,1                       
    if @return_status <> 0                        
    begin                        
        waitfor delay '0:0:0.010'                        
        insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)                        
                values (getdate(), 'STARTUP', 'HDSVC', 'ZHPS_PCT_PRMOFFSET_ON_SETTLEDAY', 202, '')                        
    end                 
              
    --zz 090624 自动生成联销率促销单              
    waitfor delay '0:0:0.010'              
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)              
        values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '合约管理自动生成联销率促销单')              
    execute @return_status = CntrAutoGenPayRatePrm              
    if @return_status <> 0              
    begin              
        waitfor delay '0:0:0.010'              
        insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)              
                values (getdate(), 'STARTUP', 'HDSVC', 'CntrAutoGenPayRatePrm', 202, '')              
 end              
  end --启用合约管理              
              
  --合约到期提醒 add by zhuhaohui, 2007.12.19              
  waitfor delay '0:0:0.010'              
  exec MSCB_CNTR_ON_SETTLEDAY              
              
  --商品促销到期提醒 add by zhuhaohui, 2007.12.19              
  waitfor delay '0:0:0.010'              
  --exec MSCB_PRCPRM_ENDDATE      --开启该项  sunya 20090524              
              
  -- 终止配货退货申请单              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_BckDmd              
              
  -- 终止供应商退货申请单              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_Vdrbckdmd              
              
  -- 终止商品资料申请单              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_GoodsApp              
              
 --季节品对应的季节隔年生效              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_SeasonLtd              
              
  -- 配货生效赠品              
  waitfor delay '0:00:0.010'              
  exec Startup_Step_AlcGft              
              
  -- 生效成本调整通知单              
  waitfor delay '0:00:0.010'              
  exec Startup_Step_INPRCADJNOTIFY              
              
  -- 供应商退款延期扣款              
  waitfor delay '0:00:0.010'              
  exec Startup_Step_BckExpFeeGen              
              
  -- 更新供应商限制退货属性              
  waitfor delay '0:00:0.010'              
  exec Startup_Step_VdrBckLmt              
              
  -- 2006.12.12 added by zhanglong 更新加工任务单状态              
 waitfor delay '0:00:0.010'              
  exec Startup_Step_ProcTask              
              
  -- 2007.0.124 added by zhourong 促销补差单生效              
 /* WAITFOR DELAY '0:00:0.010'              
  EXEC Startup_Step_PrmOffset*/              
              
  --促销返点协议生成促销补差单 zhujie              
  waitfor delay '0:00:0.010'              
  EXEC Startup_Step_PrmRtnPntAgm              
              
  --批量限制业务调整单生效  zhujie              
  waitfor delay '0:00:0.010'              
  exec Startup_Step_PolyLtdAdj              
                
  --批量价格促销单              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_PolyPrcPrm              
              
  --会员促销主题积分折扣单结束              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_MbrPromSubjEND              
                
  --会员促销类型登记单结束              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_MBRPROMTYPEEND              
                
  --特殊商品积分规则设置单结束              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_PS3SpecGDScoreEnd                
                   
  --特殊范围积分规则设置单结束              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_PS3SPECSCOPESCOREEnd              
              
              
  /* 以下日结项由于未升级振华暂未启用  sunya   20090524              
  waitfor delay '0:00:0.010'              
  EXEC DAY_VALID_AGMTINV              
              
  --2008.04.24 zz 缺省供应商调整单生效        
  WAITFOR DELAY '0:00:0.010'              
  EXEC Startup_Step_BilltoAdj              
              
  -- 完成门店调拨申请单 ShenMin              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_MxfDmd              
              
  -- 生效银行卡赠券 ShenMin              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_PS3BANKVOUCHER              
              
  -- 进价促销单生效 zz 080917              
  waitfor delay '0:0:0.010'              
  exec Startup_Step_PrcInPrm              
              
  --验证当前工作站的合法性              
  waitfor delay '0:00:0.010'              
  EXEC Startup_Step_ValidWS              
              
  --商品税率调整              
  waitfor delay '0:00:0.010'              
  EXEC Startup_Step_TaxRateAdj              
  return(0) */              
              
  --日结框架              
  WAITFOR DELAY '0:00:0.010'              
  declare @vDate datetime              
  set @vDate = CONVERT(DATETIME, CONVERT(CHAR(10), getdate(), 102))              
  exec PS3_SETTLEDAY @vDate              
              
  return(0)              
end
GO
