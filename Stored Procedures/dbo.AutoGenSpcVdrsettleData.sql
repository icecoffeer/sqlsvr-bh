SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[AutoGenSpcVdrsettleData]
@settleno int 
as  
begin  
 declare @zvdrcode char(10),@zdept char(10),@zbrand char(10),@store int,@mvdrcode char(10),@mdept char(10),@mbrand char(10),
         @payrate money,@lwtdt money,@vdrgid int
 
--
 if exists (select 1 from SpcVdrSettleData(nolock) where settleno=@settleno)
  begin
   delete from SpcVdrSettleData where settleno=@settleno
  end

--按照VdrSettleBind资料与SpcVdrOutFlag数据计算供应商押款金额
  declare vdr_kdt cursor for
    select mvdrcode,mdept,mbrand,store,mvdrcode,mdept,mbrand,payrate,lwtdt from VdrSettleBind(nolock)
  open vdr_kdt
  fetch next from vdr_kdt into @zvdrcode,@zdept,@zbrand,@store,@mvdrcode,@mdept,@mbrand,@payrate,@lwtdt
  while @@fetch_status = 0
   begin
    if not exists (select 1 from SpcVdrOutFlag(nolock) where store=@store and settleno=@settleno and vdrcode=@mvdrcode 
                   and dept=@mdept and brand=@mbrand and dt>=@lwtdt)
      begin
       select @vdrgid=gid from vendorh(nolock) where code=@zvdrcode
       insert into SpcVdrSettleData(settleno,vdrcode,vdrgid,dept,brand,qty,dt,di,kpayrate,klwtdt,kdt,paydt)
       select a.asettleno,@zvdrcode,@vdrgid,@zdept,@zbrand,sum(dq2),sum(dt2),sum(di2),@payrate,@lwtdt,
              round(sum(di2)*@payrate/100,2),round((sum(di2)-sum(di2)*@payrate/100),2)
       from vdrdrpt a(nolock),goodsh b(nolock)
       where a.asettleno=@settleno and a.bgdgid=b.gid
       and b.billto=@vdrgid and left(b.f1,7)=@zdept and b.brand=@zbrand
       group by a.asettleno
     end
    
    fetch next from vdr_kdt into @zvdrcode,@zdept,@zbrand,@store,@mvdrcode,@mdept,@mbrand,@payrate,@lwtdt
  end
  close vdr_kdt
  deallocate vdr_kdt 
   if @@error<>0
   return(@@error)
   
  return 0
end

GO
