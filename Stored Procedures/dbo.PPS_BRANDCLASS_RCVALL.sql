SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_BRANDCLASS_RCVALL](
  @Src int, --发送门店
  @Id int,  --ID
  @ErrMsg varchar(255) output  --错误消息
 )
as
begin
  delete from BrandClass where gid in (select gid from NBrandClass where Src = @src and id = @id)
  insert into BrandClass(Gid, Name, Note)
  select Gid, Name, Note
    from NBrandClass
  where Src = @src and ID = @id

  delete from NBrandClass where src = @src and id = @id

  return(0)
end
GO
