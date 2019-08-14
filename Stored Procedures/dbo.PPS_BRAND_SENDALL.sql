SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_BRAND_SENDALL]
(
  @piRcvGid integer,            --接收门店
  @poErrMsg varchar(255) output --错误信息
) as
begin
  declare
    @vSrc int,
    @vID int,
    @vCode varchar(15),
    @vFlag int,
    @UserGid int

  ---控制非总部不能发送品牌
  select @vSrc = UserGid  from FASystem(nolock) where UserGid = ZBGid
  if @@ROWCOUNT = 0
  begin
    set @poErrMsg = '非总部不能发送品牌资料'
    return(1)
  end

  --取得system.usergid
  select @UserGid = USERGID from FASYSTEM(nolock)

  delete from NBrand where Rcv = @piRcvGid

  declare curNBrand cursor for
    select Code, 0 Flag
      from Brand(nolock)
    union
    select Code, 1 Flag
      from BrandDelete(nolock)
  open curNBrand
  fetch next from curNBrand into @vCode
  while @@fetch_status = 0
  begin
    ---取得ID号
    exec @vID = SeqNextValue 'NBRAND'

    if @vFlag = 0
      ---品牌
      insert into NBrand(Src, ID, Code, Name, Rcv, Type, Area, TemplateGid,
        Creator, CreateTime, LstUpdOper, LstUpdTime, Note, IntroduceTime,
        IntroduceOper, BusinessStat, EliminateTime, BrandClass, Flag)
      select @vSrc, @vID, Code, Name, @piRcvGid, 0, Area, TemplateGid,
        Creator, CreateTime, LstUpdOper, LstUpdTime, Note, IntroduceTime,
        IntroduceOper, BusinessStat, EliminateTime, BrandClass, @vFlag
      from Brand(nolock)
      where Code = @vCode
    else
      ---已删除品牌
      insert into NBrand(Src, ID, Code, Name, Rcv, Type, Area, TemplateGid,
        Creator, CreateTime, LstUpdOper, LstUpdTime, Note, IntroduceTime,
        IntroduceOper, BusinessStat, EliminateTime, BrandClass, Flag)
      select @vSrc, @vID, Code, Name, @piRcvGid, 0, Area, TemplateGid,
        Creator, CreateTime, LstUpdOper, LstUpdTime, Note, IntroduceTime,
        IntroduceOper, BusinessStat, EliminateTime, BrandClass, @vFlag
      from BrandDelete(nolock)
      where Code = @vCode
    ---DTS发送
    exec LOGNETOBJSEQ 11, @UserGid, @vID, @piRcvGid, 0

    fetch next from curNBrand into @vCode
  end
  close curNBrand
  deallocate curNBrand

  --add by xiexinbin 2011.02.11 发送品牌分类
  exec PPS_BRANDCLASS_SENDALL @piRcvGid, @poErrMsg output

  return(0)
end
GO
