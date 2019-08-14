SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PS3_GetPromoteCode]
(
  @pi_PlatForm VarChar(80), --来源平台: Intra
  @pi_ProcName VarChar(40), --流程名称:"差额付款"
  @pi_QueryCond Varchar(255), --打折码查询条件(班组代码+供应商代码+品牌名称+打折):形如 dept=xxxx&vdr=xxxx&brand=xxxx
  @po_PromCode Varchar(255) output, --一个或多个打折码(商品码): 形如  商品1[0001],商品2[0002]
  @po_GdDept VarChar(255) output, --一个或多个商品对应的部门代码: 形如  部门1[0001],部门2[0002]
  @po_Msg varchar(255) output --错误信息
)
As
Begin
  Declare
    @v_DeptCode Varchar(40),
    @v_VdrCode Varchar(40),
    @v_VdrGid int,
    @v_BrandCode Varchar(40),
    @v_TmpCond Varchar(255),
    @v_Index int

  If @pi_PlatForm <> 'Intra'
  Begin
    Set @po_Msg = '暂不支持Intra之外的平台'
    Return 1
  End
  Select @po_PromCode = '', @po_GdDept = '', @po_Msg = ''

  If @pi_ProcName = '差额付款'
  Begin
    Set @v_TmpCond = @pi_QueryCond
    --对查询条件进行解析
    Select @v_Index = CharIndex('&', @v_TmpCond)
    If @v_Index > 1
    Begin
      Select @v_DeptCode = SubString(@v_TmpCond, 1, @v_Index - 1),
        @v_TmpCond = SubString(@v_TmpCond, @v_Index + 1, Len(@v_TmpCond))
      If Charindex('dept=', @v_DeptCode) = 0
      Begin
        Set @po_Msg = '传入条件格式存在问题,班组信息缺失'
        Return 1
      End
      Select @v_DeptCode = RTrim( SubString(@v_DeptCode, 6, Len(@v_DeptCode)) )
      If Not Exists(Select 1 from Dept Where Code = @v_DeptCode)
      Begin
        Set @po_Msg = '传入条件中班组条件存在问题,代码在Pos3中不存在'
        Return 1
      End
    End
    --供应商
    Select @v_Index = CharIndex('&', @v_TmpCond)
    If @v_Index > 1
    Begin
      Select @v_VdrCode = SubString(@v_TmpCond, 1, @v_Index - 1),
        @v_TmpCond = SubString(@v_TmpCond, @v_Index + 1, Len(@v_TmpCond))
      If Charindex('vdr=', @v_VdrCode) = 0
      Begin
        Set @po_Msg = '传入条件格式存在问题,供应商信息缺失'
        Return 1
      End
      Select @v_VdrCode = RTrim( SubString(@v_VdrCode, 5, Len(@v_VdrCode)) )
      If Not Exists(Select 1 from Vendor Where Code = @v_VdrCode)
      Begin
        Set @po_Msg = '传入条件中供应商条件存在问题,代码在Pos3中不存在'
        Return 1
      End
      Select @v_VdrGid = Gid From Vendor where Code = @v_VdrCode
    End
    --品牌
    Select @v_Index = CharIndex('&', @v_TmpCond)
    If @v_Index = 0
    Begin
      Select @v_BrandCode = SubString(@v_TmpCond, 1, Len(@v_TmpCond))
      If Charindex('brand=', @v_BrandCode) = 0
      Begin
        Set @po_Msg = '传入条件格式存在问题,品牌信息缺失'
        Return 1
      End
      Select @v_BrandCode = RTrim( SubString(@v_BrandCode, 7, Len(@v_BrandCode)) )
      If Not Exists(Select 1 from Brand Where Code = @v_BrandCode)
      Begin
        Set @po_Msg = '传入条件中品牌条件存在问题,代码在Pos3中不存在'
        Return 1
      End
    End else
    Begin
      Set @po_Msg = '传入条件格式存在问题,超出定义'
      Return 1
    End
    --获取商品列表(多个商品时用","分隔)
    Select @po_PromCode = Stuff( (select ','+ RTRIM(Name) + '[' + RTRIM(CODE) + ']'
      FROM Goods(nolock) Where IsNull(F1, '') like Rtrim(@v_DeptCode)+'%' and IsNull(Brand, '') = @v_BrandCode
        And Billto = @v_VdrGid And IsLtd = 0 And (CharIndex('折扣', Name) > 0) Order By Code FOR xml path('')), 1, 1,'')
    If @po_PromCode Is Null
    begin
      Set @po_PromCode = ''
      Return 0
    end
    Select @po_PromCode = RTrim(@po_PromCode)
    --获取打折码列表的部门信息(多个商品时用","分隔)
    Select @po_GdDept = Stuff( (select ','+ RTRIM(d.Name) + '[' + RTRIM(d.Code) + ']'
      FROM Goods(nolock), Dept d(nolock) Where IsNull(F1, '') = d.Code
        And IsNull(F1, '') like Rtrim(@v_DeptCode) + '%' and IsNull(Brand, '') = @v_BrandCode
        And Billto = @v_VdrGid And IsLtd = 0 And (CharIndex('折扣', Goods.Name) > 0) Order By Goods.Code FOR xml path('')), 1, 1,'')
    If @po_GdDept Is Null
      Set @po_GdDept = ''
    Select @po_GdDept = RTrim(@po_GdDept)
  End

  Return 0
End
GO
