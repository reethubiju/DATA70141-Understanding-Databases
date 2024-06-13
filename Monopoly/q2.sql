-- NAME: REETHU BIJU
-- USER ID: 11340063


UPDATE Player SET Current_Loc = (Current_Loc+1)%16 WHERE Token='Thimble';