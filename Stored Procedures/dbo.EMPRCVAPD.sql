SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[EMPRCVAPD](
    @p_src int,
    @p_id int
) with encryption as
begin
    declare
    @n_gid int

    select @n_gid = Gid
        from NEMPLOYEE
        where Src = @p_src and id = @p_id
    if exists (select * from EMPLOYEEH where Gid = @n_gid)
        delete from EMPLOYEEH where Gid = @n_gid
    insert into EMPLOYEE(
        Gid, Code, Name, IDCard, WorkType,
        Discount, CreateDate, LocalRight, LocalExtraRight,
        Memo, Src, SndTime, LstUpdTime, ISUSETOKEN, ISSPECLIM)--zz 081231
        select
            Gid, Code, Name, IDCard, WorkType,
            Discount, CreateDate, LocalRight, LocalExtraRight,
            Memo, Src, null, getdate(), ISUSETOKEN, ISSPECLIM--zz 081231
            from NEMPLOYEE
            where Src = @p_src and Id = @p_id
    return(0)
end
GO
