DROP TABLE IF EXISTS COMPOSE;
DROP TABLE IF EXISTS PIECE;

-- Création de la table PIECE
CREATE TABLE IF NOT EXISTS PIECE (
    id_piece INT,
    prix_unitaire DECIMAL(5,2) NOT NULL,
    nom_piece VARCHAR(50) NOT NULL,
    description TEXT,
    PRIMARY KEY (id_piece)
);



CREATE TABLE IF NOT EXISTS COMPOSE(
    id_piece_composite INT not NULL,
    id_piece_composees INT not NULL,
    detail_assemblage TEXT,
    PRIMARY KEY (id_piece_composees, id_piece_composite),
    FOREIGN KEY (id_piece_composite) REFERENCES PIECE(id_piece),
    FOREIGN KEY (id_piece_composees) REFERENCES PIECE(id_piece) 
);

INSERT INTO PIECE (id_piece, prix_unitaire, nom_piece, description) VALUES
(1, 15.00, 'Vis en titane', 'Vis en titane utilisées pour l’assemblage'),
(2, 0.50, 'Rivet en aluminium', 'Rivets pour fixer les structures métalliques'),
(3, 50.00, 'Raidisseur en composite', 'Élément structurel renforçant le panneau'),
(4, 100.00, 'Plaque en alliage d’aluminium', 'Plaque utilisée pour la structure du fuselage'),
(5, 500.00, 'Panneau de fuselage', 'Panneau intégrant plusieurs éléments de fixation'),
(6, 200.00, 'Segment de fuselage', 'Section du fuselage intégrant plusieurs panneaux et éléments structurels');


INSERT INTO COMPOSE (id_piece_composite, id_piece_composees, detail_assemblage) VALUES
(5, 1, '8 unités utilisées pour fixer les composants'), -- Pour construire le 5 on utilise le 1,2,3,4 
(5, 2, '20 unités nécessaires pour l’assemblage'),
(5, 3, '4 unités assurant le renfort structurel'),
(5, 4, '1 plaque utilisée comme base du panneau'),
(6, 5, 'Le segment de fuselage intègre le panneau de fuselage comme sous-composant');



-- Requetes SQL

-- 2. Listez tous les noms pi`eces qui sont des composants directs d’une pi`ece compos´eesp´ecifique (ex : ”Panneau de fuselage”) avec leur quantit´e.
SELECT nom_piece 
FROM PIECE 
NATURAL JOIN COMPOSE
WHERE id_piece_composees = id_piece_composite





CREATE VIEW vue_pieces_composees AS
SELECT DISTINCT p.id_piece, p.nom_piece, p.prix_unitaire, p.description
FROM PIECE p
JOIN COMPOSE c ON p.id_piece = c.id_piece_composite;

-- 3. Listez les pi`eces compos´ees tri´ees par le nombre de composants qu’elles contiennent.

select * from vue_pieces_composees
order by (select count(*) from COMPOSE where id_piece_composite = id_piece) desc;

-- 4. Comptez combien de pi`eces compos´ees existent dans la base

select * from vue_pieces_composees


-- 5. Calculez le coˆut total de chaque pi`ece compos´ee en additionnant le prix de ses com-posants directs.
SELECT c.id_piece_composite, 
       p.nom_piece,
       p.prix_unitaire + (
           SELECT SUM(p2.prix_unitaire)
            FROM COMPOSE c2
            JOIN PIECE p2 ON c2.id_piece_composees = p2.id_piece
            WHERE c2.id_piece_composite = c.id_piece_composite
       ) AS cout_total
FROM PIECE p
JOIN COMPOSE c ON p.id_piece = c.id_piece_composite
GROUP BY c.id_piece_composite, p.nom_piece, p.prix_unitaire;






-- 6 trouvez toutes les pi`eces qui entrent dans la fabrication d’une pi`ece compos´ee, directement ou indirectement. La r´eponse est une table qui, pour chaque pi`ece compos´ee, indique son composant, direct ou indirect. Cette table est ordonn´ee par le id de la pi`ece compos´ee.
WITH RECURSIVE Hierarchie AS (
    -- Cas de base : On commence avec la pièce principale
    SELECT 
        c.id_piece_composite AS id_parent, 
        c.id_piece_composees AS id_enfant, 
        p.nom_piece AS nom_enfant,
        1 AS niveau
    FROM COMPOSE c
    JOIN PIECE p ON c.id_piece_composees = p.id_piece
    WHERE c.id_piece_composite = 6  -- Remplace par l'ID de la pièce recherchée

    UNION ALL

    -- Récursion : On cherche les sous-composants des sous-composants
    SELECT 
        c.id_piece_composite, 
        c.id_piece_composees, 
        p.nom_piece,
        h.niveau + 1
    FROM COMPOSE c
    JOIN PIECE p ON c.id_piece_composees = p.id_piece
    JOIN Hierarchie h ON c.id_piece_composite = h.id_enfant
)

SELECT * FROM Hierarchie;
