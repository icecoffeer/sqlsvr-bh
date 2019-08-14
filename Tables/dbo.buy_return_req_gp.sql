CREATE TABLE [dbo].[buy_return_req_gp]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[file_path] [varchar] (200) COLLATE Chinese_PRC_CI_AS NOT NULL,
[goods] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[buy_return_req_gp] ADD CONSTRAINT [PK__buy_retu__7F4279301CFC6F02] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
