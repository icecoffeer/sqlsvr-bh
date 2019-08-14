SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CkBlankImp]
   @p_firstnum char(13)
as
begin
  declare @GCode char(13)
  declare @WrhCode char(10)
  declare @SubWrhCode char(20)
  declare @EmpCode char(10)
  declare @nWrhCode char(10)
  declare @nSubWrhCode char(20)
  declare @nEmpCode char(10)
  declare @num char(13)
  declare @Line int
  declare @GGid int
  declare @WrhGid int
  declare @EmpGid int
  declare @SettleNo int

  --删除BPCKPOOL2里的数据
  delete from BPCKPOOL2
  
  --删除条码在本地不存在的商品
  delete from BPCKPOOL where gcode not in (select code from gdinput)

  select top 1 @nWrhCode = WRHCODE, @nSubWrhCode = SUBWRHCODE, @nEmpCode = EMPCODE
  from BPCKPOOL order by WRHCODE, SUBWRHCODE, EMPCODE
  set @Line = 1
  select @settleno = max(no) from monthsettle

  declare Cur_BpckPool cursor for
    select GCODE, WRHCODE, SUBWRHCODE, EMPCODE from BPCKPOOL order by WRHCODE, SUBWRHCODE, EMPCODE
  open Cur_BPCKPOOL
  fetch next from Cur_BpckPool into @GCode, @WrhCode, @SubWrhCode, @EmpCode
  while @@Fetch_Status = 0
    begin
    --如果仓位、货位和员工代码都和上一条数据相同，则插入到BPCKPOOL2表中
      if (@WrhCode = @nWrhCode) and (@SubWrhCode = @nSubWrhCode) and (@EmpCode = @nEmpCode)
        begin
          select @GGid = GID from gdinput(nolock) where CODE = @GCode
          insert into BPCKPOOL2 values(@GGid, @Line)
          set @Line = @Line + 1
        end
    --如果仓位、货位和员工代码和上一条数据不同，则将前面的数据生成新单据
      else
        begin
          if (select count(*) from BPCKPOOL2) <> 0
            begin
            --取单号
              if @p_firstnum is null
	        begin
		  select @num = max(num) from BPCK
		  if (@num is null)
			select @num = '0000000001'
		  else
			execute NEXTBN @num, @num output
	        end
	      else
	        begin
		  select @num = @p_firstnum
		  if exists(select * from BPCK where NUM = @num)
		    begin
			select @num = max(NUM) from BPCK
			execute NEXTBN @num, @num output
		    end
	        end
            --插入明细
              insert into BPCKDTL (NUM, LINE, SETTLENO, GDGID)
                           select @num, LINE, @SettleNo, GDGID
                           from BPCKPOOL2
            --插入汇总
              select @WrhGid = Gid from warehouse(nolock) where code = @nWrhCode
              select @EmpGid = Gid from Employee(nolock) where code = @nEmpCode
              insert into BPCK (NUM, SETTLENO, FILDATE, FILLER, WRH, RECCNT, NOTE)
                         values(@num, @SettleNo, getdate(), @EmpGid, @WrhGid, @Line-1, @nSubWrhCode)
            --重新初始化数据
              delete from BPCKPOOL2
              set @Line = 1
              select @nWrhCode = @WrhCode, @nSubWrhCode = @SubWrhCode, @nEmpCode = @EmpCode
            --将当前记录插入BPCKPOOL2表
              select @GGid = GID from gdinput(nolock) where CODE = @GCode
              insert into BPCKPOOL2 values(@GGid, @Line)
              set @Line = @Line + 1
            end
        end
      fetch next from Cur_BpckPool into @GCode, @WrhCode, @SubWrhCode, @EmpCode
    end
  if (select count(*) from BPCKPOOL2) <> 0
    begin
    --取单号
      if @p_firstnum is null
	    begin
	  select @num = max(num) from BPCK
	  if (@num is null)
		select @num = '0000000001'
	  else
		execute NEXTBN @num, @num output
	    end
	  else
	    begin
	  select @num = @p_firstnum
	  if exists(select * from BPCK where NUM = @num)
	    begin
		select @num = max(NUM) from BPCK
		execute NEXTBN @num, @num output
	    end
	    end
    --插入明细
      insert into BPCKDTL (NUM, LINE, SETTLENO, GDGID)
                   select @num, LINE, @SettleNo, GDGID
                   from BPCKPOOL2
    --插入汇总
      select @WrhGid = Gid from warehouse(nolock) where code = @nWrhCode
      select @EmpGid = Gid from Employee(nolock) where code = @nEmpCode
      insert into BPCK (NUM, SETTLENO, FILDATE, FILLER, WRH, RECCNT, NOTE)
                 values(@num, @SettleNo, getdate(), @EmpGid, @WrhGid, @Line-1, @nSubWrhCode)
    end
  close Cur_BpckPool
  deallocate Cur_BpckPool
  delete from BPCKPOOL2
end
GO
