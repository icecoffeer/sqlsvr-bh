SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[RQ_CHECKPERMISSION] (
  @piUserGId     varchar(255),          --用户ID
  @piModuleId    varchar(255),          --模块ID
  @poMsg         varchar(255)  output   --权限列表, 0-没有权限,1-有权限, 依次为：查看权\导出权\打印权
) 
as 
Begin  
  --变量定义
  declare
    @v_Right             varchar(999),
    @v_SpecRight         varchar(999),
    @v_ModuleRight       varchar(1),
    @v_Len               Int,
    @v_ModuleRight_Count Int,
    @v_RightCount        Int,
    @I                   Int,
    @v_RightLen          Int,
    @v_Opt_Ctrl          Int,
    @v_SpecRightNo       Int
  
  
  --读取用户模块特殊权限 
  if object_id('c_SpecRight') is not null deallocate c_ChgBook
  Declare c_SpecRight cursor For
    Select distinct ugsr.SpecrightNo
      From FaUserGrpSpecRight ugsr (nolock), ModuleRight mr (nolock)
        Where ugsr.UserGrpGId in (Select usergrpgid From FAUserUserGrp (nolock) Where usergid = Convert(int, @piUserGId))
          and mr.Module = Convert(int, @piModuleID)  
          and ugsr.SpecRightNo = mr.No
          and ugsr.SpecRightNo2 = mr.No2
          and ugsr.RightLevel = 0
     Order By ugsr.SpecRightNo     
      
  set @v_SpecRight = ''
  set @v_Len = 0
  open c_SpecRight
  fetch next from c_SpecRight into @v_SpecRightNo
  while @@fetch_status = 0
  begin
  
    set @I = @v_SpecRightNo % 1000
    If @I <= @v_Len
    begin
      set @v_SpecRight = SubString(@v_SpecRight, 1, @i - 1) + '1' + SubString(@v_SpecRight, @i + 1, @v_Len - @i)
    end Else
    begin
      set @v_SpecRight = @v_SpecRight + Replicate('0', @i - 1 - @v_Len) + '1'
      set @v_Len = @i
    end

    fetch next from c_SpecRight into @v_SpecRightNo
  end
  close c_SpecRight
  deallocate c_SpecRight

  ---权限不足在权限表中的长度，补齐到相应的长度
  Select @v_RightCount = Count(1) From ModuleRight (nolock) Where Module = Convert(int, @piModuleID)  
  If @v_RightCount < 2
    --保证至少有导出权以及打印权两个默认权限
    Set @v_RightCount = 2
  
  If @v_SpecRight Is Null
  begin
    --如果不控制明细权限 则全部返回1-有权限
    --exec PFA_OPTION_READINTEGER 0, 'FA_WebQueryCtrlDetileRight', @v_Opt_Ctrl output, 0 
    select @v_Opt_Ctrl = optionvalue from hdoption (nolock) where moduleno = 0 and optioncaption = 'FA_WebQueryCtrlDetileRight';
    if @@rowcount <> 0 
      set @v_Opt_Ctrl = 0
    
    if @v_Opt_Ctrl = 1 
    begin
      Set @v_SpecRight = Replicate('0', @v_RightCount)
    end Else 
    begin
      Set @v_SpecRight = Replicate('1', @v_RightCount)
    end
  end Else
  begin
    set @v_RightLen = Len(@v_SpecRight)
    If @v_RightLen <> @v_RightCount 
    begin
      Set @i = @v_RightLen      
      while 1=1 
      begin
        set @v_SpecRight = @v_SpecRight + '0'
        set @i = @i + 1
        if @i >= @v_RightCount 
          Break
      end
    end
  end
    
  --查看权
  Select @v_ModuleRight_Count = Count(1) From FAUserGrpRight fr (nolock), FAUserUserGrp fug (nolock)
    Where fr.UserGrpGId = fug.UserGrpGId and fug.UserGId = Convert(int, @piUserGId) and fr.ModuleNo = Convert(int, @piModuleID)  
  If @v_ModuleRight_Count > 0
  begin
    Set @v_ModuleRight = '1'
  end Else
  begin
    Set @v_ModuleRight = '0'
  end
    
  Set @v_Right = @v_ModuleRight + rtrim(ltrim(@v_SpecRight))
  
  --返回权限
  Set @poMsg = @v_Right
End
GO
