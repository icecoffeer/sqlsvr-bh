SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VDRAGMTCHK]
(
 @piNum   varchar(14),
 @piAggNum  varchar(14),
 @piOper   varchar(30),
 @piVdrGid  int,  
 @poErr_Msg varchar(255) output
)
as
begin
  declare
    @VRECCNT INT,
    @vUserGid INT,
    @vVdrGid INT
    
  select @vUserGid = UserGid from FASystem(nolock)
  
  select @vVdrGid = VdrGid from VdrAgmt where Num = @piNum
  
  --删除当前的数据
  delete VDRAGMTDTLINV where num = @piAggNum
  
  --根据当前的贸易协议增加明细当前值
  insert into VdrAgmtDtlInv(Num, Line, GDGid, GDCode, Munit, 
    QpcStr, Qpc, QtyRat, IsGft, FromGid, 
    ListPrc, LackChgPrice, AmtDis, NDis, DDis, 
    EDis, MDis, REBate, BDis,
    NPDis, ODis, Price, MinOrdQty, GftDesc, CalcFlag, Sale) 
  select Mst.AgmtNum, Line, GDGid, GDCode, Munit,
    QpcStr, Qpc, QtyRat, IsGft, FromGid, 
    ListPrc, LackChgPrice, AMTDis, NDis, DDis,
    EDis, MDis, REBate, BDis, NPDis, ODis, 
    Price, MinOrdQty, GftDesc, CalcFlag, Sale 
  from VdrAgmtDtl Dtl, VdrAgmt Mst 
  where Dtl.Num = Mst.Num and Dtl.Oper = 0 and Mst.Num = @piNum
  
  
    
  select @VRecCnt = count(GDGid) from VdrAgmtDtlInv(nolock) where Num = @piAggNum
  
  delete VdrAgmtInv where Num = @piAggNum
  insert into VdrAgmtInv(Num, VdrGid, StartDate, FinishDate, LmodDate, Lmodopid, Buyer, OrgViser, RecCnt)
    select AgmtNum, VdrGid, StartDate, FinishDate, getdate(), @piOper, Buyer, OrgViser, @vRecCnt 
    from VdrAgmt where Num = @piNum
    
  update VdrAgmtInv set memo = (select memo from VdrAgmt(nolock) where num = @piNum);
  update VdrAgmt set stat = 110 where stat = 100 and VdrGid = @piVdrGid
  update VdrAgmt set stat = 100 where Num = @piNum
  
  ---插入VdrGd2表
  delete from VdrGD2
  where StoreGid = @vUserGid and VdrGid = @vVdrGid and GdGid in (
  select GDGid
  from VdrAgmtDtl Dtl, VdrAgmt Mst 
  where Dtl.Num = Mst.Num and Dtl.Oper = 0 and Mst.Num = @piNum)
  
  Insert into VdrGD2(StoreGid, GDGid, VdrGid)
  select @vUserGid, GDGid, @vVdrGid
  from VdrAgmtDtl Dtl, VdrAgmt Mst 
  where Dtl.Num = Mst.Num and Dtl.Oper = 0 and Mst.Num = @piNum
  
  insert into VdrAgmtLog(Num, Cls, Stat, Modifier, Time) 
  values(@piNum, '经销', 100, @piOper, getdate())
  
  return(0)
end


--E:\工作\版本发布\升级\SPV2\PS3_11420(联销商品使用红蓝卡成本计算方法的调整)_SP_MSSQL.sql
print 'create procedure RTLCHK ...'
GO
