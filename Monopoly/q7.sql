-- NAME: REETHU BIJU
-- USER ID: 11340063


UPDATE Player SET Current_Loc = (Current_Loc+6)%16 WHERE Token='Battleship';
UPDATE Player SET Current_Loc = (Current_Loc+5)%16 WHERE Token='Battleship';