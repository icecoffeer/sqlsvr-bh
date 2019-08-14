SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetPayRatebyVdr]
(
  @VdrGid int,
  @Dept varchar(13),
  @Brand varchar(10),
  @PayRate decimal(24,4) output,
  @ErrMsg varchar(255) output
)
as
begin
  declare
    @DeptFlag int,
    @ParentCode varchar(13),
    @DeptCode varchar(13)

  select @DeptFlag = 0;
  select @DeptCode = @Dept;
  select @PayRate = null; --ShenMin

  select @PayRate = PAYRATE
  from VDRLESSORTBRANDINV(nolock)
  where VDRGID = @VdrGid
    and SORT = @DeptCode
    and BRAND = @Brand
  while @PayRate is NULL
    begin
      select @ParentCode = PARENTCODE
      from DEPT(nolock)
      where CODE = @DeptCode
      and DEPTH <> 0
      if @ParentCode is NULL or @ParentCode =  @DeptCode
        set @DeptFlag = 1;
      else
        begin
          set @DeptCode = @ParentCode;
          set @DeptFlag = 0;
        end;
      if @DeptFlag = 1
        break;
      else
        select @PayRate = PAYRATE
        from VDRLESSORTBRANDINV(nolock)
        where VDRGID = @VdrGid
          and SORT = @DeptCode
          and BRAND = @Brand;
    end;
  set @DeptCode = @Dept;
  while @PayRate is NULL
    begin
      select @PayRate = PAYRATE
      from VDRLESSORTDINV(nolock)
      where VDRGID = @VdrGid
        and SORT = @DeptCode
      if @PayRate is not null
        set @DeptFlag = 1;
      else
        begin
          select @ParentCode = PARENTCODE
          from DEPT(nolock)
          where CODE = @DeptCode;
          if @ParentCode is NULL or @ParentCode = @DeptCode
            set @DeptFlag = 1;
          else
            begin
              set @DeptCode = @ParentCode;
              set @DeptFlag = 0;
            end;
          if @DeptFlag = 1
            break;
        end;
    end;
  if @PayRate is null
    select @PayRate = PAYRATE
    from VDRLESSEEINV(nolock)
    where VDRGID = @VdrGid;
  if @PayRate is null
    set @PayRate = 0;
  return(0);
end;
GO
