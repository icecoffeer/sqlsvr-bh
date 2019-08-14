CREATE TABLE [dbo].[buy_ret_req_line]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[line_no] [int] NULL,
[remark] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[amount] [numeric] (19, 4) NULL,
[buy_return_req] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[fav_amt] [numeric] (19, 4) NULL,
[gd_code] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[gd_name] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[gid] [numeric] (19, 0) NOT NULL,
[price] [numeric] (19, 6) NULL,
[qty] [numeric] (19, 4) NULL,
[real_amt] [numeric] (19, 2) NULL,
[reason] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[refused_reason] [varchar] (765) COLLATE Chinese_PRC_CI_AS NULL,
[returned_qty] [numeric] (19, 4) NULL,
[sale_qty] [numeric] (19, 4) NULL,
[src_item_no] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[buy_ret_req_line] ADD CONSTRAINT [PK__buy_ret___7F4279304AC339B2] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
