SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[VOUTDRPT]
AS
SELECT ASTORE, ASETTLENO, ADATE, BGDGID, BWRH, SUM(DQ1) AS DQ1, SUM(DQ2) 
      AS DQ2, SUM(DQ3) AS DQ3, SUM(DQ4) AS DQ4, SUM(DQ5) AS DQ5, SUM(DQ6) 
      AS DQ6, SUM(DQ7) AS DQ7, SUM(DT1) AS DT1, SUM(DT2) AS DT2, SUM(DT3) AS DT3, 
      SUM(DT4) AS DT4, SUM(DT5) AS DT5, SUM(DT6) AS DT6, SUM(DT7) AS DT7, 
      SUM(DT91) AS DT91, SUM(DT92) AS DT92, SUM(DI1) AS DI1, SUM(DI2) AS DI2, 
      SUM(DI3) AS DI3, SUM(DI4) AS DI4, SUM(DI5) AS DI5, SUM(DI6) AS DI6, SUM(DI7) 
      AS DI7, SUM(DR1) AS DR1, SUM(DR2) AS DR2, SUM(DR3) AS DR3, SUM(DR4) 
      AS DR4, SUM(DR5) AS DR5, SUM(DR6) AS DR6, SUM(DR7) AS DR7
FROM dbo.OUTDRPT
WHERE (ASETTLENO >
          (SELECT (CONVERT(FLOAT,
                   (SELECT MAX(ASETTLENO)
                  FROM OUTDRPT))) - 2))
GROUP BY ASTORE, ASETTLENO, ADATE, BGDGID, BWRH
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "OUTDRPT"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 109
               Right = 188
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 240
      Begin ColumnWidths = 36
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'VOUTDRPT', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'VOUTDRPT', NULL, NULL
GO
