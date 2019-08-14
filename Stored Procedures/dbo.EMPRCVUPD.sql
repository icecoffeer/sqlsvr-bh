SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[EMPRCVUPD](
    @p_src int,
    @p_id int,
    @p_l_gid int
) with encryption as
begin
    update EMPLOYEE
        set
            Code = N.Code, /*2001-06-09*/
            Name = N.Name, IDCard = N.IDCard, WorkType = N.WorkType,
            Discount = N.Discount, CreateDate = N.CreateDate,
            LocalRight = N.LocalRight,
            LocalExtraRight = N.LocalExtraRight, Memo = N.Memo,
            Src = @p_src, SndTime = null, LstUpdTime = getdate(),ISUSETOKEN = N.ISUSETOKEN,
            ISSPECLIM = N.ISSPECLIM--zz 081231
        from NEMPLOYEE N, EMPLOYEE C
        where C.Gid = @p_l_gid
            and N.Src = @p_src
            and N.Id = @p_Id
    return(0)
end
GO
