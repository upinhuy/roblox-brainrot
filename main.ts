// Brainrot Bazaar hands itself in for roblox-brainrot-01 (Node 22, standard
// library only). The game is the Rojo project in this directory: build it
// first with `rojo build default.project.json --output game.rbxl`. This
// program then carries game.rbxl, src/, screenshots/ and PLAY.json into
// /output and writes /output/dossier.json, the summary the judge reads, with
// the vendored make.fun library. Screenshots come from the user in Studio;
// the first by name is the cover and must match the Roblox thumbnail.
// PLAY.json names the published place; until it does, the gate refuses the
// entry on the play link alone.
//
// Every name under /output starts with a letter, a digit or _ and holds only
// letters, digits, . _ and -: the grader fails an entry whose output holds
// any other, so a file such as .gitkeep or .DS_Store copied in fails it.
// src/ and screenshots/ are therefore copied without any name that starts
// with a dot, at any depth.
//
// Outside the grader's container, MAKEFUN_OUTPUT_DIR stands in for /output:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const repoRoot = fileURLToPath(new URL('.', import.meta.url));
const outDir = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

/** True for every path cpSync may carry over: nothing starting with a dot. */
const keepName = (path: string): boolean => !basename(path).startsWith('.');

mkdirSync(outDir, { recursive: true });
if (!existsSync(join(repoRoot, 'game.rbxl'))) {
  throw new Error('game.rbxl is missing: build it first with `rojo build default.project.json --output game.rbxl`.');
}
copyFileSync(join(repoRoot, 'game.rbxl'), join(outDir, 'game.rbxl'));
copyFileSync(join(repoRoot, 'PLAY.json'), join(outDir, 'PLAY.json'));
cpSync(join(repoRoot, 'src'), join(outDir, 'src'), { recursive: true, filter: keepName });
mkdirSync(join(outDir, 'screenshots'), { recursive: true });
if (existsSync(join(repoRoot, 'screenshots'))) {
  cpSync(join(repoRoot, 'screenshots'), join(outDir, 'screenshots'), { recursive: true, filter: keepName });
}

// The caps mirror the scorer's own limits: at most 4 screenshots of 256 KiB
// each, a place of at most 500000 instances, scripts of at most 8 MiB of
// source in all, and a dossier text of at most 65536 bytes.
const dossierCaps = {
  text_max_bytes: 65536,
  screenshots: { max: 4, max_bytes: 262144 },
  max_instances: 500000,
  scripts_max_source_bytes: 8388608,
  scripts_max_path_chars: 1048576,
};

writeFileSync(join(outDir, 'dossier.json'), buildDossier(outDir, dossierCaps));
