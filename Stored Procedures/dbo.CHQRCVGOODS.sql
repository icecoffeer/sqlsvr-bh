SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CHQRCVGOODS](
	@piGroupID INT,
	@OPERGID INT,
	@MSG VARCHAR(255) OUTPUT
) as
begin
  declare @NTYPE SMALLINT,  @NNOTE varchar(100),
          @EXTIME DATETIME, @RHQUUID CHAR(32),  @NSTAT SMALLINT
  declare @vRet int,        @vUpCtrl int,       @GID INT,
          @optvalue int
  set @vRet = 0
  exec OPTREADINT 0, 'USECHQ', 0, @optvalue output
  if @optvalue = 1
  begin
    select @vUpCtrl = UpCtrl, @NTYPE = NTYPE, @NSTAT = NSTAT, 
      @EXTIME = EXTIME, @GID = GID
      from CQNGoods where NTYPE = 1 and GroupID = @piGroupID and NTYPE = 1
    if @vUpCtrl = 0
    begin
      --set @MSG = '非统一控制商品不更新本地资料。'
      update GOODS set
        LstUpdTime = Getdate(), UPCtrl = @vUpCtrl, HQControl = 0
      from CQNGOODS where CQNGOODS.GROUPID = @piGroupID and GOODS.GID = CQNGOODS.GID and NTYPE = 1
    end else
    begin
      update GOODS set
        BILLTO = CQNGOODS.BILLTO, LstUpdTime = Getdate(),
        UPCtrl = @vUpCtrl, HQControl = 1
      from CQNGOODS where CQNGOODS.GROUPID = @piGroupID and GOODS.GID = CQNGOODS.GID and NTYPE = 1
      --接收输入码
      delete from GDINPUT where gid = @gid
      insert into GDINPUT (gid, code, codetype, flags)
      select gid, code, codetype, flags
        from CQNGDINPUT where groupid = @piGroupID and NTYPE = 1
    end
  end
  delete from CQNGOODS where GROUPID = @piGroupID and NTYPE = 1
  delete from CQNGDINPUT where GROUPID = @piGroupID and NTYPE = 1
  delete from CQNPKG where GROUPID = @piGroupID and NTYPE = 1
  delete from CQNVDRGD where GROUPID = @piGroupID and NTYPE = 1
  return 0
end;
GO
