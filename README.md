# Brainrot Bazaar — roblox-brainrot-01

[![make.fun bounty](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/upinhuy/roblox-brainrot/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/upinhuy/roblox-brainrot/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

An original 3D Roblox brainrot game for make.fun's "Make the best AI Roblox brainrot game" bounty
(roblox-brainrot-01). You run a base beside a conveyor belt in a little plaza: absurd meme characters
ride the belt, you click one to buy it, it walks home to your base and earns cash every second. Climb
the rarity ladder from Common to Secret, steal from other players' open bases, lock your own base
against thieves, outrun the Meme Wave that sweeps the map, and rebirth for a permanent income boost.

## The cast

Ten characters of our own, none copied from another game:

| Character | Rarity | Price | Earns |
| --- | --- | --- | --- |
| Kucing Kopi | Common | $50 | $5/s |
| Pisang Karate | Common | $100 | $8/s |
| Ayam Disco | Rare | $300 | $20/s |
| Bebek Astronot | Rare | $600 | $35/s |
| Ikan Terbang | Epic | $1,500 | $70/s |
| Kambing DJ | Epic | $3,000 | $120/s |
| Sapi Balon | Legendary | $8,000 | $250/s |
| Kura-kura Turbo | Legendary | $15,000 | $450/s |
| Nasi Goreng Ninja | Mythic | $40,000 | $900/s |
| Kentang Presiden | Secret | $150,000 | $2,500/s |

## How the game plays

- **Buy:** brainrots roll off the belt every few seconds. Click one to buy it with cash; it walks to
  a free slot on your base and starts earning.
- **Earn:** every brainrot on your base pays its rate once a second. The HUD shows your cash and
  your income a second.
- **Steal:** click a brainrot on another player's base to lift it and carry it home over your head.
  Step onto your own base to keep it. A locked base cannot be stolen from: the lock lasts 20
  seconds and then needs a 60 second cooldown.
- **Survive:** every 100 seconds the Meme Wave sweeps the map. A carrier caught outside their own
  base when the wall reaches them drops the catch.
- **Rebirth:** pay $25,000 (doubling each time) to reset your cash and empty your base for a
  permanent +25% income per rebirth.

## Controls

Move with WASD or the arrow keys. Click brainrots to buy or steal. The HUD buttons lock your base
and rebirth; the same actions are on **L** and **R**.

## The world

A real 3D plaza built in Roblox's world: a central conveyor with gates and rails, eight coloured
base plots around it, trees, lamps and billboards by the spawn, and a ScreenGui HUD over it all.
The static plaza is laid out in `default.project.json`; trees, lamps and signs are raised by the
server at runtime.

## Code layout

- `src/shared/Config.luau` — every number the game balances on, in one place.
- `src/shared/BrainrotData.luau` — the cast, the rarities and the belt's roll.
- `src/server/BrainrotFactory.luau` — turns a cast member into a labelled model.
- `src/server/Economy.luau` — wallets, the one-second income tick, rebirth count.
- `src/server/Bases.luau` — the eight plots, their six slots, and the base lock.
- `src/server/Conveyor.luau` — the belt: spawning, walking, selling.
- `src/server/Steal.luau` — lifting, carrying and delivering a stolen brainrot.
- `src/server/Hazard.luau` — the Meme Wave timer and sweep.
- `src/server/Rebirth.luau` — the rebirth price and reset.
- `src/server/World.luau` — trees, lamps, base signs and billboards at runtime.
- `src/server/Tour.luau` — the reviewer tour's jump-to-screen helpers.
- `src/server/init.server.luau` — wires the modules, the remotes and the players.
- `src/client/Game.client.luau` — the HUD: cash, income, lock and rebirth buttons.

## Run it

Build the place with Rojo, then open it in Roblox Studio:

    rojo build default.project.json --output game.rbxl

Hand it in as the grader does, writing `out/` in place of `/output`:

    mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

`PLAY.json` names the published place once it is public on Roblox. Until the owner publishes
the place from Roblox Studio and fills in its place and universe ids, the play link check refuses
the entry — that step belongs to the account owner, not to this program. `TOUR.json` walks a
reviewer through the four screenshots: spawn, a Legendary on the belt, the Meme Wave, and a rich
endgame base.

## Referral

New to make.fun? Join through my link and we both get a head start:
https://make.fun/r/hv9zk8y5 (referral code `hv9zk8y5`).
