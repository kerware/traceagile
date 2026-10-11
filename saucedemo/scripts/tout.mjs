// Enchaîne les deux temps du jeu de données :
// 1. les tests réels de www.saucedemo.com (un échec attendu : le défaut de problem_user) → rapport JUnit ;
// 2. le scénario du guide contre TraceAgile, qui importe ce rapport et capture les écrans.
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const racine = fileURLToPath(new URL('..', import.meta.url));
const lancer = (args) => spawnSync('npx', ['playwright', 'test', ...args], { cwd: racine, stdio: 'inherit', shell: true }).status;

const app = lancer([]);
console.log(app === 0
  ? '\nTests saucedemo : tous réussis.'
  : '\nTests saucedemo terminés avec au moins un échec (attendu : « problem_user retire un produit… @fail »).');

process.exit(lancer(['-c', 'guide.config.ts']) ?? 1);
