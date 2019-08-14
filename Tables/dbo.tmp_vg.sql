CREATE TABLE [dbo].[tmp_vg]
(
[gdgid] [int] NULL,
[qty] [money] NULL,
[inprc] [money] NULL,
[rtlprc] [money] NULL,
[gcode] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[gname] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[vcode] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[vname] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
