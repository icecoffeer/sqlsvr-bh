SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PCT_CHGBOOK_ON_BILLABORT](
  @piCls varchar(10), --类型
  @piNum varchar(14), --单号
  @piOperGid integer, --操作人
  @poErrMsg varchar(255) output --出错信息
) As
Begin
  Declare
    @vRet int,
    @vStat int,
    @vNum varchar(14),
    @vStatName varchar(50)

  If @piCls Not In ('付款单')
  Begin
    Set @poErrMsg = '不支持的单据类型';
    Return 1
  End

  Declare c_Dtl Cursor Local For
    Select Num, Stat From CHGBOOK
      Where SRCCLS = @piCls And SRCNUM = @piNum
  Open c_Dtl
  Fetch Next From c_Dtl into @vNum, @vStat
  While @@fetch_status = 0
  Begin
    If @vStat = 0
    Begin
      Exec @vRet = PCT_CHGBOOK_REMOVE @vNum, @piOperGid, @poErrMsg Output
      If @vRet <> 0
        Return @vRet
    End Else If @vStat In (510, 520)
    Begin
      Select @vStatName = StatName From ModuleStat Where No = @vStat
      Set @poErrMsg = '本' + @piCls + '生成的费用单' + @vNum + '已经被处理,'
        + '费用单状态:' + @vStatName
      Return 1
    End

    Fetch Next From c_Dtl into @vNum, @vStat
  End
  Close c_Dtl
  Deallocate c_Dtl

  Return 0
End
GO
