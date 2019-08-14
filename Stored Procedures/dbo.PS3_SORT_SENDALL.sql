SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_SORT_SENDALL]
(
  @piRcvGid int,            --接收门店
  @piFrcUpd int,            --是否强制更新
  @poErrMsg varchar(255) output --错误信息
) as
begin
  declare
    @vID int,
    @vCode varchar(13),
    @vUserGid int,
    @vFlag int

  --取得system.usergid
  select @vUserGid = USERGID from FASYSTEM(nolock)

  delete from NSORT where TYPE = 0 and RCV = @piRcvGid

  declare curNSort cursor for
    select Code, 0 Flag from Sort(nolock)
      union
    Select Code, 1 Flag From SortDelete(nolock)
  open curNSort
  fetch next from curNSort into @vCode, @vFlag
  while @@fetch_status = 0
  begin
    ---取得ID号
    exec @vID = SeqNextValue 'NSort'

    if @vFlag = 0
      ---类别
      insert into NSort (SRC, ID, CODE, NAME, RCV, FRCUPD, TYPE, NSTAT, Flag)
      select @vUserGid, @vID, Code, Name, @piRcvGid, @piFrcUpd, 0, 0, @vFlag
        from Sort(nolock)
      where Code = @vCode
    else
      ---类别
      insert into NSort (SRC, ID, CODE, NAME, RCV, FRCUPD, TYPE, NSTAT, Flag)
      select @vUserGid, @vID, Code, Name, @piRcvGid, @piFrcUpd, 0, 0, @vFlag
        from SortDelete(nolock)
      where Code = @vCode
    --DTS
    exec LOGNETOBJSEQ 8, @vUserGid, @vID, @piRcvGid, 0

    fetch next from curNSort into @vCode, @vFlag
  end
  close curNSort
  deallocate curNSort

  return(0)
end
GO
