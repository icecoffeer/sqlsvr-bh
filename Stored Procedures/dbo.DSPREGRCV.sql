SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DSPREGRCV]
	@src_gid int,
	@id int,
	@new_oper int
as
begin
	declare
        	@return_status int,         @src_num char(10),
                @src_stat smallint,         @src_fildate datetime,
		@local_num char(10),
		@temp_id int,               @max_num char(10),
                @localnum char(10),
		@neg_num char(10),          @line smallint,
                @dspqty money,              @bckqty money,
                @dsptotal money,            @bcktotal money,
                @src_dspnum char(10)

        if not exists(select * from NDSPREG where ID = @id and SRC = @src_gid)
	begin
		raiserror('单据已被接收或删除', 16, 1)
      -- Q6402: 网络单据接收时被拒绝自动删除单据
      IF EXISTS (SELECT 1 FROM HDOption WHERE ModuleNo = 0 AND OptionCaption = 'DelNBill' AND OptionValue = 1)
      BEGIN
        delete from NDSPREGDTL where ID = @id and SRC = @src_gid
        delete from NDSPREG where ID = @id and SRC = @src_gid
      END
		return(1)
	end

        if (@src_gid = (select USERGID from SYSTEM)) or (@src_gid = 1)
	begin
		raiserror('不能接收本单位生成的单据', 16, 1)
		return(1)
	end

	select
		@src_num = NUM,
                @src_dspnum = DSPNUM
	from NDSPREG where ID = @id and SRC = @src_gid

	if exists(select * from DSPREG where SRCNUM = @src_num AND SRC = @src_gid)
        begin
		delete from NDSPREGDTL where ID = @id and SRC = @src_gid
		delete from NDSPREG where ID = @id and SRC = @src_gid
		return(0)
	end

        if not exists(select * from DSP where srcnum = @src_dspnum and src = @src_gid)
        begin
        	raiserror('此单据对应的提货单没有接收过', 16, 1)
		return(1)
        end

	--//下面处理第一次接收此单据的情况
	execute @return_status = DSPREGINSLOCBILL @src_gid, @id, @new_oper, @neg_num output
	if @return_status = 1
	begin
		raiserror('本单位没有此单据中的员工资料', 16, 1)
		return(1)
	end
	else if @return_status = 2
	begin
		raiserror('本单位没有此单据中的商品资料', 16, 1)
		return(1)
	end
end
GO
