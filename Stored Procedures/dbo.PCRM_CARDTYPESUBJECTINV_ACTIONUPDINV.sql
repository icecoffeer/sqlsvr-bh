SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PCRM_CARDTYPESUBJECTINV_ACTIONUPDINV]
(
  @piDate         DateTime,            --时间
  @poErrMsg       varchar(255) output  --返回出错信息。
)
as
begin
  declare 
    @vUserGid int, @vOperTime datetime, @vUpdTime datetime, @vCardType varchar(20)

  select @vUserGid = UserGid from FASystem(nolock) where UserGid = ZBGid
  if @@RowCount <> 1 
  begin
    select @poErrMsg = '非总部不能做该操作'
    return(1)
  end  
  
  ---操作时间
  select @vOperTime = getdate(), @vUpdTime = DateAdd(n, -5, @piDate)

  declare cur_AllCardType cursor for
    select Rtrim(Code) from CRMCardType(nolock) order by Code
  open cur_AllCardType
  fetch next from cur_AllCardType into @vCardType
  while @@fetch_status = 0
  begin
    exec PCRM_CARDTYPESUBJECTINV_SINGLEACTOINUPDINV @vUserGid, '制卡', @vCardType, @vUpdTime, @vOperTime, 200, 400, @poErrMsg output
    exec PCRM_CARDTYPESUBJECTINV_SINGLEACTOINUPDINV @vUserGid, '发卡', @vCardType, @vUpdTime, @vOperTime, 400, 500, @poErrMsg output
    exec PCRM_CARDTYPESUBJECTINV_SINGLEACTOINUPDINV @vUserGid, '退卡', @vCardType, @vUpdTime, @vOperTime, 300, 400, @poErrMsg output
    exec PCRM_CARDTYPESUBJECTINV_SINGLEACTOINUPDINV @vUserGid, '旧卡发卡', @vCardType, @vUpdTime, @vOperTime, 400, 500, @poErrMsg output
    exec PCRM_CARDTYPESUBJECTINV_SINGLEACTOINUPDINV @vUserGid, '补发卡', @vCardType, @vUpdTime, @vOperTime, 400, -1, @poErrMsg output
    exec PCRM_CARDTYPESUBJECTINV_CHECKACTOINUPDINV @vUserGid, '核对', @vCardType, @vUpdTime, @vOperTime, @poErrMsg output

    fetch next from cur_AllCardType into @vCardType                  
  end   
  close cur_AllCardType
  deallocate cur_AllCardType 

  return(0)
end
GO
