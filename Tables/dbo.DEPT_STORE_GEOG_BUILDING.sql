CREATE TABLE [dbo].[DEPT_STORE_GEOG_BUILDING]
(
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BUILDINGAREA] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__DEPT_STOR__BUILD__2C72F165] DEFAULT (0),
[USABLEAREA] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__DEPT_STOR__USABL__2D67159E] DEFAULT (0),
[RENTALAREA] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__DEPT_STOR__RENTA__2E5B39D7] DEFAULT (0),
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CREATIONTIME] [datetime] NOT NULL CONSTRAINT [DF__DEPT_STOR__CREAT__2F4F5E10] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__DEPT_STOR__LSTUP__30438249] DEFAULT (getdate()),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DEPT_STORE_GEOG_BUILDING] ADD CONSTRAINT [PK__DEPT_STORE_GEOG___3137A682] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
