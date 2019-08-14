SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PPS_BRANDCLASS_SENDALL](
  @Rcv int, --接收门店
  @ErrMsg varchar(255) output  --错误消息
 )
as
begin
  declare 
    @vSrc int,
    @vID int
  
  select @vSrc = UserGid  from FASystem(nolock)
  
  delete from NBrandClass where src = @vSrc and rcv = @rcv   
  --取得ID号
  execute GetNetBillId @vID output
  insert into NBrandClass(Src, ID, Rcv, Type, Gid, Name, Note, SNDTIME, RCVTIME,  NSTAT, NNOTE)
  select @vSrc, @vID, @Rcv, 0, Gid, Name, Note, GETDATE(), NULL, 0, ''
  	from BrandClass 
  return(0)
end
GO
