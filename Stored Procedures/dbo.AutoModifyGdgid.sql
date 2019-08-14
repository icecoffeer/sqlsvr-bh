SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoModifyGdgid](  
@ogid int,  
@ngid int,  
@msg varchar(100) output  
)  
  as  
begin  
   
 if exists (select 1 from goodsh(nolock) where gid=@ngid) or not exists (select 1 from goodsh(nolock) where gid=@ogid)  
  begin  
   set @msg='原商品和新GID不合法'  
   return 1  
  end  
  
----基本资料   
  update goods set goods.gid=@ngid where goods.gid=@ogid and goods.gid<>@ngid  
  update goodsh set goodsh.gid=@ngid where goodsh.gid=@ogid and goodsh.gid<>@ngid  
  update gdxlate set gdxlate.ngid=@ngid where gdxlate.ngid=@ogid and gdxlate.ngid<>@ngid  
  update gdxlate set gdxlate.lgid=@ngid where gdxlate.lgid=@ogid and gdxlate.lgid<>@ngid  
  update gdinput set gdinput.gid=@ngid where gdinput.gid=@ogid and gdinput.gid<>@ngid  
     
----当前值  
  update gdstore set gdstore.gdgid=@ngid where gdstore.gdgid=@ogid and gdstore.gdgid<>@ngid  
  update gdwrh set gdwrh.gdgid=@ngid where gdwrh.gdgid=@ogid and gdwrh.gdgid<>@ngid  
  update inv set inv.gdgid=@ngid where inv.gdgid=@ogid and inv.gdgid<>@ngid  
  update vdrgd set vdrgd.gdgid=@ngid where vdrgd.gdgid=@ogid and vdrgd.gdgid<>@ngid  
    
------DRPT系列  
  update invdrpt set invdrpt.bgdgid=@ngid where invdrpt.bgdgid=@ogid and invdrpt.bgdgid<>@ngid  
  update invmrpt set invmrpt.bgdgid=@ngid where invmrpt.bgdgid=@ogid and invmrpt.bgdgid<>@ngid  
  update invyrpt set invyrpt.bgdgid=@ngid where invyrpt.bgdgid=@ogid and invyrpt.bgdgid<>@ngid  
 --  
  update indrpti set indrpti.bgdgid=@ngid where indrpti.bgdgid=@ogid and indrpti.bgdgid<>@ngid  
  update indrpt set indrpt.bgdgid=@ngid where indrpt.bgdgid=@ogid and indrpt.bgdgid<>@ngid  
  update inmrpt set inmrpt.bgdgid=@ngid where inmrpt.bgdgid=@ogid and inmrpt.bgdgid<>@ngid  
  update inyrpt set inyrpt.bgdgid=@ngid where inyrpt.bgdgid=@ogid and inyrpt.bgdgid<>@ngid  
--  
  update outdrpti set outdrpti.bgdgid=@ngid where outdrpti.bgdgid=@ogid and outdrpti.bgdgid<>@ngid  
  update outdrpt set outdrpt.bgdgid=@ngid where outdrpt.bgdgid=@ogid and outdrpt.bgdgid<>@ngid  
  update outmrpt set outmrpt.bgdgid=@ngid where outmrpt.bgdgid=@ogid and outmrpt.bgdgid<>@ngid  
  update outyrpt set outyrpt.bgdgid=@ngid where outyrpt.bgdgid=@ogid and outyrpt.bgdgid<>@ngid  
--  
  update vdrdrpti set vdrdrpti.bgdgid=@ngid where vdrdrpti.bgdgid=@ogid and vdrdrpti.bgdgid<>@ngid  
  update vdrdrpt set vdrdrpt.bgdgid=@ngid where vdrdrpt.bgdgid=@ogid and vdrdrpt.bgdgid<>@ngid  
  update vdrmrpt set vdrmrpt.bgdgid=@ngid where vdrmrpt.bgdgid=@ogid and vdrmrpt.bgdgid<>@ngid  
  update vdryrpt set vdryrpt.bgdgid=@ngid where vdryrpt.bgdgid=@ogid and vdryrpt.bgdgid<>@ngid  
--  
  update invchgdrpti set invchgdrpti.bgdgid=@ngid where invchgdrpti.bgdgid=@ogid and invchgdrpti.bgdgid<>@ngid  
  update invchgdrpt set invchgdrpt.bgdgid=@ngid where invchgdrpt.bgdgid=@ogid and invchgdrpt.bgdgid<>@ngid  
  update invchgmrpt set invchgmrpt.bgdgid=@ngid where invchgmrpt.bgdgid=@ogid and invchgmrpt.bgdgid<>@ngid  
  update invchgyrpt set invchgyrpt.bgdgid=@ngid where invchgyrpt.bgdgid=@ogid and invchgyrpt.bgdgid<>@ngid  
--  
  update osbal set osbal.gdgid=@ngid where osbal.gdgid=@ogid and osbal.gdgid<>@ngid  
  --update hftm set hftm.bgdgid=@ngid where hftm.bgdgid=@ogid and hftm.bgdgid<>@ngid  
--  
  update cstdrpti set cstdrpti.bgdgid=@ngid where cstdrpti.bgdgid=@ogid and cstdrpti.bgdgid<>@ngid  
  update cstdrpt set cstdrpt.bgdgid=@ngid where cstdrpt.bgdgid=@ogid and cstdrpt.bgdgid<>@ngid  
  update cstmrpt set cstmrpt.bgdgid=@ngid where cstmrpt.bgdgid=@ogid and cstmrpt.bgdgid<>@ngid  
  update cstyrpt set cstyrpt.bgdgid=@ngid where cstyrpt.bgdgid=@ogid and cstyrpt.bgdgid<>@ngid  
  
-----盘点系列  
  update ckchg set ckchg.gdgid=@ngid where ckchg.gdgid=@ogid and ckchg.gdgid<>@ngid  
  update ckdtl set ckdtl.gdgid=@ngid where ckdtl.gdgid=@ogid and ckdtl.gdgid<>@ngid  
  update PCKDTL set PCKDTL.gdgid=@ngid where PCKDTL.gdgid=@ogid and PCKDTL.gdgid<>@ngid  
  update PCKS set PCKS.gdgid=@ngid where PCKS.gdgid=@ogid and PCKS.gdgid<>@ngid  
  update CKINV set CKINV.gdgid=@ngid where CKINV.gdgid=@ogid and CKINV.gdgid<>@ngid  
--  
  update paydtl set paydtl.gdgid=@ngid where paydtl.gdgid=@ogid and paydtl.gdgid<>@ngid  
  update payadjdtl set payadjdtl.gdgid=@ngid where payadjdtl.gdgid=@ogid and payadjdtl.gdgid<>@ngid  
    
-----单据  
  update prcadjdtl set prcadjdtl.gdgid=@ngid where prcadjdtl.gdgid=@ogid and prcadjdtl.gdgid<>@ngid  
  update gdprcadj set gdprcadj.gdgid=@ngid where gdprcadj.gdgid=@ogid and gdprcadj.gdgid<>@ngid  
  update prcprmdtl set prcprmdtl.gdgid=@ngid where prcprmdtl.gdgid=@ogid and prcprmdtl.gdgid<>@ngid  
  update price set price.gdgid=@ngid where price.gdgid=@ogid and price.gdgid<>@ngid  
  update inprice set inprice.gdgid=@ngid where inprice.gdgid=@ogid and inprice.gdgid<>@ngid  
  update orddtl set orddtl.gdgid=@ngid where orddtl.gdgid=@ogid and orddtl.gdgid<>@ngid  
 ----  
  update dspdtl set dspdtl.gdgid=@ngid where dspdtl.gdgid=@ogid and dspdtl.gdgid<>@ngid  
  update rtldtl set rtldtl.gdgid=@ngid where rtldtl.gdgid=@ogid and rtldtl.gdgid<>@ngid  
  update rtlbckdtl set rtlbckdtl.gdgid=@ngid where rtlbckdtl.gdgid=@ogid and rtlbckdtl.gdgid<>@ngid  
  update stkindtl set stkindtl.gdgid=@ngid where stkindtl.gdgid=@ogid and stkindtl.gdgid<>@ngid  
  update stkinbckdtl set stkinbckdtl.gdgid=@ngid where stkinbckdtl.gdgid=@ogid and stkinbckdtl.gdgid<>@ngid  
  update stkoutdtl set stkoutdtl.gdgid=@ngid where stkoutdtl.gdgid=@ogid and stkoutdtl.gdgid<>@ngid  
  update stkoutbckdtl set stkoutbckdtl.gdgid=@ngid where stkoutbckdtl.gdgid=@ogid and stkoutbckdtl.gdgid<>@ngid  
  update xfdtl set xfdtl.gdgid=@ngid where xfdtl.gdgid=@ogid and xfdtl.gdgid<>@ngid  
  update lsdtl set lsdtl.gdgid=@ngid where lsdtl.gdgid=@ogid and lsdtl.gdgid<>@ngid  
  update ovfdtl set ovfdtl.gdgid=@ngid where ovfdtl.gdgid=@ogid and ovfdtl.gdgid<>@ngid  
    
  if @@error<>0  
  begin  
   set @msg='更新商品GID失败'  
   return 2  
  end  
    
 return 0  
end  
  
GO
