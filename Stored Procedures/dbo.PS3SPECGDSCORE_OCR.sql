SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3SPECGDSCORE_OCR]
(
  @Num varchar(14),
  @Cls varchar(10),
  @Oper varchar(20),
  @Msg varchar(255) output
) as
begin
 declare
    @vGDGid int,
    @vBeginDateN DateTime,
    @vEndDateN DateTime,
    @vBeginDateO DateTime,
    @vEndDateO DateTime

  declare curDataSet cursor for
    select GDGid, BeginDate, EndDate
    from PS3SPECGDSCOREDTL(nolock)
    where Num = @Num and Cls = @Cls
  open curDataSet
  fetch next from curDataSet into @vGDGid, @vBeginDateN, @vEndDateN
  while @@fetch_status = 0
  begin
    --当同种类型的最新开始时间和结束时间跟原先记录有交集，删除原先的记录
    delete from PS3SPECGDSCOREINV
      where GDGid = @vGDGid and BeginDate <= @vEndDateN and EndDate >= @vBeginDateN

    Fetch Next From curDataSet into @vGDGid, @vBeginDateN, @vEndDateN
  end
  close curDataSet
  deallocate curDataSet
  --将设置表中的值插入到当前值表
  insert into PS3SPECGDSCOREINV(UUID, GDGID, MINAMOUNT, AMOUNT, SCORESORT, SCORE, NSCORE,
    MAXDISCOUNT, BEGINDATE, ENDDATE, SRCNUM, SRCCLS, DISCOUNT, DISMAXDIS, DISPREC)
  select newid(), GDGID, MINAMOUNT, AMOUNT, SCORESORT, SCORE, NSCORE,
    MAXDISCOUNT, BEGINDATE, ENDDATE, @Num, @Cls, DISCOUNT, DISMAXDIS, DISPREC
  from PS3SPECGDSCOREDTL
    where Num = @Num and Cls = @Cls
  insert into PS3SPECGDSCOREINVOUT(UUID, SUBJCODE, SUBJCLS, SRCNUM, SRCCLS)
    select newid(), SUBJCODE, SUBJCLS, @Num, @Cls from PS3SPECGDSCOREPROMSUBJOUTDTL
    where Num = @Num and Cls = @Cls
  --不同卡类型定义不同折扣率当前值表
  If @Cls = '折扣'
  begin
    insert into PS3SPECGDSCOREINVSPECDIS(UUID, CARDTYPECODE, CARDTYPENAME, DISCOUNT, SRCNUM, SRCCLS)
    select newid(), CARDTYPECODE, CARDTYPENAME, DISCOUNT, @Num, @Cls
    from PS3SPECGDSCORESPECDIS
      where Num = @Num and Cls = @Cls
  end

  return(0)
end
GO
