# Sheep sprite assets (Counting Sheep app)

## Current behaviour

- **Per-habit sprite:** Each habit has a `spriteSeed` (Int). The same seed produces the same procedural pixel sheep in `PixelArtMenuSheepView`.
- **New habit:** On creation, a habit gets `spriteSeed = HabitSheep.randomSpriteSeed()`.
- **Personalise:** Tapping "Personalise" on the habit detail screen re-rolls the sprite by setting `spriteSeed` to a new random value and saving. The gear (top right) opens habit editing; Personalise does **not** open editing.
- **Where it’s used:** Home tab cards and habit detail header both use `PixelArtMenuSheepView(seed: sheep.spriteSeed, …)`.

## Storing 16×16 PNG sprites (when you add image assets)

### Where to store

- **Recommended:** `Assets.xcassets/SheepSprites/`  
  - Add an **Image Set** (e.g. `SheepSprites`) or one image set per variant (e.g. `sheep_01`, `sheep_02`, …).
  - Each image: **exactly 16×16 px**, PNG, no @2x/@3x (use a single 16×16 and let the app scale).
- **Alternative:** A single **sprite sheet** (e.g. one PNG with multiple 16×16 frames in a row or grid) and slice in code. Less convenient in Xcode; better if you have many frames or animations.

### Style constraints (for asset creation)

- 8-bit pixel art (early Pokémon / Game Boy Color style).
- Canvas: **16×16 px** per sprite.
- No anti-aliasing, gradients, or blur; hard pixel edges only.
- **Max 4 colours per sprite + transparent background.**
- Outline: pure black or very dark.
- Cute, simple, readable at small size; no background elements.
- Character: chubby, fluffy sheep; rounded blob-like body; white/off-white wool; tiny black dot eyes; subtle expression.

### How to switch from procedural to image-based

1. Add PNGs to `Assets.xcassets/SheepSprites/` (e.g. `sheep_01` … `sheep_N`).
2. Map `spriteSeed` to a variant index, e.g. `let index = abs(sheep.spriteSeed) % N` and use image name `sheep_\(index + 1)` or a fixed list of asset names.
3. In `PixelArtMenuSheepView`, when using assets: load `Image("sheep_\(variantIndex)")` (or from a sprite sheet) instead of drawing the procedural grid; keep the same `seed`/`spriteSeed` contract so Home and Detail stay in sync.
4. Keep `spriteSeed` in `HabitSheep`; “Personalise” continues to set a new random `spriteSeed`, which then maps to a (possibly different) asset.

## Animation (optional, multiple frames)

- If you add multiple frames (e.g. idle animation), use minimal changes between frames (small position/eye/limb tweaks; no new colours or silhouette changes).
- Store as separate images (e.g. `sheep_01_idle_0`, `sheep_01_idle_1`) or as frames in a sprite sheet; advance frame by time in the view.
