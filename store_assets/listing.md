# Play Store Listing — Arrow Puzzle

Paste-ready text for the Play Console listing form.

---

## App name (max 30 chars)

```
Arrow Puzzle: Tap Logic
```
(22 chars)

Alternates:
- `Arrow Puzzle - Tap Away` (23)
- `Arrow Puzzle: Brain Logic` (25)

## Short description (max 80 chars)

```
Tap arrows away in a calming logic puzzle. 60 levels + daily challenges.
```
(72 chars)

Alternates:
- `Relaxing tap-away arrow logic game. 60 levels, daily puzzles, no ads.` (69)
- `Calm logic puzzle: tap arrows, clear the board. Brain training daily.` (68)

## Full description (max 4000 chars)

```
Arrow Puzzle is a relaxing logic puzzle game where every level is a small mental reset. Tap arrows to clear them from the grid — but only if their forward path is free. Plan your order, solve the puzzle, breathe out.

🎯 SIMPLE RULES, DEEP STRATEGY
• Each arrow can only escape if its path to the edge is clear.
• Tap a blocked arrow and you lose a life.
• Plan the order. Clear every arrow. That's it.

🌟 60 HAND-CURATED LEVELS
• Easy → Normal → Hard → Expert → Insane → Boss
• Solver-validated puzzles — every level is genuinely solvable.
• Three-star rating: master each level by losing zero lives.

⚡ TIMER ATTACK MODE
• 60 seconds. Procedural puzzles. Maximum score.
• Beat your own best, then challenge your friends.

🗓️ DAILY CHALLENGE
• A fresh puzzle every day, the same for every player.
• Build streaks. Earn monthly trophies.
• Smart reminder notification so you never miss one.

✨ FEATURES
• Hint system — get unstuck without losing.
• Smooth animations and satisfying haptics.
• Light + dark themes with neon accents.
• No ads. No data collection. Fully offline.

🧠 GOOD FOR YOUR MIND
Arrow Puzzle was designed to be a calm, focused break — perfect for unwinding before bed, on a commute, or whenever you need a small mental reset. Train your logic, sharpen your spatial reasoning, and enjoy a beautiful puzzle game that respects your time.

Privacy first. Zero tracking. Pure puzzles.
```

(~1450 chars — well under 4000 limit)

---

## ASO Keywords (use in description naturally, NOT a separate field)

Primary: `arrow puzzle`, `tap away`, `logic puzzle`, `brain game`
Secondary: `relaxing puzzle`, `brain training`, `puzzle game`, `tap game`
Long-tail: `tap away arrows`, `logic game offline`, `puzzle no ads`

## App category

- **Primary**: Puzzle
- **Secondary**: Casual / Brain Games

## Tags

`logic`, `puzzle`, `brain`, `relaxing`, `offline`, `single-player`

## Content rating

- Everyone (3+)
- No violence, no in-app purchases (v1), no ads (v1)

## Privacy policy URL

Host `privacy_policy.html` on GitHub Pages or any static host. Suggested URL:
```
https://modajxx.github.io/ArrowPuzzle/privacy.html
```

Steps to host on GitHub Pages:
1. In the GitHub repo, go to Settings → Pages
2. Source: Deploy from a branch → `main` → `/store_assets`
3. Save — URL becomes `https://modajxx.github.io/ArrowPuzzle/privacy_policy.html`

## Contact email

Use a real email you check — Play Console requires one and surfaces it in the listing.

---

## Screenshot brief (4-8 needed, 1080x1920+ or 16:9)

Capture these in-app states (already preset for capture via adb):
1. Main menu (logo + buttons) ← captured automatically
2. Game screen mid-puzzle (arrows + hearts visible)
3. Level select grid (showing stars)
4. Timer attack in progress with status chips
5. Level complete overlay with stars + confetti
6. Daily challenge screen with calendar
7. Dark/light theme contrast comparison (optional)

Capture command:
```bash
adb -s <device-id> exec-out screencap -p > screenshots/02_game.png
```

You can add captions in Canva/Photoshop if desired ("Tap. Think. Clear.", "60 Hand-Crafted Levels", etc.).
