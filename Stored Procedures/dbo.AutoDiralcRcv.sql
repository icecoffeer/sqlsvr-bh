SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoDiralcRcv]  
 @SRC int,  
 @ID int,  
 @ErrMsg varchar(200) output  
as  
begin  
 declare @result int  
 exec @result = DirAlcRcv @SRC, @ID,1  
 return @result  
end 


update netftpgroup set rcvselect='select distinct rcv from ncardtype(nolock) where ntype = 0' where grpid=901


insert into netftpgroupdtl
values(166,167)


DROP procedure AutoSendInvDRpt 
GO
