SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMSND_TO100]  
(  
  @piNum char(14),  
  @piOperGid int,  
  @poErrMsg varchar(255) output  
)  
as  
begin  
  declare @vRet int  
  declare @vStat int  
  declare @vGftGid int  
  declare @vQty money  
  declare @vWrhGid int  
  declare @vTotal money  
  declare @vSettleNo int  
  declare @vFildate datetime  
  declare @vVdrGid int  
  declare @vCls varchar(10)  
  declare @vPosNo varchar(10)  
  declare @vFlowNo varchar(14)  
  declare @optDupSnd int  
  
  select @vStat = STAT, @vFildate = FILDATE from GFTPRMSND where NUM = @piNum;  
  if @vStat <> 1600  
  begin  
    set @poErrMsg = @piNum + '不是未审核或已预审单据，不能审核'  
    return(1)  
  end  
  exec OPTREADINT 573, '零售单重复发放', 0, @optDupSnd output  
  
  --判断销售单据是否已经发过赠品  
  exec HDDEALLOCCURSOR 'c_gftsnd' --确保游标被释放  
  declare c_gftsnd cursor for  
    select CLS, POSNO, FLOWNO from GFTPRMSNDBILL  
    where NUM = @piNum;  
  open c_gftsnd  
  fetch next from c_gftsnd into @vCls, @vPosNo, @vFlowNo  
  while @@fetch_status = 0  
  begin  
    if @vCls = '收银条'  
    begin  
      if @optDupSnd = 0  
      begin  
        if exists(select 1 from GFTPRMSND m(nolock), GFTPRMSNDBILL b(nolock), GFTPRMSNDGIFT g(nolock)  
           where m.NUM = b.NUM and m.STAT = 100 and b.CLS = @vCls  
             and b.POSNO = @vPosNo and b.FLOWNO = @vFlowNo 
             and g.NUM = m.NUM and g.BCKQTY <> g.QTY) -- BCKQTY = 0 发放且未回收   0 < BCKQTY < QTY 部分回收   BCKQTY = QTY 全部回收       
        begin  
          set @poErrMsg = '收银条[POS机号=' + rtrim(@vPosNo) + ', 流水号=' + rtrim(@vFlowNo) + ']已经发放过赠品！'  
          close c_gftsnd  
          deallocate c_gftsnd  
          return(1)  
        end  
      end  
    end else if @vCls = '普通发票'  
    begin  
      if exists(select 1 from GFTPRMSND m(nolock), GFTPRMSNDBILL b(nolock), GFTPRMSNDGIFT g(nolock)  
        where m.NUM = b.NUM and m.STAT = 100 and b.CLS = @vCls  
          and b.FLOWNO = @vFlowNo and g.NUM = m.NUM and g.BCKQTY = 0)
      begin  
        set @poErrMsg = '普通发票[' + rtrim(@vFlowNo) + ']已经发放过赠品！'  
        close c_gftsnd  
        deallocate c_gftsnd  
        return(1)  
      end  
    end else if @vCls = '预售收银条'  
    begin  
      if @optDupSnd = 0  
      begin  
        if exists(select 1 from GFTPRMSND m(nolock), GFTPRMSNDBILL b(nolock), GFTPRMSNDGIFT g(nolock)  
           where m.NUM = b.NUM and m.STAT = 100 and b.CLS = @vCls  
             and b.POSNO = @vPosNo and b.FLOWNO = @vFlowNo 
             and g.NUM = m.NUM and g.BCKQTY <> g.QTY)   
        begin  
          set @poErrMsg = '预售收银条[POS机号=' + rtrim(@vPosNo) + ', 流水号=' + rtrim(@vFlowNo) + ']已经发放过赠品！'  
          close c_gftsnd  
          deallocate c_gftsnd  
          return(1)  
        end  
      end  
    end  
  
    fetch next from c_gftsnd into @vCls, @vPosNo, @vFlowNo  
  end  
  close c_gftsnd  
  deallocate c_gftsnd  
  
  --赠品出库  
  exec HDDEALLOCCURSOR 'c_gftsnd' --确保游标被释放  
  declare c_gftsnd cursor for  
  select GFTGID, sum(QTY), sum(QTY * PAYPRC) from GFTPRMSNDGIFT  
  where NUM = @piNum group by GFTGID  
  open c_gftsnd  
  fetch next from c_gftsnd into @vGftGid, @vQty, @vTotal  
  while @@fetch_status = 0  
  begin  
    select @vWrhGid = WRH, @vVdrGid = BILLTO from GOODS(nolock) where GID = @vGftGid  
    /*取售价为0*/  
    execute @vRet = UNLOAD @vWrhGid, @vGftGid, @vQty, 0, null  
    if @vRet <> 0  
    begin  
      close c_gftsnd  
      deallocate c_gftsnd  
    end  
    select @vSettleNo = MAX(NO) from MONTHSETTLE(nolock)  
    insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,  
      LS_Q, LS_A, LS_T, LS_I, LS_R)  
    values(convert(datetime, convert(char, getdate(), 102)),  --@vFildate -> getdate() by jinlei  
      @vSettleNo, @vWrhGid, @vGftGid, 1, 1, @vVdrGid, @vQty, @vTotal, 0, 0, 0)  
  
    exec GFTPRMSND_ADDGIFTLOG @piNum, @vGftGid, @vQty, @piOperGid  
    fetch next from c_gftsnd into @vGftGid, @vQty, @vTotal  
  end  
  close c_gftsnd  
  deallocate c_gftsnd  
  
  --回写赠品规则  
  exec @vRet = GFTPRMSND_UPDATERULE @piNum, @poErrMsg output  
  if @vRet <> 0 return(@vRet)  
  
  update GFTPRMSND set STAT = 100, LSTUPDTIME = getdate() where NUM = @piNum;  
  exec GFTPRMSND_ADDLOG @piNum, 100, @piOperGid  
  
  return 0  
end  
GO
