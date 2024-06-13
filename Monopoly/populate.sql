-- NAME: REETHU BIJU
-- USER ID: 11340063


INSERT INTO Property VALUES
('Oak House', 100, 'Orange'),
('Owens Park', 30, 'Orange'),
('AMBS', 400, 'Blue'),
('Co-Op', 30, 'Blue'),
('Kilburn', 120, 'Yellow'),
('Uni Place', 100, 'Yellow'),
('Victoria', 75, 'Green'),
('Piccadilly', 35, 'Green');

INSERT INTO Bonus VALUES
(1, 'Chance 1', 50, 2, 0),
(2, 'Chance 2', 0, 0, 3),
(3, 'Community Chest 1', 100, 0, 0),
(4, 'Community Chest 2', 30, 1, 0),
(5, 'Free Parking', 0, 0, 0),
(6, 'Go to Jail', 0, 0, 0),
(7, 'Go', 200, 0, 0),
(8, 'In Jail', 0, 0, 0);

INSERT INTO Location VALUES
(0, NULL, 7),
(1, 'Kilburn', NULL),
(2, NULL, 1),
(3, 'Uni Place', NULL),
(4, NULL, 8),
(5, 'Victoria', NULL),
(6, NULL, 3),
(7, 'Piccadilly', NULL),
(8, NULL, 5),
(9, 'Oak House', NULL),
(10, NULL, 2),
(11, 'Owens Park', NULL),
(12, NULL, 6),
(13, 'AMBS', NULL),
(14, NULL, 4),
(15, 'Co-Op', NULL);

INSERT INTO Player VALUES
(1, 'Mary', 'Battleship', 0, 8, NULL),
(2, 'Bill', 'Dog', 0, 11, NULL),
(3, 'Jane', 'Car', 0, 13, NULL),
(4, 'Norman', 'Thimble', 0, 1, NULL);

INSERT INTO Bank VALUES
(1,190),
(2,500),
(3,150),
(4,250);

INSERT INTO Ownership VALUES
(1, 'Uni Place'),
(2, 'Victoria'),
(3, 'Co-Op'),
(4, 'Oak House'),
(4, 'Owens Park');
 

