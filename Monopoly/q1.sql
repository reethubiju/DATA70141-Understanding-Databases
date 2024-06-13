-- NAME: REETHU BIJU
-- USER ID: 11340063



--Update the Bank Balance on buying a propert. If Player doesn't have enough balance, Player is declared to be bankrupt and removed from the table.
DROP TRIGGER IF EXISTS BuyProperty;
CREATE TRIGGER BuyProperty
AFTER INSERT ON Ownership
BEGIN

--First we check if Balance is greater than the Cost if the property, Then we update the balance with cost reduced.
UPDATE Bank SET Balance=
CASE
	WHEN ((SELECT Balance FROM Bank WHERE Bank.Player_ID=NEW.Player_ID)>(SELECT Cost FROM Property WHERE Property.Name=NEW.Property_Name))
		THEN (SELECT Balance-Cost FROM Bank,Property WHERE Property.Name=NEW.Property_Name AND Bank.Player_ID=NEW.Player_ID)
	ELSE 0
END
WHERE Player_ID=NEW.Player_ID;

--Delete the record of the player if bankrupt.
DELETE FROM Ownership
WHERE Player_ID IN (SELECT Player_ID FROM Bank WHERE Balance<=0);

DELETE FROM Bank
WHERE Balance<=0;

DELETE FROM Player 
WHERE Player_ID NOT IN (SELECT Player_ID FROM Bank);

END;


--If the player is already in Jail and rolls a 6, this trigger gets executed. Sets the location of the player back to jail but the Bonus_Owned gets assigned to NULL.
DROP TRIGGER IF EXISTS Jail;
CREATE TRIGGER Jail
AFTER UPDATE ON Player
WHEN NEW.Current_Loc-OLD.Current_Loc=6  AND NEW.Bonus_Owned=8
BEGIN

UPDATE Player SET Bonus_Owned=NULL, Current_Loc=4, Round=NEW.Round-1 WHERE Player_ID=NEW.Player_ID;

END;


--If the player rolls a 6 and passes Go, This updates the bank with an addition of 200
DROP TRIGGER IF EXISTS RollDiceAgain;
CREATE TRIGGER RollDiceAgain
AFTER UPDATE ON Player
WHEN  OLD.Current_Loc-NEW.Current_Loc=10 AND NEW.Current_Loc<OLD.Current_Loc 
BEGIN

UPDATE Bank 
SET Balance= Balance+200
WHERE Player_ID=NEW.Player_ID;

END;


--This is the main trigger. Gets executed if the player does not roll a 6.
DROP TRIGGER IF EXISTS Play;
CREATE TRIGGER Play
AFTER UPDATE ON Player
WHEN ((NEW.Current_Loc-OLD.Current_Loc!=6 AND NEW.Current_Loc>OLD.Current_Loc) OR ((OLD.Current_Loc-NEW.Current_Loc!=10) AND NEW.Current_Loc<OLD.Current_Loc))
BEGIN


--Update the Round Number. Increment by 1 for every round of the player.
UPDATE Player SET Round= NEW.Round+1 WHERE Token=OLD.Token;


--Update the Balance of the Player on passing GO and making sure the PLayer has not landed on 'Jail'
UPDATE Bank SET Balance=
CASE
	WHEN NEW.Current_Loc < OLD.Current_Loc AND OLD.Current_Loc-NEW.Current_Loc!=10 AND NEW.Current_Loc!=4 
		THEN (SELECT Balance+200 FROM Bank WHERE Bank.Player_ID IN (SELECT Player_ID FROM Player WHERE Token=OLD.Token))
	ELSE (SELECT Balance FROM Bank WHERE Bank.Player_ID IN (SELECT Player_ID FROM Player WHERE Token=OLD.Token))
END
WHERE Player_ID IN (SELECT Player_ID FROM Player WHERE Token=OLD.Token);

--Update the location to Jail if the Player lands on Go To Jail and set the Bonus_Owned to 8, so that next round, only when the player rolls a 6 the Jial trigger gets executed.
UPDATE Player SET Current_Loc=
CASE
	WHEN NEW.Current_Loc=12 
		THEN 4
	ELSE NEW.Current_Loc
END,
Bonus_Owned=8
WHERE Token=OLD.Token;

--If Player lands on a Property not owned by anoyone, then buys it
--Checks if the propert the player is on is present in the Ownership table. If no then Insert query will take place, after which the BuyProperty trigger gets initiated.
INSERT INTO Ownership(Player_ID,Property_Name)
SELECT Player.Player_ID,Location.Property_Name
FROM Player, Location
WHERE Player.Token=OLD.Token AND Player.Current_Loc=Location.Loc_ID AND Location.Bonus_ID IS NULL 
	AND Location.Property_Name NOT IN (SELECT Property_Name FROM Ownership);
	
--IF Player lands on a Property Owned By some other player then Player pays the Rent
--Deduct the rent from player's bank balance
UPDATE Bank SET Balance=Balance-
CASE 
	-- The condition here is, we find the owner's ID and and choose all the properties he owns which is of the same colour as the current property. If it is 2 the first condition gets executed, where double the rent is to be paid.
	WHEN
		(SELECT COUNT(Colour) FROM Property INNER JOIN Ownership
		ON Ownership.Property_Name=Property.Name
		WHERE Ownership.Player_ID IN 
			(SELECT Player_ID FROM Ownership WHERE Property_Name IN 
				(SELECT Property_Name FROM Player INNER JOIN Location ON Loc_ID=Current_Loc WHERE Loc_ID=NEW.Current_Loc))AND 
			Property.Colour IN (SELECT Colour FROM Property WHERE Name IN 
				(SELECT Property_Name FROM Player INNER JOIN Location ON Current_Loc=Loc_ID WHERE Loc_ID=NEW.Current_Loc )))=2        -- Checks if Properties of same color owned is 2
		
		THEN
			(SELECT Cost FROM Property WHERE Name IN (
				SELECT Property_Name FROM Player INNER JOIN Location 
				ON Loc_ID=Current_Loc 
				WHERE Loc_ID=NEW.Current_Loc))*2

	WHEN
		(SELECT COUNT(Colour) FROM Property INNER JOIN Ownership
		ON Ownership.Property_Name=Property.Name
		WHERE Ownership.Player_ID IN 
			(SELECT Player_ID FROM Ownership WHERE Property_Name IN 
				(SELECT Property_Name FROM Player INNER JOIN Location ON Loc_ID=Current_Loc WHERE Loc_ID=NEW.Current_Loc))AND 
			Property.Colour IN (SELECT Colour FROM Property WHERE Name IN 
				(SELECT Property_Name FROM Player INNER JOIN Location ON Current_Loc=Loc_ID WHERE Loc_ID=NEW.Current_Loc )))=1       -- Checks if Properties of same color owned is 1
		
		THEN
			(SELECT Cost FROM Property WHERE Name IN (
				SELECT Property_Name FROM Player INNER JOIN Location 
				ON Loc_ID=Current_Loc 
				WHERE Loc_ID=NEW.Current_Loc))
				
		ELSE 0
		
END
WHERE Player_ID=NEW.Player_ID;

--Update the Rent from the Player that just paid. If the player does not have enough balance to pay the rent completely, it is assumed that the bank will pay for the owner and the player is declared bankrupt.
UPDATE Bank SET Balance=Balance+
CASE 

	-- The same condition as above is used to check if number of properties of same colour is 2. If yest then double the rent is received to the owner.
	WHEN
		(SELECT COUNT(Colour) FROM Property INNER JOIN Ownership
		ON Ownership.Property_Name=Property.Name
		WHERE Ownership.Player_ID IN 
			(SELECT Player_ID FROM Ownership WHERE Property_Name IN 
				(SELECT Property_Name FROM Player INNER JOIN Location ON Loc_ID=Current_Loc WHERE Loc_ID=NEW.Current_Loc))AND 
			Property.Colour IN (SELECT Colour FROM Property WHERE Name IN 
				(SELECT Property_Name FROM Player INNER JOIN Location ON Current_Loc=Loc_ID WHERE Loc_ID=NEW.Current_Loc )))=2    -- Checks if Properties of same color owned is 2
		
		THEN
			(SELECT Cost FROM Property WHERE Name IN (
				SELECT Property_Name FROM Player INNER JOIN Location 
				ON Loc_ID=Current_Loc 
				WHERE Loc_ID=NEW.Current_Loc))*2

	WHEN
		(SELECT COUNT(Colour) FROM Property INNER JOIN Ownership
		ON Ownership.Property_Name=Property.Name
		WHERE Ownership.Player_ID IN 
			(SELECT Player_ID FROM Ownership WHERE Property_Name IN 
				(SELECT Property_Name FROM Player INNER JOIN Location ON Loc_ID=Current_Loc WHERE Loc_ID=NEW.Current_Loc))AND 
			Property.Colour IN (SELECT Colour FROM Property WHERE Name IN 
				(SELECT Property_Name FROM Player INNER JOIN Location ON Current_Loc=Loc_ID WHERE Loc_ID=NEW.Current_Loc )))=1    -- Checks if Properties of same color owned is 1
		
		THEN
			(SELECT Cost FROM Property WHERE Name IN (
				SELECT Property_Name FROM Player INNER JOIN Location 
				ON Loc_ID=Current_Loc 
				WHERE Loc_ID=NEW.Current_Loc))
				
		ELSE 0
		
END
-- To find the owner we select the Player ID from Ownership table where the Location ID is same as the Current location ID.
WHERE Player_ID IN (SELECT Player_ID FROM Ownership WHERE Property_Name IN (SELECT Property_Name FROM Player INNER JOIN Location ON Loc_ID=Current_Loc WHERE Loc_ID=NEW.Current_Loc));
				

--Assigning the bonus token if a player lands on a bonus (Chance 1, Chance 2, Community Chest 1, Community Chest 2)
UPDATE Player 
SET Bonus_Owned = (SELECT Bonus_ID FROM Player INNER JOIN Location ON Loc_ID=Current_Loc WHERE Loc_ID=NEW.Current_Loc AND Bonus_ID NOT NULL AND Bonus_ID IN (1,2,3,4))
WHERE Player_ID IN (SELECT Player_ID FROM Player WHERE Current_Loc=NEW.Current_Loc);

--Executing Bonuses
--Reducing the balance if Chance 1 
--When isPay is 2, it means that the player has to pay the amount to other players. When isPay is 1 it means the player has to pay the Bank. When isPay is 0 the player has to receive the amount from the bank
UPDATE Bank SET Balance=Balance- 
CASE
	WHEN (SELECT isPay FROM Bonus WHERE Bonus_ID IN (SELECT Bonus_Owned FROM Player WHERE Player_ID=NEW.Player_ID))=2
		THEN ((SELECT Amount FROM Bonus WHERE Bonus_ID IN (SELECT Bonus_Owned FROM Player WHERE Player_ID=NEW.Player_ID))*(SELECT COUNT(Player_ID) FROM Bank))
		
	ELSE 0	
END
WHERE Player_ID=NEW.Player_ID;

--Paying the other players the amount from Chance 1
UPDATE Bank 
SET Balance= Balance+
CASE
	WHEN (SELECT isPay FROM Bonus WHERE Bonus_ID IN (SELECT Bonus_Owned FROM Player WHERE Player_ID=NEW.Player_ID)) = 2
		THEN (SELECT Amount FROM Bonus WHERE Bonus_ID IN (SELECT Bonus_Owned FROM Player WHERE Player_ID=NEW.Player_ID))
	ELSE 0
END
WHERE Player_ID NOT IN (NEW.Player_ID);

--Reducing the balance if Community Chest 2 
UPDATE Bank SET Balance=Balance- 
CASE
	WHEN (SELECT isPay FROM Bonus WHERE Bonus_ID IN (SELECT Bonus_Owned FROM Player WHERE Player_ID=NEW.Player_ID))=1
		THEN (SELECT Amount FROM Bonus WHERE Bonus_ID IN (SELECT Bonus_Owned FROM Player WHERE Player_ID=NEW.Player_ID))
	ELSE 0	
END
WHERE Player_ID=NEW.Player_ID;

--Paying the player from Community Chest 1
UPDATE Bank 
SET Balance= Balance+
CASE
	WHEN (SELECT Amount FROM Bonus WHERE Bonus_ID IN (SELECT Bonus_Owned FROM Player WHERE Player_ID=NEW.Player_ID)) IS NOT NULL
		THEN (SELECT Amount FROM Bonus WHERE Bonus_ID IN (SELECT Bonus_Owned FROM Player WHERE Player_ID=NEW.Player_ID))
	ELSE 0
END
WHERE Player_ID=NEW.Player_ID;

--Moving the player by 3 locations from Chance 2
-- Forward has the number of steps the player has to move forward.
UPDATE Player 
SET Current_Loc= Current_Loc+
CASE
	WHEN (SELECT Forward FROM Bonus WHERE Bonus_ID IN (SELECT Bonus_Owned FROM Player WHERE Player_ID=NEW.Player_ID))!=0
		THEN (SELECT Forward FROM Bonus WHERE Bonus_ID IN (SELECT Bonus_Owned FROM Player WHERE Player_ID=NEW.Player_ID))
	ELSE 0
END
WHERE Player_ID=NEW.Player_ID;

--AUDIT TRAIL
--Insert the values into the table after the player finishes their game.
INSERT INTO Audit_Trail(Player_ID,Name,Token,Round,Balance,Current_Loc)
SELECT Player.Player_ID,Player.Name,Player.Token,Player.Round,Bank.Balance,Player.Current_Loc
FROM Player,Bank
WHERE Player.Player_ID=NEW.Player_ID AND Bank.Player_ID=NEW.Player_ID;


--If Player is bankrupt then removed from the game	
DELETE FROM Ownership
WHERE Player_ID IN (SELECT Player_ID FROM Bank WHERE Balance<=0);

DELETE FROM Bank
WHERE Balance<=0;

DELETE FROM Player 
WHERE Player_ID NOT IN (SELECT Player_ID FROM Bank);


END;



--Gameplay 1 (The % operator is a way of incrementing the location of the player)
UPDATE Player SET Current_Loc = (Current_Loc+3)%16	 WHERE Token='Car';


