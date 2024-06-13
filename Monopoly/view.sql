-- NAME: REETHU BIJU
-- USER ID: 11340063

--Display the name, token Properties_Owned, Balance and Current Location in the form of View.
DROP VIEW IF EXISTS gameView;
CREATE VIEW gameView AS
SELECT
    Player.Name,
    Player.Token,
	GROUP_CONCAT(Ownership.Property_Name, ', ') AS Properties_Owned,
    Bank.Balance,

    CASE
        WHEN LocPlayer.Property_Name IS NOT NULL THEN LocPlayer.Property_Name
        ELSE BonusPlayer.Name
    END AS "Current Location"
FROM Player
JOIN Ownership ON Player.Player_ID = Ownership.Player_ID
JOIN Bank ON Player.Player_ID = Bank.Player_ID
LEFT JOIN (
    SELECT Player.Player_ID, Location.Property_Name
    FROM Location
    INNER JOIN Player ON Location.Loc_ID = Player.Current_Loc
) AS LocPlayer ON Player.Player_ID = LocPlayer.Player_ID
LEFT JOIN (
    SELECT Player.Player_ID, Bonus.Name
    FROM Bonus
    INNER JOIN Location ON Location.Bonus_ID = Bonus.Bonus_ID
    INNER JOIN Player ON Location.Loc_ID = Player.Current_Loc
) AS BonusPlayer ON Player.Player_ID = BonusPlayer.Player_ID
GROUP BY Player.Token
ORDER BY Bank.Balance DESC;

SELECT * FROM gameView;

