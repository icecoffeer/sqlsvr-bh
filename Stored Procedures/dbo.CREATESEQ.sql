SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CREATESEQ](
	@pi_objname char(32),		--对象名称
	@pi_startvalue int = 1,		--起始值
	@pi_step int = 1			--步长
)with encryption as
begin
	declare @ret int
    select @ret=1

    exec SEQEXISTS @pi_objname,@ret output

    if @ret<> 1
        insert into seq values(@pi_objname,@pi_startvalue,@pi_step)
    else
    begin
        --raiserror('指定的SEQUENCE已经存在', 16, 1)
        print 'WARNING: 指定的SEQUENCE已经存在'
        return(1)
    end
end
GO
