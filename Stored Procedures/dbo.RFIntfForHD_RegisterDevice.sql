SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_RegisterDevice]
(
  @piPDAMac varchar(40),          --手持设备的MAC地址
  @piPDANum varchar(40),          --手持设备的机器号
  @poErrMsg varchar(255) output   --错误信息
)
as
begin
  declare
    @vPDANum varchar(40)

  --检查机器号及MAC地址，要求：机器号及MAC地址一一对应，不能更改对应关系

  if exists(select * from PDAMACHINE(nolock) where MAC = @piPDAMac)
  begin
    select @vPDANum = NUM from PDAMACHINE(nolock)
      where MAC = @piPDAMac
    if rtrim(@vPDANum) <> rtrim(@piPDANum)
    begin
      set @poErrMsg = '该设备已经和 ' + @vPDANum + ' 机器号绑定，' +
        '请联系系统管理员进行核实处理。'
      return 1
    end
  end
  /*
  else if exists(select * from PDAMACHINE(nolock) where NUM = @piPDANum)
  begin
    set @poErrMsg = '该设备的机器编号和和其他设备的机器编号重复。'
    return 1
  end
  */
  else begin
    --登记到数据表中
    insert into PDAMACHINE(MAC, NUM) select @piPDAMac, @piPDANum
  end

  return 0
end
GO
