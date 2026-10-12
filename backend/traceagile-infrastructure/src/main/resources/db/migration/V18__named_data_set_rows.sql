-- ADR-0029 appel d'un cas de test avec un jeu de données nommé de l'appelé (nom du jeu, nom de la ligne).
-- Les noms des lignes sont portés par le jsonb data_sets (rowNames) ; absents, ils sont déduits à la lecture.
alter table manual_steps
    add column call_data_set text,
    add column call_data_row text;
