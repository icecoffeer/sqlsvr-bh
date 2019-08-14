SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CHQRCVVENDOR](
	@piGroupID INT,
	@OPERGID INT,
	@MSG VARCHAR(255) OUTPUT
) as
begin
  --UpCtrl字段的功能屏蔽，以统一结算作为判断是否更新依据
  declare @NTYPE SMALLINT,    @NNOTE varchar(100),
          @EXTIME DATETIME, @RHQUUID CHAR(32),  @NSTAT SMALLINT
  declare @vRet int,        @vUpCtrl int,       @GID INT,
          @optvalue int,    @vUPAY int
  set @vRet = 0
  exec OPTREADINT 0, 'USECHQ', 0, @optvalue output
  if @optvalue = 1
  begin
    select @vUpCtrl = UpCtrl, @NTYPE = NTYPE, @NSTAT = NSTAT, 
      @EXTIME = EXTIME, @GID = GID, @vUPay = UPay
      from CQNVENDOR where NTYPE = 1 and GroupID = @piGroupID and NTYPE = 1
    if @vUPAY = 0
    begin
      update VENDOR set
        LstUpdTime = Getdate(), UpCtrl = CQNVENDOR.UpCtrl, UPay = CQNVENDOR.UPay
      from CQNVENDOR where CQNVENDOR.GROUPID = @piGroupID and CQNVENDOR.GID = VENDOR.GID and NTYPE = 1
    end else
    begin
      update VENDOR set
        UPAY = CQNVENDOR.UPAY, SENDTYPE = CQNVENDOR.SENDTYPE, 
        SENDLOCATION = CQNVENDOR.SENDLOCATION, LstUpdTime = Getdate(),
        UpCtrl = CQNVENDOR.UpCtrl
      from CQNVENDOR where CQNVENDOR.GROUPID = @piGroupID and CQNVENDOR.GID = VENDOR.GID and NTYPE = 1
    end
  end
  delete from CQNVENDOR where GROUPID = @piGroupID and NTYPE = 1
  return 0
end;
GO
