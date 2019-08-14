SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PS3_GenCntr_FromOnLine]
(
  @piPlatForm Varchar(80), --PS3_OnLineCntr.PlatForm
  @piCntrNo Varchar(100),  --PS3_OnLineCntr.CntrNo
  @poErrMsg Varchar(255) Output
)
As
Begin
  Declare
    @v_UUID Varchar(40),
    @v_StoreCode Varchar(30), --生效门店
    @v_VdrCode Varchar(30), --供应商代码
    @v_DeptCode Varchar(30), --结算组代码
    @v_BeginDate DateTime,
    @v_EndDate DateTime,
    @v_RealEndDate DateTime,
    @v_OperationStat smallint, --处理状态: 0-未处理,1-已处理
    @v_Signer Varchar(30), --Intra品牌类别,对应H3签约人
    @v_VdrGid int,
    @v_StoreGid int,
    @v_EmpGid Int, --H3签约人

    @v_GroupNum Varchar(20), --合约组单号
    @v_GroupVersion int, --合约组版本号
    @v_NewNum Varchar(14), --新增合约单号
    @v_NewVersion smallint, --新合约版本号
    @v_IsChange smallint, --是否变更原合约号 0:否 1:是
    @v_Ret int,

    @v_Line int,
    @v_ChgCode Varchar(20),
    @v_OffSetCode Varchar(40),
    @v_IsAdded int,
    @v_GdScope Varchar(4),
    @v_StoreScope Varchar(4),
    @v_GdScopeText Varchar(255),
    @v_GenUnit Varchar(4),
    @v_Cycle Smallint,
    @v_DayOffSet Smallint,

    @v_GdGid int, --补差商品
    @v_ChgCls Varchar(4), --固定, 提成
    @v_ModalType Varchar(4), --02,03,06
    @v_GenMethod smallint, --0=固定周期，1=固定日
    @v_GdScopeSql Varchar(255)

  Select @v_UUID = UUID, @v_StoreCode = ShopId, @v_VdrCode = VdrCode, @v_DeptCode = SettleDept,
    @v_BeginDate = BeginDate, @v_EndDate = EndDate, @v_RealEndDate = RealEndDate,
    @v_OperationStat = OperationStat, @v_Signer = Signer
  From PS3_OnlineCntr
    Where PlatForm = @piPlatForm and CntrNo = @piCntrNo
  If @@RowCount = 0
  Begin
    Set @poErrMsg = 'PS3_OnlineCntr表中不存在指定的记录'
    Return 1
  End
  If @v_OperationStat <> 0
    Return 0

  --合法性判断
  Select @v_VdrGid = Gid From Vendor(Nolock)
    Where Code = @v_VdrCode
  If @@RowCount = 0
  Begin
    Set @poErrMsg = 'POS3供应商资料中不存在代码:' + @v_VdrCode
    Return 1
  End
  If Not Exists(Select 1 From SettleDept Where Code = @v_DeptCode)
  Begin
    Set @poErrMsg = 'POS3费用结算组资料中不存在代码:' + @v_DeptCode
    Return 1
  End
  Select @v_StoreGid = Gid From Store(Nolock)
    Where Code = @v_StoreCode
  If @@RowCount = 0
  Begin
    Set @poErrMsg = 'POS3门店资料中不存在代码:' + @v_StoreCode
    Return 1
  End
  Select @v_EmpGid = Gid From Employee(Nolock)
    Where Code = @v_Signer
  If @@RowCount = 0
  Begin
    Set @poErrMsg = 'POS3员工资料中不存在代码:' + @v_Signer
    Return 1
  End

  -- 合约组,根据供应商和结算组选取一个时间最新的合约组
  Select @v_GroupNum = Num, @v_GroupVersion = Version From CntrGroup(Nolock)
    Where Vendor = @v_VdrGid And Stat = 100 And Tag = 1
  If @@RowCount = 0
  Begin
    Set @poErrMsg = '供应商' + @v_VdrCode + '不存在合约组'
    Update PS3_OnlineCntr Set OperationNote = @poErrMsg
      Where UUID = @v_UUID
    Return 1
  End

  Set @v_IsChange = 0
  -- 根据供应商和结算组,查找当前是否已有正在生效的合约
  --   (百货只会存在一条有效合约,超市的可能存在两条,但起止时间不会有重叠)
  -- 如果不存在或起止时间无重叠,则新增合约; 否则变更该合约
  Select Top 1 @v_NewNum = Num, @v_NewVersion = Version From CtCntr(Nolock)
    Where VENDOR = @v_VdrGid And Dept = @v_DeptCode And Stat = 500 And Tag = 1
      Order By SignDate Desc
  If @@RowCount > 0
  Begin
    --如果起止时间有重叠,则变更
    If Exists(Select 1 From CtCntr(Nolock) Where (BeginDate <= @v_EndDate) And (EndDate >= @v_BeginDate))
      Set @v_IsChange = 1
  End

  If @v_IsChange = 0
  Begin
    --计算新的合约单号
    Exec GenNextBillNumEx Null, 'CTCNTR', @v_NewNum Output
    Set @v_NewVersion = 0
  End Else
  Begin
    --变更原有合约
    Exec @v_Ret = Pct_Cntr_Before_Change @v_NewNum, @v_NewVersion, 1, @poErrMsg Output
    If @v_Ret <> 0
      Return 1
    --删除"合约生成供应商联销协议条件"相关表记录
    Delete From Cntr_GenVdrlessee Where CntrNum = @v_NewNum And Version = @v_NewVersion And VdrGid = @v_VdrGid
    Delete From Cntr_GenVdrlseDept Where CntrNum = @v_NewNum And Version = @v_NewVersion And VdrGid = @v_VdrGid
    Delete From Cntr_GenVdrlseDeptBrand Where CntrNum = @v_NewNum And Version = @v_NewVersion And VdrGid = @v_VdrGid
  End
  Set @v_NewVersion = @v_NewVersion + 1

  --写合约汇总
  Insert Into CtCntr(Num, Version, Stat, Vendor, SignDate, BeginDate, EndDate, RealEndDate, Dept,
    Signer, CntrNo, FileText, Modifier, LstUpdTime, Tag, Note, AgentMode, Salesq, Salecls, GuardAmt,
    UpguardRate, GuardRate, Rent, Customdef, Exstore, Actsq)
  Select @v_NewNum, @v_NewVersion, 0, @v_VdrGid, GetDate(), @v_BeginDate, @v_EndDate, @v_RealEndDate, @v_DeptCode,
    @v_EmpGid, @piCntrNo, FileText, '未知[-]', GetDate(), 1, Note, AgentMode, SaleArea, SaleCls, GuardAmt,
    UpguardRate, GuardRate, Rent, Customdef, @v_StoreGid, RealArea
  From PS3_OnlineCntr Where UUID = @v_UUID
  --写合约组与合约对照关系
  Delete From GroupCntr Where Num = @v_GroupNum And Version = @v_GroupVersion
    And CntrNum = @v_NewNum And CntrVersion = @v_NewVersion
  Insert Into GroupCntr(Num, Version, CntrNum, CntrVersion)
  Select @v_GroupNum, @v_GroupVersion, @v_NewNum, @v_NewVersion

  --合约经营品牌表(百货独有)
  insert into CtCntrBrand(Num, Version, ItemNo, Code, Type, Status, BeginDate, EndDate)
  Select @v_NewNum, @v_NewVersion, Line, Code, Type, Status, StartDate, EndDate
    From PS3_OnlineCntrBrand Where UUID = @v_UUID
  --合约联销率变更条件(百货独有)
  Insert Into CtCntrRateCondPlan(Num, Version, Line, Vendor, Dept, BeginDate, EndDate, ExpAmt, AddRate, ExeStat)
  Select @v_NewNum, @v_NewVersion, Line, @v_VdrGid, @v_DeptCode, BeginDate, EndDate, SaleAmt, AddRate, 0
    From PS3_OnlineCntrRateCond Where UUID = @v_UUID
  --超市考核协议(超市独有)
  /*Insert Into CtCntrKhxy(Num, Version, CMonth, GuardSaleAmt, GuardGpRate)
  Select @v_NewNum, @v_NewVersion, CMonth, GuardSaleAmt, GuardGpRate
    From PS3_OnlineCntrCheckAgmt Where UUID = @v_UUID*/

  Declare c_Dtl Cursor Local For
    Select Line, ChgCode, OffsetCode, IsAdded, StoreScope, GdScope, GdScopeText,
      GenUnit, GenCycle, GenDayOffSet
    From PS3_OnlineCntrDtl Where UUID = @v_UUID
    Order By Line
  Open c_Dtl
  Fetch Next From c_Dtl into @v_Line, @v_ChgCode, @v_OffSetCode, @v_IsAdded, @v_StoreScope,
    @v_GdScope, @v_GdScopeText, @v_GenUnit, @v_Cycle, @v_DayOffSet
  While @@fetch_status = 0
  Begin
    /*根据OFFSETCODE找商品表中的gid*/
    Set @v_GdGid = null
    If @v_IsAdded = 1
    Begin
      If @v_OffSetCode is null
      Begin
        Set @poErrMsg = 'PS3_OnlineCntrDtl表第' + LTrim(Str(@v_Line)) + '行账款项目' + RTrim(@v_ChgCode) + '为补差类型,补差码不能为空'
        Return 1
      End
      Select @v_GdGid = Gid From Goods Where IsOffSetGoods = 1 And Code = @v_OffSetCode
      If @@RowCount = 0
      Begin
        Set @poErrMsg = 'POS3商品资料中不存在该补差商品码:' + @v_OffSetCode
        Return 1
      End
    End
    Select @v_ChgCls = ChgCls, @v_ModalType = ModalType, @v_GenMethod = GenMethod
      From CtChgDef Where Code = @v_ChgCode
    If @@RowCount = 0
    Begin
      Set @poErrMsg = 'POS3账款项目资料中不存在代码:' + @v_ChgCode
      Return 1
    End
    --根据配置,计算下次生成日期 等
    Declare @v_CurDate Datetime, @v_NextEndDate DateTime, --下次统计日期
      @v_NextGenDate DateTime --下次生成日期
    Select @v_CurDate = Convert(Datetime, Convert(Date, Getdate()))
    If not (@v_GenUnit is null or @v_Cycle is null or @v_DayOffSet is null)
    Begin
      --提取客户端计算逻辑,根据当前日期及生成周期配置,计算 下次统计结束日期
      Exec @v_NextEndDate = CalculateEndDate @v_curDate, @v_GenUnit, @v_Cycle, @v_DayOffSet
    End Else
    Begin
      Set @v_NextEndDate = null
      If not (@v_ChgCls = '固定' And (@v_GenMethod = 1))
        --如果生成周期未维护,则默认取当前日期+1天,作为 下次统计结束日期
        Select @v_NextEndDate = @v_CurDate + 1
    End
    Set @v_NextGenDate = null
    If @v_NextEndDate is not null
      --下次生成时间取下次统计结束时间+1天
      Set @v_NextGenDate = @v_NextEndDate + 1

    --合约明细
    Insert Into CtCntrDtl(Num, Version, Line, ChgCode, GenUnit, GenCycle, GendayOffset, FstGendate, NextGendate,
      GatheringMode, IsAdded, ModalCls, VdrGdgid, SingleFee)
    Select @v_NewNum, @v_NewVersion, Line, ChgCode, GenUnit, GenCycle, GendayOffset, @v_NextGenDate, @v_NextGenDate,
      --IsAdded=1时,ModalCls也记为1(补差),否则为0(费用)
      GatheringMode, IsAdded, IsAdded, @v_GdGid, SingleFee
    From PS3_OnlineCntrDtl Where UUID = @v_UUID And Line = @v_Line
    --固定类明细
    If @v_ChgCls = '固定'
    Begin
      Insert Into CtCntrFixDtl(Num, Version, Line, FeeUnit, FeeCycle, FstFeeDate, Amount)
      Select @v_NewNum, @v_NewVersion, Line, Case @v_GenMethod When 0 then GenUnit else null end,
        Case @v_GenMethod When 0 then GenCycle else null end,
        Case @v_GenMethod When 0 then @v_NextGenDate else null end,
        Case @v_GenMethod When 0 then Amount else 0 end
      From PS3_OnlineCntrDtl Where UUID = @v_UUID And Line = @v_Line
      --固定类指定日期明细
      If @v_GenMethod = 1
      Begin
        Insert Into CtCntrFixDate(Num, Version, Line, ItemNo, GenDate, Total)
        Select @v_NewNum, @v_NewVersion, Line, 1, GenDate, Amount
          From PS3_OnlineCntrDtl Where UUID = @v_UUID And Line = @v_Line
      End
    End
    Else If @v_ChgCls = '提成'
    Begin
      --提成类数据源
      Insert Into CtCntrDtlDataSrc(Num, Version, Line, DsCode)
      Select @v_NewNum, @v_NewVersion, @v_Line, DsCode
        From CtChgDataSrc Where Code = @v_ChgCode
      --读取CtScope中商品范围Sql
      Set @v_GdScopeSql = null
      If @v_GdScope = '指定' And @v_GdScopeText is not Null
      Begin
        Select @v_GdScopeSql = SqlCond From CtScope
          Where CateGory = '商品' And SqlText = @v_GdScope
      End
      --提成类明细
      Insert Into CtCntrRateDtl(Num, Version, Line, FeeUnit, FeeCycle, FeeDayOffSet, FstFeeDate,
        NextBeginDate, NextEndDate, StoreScope, GdScope, GdScopeText, GdScopeSql)
      Select @v_NewNum, @v_NewVersion, Line, GenUnit, GenCycle, GendayOffset - 1, @v_CurDate,
        @v_CurDate, @v_NextEndDate, @v_StoreScope, @v_GdScope, GdScopeText, @v_GdScopeSql
      From PS3_OnlineCntrDtl Where UUID = @v_UUID And Line = @v_Line
      --合约提成类提成率明细
      If @v_ModalType = '02'
      Begin
        Insert Into CtCntrRateDisc(Num, Version, Line, ItemNo, Rate, LowAmt, HighAmt, QBase)
        Select @v_NewNum, @v_NewVersion, @v_Line, ItemNo, Rate, LowAmt, HighAmt, 0
          From PS3_OnlineCntrRateDisc Where UUID = @v_UUID And DLine = @v_Line
      End Else
      --合约保底提成类提成率明细
      If @v_ModalType = '06'
      Begin
        Insert Into CtCntrRateByMonthDisc(Num, Version, Line, ItemNo, Rate, LowDate, HighDate, GAmt)
        Select @v_NewNum, @v_NewVersion, @v_Line, ItemNo, Rate, LowDate, HighDate, 0
          From PS3_OnlineCntrRateByMonthDisc Where UUID = @v_UUID And DLine = @v_Line
      End
      --合约提成类门店
      If @v_StoreScope = '指定'
      Begin
        Insert Into CtCntrRateStore(Num, Version, Line, ItemNo, StoreGid)
        Select @v_NewNum, @v_NewVersion, @v_Line, ItemNo, StoreGid
          From PS3_OnlineCntrRateStore Where UUID = @v_UUID And DLine = @v_Line
      End
    End Else
    Begin
      Set @poErrMsg = '不支持的账款项目类型:' + @v_ChgCls
      Return 2
    End

    Fetch Next From c_Dtl into @v_Line, @v_ChgCode, @v_OffSetCode, @v_IsAdded, @v_StoreScope,
      @v_GdScope, @v_GdScopeText, @v_GenUnit, @v_Cycle, @v_DayOffSet
  End
  Close c_Dtl
  Deallocate c_Dtl

  --如果是变更原有合约,需要调用过程更新相关数据
  If @v_IsChange = 1
  Begin
    Declare @v_OldVersion int
    Select @v_OldVersion = @v_NewVersion - 1
    Exec @v_Ret = Pct_Cntr_On_Change @v_NewNum, @v_OldVersion, @v_NewVersion, 1, @poErrMsg Output
    If @v_Ret <> 0
      Return @v_Ret
  End

  --记录到生成日志表
  insert into PS3_OnlineCntrGenLog(PlatForm, CntrNo, GenCntrNum, GenCntrVersion, UUID)
    Values(@piPlatForm, @piCntrNo, @v_NewNum, @v_NewVersion, @v_UUID)
  if @@Error <> 0
  begin
    Set @poErrMsg = '写入表PS3_OnlineCntrGenLog失败。'
    Return 1
  end
  --回写 中间表汇总 生成单据信息
  UPDATE PS3_OnlineCntr
    SET OperationStat = 1, OperationNote = ''
  WHERE UUID = @v_UUID

  Return 0
End
GO
