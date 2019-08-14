SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_OCCUR_GEN] (
  @piVdrGid integer,                --供应商
  @piDataSrcCls varchar(20),        --数据源分类
  @piSrcNum varchar(14),            --来源单号
  @piOperGid integer,               --操作人
  @poErrMsg varchar(255) output     --出错信息
) as
begin
  declare @vRet integer
  declare @vCntrNum varchar(14)
  declare @vCntrVersion integer
  declare @vCntrLine integer
  declare @vMessage varchar(255)
  declare @vDataSrc varchar(20)

  set @vMessage = '供应商=' + convert(varchar, @piVdrGid) + ', 数据来源分类=' + @piDataSrcCls + ', 来源单号=' + @piSrcNum
  exec PCT_CHGBOOK_LOGDEBUG 'Occur_Gen', @vMessage

  if object_id('c_Line') is not null deallocate c_Line
  declare c_Line cursor for
    select d.NUM, d.VERSION, d.LINE, w.DSCODE
    from CTCNTR m, CTCNTRDTL d, CTCHGDEF c, CTCNTRDTLDATASRC w
    where m.NUM = d.NUM and m.VERSION = d.VERSION and m.TAG = 1
      and m.STAT in (500, 1400) and m.VENDOR = @piVdrGid
      and d.CHGCODE = c.CODE and c.WHENGEN = '发生时间'
      and w.DSCODE in (select CODE from CTDATASRC where CLS = @piDataSrcCls and FLAG = 1)  
      and w.NUM = d.NUM and w.VERSION = d.VERSION and w.LINE = d.LINE 
    union
    select d.NUM, d.VERSION, d.LINE, s.DSCODE
    from CTCNTR m, CTCNTRDTL d, CTCHGDEF c, CTCHGDATASRC s
    where m.NUM = d.NUM and m.VERSION = d.VERSION and m.TAG = 1
      and m.STAT in (500, 1400) and m.VENDOR = @piVdrGid
      and d.CHGCODE = c.CODE and c.WHENGEN = '发生时间' and c.CODE = s.CODE
      and s.DSCODE in (select CODE from CTDATASRC where CLS = @piDataSrcCls and FLAG = 1)  
      and rtrim(d.num + ltrim(str(d.VERSION)) + ltrim(str(d.Line))) not in 
        (select rtrim(a.num + ltrim(str(a.VERSION)) + ltrim(str(a.Line))) 
        from CTCNTRDTL a, CTCNTRDTLDATASRC w 
        where w.NUM = a.NUM and w.VERSION = a.VERSION and w.LINE = a.LINE)
      
  delete from TMPGENBILLS where OWNER = '生成费用单' and SPID = @@spid
  open c_Line
  fetch next from c_Line into @vCntrNum, @vCntrVersion, @vCntrLine, @vDataSrc
  while @@fetch_status = 0
  begin
    exec @vRet = PCT_CHGBOOK_OCCUR_GEN_ONE @vCntrNum, @vCntrVersion, @vCntrLine, @vDataSrc, @piSrcNum, @piOperGid, @poErrMsg output
    if @vRet <> 0 break

    fetch next from c_Line into @vCntrNum, @vCntrVersion, @vCntrLine, @vDataSrc
  end
  close c_Line
  deallocate c_Line

  return(0)
end
GO
