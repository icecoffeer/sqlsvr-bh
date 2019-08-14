SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CHQSNDSORT](
	@OPERGID INT,
	@MSG VARCHAR(255) OUTPUT
) as
begin
  declare @GROUPID INT,     @NTYPE SMALLINT,    @NNOTE varchar(100),
          @EXTIME DATETIME, @RHQUUID CHAR(32),  @NSTAT SMALLINT
  --exec OPTREADINT 0, '...', 0, @optvalue output
  exec @GROUPID = SeqNextValue 'CHQBASIC'
  set @RHQUUID = '1'
  set @NTYPE = 0
  set @NNOTE = ''
  set @NSTAT = 0
  set @EXTIME = Getdate()
  insert into CQNSORT(GROUPID, RHQUUID, NTYPE, NSTAT, NNOTE, EXTIME, 
      CODE, NAME, GDCOUNT)
    select @GROUPID, @RHQUUID, @NTYPE, @NSTAT, @NNOTE, @EXTIME, 
      CODE, NAME, GDCOUNT
    from SORT(nolock)
end;
GO
