SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_SORT_SENDONE]
(
  @piCode varchar(13),          --类别代码
  @piRcvGid integer,            --接收门店
  @piFrcUpd int,                --是否强制更新
  @piFlag integer,              --是否已删除类别资料，0-否；1-是
  @poErrMsg varchar(255) output --错误信息
) as
begin
  declare
    @vSrc int,
    @vID int,
    @vCount int

  select @vSrc = UserGid from FASystem(nolock)
  if @piFlag = 1
  begin
    --取得ID号
    exec @vID = SeqNextValue 'NSORT'

    insert into NSORT(Src, ID, Code, Name, Rcv, Type, FRCUPD, NSTAT, FLAG)
    select @vSrc, @vID, Code, Name, @piRcvGid, 0, @piFrcUpd, 0, 1
      from SORTDELETE(nolock)
    where Code = @piCode
  end
  else
  begin
    --取得ID号
    exec @vID = SeqNextValue 'NSORT'
    insert into NSORT(Src, ID, Code, Name, Rcv, Type, FRCUPD, NSTAT, FLAG)
    select @vSrc, @vID, Code, Name, @piRcvGid, 0, @piFrcUpd, 0, 0
      from SORT(nolock)
    where Code = @piCode
  end
  --DTS
  exec LOGNETOBJSEQ 8, @vSrc, @vID, @piRcvGid, 0

  return(0)
end
GO
