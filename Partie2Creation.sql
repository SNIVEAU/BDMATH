--Suppression des objets avant de les recréer (évite les erreurs si déjà existants)

-- Supprimer la table avant de la recréer
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Piece CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL; -- Ignore l'erreur si la table n'existe pas
END;
/

-- Supprimer les types avant de les recréer
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE Liste_Equipe';
    EXECUTE IMMEDIATE 'DROP TYPE Membre_Equipe';
    EXECUTE IMMEDIATE 'DROP TYPE Liste_Indices';
    EXECUTE IMMEDIATE 'DROP TYPE Indice_Qualite';
EXCEPTION
    WHEN OTHERS THEN NULL; -- Ignore l'erreur si les types n'existent pas
END;
/

-- Activer l'utilisation des scripts Oracle (utile parfois pour les objets)
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
/

-- 🔹 Type pour représenter un membre de l’équipe
CREATE TYPE Membre_Equipe AS OBJECT (
    nom VARCHAR2(100),
    role VARCHAR2(50)
);
/

-- 🔹 Collection de membres d'équipe (TABLE OF pour une taille dynamique)
CREATE TYPE Liste_Equipe AS TABLE OF Membre_Equipe;
/

-- 🔹 Type pour représenter un indice de qualité avec son poids
CREATE TYPE Indice_Qualite AS OBJECT (
    nom VARCHAR2(50),
    poids NUMBER(5,2)  -- Poids avec 2 décimales
);
/

-- 🔹 Liste de 3 indices de qualité (VARRAY car taille fixe)
CREATE TYPE Liste_Indices AS VARRAY(3) OF Indice_Qualite;
/

-- 🔹 Création de la table Piece avec dates de début et de fin
CREATE TABLE Piece (
    id NUMBER PRIMARY KEY,
    nom VARCHAR2(100),
    date_debut DATE,       -- Ajout de la date de début
    date_fin DATE,         -- Ajout de la date de fin
    equipe Liste_Equipe,   -- Table imbriquée pour l'équipe
    indices Liste_Indices  -- Liste fixe de 3 indices
) NESTED TABLE equipe STORE AS equipe_tab; 
/

-- 🔹 Insertion de données avec les dates
INSERT INTO Piece VALUES (
    1, 
    'Moteur V8',
    TO_DATE('2024-03-01', 'YYYY-MM-DD'), -- Date de début
    TO_DATE('2024-06-30', 'YYYY-MM-DD'), -- Date de fin
    Liste_Equipe(
        Membre_Equipe('Alice', 'Ingénieur'),
        Membre_Equipe('Bob', 'Technicien')
    ),
    Liste_Indices(
        Indice_Qualite('Durabilité', 8.5),
        Indice_Qualite('Précision', 9.2),
        Indice_Qualite('Fiabilité', 9.0)
    )
);
/
INSERT INTO Piece VALUES (
    442, 
    'Panneau Fuselage',
    TO_DATE('2025-06-11 13:00', 'YYYY-MM-DD HH24:MI'), -- Date de début
    TO_DATE('2025-06-13 19:00', 'YYYY-MM-DD HH24:MI'), -- Date de fin
    Liste_Equipe(
        Membre_Equipe('Goscinny', 'Mécanicien'),
        Membre_Equipe('Uderzo', 'Inspecteur')
    ),
    Liste_Indices(
        Indice_Qualite('Carbone', 3.4),
        Indice_Qualite('Sécurité', 4.5),
        Indice_Qualite('Prix', 4.3)
    )
);
/

COMMIT;
/

/

-- Confirmer les modifications
COMMIT;
/

-- Vérifier les données
SELECT * FROM Piece;
/



--- PARTIE REQUETE

-- # 1 Pour chaque piece, donnez le nombre de personnes de l’equipe, par fonction.

SELECT p.nom AS piece_nom, e.role, COUNT(e.nom) AS nb_personnes FROM Piece p, TABLE(p.equipe) e GROUP BY p.nom, e.role ORDER BY p.nom, e.role;

-- # 2 Pour chaque m´ecanicien, indiquez combien des pi`eces lui sont associ´ees.

select e.nom, p.nom, count(p.nom) as nb_pieces_associees from Piece p, TABLE(p.equipe) e where e.role = 'Mécanicien' group by e.nom, p.nom;

-- # 3 L’impact d’un indice de qualit´e est donn´e par le produit de sa valeur et du poids que lui est attribu´e. Pour chaque pi`ece, indiquez l’impact de chaque indice de qualit´e.

SELECT p.nom AS piece_nom, i.nom AS indice_nom, i.poids * i2.poids AS impact FROM Piece p, TABLE(p.indices) i, TABLE(p.indices) i2 WHERE i.nom <> i2.nom ORDER BY p.nom, i.nom;

-- # 4 Pour chaque indice de qualit´e, calculez son impact moyen.

SELECT i.nom AS indice_nom, AVG(i.poids * i2.poids) AS impact_moyen FROM Piece p, TABLE(p.indices) i, TABLE(p.indices) i2 WHERE i.nom <> i2.nom GROUP BY i.nom;
