# ADR-0001 — Consigner les décisions d'architecture

**Statut** : acceptée (lot 0)

**Contexte.** La spécification (§16.1-5) demande de choisir l'option la plus simple en cas
d'ambiguïté et de la consigner dans `docs/adr/`.

**Décision.** Une décision = un fichier `NNNN-titre.md` (contexte, décision, conséquences), indexé
dans `docs/adr/README.md`. Le code et les tests renvoient à l'ADR concernée (`ADR-0004`…).

**Conséquences.** Les écarts ou précisions par rapport à `SPECIFICATION.md` sont traçables.
