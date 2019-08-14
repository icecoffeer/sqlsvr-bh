SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3ChkDup_NotScore]
(
  @PiNum varchar(14),
  @PiCls varchar(10),
  @PoErrMsg varchar(255) output
) as
begin
  Declare
    @v_Line Int,
    @v_DupLine Int,
    @v_Dept varchar(20),
    @v_Vendor int,
    @v_Sort varchar(20),
    @v_Brand varchar(20),
    @v_GDGid int,
    @v_BeginDate DateTime,
    @v_EndDate DateTime,
    @v_optDealWith Int, --对重复数据的处理选项
    @v_strSql VarChar(2048),
    @v_strCondition VarChar(1000)

  EXEC OPTREADINT 5144, 'PS3_DealWithDupData', 0, @v_optDealWith OUTPUT

  if object_id('cDupDtl') is not null deallocate cDupDtl
  Declare cDupdtl Cursor For
    Select Dept, VENDOR, SORT, BRAND, GDGID
      From PS3NOTSCOREGDSCOPEDTL(nolock)
    where NUM = @PiNum And CLS = @PiCls
    Group By Dept, VENDOR, SORT, BRAND, GDGID
    Having(Count(1) > 1)
  Open cDupdtl
  Fetch Next From cDupdtl Into @v_Dept, @v_Vendor, @v_Sort, @v_Brand, @v_GDGid
  While @@Fetch_Status = 0
  Begin
    if object_id('cDtl') is not null deallocate cDtl
    Set @v_strSql = ' Declare cDtl Cursor For
      Select BEGINDATE, ENDDATE, LINE
        From PS3NOTSCOREGDSCOPEDTL
      Where NUM = ''' + @PiNum + ''' And CLS = ''' + @PiCls + ''''
    --条件语句公用
    Set @v_strCondition = ''
    If @v_Dept is Not null
      Set @v_strCondition = @v_strCondition + ' And Dept = ''' + @v_Dept + ''''
    Else
      Set @v_strCondition = @v_strCondition + ' And Dept Is Null '
    If @v_Vendor is Not null
      Set @v_strCondition = @v_strCondition + ' And Vendor = ' + Str(@v_Vendor)
    Else
      Set @v_strCondition = @v_strCondition + ' And Vendor Is Null '
    If @v_Sort is Not null
      Set @v_strCondition = @v_strCondition + ' And Sort = ''' + @v_Sort + ''''
    Else
      Set @v_strCondition = @v_strCondition + ' And Sort Is Null '
    If @v_Brand is Not null
      Set @v_strCondition = @v_strCondition + ' And Brand = ''' + @v_Brand + ''''
    Else
      Set @v_strCondition = @v_strCondition + ' And Brand Is Null '
    If @v_GDGid is Not null
      Set @v_strCondition = @v_strCondition + ' And GdGid = ' + Str(@v_GDGid)
    Else
      Set @v_strCondition = @v_strCondition + ' And GdGid Is Null '
    Set @v_strSql = @v_strSql + @v_strCondition
    Exec(@v_strSql)

	  Open cDtl
	  Fetch Next From cDtl Into @v_BeginDate, @v_EndDate, @v_Line
	  While @@Fetch_Status = 0
	  Begin
	    if object_id('TEMPDB..#tmpLine') is null
        create table #tmpLine(Line Int Null)                              
	    else
	      delete from #tmpLine
			Set @v_strSql = 'Insert INTO #tmpLine(Line) SELECT LINE FROM PS3NOTSCOREGDSCOPEDTL(nolock) 
			  where CLS = ''' + @PiCls + ''' And NUM = ''' + @PiNum + ''' And Line <> ' + Str(@v_Line)
			    + @v_strCondition + ' And ( (BEGINDATE between ''' + convert(char(10), @v_BeginDate, 102) + ''' and ''' + Convert(char(10), @v_EndDate, 102) + ''''
			    + ') Or (ENDDATE between ''' + convert(char(10), @v_BeginDate, 102) + '''and ''' + convert(char(10), @v_EndDate, 102) + ''') )'
			Print @v_strSql
			Exec(@v_strSql)

      Select @v_DupLine = Line From #tmpLine
	    If @v_DupLine Is Not Null
	    Begin
	      If (@v_optDealWith = 1) --直接删除
	        Delete From PS3NOTSCOREGDSCOPEDTL WHERE CURRENT OF cDtl
	      Else
	      Begin
	        Set @PoErrMsg = '明细第' + Str(@v_Line) +  '行与第' + Str(@v_DupLine) + '行在同一时间段内记录重复.'
	        Close cDtl
	        Deallocate cDtl
	        Close cDupdtl
          Deallocate cDupdtl
	        Return 1
	      End
	    End

	    Fetch Next From cDtl Into @v_BeginDate, @v_EndDate, @v_Line
	  End
	  Close cDtl
	  Deallocate cDtl

    Fetch Next From cDupdtl Into @v_Dept, @v_Vendor, @v_Sort, @v_Brand, @v_GDGid
  End
  Close cDupdtl
  Deallocate cDupdtl

  Return 0
end
GO
