SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[BLPREORDE_NET_RECEIVE]
  (
  @bill_id int,
  @src_id  int,
  @oper char(30),
  @msg  varchar(255) output
  )
  as
  begin
    set nocount on;     
    
    declare @vRnt   int;
    declare @vExv   int;
    declare @vUID   int;
    declare @vZID   int;
    declare @vSrNum char(14);
    declare @vNum   char(14);
    declare @vStat  int;
    
    set @vRnt = 0;
    select @vUID = USERGID, @vZID = ZBGID
      from SYSTEM;
    if @@rowcount = 0
    begin
      set @msg = '门店信息访问出错!';
      return(1);
    end;
             
    if @vUID = @vZID
    begin
      set @msg = '本店是总部，而此单据只能由总部发往门店。拒绝接收。';
      return (1);
    end;
    
    select @vSrNum = NUM
         , @vStat = STAT
      from NBLPREORD
     where [ID] = @bill_id
       and SRC = @src_id;

    if @@rowcount = 0
    begin
      set @msg = '单据不存在。';
      return(1);
    end;

    select @vNum = NUM
      from BLPREORD
     where SRCNUM = @vSrNum;

    if @@rowcount > 0  ---- #### 
    begin
      set @msg = '此单据已经接收，拒绝再次接收。';
      -- Q6402: 如果被拒绝，则自动删除单据
      IF EXISTS (SELECT 1 FROM HDOption WHERE ModuleNo = 0 AND OptionCaption = 'DelNBill' AND OptionValue = 1)
      BEGIN
        delete NBLPREORD
        where [ID] = @bill_id
        and SRC = @src_id
        and NTYPE = 1;

        delete NBLPREORDDTL
        from NBLPREORD mst
        where NBLPREORDDTL.[ID] = mst.[ID]
        and NBLPREORDDTL.SRC = mst.SRC
        and mst.[ID] = @bill_id
        and mst.SRC = @src_id;
      END

      return(1);
    end;

    exec @vRnt = GENNEXTBILLNUM N'', N'BLPREORD', @vNum out;
    
    insert into BLPREORDLOG(NUM, STAT, ACT, MODIFIER, [TIME])	
         values( @vNum, @vStat, 'receive', @vUID, getdate());

    insert into BLPREORD( NUM, STAT, PREORDSET, SRC, PSR, FILDATE, FILLER, CHECKER, CHKDATE 
                        , DEADDATE,LSTUPDTIME ,PRNTIME ,SNDTIME ,SETTLENO,NOTE, RECCNT, SRCNUM)
         select @vNum, STAT, PREORDSET, SRC, PSR, getdate(), @oper, CHECKER, CHKDATE 
              , DEADDATE, LSTUPDTIME, PRNTIME, SNDTIME, SETTLENO, NOTE, RECCNT, NUM
           from NBLPREORD
          where [ID] = @bill_id
            and SRC = @src_id
            and RCV = @vUID
            and NTYPE = 1;

    insert into BLPREORDDTL( NUM, LINE, FLAG
                            , GDGID, MINORDCases, MINORDQTY, ORDPRC, RTLPRC, WHSPRC, NOTE)
         select @vNum, LINE, FLAG
               , GDGID, MINORDCases, MINORDQTY, ORDPRC, RTLPRC, WHSPRC, ndtl.NOTE
           from NBLPREORDDTL ndtl, NBLPREORD nmst
          where ndtl.[ID] = nmst.[ID]
            and ndtl.SRC = nmst.SRC
            and nmst.[ID] = @bill_id
            and nmst.SRC = @src_id
            and RCV = @vUID
            and nmst.NTYPE = 1;

    delete NBLPREORD
     where [ID] = @bill_id
       and SRC = @src_id
       and NTYPE = 1;
    -- and NUM = @vSrNum;

    delete NBLPREORDDTL
      from NBLPREORD mst
     where NBLPREORDDTL.[ID] = mst.[ID]
       and NBLPREORDDTL.SRC = mst.SRC
       and mst.[ID] = @bill_id
       and mst.SRC = @src_id;
    -- and mst.NUM = @vSrNum;

    return (0);
  end
GO
