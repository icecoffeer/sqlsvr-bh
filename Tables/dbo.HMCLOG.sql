CREATE TABLE [dbo].[HMCLOG]
(
[TYPE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MEMO] [text] COLLATE Chinese_PRC_CI_AS NULL,
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HMCLOG] ADD CONSTRAINT [PK__HMCLOG__1CF6DFA1] PRIMARY KEY CLUSTERED  ([TYPE], [OPER], [TIME]) ON [PRIMARY]
GO
