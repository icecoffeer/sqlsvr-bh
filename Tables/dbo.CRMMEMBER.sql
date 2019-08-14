CREATE TABLE [dbo].[CRMMEMBER]
(
[GID] [int] NOT NULL,
[CODE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MMBR] [int] NULL,
[CREATEDATE] [datetime] NOT NULL CONSTRAINT [DF__CRMMEMBER__CREAT__6AA8F4F1] DEFAULT (getdate()),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__CRMMEMBER__SRC__6B9D192A] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__CRMMEMBER__LSTUP__6C913D63] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMMEMBER__FILLE__6D85619C] DEFAULT (1),
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMMEMBER__MODIF__6E7985D5] DEFAULT (1),
[ENGNAME] [char] (60) COLLATE Chinese_PRC_CI_AS NULL,
[IDCARD] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[SEX] [char] (2) COLLATE Chinese_PRC_CI_AS NULL,
[BIRTH] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[AGE] [int] NULL CONSTRAINT [DF__CRMMEMBER__AGE__6F6DAA0E] DEFAULT (0),
[AGESCOPE] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[BUSINESSTYPE] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[COMPANY] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[BUSINESS] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[FAMILIES] [int] NULL,
[INCOME] [int] NULL,
[MONTHINCOME] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[HOBBY] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[TRAFFIC] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[TRANSACTOR] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[WEDLOCK] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[WEDDINGDAY] [datetime] NULL,
[FAVCOLOR] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[OTHERCARD] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[ZIP] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[ADDRESS] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[ZIP2] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[ADDR2] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[TELE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[TEL2] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[EMAILADR] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[MOBILEPHONE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[BP] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[FAX] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[WWWADR] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[LASTTIME] [datetime] NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMMEMBER__TOTAL__7061CE47] DEFAULT (0),
[FAVAMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMMEMBER__FAVAM__7155F280] DEFAULT (0),
[TLCNT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CRMMEMBER__TLCNT__724A16B9] DEFAULT (0),
[TLGD] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CRMMEMBER__TLGD__733E3AF2] DEFAULT (0),
[BALANCE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMMEMBER__BALAN__74325F2B] DEFAULT (0),
[BACKBUYTOTAL] [decimal] (24, 2) NULL CONSTRAINT [DF__CRMMEMBER__BACKB__75268364] DEFAULT (0),
[CDTLMT] [decimal] (24, 2) NULL,
[STAT] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[STATNOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[TYPE] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[TYPENOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[EXPERIENCE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[DEGREE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CHILDRENNUMBER] [int] NULL,
[SPOUSENAME] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[SPOUSEAGE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[SPOUSEBIRTH] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SPOUSEMOBILEPHONE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[SPOUSECOMPANY] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[SPOUSEBUSINESS] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SPOUSEEXPERIENCE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[SPOUSEBUSINESSTYPE] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[SPOUSEDEGREE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CHILDNAME] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[CHILDAGE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CHILDSEX] [char] (2) COLLATE Chinese_PRC_CI_AS NULL,
[CHILDBIRTH] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[CHILDSCHOOL] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[CHILDGRADE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[OTHERMEMBER] [char] (60) COLLATE Chinese_PRC_CI_AS NULL,
[HOUSETYPE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CARQUANTITY] [int] NULL,
[CARTYPE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CARCOLOR] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[CARNUMBER] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[CARUSAGE] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create trigger [dbo].[PCRM_MEMBER_DLT] on [dbo].[CRMMEMBER] for delete as
begin
  declare @vGid int
  
  if exists(select * from deleted where GID = 1)
  begin
    rollback transaction
    raiserror('不能删除系统设定的记录', 16, 1)
    return
  end
  select @vGid = Gid from deleted
  update CRMMember set LstUpdTime = Getdate() where Gid = @vGid
  update CRMMemberH set LstUpdTime = Getdate() where Gid = @vGid
end
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create trigger [dbo].[PCRM_MEMBER_INS] on [dbo].[CRMMEMBER] for insert as
begin
  declare @vCode varchar(20)
  declare @vName varchar(50)
  declare @vModifier varchar(70)
  declare @vLeft int
  declare @vRight int
  declare @vGid int
  declare @vMemberGid int
  
  select @vModifier = Modifier from inserted
  select @vMemberGid = Gid from inserted
  set @vLeft = Charindex('[', @vModifier)
  set @vRight = Charindex(']', @vModifier)
  set @vName = Substring(@vModifier, 1, @vLeft - 1)
  set @vCode = Substring(@vModifier, @vLeft + 1, @vRight - @vLeft - 1)
  select @vGid = Gid from employee(nolock) where Code = @vCode and Name = @vName
  
  
  insert into InfoChgLog(TableName, Gid, FilDate, FieldLabel, Content)
    values('CRMMEMBER', @vGid, getdate(), '新增记录', '新增会员：' + Convert(varchar(20), @vMemberGid))
  
  insert into CRMMEMBERH select * from inserted
end
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create trigger [dbo].[PCRM_MEMBER_UPD] on [dbo].[CRMMEMBER] for update as
begin
  declare @vCode varchar(20)
  declare @vName varchar(50)
  declare @vModifier varchar(70)
  declare @vLeft int
  declare @vRight int
  declare @vGid int
  declare @vIDCard varchar(30)
  declare @vNewIDCard varchar(30)
  declare @vMemberGid int
  declare @vFieldLabel varchar(50)
  
  select @vIDCard = IDCard from deleted
  select @vNewIDCard = IDCard from inserted 
  select @vMemberGid = Gid from inserted
  if @vIDCard <> @vNewIDCard 
  begin
    select @vModifier = Modifier from inserted
    set @vLeft = Charindex('[', @vModifier)
    set @vRight = Charindex(']', @vModifier)
    set @vName = Substring(@vModifier, 1, @vLeft - 1)
    set @vCode = Substring(@vModifier, @vLeft + 1, @vRight - @vLeft - 1)
    select @vGid = Gid from employee(nolock) where Code = @vCode and Name = @vName
    
    exec GetFieldName 'CRMMEMBER', 'IDCARD', @vFieldLabel output
    insert into InfoChgLog(TableName, Gid, FilDate, FieldLabel, OldValue, NewValue, Content)
      values('CRMMEMBER', @vGid, Getdate(), @vFieldLabel, @vIDCard, @vNewIDCard, '修改会员：' + Convert(varchar(30), @vMemberGid)) 			
  end
  
  delete from CRMMEMBERH from deleted where CRMMEMBERH.GID = deleted.GID
  insert into CRMMEMBERH select * from inserted
end
GO
ALTER TABLE [dbo].[CRMMEMBER] ADD CONSTRAINT [PK__CRMMEMBER__761AA79D] PRIMARY KEY CLUSTERED  ([GID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_MEMBER_CODE] ON [dbo].[CRMMEMBER] ([CODE]) ON [PRIMARY]
GO
