SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[V_ORDVENDOR] (
  [VDRGID],
  [DELAYDAY]
) as
SELECT DISTINCT A.GID GID,ISNULL(B.DELAYDAY,0) DELAYDAY  FROM VENDOR A, VDRORDSET B 
WHERE A.GID *= B.VDRGID AND (A.GID NOT IN(SELECT VDRGID FROM VDRORDSET) OR  A.GID IN(
SELECT VDRGID FROM VDRORDSET  
WHERE (ORDUNIT = '月' AND CONVERT(CHAR(2), GETDATE(), 103) = ORDINDEX)   
OR (ORDUNIT = '周' AND  DATENAME(Weekday, getdate()) = '星期'+ ORDINDEX) 
))
GO