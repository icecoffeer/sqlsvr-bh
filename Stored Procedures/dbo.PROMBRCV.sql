SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PROMBRCV]
(
	@SRC	INT,
	@Id 	INT,
	@MSG	VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @ret_status  int,
    @n_type smallint,
    @cnt int

    select @ret_status = 0
    select @n_type = Type
    from NPROMB where Src = @SRC and Id = @Id
    if @@RowCount < 1
    begin
        raiserror('未找到指定组合促销单', 16, 1)
        return(2)
    end
    
    select *
    from NPROMBGOODS where Src = @SRC and Id = @Id
    if @@RowCount < 1
    begin
        raiserror('未找到指定组合促销单商品', 16, 1)
        return(2)
    end
    
    select *
    from NPROMBDIS where Src = @SRC and Id = @Id
    if @@RowCount < 1
    begin
        raiserror('未找到指定组合促销优惠折扣表', 16, 1)
        return(2)
    end
        
    if @n_type <> 1
    begin
        raiserror('不是可接收单据', 16, 1)
        return(3)
    end

    select @cnt = sum(case when X.LGid is null then 1 else 0 end)
        from NPRCPRMDTL N, GDXLATE X
        where N.Src = @SRC and N.Id = @ID and
            N.GdGid *= X.NGid
    if @cnt > 0
    begin
        raiserror('本地未包含商品资料', 16, 1)
        return(5)
    end

    EXEC @ret_status = RCVONEPROMB @SRC, @ID, '交换服务', @MSG
    IF @ret_status <> 0 RETURN(@ret_status)
    RETURN(0)
END
GO
