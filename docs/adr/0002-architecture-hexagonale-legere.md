# ADR-0002 — Architecture hexagonale légère et modules Maven

**Statut** : acceptée (lot 0)

**Contexte.** §11.2 et §11.3 imposent quatre modules (domaine, application, infrastructure, API)
plus le simulateur, un domaine indépendant du web et de l'infrastructure, des ports implémentés par
l'infrastructure, et des entités JPA dans le domaine.

**Décision.**
- `traceagile-domain` : entités JPA, énumérations, règles métier pures. Il dépend de
  `jakarta.persistence` et des seules annotations d'audit de Spring Data (`@CreatedBy`…, via
  `AuditingEntityListener`) pour remplir les champs techniques du §3 sans code dupliqué.
- `traceagile-application` : services transactionnels et **ports** (`UserRepository`,
  `ProjectRepository`, `PasswordHasher`…). Les ports de persistance ont des signatures compatibles
  Spring Data (`findByLogin`, `findDistinctByMembers_User_Login`).
- `traceagile-infrastructure` : les adaptateurs sont de simples interfaces
  `JpaXxxRepository extends JpaRepository<…>, XxxRepository`, plus les migrations Flyway et BCrypt.
- `traceagile-api` : contrôleurs, DTO (records), mappers MapStruct, sécurité, application Spring Boot.
- Les règles de dépendance sont vérifiées par `ArchitectureTest` (ArchUnit, §15.2).
- `spring.jpa.open-in-view` reste activé : les contrôleurs convertissent les entités en DTO après
  l'appel du service. C'est le plus simple pour un prototype ; à revoir si NF-01 l'exige.

**Conséquences.** Pas de double modèle entité / persistance. Le domaine reste testable sans Spring.
