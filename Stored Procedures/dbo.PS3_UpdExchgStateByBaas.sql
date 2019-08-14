SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PS3_UpdExchgStateByBaas]
(
  @piFileName Varchar(100), --资料包文件名
  @poMsg Varchar(255) output
) As
Begin
  Declare
    @vPosExt int, --压缩包后缀".zip"的位置
    @vtmpFileName varchar(100),
    @vVersion varchar(14),
    @vCls varchar(30),
    @vClsName varchar(30),
    @vStateName varchar(60),
    @vSvrVersion varchar(14),
    @vOriVersion varchar(14),
    @cpntName varchar(60), /*同步组件,SAS及PMS*/
    @synState varchar(60)

  If Not Exists(Select 1 From PS3_BaasExchgState
    Where ZipFileName = @piFileName and Finished = 0)
    Return 0

  Select @vPosExt = Charindex('.zip', @piFileName)
  --去掉文件后缀
  Select @vtmpFileName = SubString(@piFileName, 1, @vPosExt -1)
  --后14位为版本号
  select @vVersion = Right(@vtmpFileName, 14)
  --前面剩余部分为资料类型
  select @vCls = SubString(@vtmpFileName, 1, CharIndex(@vVersion, @vtmpFileName) -1)
  --获取资料类型中文名称
  Select @vClsName = DisplayName From PosDbGenItems Where ClsName = @vCls

  --获取style为5或6的收银机该资料类型的版本号
  Select Top 1 @vSvrVersion = e.SvrCurVer, @vOriVersion = PosCurVer
    From EXCHANGESTATE e, WorkStation w
  Where e.PosNo = w.No and e.Cls = @vClsName and w.Style in (5, 6)
  If @@RowCount = 0
    Return 0
  --如果中台本次同步的资料版本号小于后台记录的收银机版本号,则忽略
  If (@vVersion < @vOriVersion)
    Return 0
  --更新Exchangestate表的poscurver字段
  if @vVersion <> @vOriVersion
    Update e Set e.PosCurVer = @vVersion
      From ExchangeState e, WorkStation w
    Where e.PosNo = w.No and Cls = @vClsName and w.Style in (5, 6)
  --根据中间表中的同步状态,更新ExchangeState表中的Stat字段
  If @vClsName <> '商品字典'
  Begin
    Select @synState = SynState from PS3_BaasExchgState
      Where ZipFileName = @piFileName and Finished = 0
    --成功或失败都是终态
    if (@synState = '更新成功') or (@synState = '更新失败')
    begin
      Update PS3_BaasExchgState Set Finished = 1, LstUpdTime = GetDate()
        Where ZipFileName = @piFileName
    end else
      Set @synState = '更新中'
    --更新ExchangeState表的状态字段
    Update e Set e.Stat = @synState
      From ExchangeState e, WorkStation w
    Where e.PosNo = w.No and Cls = @vClsName and w.Style in (5, 6)
  End Else
  --"商品字段"类型需要在所有组件(目前是SAS和PMS)同步成功后,再更新ExchangeState表中的状态
  Begin
    Declare @sasState varchar(60), @pmsState varchar(60), @isfinished int
    set @isfinished = 0
    Select @sasState = SynState from PS3_BaasExchgState
      Where ZipFileName = @piFileName and CPNTNAME = 'SAS' and Finished = 0
    Select @pmsState = SynState from PS3_BaasExchgState
      Where ZipFileName = @piFileName and CPNTNAME = 'PMS' and Finished = 0
    if (@sasState = '更新成功') and (@pmsState = '更新成功')
    begin
      set @synState = '更新成功'
      set @isfinished = 1
    end else if (@sasState = '更新失败') or (@pmsState = '更新失败')
    begin
      set @synState = '更新失败'
      set @isfinished = 1
    end else
  	  set @synState = '更新中'
  	--更新ExchangeState表的状态字段
    Update e Set e.Stat = @synState
      From ExchangeState e, WorkStation w
    Where e.PosNo = w.No and Cls = @vClsName and w.Style in (5, 6)
  	--更新状态及最后修改时间
  	if @isfinished = 1
      Update PS3_BaasExchgState
        Set Finished = @isfinished, LstUpdTime = GetDate()
      Where ZipFileName = @piFileName
  End

  Return 0
End
GO
