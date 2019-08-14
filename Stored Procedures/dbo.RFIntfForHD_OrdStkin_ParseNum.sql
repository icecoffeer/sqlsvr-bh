SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_OrdStkin_ParseNum](
  @piOrdNum varchar(14),        --传入参数：定单号(10位，或14位且前4位为本店代码)或定单来源单号(14位且前4位为其他门店代码)。
  @poOrdNum varchar(10) output, --传出参数（返回值为0时有效）：定单号。
  @poErrMsg varchar(255) output --传出参数（返回值不为0时有效）：错误消息。
) as
begin
  declare
    @return_status int,
    @OptPad int, --选项：门店代码不足4位时的补齐方式
    @OrdNumLeft4 varchar(4), --传入单号的左4位
    @OrdNumRight10 varchar(10) --传入单号的右10位

  --读取选项。
  exec OptReadInt 8146, 'Ord_Rcv_Pad', 0, @OptPad output

  --初始化传出参数。
  set @poOrdNum = ''

  --解析传入单号。
  set @piOrdNum = rtrim(isnull(@piOrdNum, ''))
  if len(@piOrdNum) = 10
  begin
    --传入单号为定单号，则传出单号等于传入单号。
    set @poOrdNum = @piOrdNum
  end
  else if len(@piOrdNum) = 14
  begin
    /*1.传入单号为14位时，将其按门店代码(4位)+定单来源单号(10位)的格式进行解析。
        传出单号为传入单号对应的定单号。
      2.门店代码有时候小于4位。这时候，条码编制者会给这种代码补零，将其补足4位。
        补零的方式有两种：左补、右补。因此在解析门店代码时，需要先将这种补进的零去除。*/
    --传入单号左4位：门店代码
    set @OrdNumLeft4 = left(@piOrdNum, 4)
    --传入单号右10位：定单号或定单来源单号
    set @OrdNumRight10 = right(@piOrdNum, 10)
    --根据门店代码和定单号（或定单来源单号），找到其对应的定单号。
    if exists(select 1 from STORE(nolock) where CODE = @OrdNumLeft4)
    begin
      exec RFIntfForHD_OrdStkin_ParseOneNum @OrdNumLeft4, @OrdNumRight10, @poOrdNum output
    end
    else begin
      if @OptPad = 0 --规定左补零，则删除左侧的零。
      begin
        set @OrdNumLeft4 = substring(@OrdNumLeft4, 2, len(@OrdNumLeft4) - 1)
        while len(@OrdNumLeft4) >= 1
        begin
          exec @return_status = RFIntfForHD_OrdStkin_ParseOneNum @OrdNumLeft4, @OrdNumRight10, @poOrdNum output
          if @return_status = 0
            break
          set @OrdNumLeft4 = substring(@OrdNumLeft4, 2, len(@OrdNumLeft4) - 1)
        end
      end
      else if @OptPad = 1 --规定右补零，则删除右侧的零。
      begin
        set @OrdNumLeft4 = substring(@OrdNumLeft4, 1, len(@OrdNumLeft4) - 1)
        while len(@OrdNumLeft4) >= 1
        begin
          exec @return_status = RFIntfForHD_OrdStkin_ParseOneNum @OrdNumLeft4, @OrdNumRight10, @poOrdNum output
          if @return_status = 0
            break
          set @OrdNumLeft4 = substring(@OrdNumLeft4, 1, len(@OrdNumLeft4) - 1)
        end
      end
      else begin
        set @poErrMsg = '选项 Ord_Rcv_Pad(8146) 的值 ' + isnull(convert(varchar, @OptPad), 'null') + ' 未定义。'
        return 1
      end
    end
  end
  else begin
    set @poErrMsg = '传入单号 ' + @piOrdNum + ' 的长度 ' + convert(varchar, len(@piOrdNum)) + ' 不正确。'
    return 1
  end

  --返回。
  if @poOrdNum is null or rtrim(@poOrdNum) = ''
  begin
    set @poErrMsg = '根据传入单号 ' + @piOrdNum + ' ，未能找到其对应的定单号。'
    return 1
  end
  else begin
    return 0
  end
end
GO
