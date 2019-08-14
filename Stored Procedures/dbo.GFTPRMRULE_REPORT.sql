SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMRULE_REPORT]
(
  @piCode	char(18),
  @poErrMsg	varchar(255)	output
)
as
begin
  declare @v1 varchar(255)
  declare @v2 varchar(1000)
  declare @v3 varchar(1000)
  declare @v4 varchar(2000)
  declare @v5 varchar(1000)
  declare @vCode varchar(18)
  declare @vName varchar(50)
  declare @vBeginTime datetime
  declare @vEndTime datetime
  declare @vQty money
  declare @vAmt money
  declare @vNote varchar(1024)
  declare @vTopicName varchar(50)
  declare @vLine int
  declare @vGroupID int
  declare @vGdCode varchar(13)
  declare @vGdName varchar(50)
  declare @vMunit varchar(4)
  declare @vGdCondText varchar(1024)

  --概要 
  select 
    @vName = r.NAME,
    @vBeginTime = r.BEGINTIME,
    @vEndTime = r.ENDTIME,
    @vQty = r.QTY,
    @vAmt = r.AMT,
    @vNote = r.NOTE,
    @vTopicName = t.NAME
  from GFTPRMRULE r(nolock), PRMTOPIC t(nolock)
  where r.CODE = @piCode and r.TOPIC = t.CODE;
  if @@rowcount = 0 return(0);
  set @v1 = '编号: ' + @piCode + char(10) 
          + '名称: ' + rtrim(@vName) + char(10)
	  + '主题: ' + rtrim(@vTopicName) + char(10)
	  + '时间: ' + convert(varchar(10), @vBeginTime, 120) + ' - ' + convert(varchar(10), @vEndTime, 120) + char(10);

  --商品条件
  set @v2 = ''
  if @vQty > 0
    set @v2 = @v2 + '总数量满: ' + rtrim(convert(varchar(10), @vQty)) + char(10)
  if @vAmt > 0
    set @v2 = @v2 + '总金额满: ' + rtrim(convert(varchar(10), @vAmt)) + '元' + char(10)

  set @v3 = ''
  set @vLine = 0
  if object_id('c_rulegoods') is not null deallocate c_rulegoods
  declare c_rulegoods cursor for
  select GDCONDTEXT, QTY, AMT from GFTPRMGOODS(nolock) where RCODE = @piCode;
  open c_rulegoods
  fetch next from c_rulegoods into @vGdCondText, @vQty, @vAmt
  while @@fetch_status = 0
  begin
    set @vLine = @vLine + 1
    if @vQty > 0
      set @v3 = @v3 + rtrim(convert(varchar(3), @vLine)) + '. 每' + rtrim(convert(varchar(10), @vQty)) + '单位 ' + rtrim(@vGdCondText) + char(10)
    else if @vAmt > 0
      set @v3 = @v3 + rtrim(convert(varchar(3), @vLine)) + '. 每' + rtrim(convert(varchar(10), @vAmt)) + '元 ' + rtrim(@vGdCondText) + char(10)

    fetch next from c_rulegoods into @vGdCondText, @vQty, @vAmt
  end
  close c_rulegoods
  deallocate c_rulegoods
  if @v3 <> ''
    set @v3 = '买以下商品: ' + char(10) + @v3
  else
    set @v3 = '买任意商品' + char(10)

  --赠品条件
  set @v4 = ''
  if object_id('c_rulegroup') is not null deallocate c_rulegroup
  declare c_rulegroup cursor for
  select QTY, AMT, GROUPID from GFTPRMGIFT(nolock) where RCODE = @piCode order by GROUPID;
  open c_rulegroup
  fetch next from c_rulegroup into @vQty, @vAmt, @vGroupID
  while @@fetch_status = 0
  begin
    if (@vQty > 0) or (@vAmt > 0)
    begin
      if @vGroupID > 1
      begin
        if @vQty > 0
          set @v4 = @v4 + '并且送以下商品总共满' + rtrim(convert(varchar(10), @vQty)) + '单位:' + char(10)
        else if @vAmt > 0
          set @v4 = @v4 + '并且送以下商品总共满' + rtrim(convert(varchar(10), @vAmt)) + '元:' + char(10)
      end else
      begin
        if @vQty > 0
          set @v4 = @v4 + '送以下商品总共满' + rtrim(convert(varchar(10), @vQty)) + '单位:' + char(10)
        else if @vAmt > 0
          set @v4 = @v4 + '送以下商品总共满' + rtrim(convert(varchar(10), @vAmt)) + '元:' + char(10)
      end

      set @vLine = 0
      if object_id('c_rulegift') is not null deallocate c_rulegift
      declare c_rulegift cursor for
      select g.CODE, g.NAME, d.QTY
      from GFTPRMGIFTDTL d(nolock), GOODSH g(nolock)
      where d.RCODE = @piCode and d.GROUPID = @vGroupID and d.GFTGID = g.GID
      open c_rulegift
      fetch next from c_rulegift into @vGdCode, @vGdName, @vQty
      while @@fetch_status = 0
      begin
        set @vLine = @vLine + 1
	set @v4 = @v4 + rtrim(convert(varchar(3), @vLine)) + '. ' + rtrim(@vGdName) + '[' + rtrim(@vGdCode) + ']' + char(10)
        fetch next from c_rulegift into @vGdCode, @vGdName, @vQty
      end
      close c_rulegift
      deallocate c_rulegift
    end else
    begin
      if @vGroupID > 1
        set @v4 = @v4 + '并且送以下一种商品:' + char(10)
      else
        set @v4 = @v4 + '送以下一种商品:' + char(10)

      set @vLine = 0
      if object_id('c_rulegift') is not null deallocate c_rulegift
      declare c_rulegift cursor for
      select g.CODE, g.NAME, d.QTY, g.MUNIT
      from GFTPRMGIFTDTL d(nolock), GOODSH g(nolock)
      where d.RCODE = @piCode and d.GROUPID = @vGroupID and d.GFTGID = g.GID
      open c_rulegift
      fetch next from c_rulegift into @vGdCode, @vGdName, @vQty, @vMunit
      while @@fetch_status = 0
      begin
        set @vLine = @vLine + 1
	set @v4 = @v4 + rtrim(convert(varchar(3), @vLine)) + '. ' 
	  + rtrim(convert(varchar(10), @vQty)) + @vMunit + ' ' 
	  + rtrim(@vGdName) + '[' + rtrim(@vGdCode) + ']' + char(10)
        fetch next from c_rulegift into @vGdCode, @vGdName, @vQty, @vMunit
      end
      close c_rulegift
      deallocate c_rulegift
    end

    fetch next from c_rulegroup into @vQty, @vAmt, @vGroupID
  end
  close c_rulegroup
  deallocate c_rulegroup

  --互斥
  set @v5 = ''
  set @vLine = 0
  if object_id('c_rule') is not null deallocate c_rule
  declare c_rule cursor for
  select r.CODE, r.NAME
  from GFTPRMRULEMUTEX m(nolock), GFTPRMRULE r(nolock)
  where m.MUTEXCODE = r.CODE and m.RCODE = @piCode
  union
  select r.CODE, r.NAME
  from GFTPRMRULEMUTEX m(nolock), GFTPRMRULE r(nolock)
  where m.RCODE = r.CODE and m.MUTEXCODE = @piCode
  open c_rule
  fetch next from c_rule into @vCode, @vName
  while @@fetch_status = 0
  begin
    set @vLine = @vLine + 1
    set @v5 = @v5 + rtrim(convert(varchar(3), @vLine)) + '. ' + @vCode + ' ' + @vName + char(10)
    fetch next from c_rule into @vCode, @vName
  end
  close c_rule
  deallocate c_rule
  if @vLine > 0
    set @v5 = '不能同时享受的赠品促销规则:' + char(10) + @v5
   
  --约束  
  update GFTPRMRULE set 
    REPORT = rtrim(@v1) + '描述:' + char(10) + rtrim(@v2) + rtrim(@v3) + rtrim(@v4) + rtrim(@v5) + 'abc' where CODE = @piCode

  return(0);
end
GO
