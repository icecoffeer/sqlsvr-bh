SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTSND_LOADRULEGOODS]
(
  @piCode  varchar(18)
)
as
begin
  declare @vGdCond varchar(8000)
  declare @vSQL varchar(8000)

  delete from TMPGFTSNDRULEGOODS where SPID = @@SPID;
  if @piCode is null
  begin
    declare c_gdcond cursor for
      select GDCOND from GFTPRMGOODS g(nolock), TMPGFTSNDRESULT r(nolock)
      where r.SPID = @@SPID
      and r.rcode = g.rcode
    open c_gdcond
    fetch next from c_gdcond into @vGdCond
    while @@fetch_status = 0
    begin
      if @vGdCond is null set @vGdCond = ''
      if (@vGdCond <> '') and (@vGdCond <> '/*3*/')
      begin
        select  @vSQL = 'insert into TMPGFTSNDRULEGOODS(SPID, GDGID)
        		 select @@SPID, GID
        		 from GOODS(nolock), tmpgftsndsale
        		 where goods.Gid = tmpgftsndsale.gdgid
        		 and tmpgftsndsale.spid = @@spid
        		 and tmpgftsndsale.gdGID not in (select GDGID from TMPGFTSNDRULEGOODS where SPID = @@SPID)
        		 and ' + @vGdCond
        exec(@vSQL)
      end
      fetch next from c_gdcond into @vGdCond
    end
    close c_gdcond
    deallocate c_gdcond
  end else
  begin
    declare c_gdcond cursor for
      select GDCOND from GFTPRMGOODS(nolock)
      where RCODE = @piCode
    open c_gdcond
    fetch next from c_gdcond into @vGdCond
    while @@fetch_status = 0
    begin
      if @vGdCond is null set @vGdCond = ''
      if (@vGdCond <> '') and (@vGdCond <> '/*3*/')
      begin
        select @vSQL = 'insert into TMPGFTSNDRULEGOODS(SPID, GDGID)
        		select @@SPID, GID
        		from GOODS(nolock), tmpgftsndsale
        		where goods.Gid = tmpgftsndsale.gdgid
        		and tmpgftsndsale.spid = @@spid
        		and tmpgftsndsale.gdgid not in (select GDGID from TMPGFTSNDRULEGOODS where SPID = @@SPID)
        		and ' + @vGdCond
        exec(@vSQL)
      end
      fetch next from c_gdcond into @vGdCond
    end
    close c_gdcond
    deallocate c_gdcond
  end
  return(0)
end
GO
