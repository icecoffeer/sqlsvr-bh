CREATE TABLE [dbo].[buy_ret_req_photos]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[file_path] [varchar] (200) COLLATE Chinese_PRC_CI_AS NOT NULL,
[owner] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[buy_ret_req_photos] ADD CONSTRAINT [PK__buy_ret___7F42793046F2A8CE] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
