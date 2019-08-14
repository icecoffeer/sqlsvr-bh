SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[TaxSortAdj_To800]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @MSG VARCHAR(255) OUTPUT
)
As
Begin
	declare @stat int, @eon int, @launch datetime, @Store int, @UserGid int 
	declare @GDGID integer, @NEWTAXSORT int
	
	select @stat = stat, @launch = launch, @eon = eon from TaxSortAdj where num = @Num
	if @stat <> 100
	begin
		set @MSG = '不能生效不是审核的单据'
		return 1
	end
	Select @UserGid = UserGid From System
  
  	declare c_taxsortadjdtl scroll cursor for
		select GDGID, NEWTAXSORT from TaxSortAdjDtl
			where num = @num order by line asc for update
    open c_taxsortadjdtl
	if @eon = 1
	begin
		fetch first from c_taxsortadjdtl into @gdgid, @NEWTAXSORT 
		while @@fetch_status = 0
		begin
			exec TaxSortAdj_To800_Single @NUM, @UserGid, @UserGid, @gdgid, @NEWTAXSORT
			fetch next from c_taxsortadjdtl into @gdgid, @NEWTAXSORT
		end
	end
	
	declare c_taxsortadjlacdtl cursor for
		select STOREGID from TaxSortAdjLacDtl
			where num = @num 
    open c_taxsortadjlacdtl 
	fetch next from c_taxsortadjlacdtl into @Store   
	while @@fetch_status = 0
	begin
	   	fetch first from c_taxsortadjdtl into @gdgid, @NEWTAXSORT 
		while @@fetch_status = 0
		begin
			exec TaxSortAdj_To800_Single @NUM, @Store, @UserGid, @gdgid, @NEWTAXSORT
			fetch next from c_taxsortadjdtl into @gdgid, @NEWTAXSORT
		end
		fetch next from c_taxsortadjlacdtl into @Store
	end	
	close c_taxsortadjlacdtl
	deallocate c_taxsortadjlacdtl

   	close c_taxsortadjdtl
	deallocate c_taxsortadjdtl
	 
	update TaxSortAdj set stat = 800,LstUpdTime = Getdate(), checker = @oper,
		chkdate = getdate()
	where num = @num
  
    exec TaxSortAdj_ADD_LOG @num, 800, @OPER
  
    return 0
End
GO
