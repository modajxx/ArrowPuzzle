# Play Console Step-by-Step Guide — Arrow Puzzle

Follow these steps in order to publish Arrow Puzzle on the Play Store.

---

## STEP 0: One-Time Setup (30 min)

### 0.1 Create Play Console developer account
- Go to **https://play.google.com/console**
- Sign in with the Google account you want to own the app
- Pay **$25 one-time fee** (≈ ₹2,083)
- Fill: developer name, address, phone (verification will be sent)
- Wait 1-2 days for account verification

### 0.2 Host the privacy policy on GitHub Pages
1. Go to https://github.com/modajxx/ArrowPuzzle → **Settings** (top tab)
2. Sidebar → **Pages**
3. Source: **Deploy from a branch**
4. Branch: `main` · Folder: `/ (root)` · Save
5. Wait 1 min — GitHub will show the live URL near the top of the page

**Your privacy policy URL will be:**
```
https://modajxx.github.io/ArrowPuzzle/store_assets/privacy_policy.html
```

Open that URL in a browser to verify it loads before pasting it into Play Console.

### 0.3 Update the contact email
The privacy policy currently has placeholder email `hello@jtpl.example`. Before publishing:
1. Edit `store_assets/privacy_policy.html` line ~92 — replace with your real email
2. Commit + push (GitHub Pages auto-redeploys in ~1 min)

---

## STEP 1: Create the App in Play Console (5 min)

After your account is verified:

1. Play Console home → **Create app** (top right)
2. Fill the form:

| Field | Value |
|---|---|
| **App name** | `Arrow Puzzle: Tap Logic` |
| **Default language** | English – en-US |
| **App or game** | **Game** |
| **Free or paid** | Free |
| Declarations | Tick both checkboxes |

3. Click **Create app**

---

## STEP 2: Set up the Dashboard Tasks (15 min)

Play Console shows a "Set up your app" checklist on the dashboard. Hit them in this order:

### 2.1 App access
- **All functionality is available without restrictions** ✓

### 2.2 Ads
- **No, my app does not contain ads** ✓ (v1)

### 2.3 Content rating
- Click **Start questionnaire**
- Email: your real email
- Category: **Game**
- Answer questions truthfully — Arrow Puzzle has zero violence/sex/profanity/etc., so it'll come out **Everyone (3+)**
- Apply rating

### 2.4 Target audience
- Age groups: **13 and over** (default safe) — or include younger groups if you want
- Does your app appeal to children? **No** (or Yes if you want — both fine for puzzle)

### 2.5 News apps
- **My app is not a news app**

### 2.6 COVID-19 contact tracing
- **My app is neither a tracing nor status app**

### 2.7 Data safety
This is the big one. Answer truthfully — Arrow Puzzle collects NOTHING:
- Does your app collect or share any of the required user data types? → **No**
- Does your app encrypt user data in transit? → N/A (no transit)
- Do you provide a way for users to request that their data be deleted? → N/A
- Submit

### 2.8 Government apps
- **My app is not a government app**

### 2.9 Financial features
- **My app doesn't provide any financial features**

### 2.10 Health
- **My app is not a health app**

### 2.11 Advertising ID
- **No, my app does not use advertising ID**

---

## STEP 3: Store Listing (15 min)

Sidebar → **Grow** → **Store presence** → **Main store listing**

Open this file and copy-paste from each section: **`store_assets/listing.md`**

Field-by-field:

| Field | Source |
|---|---|
| **App name** (max 30) | `Arrow Puzzle: Tap Logic` |
| **Short description** (max 80) | From `listing.md` |
| **Full description** (max 4000) | From `listing.md` |

### Graphics (upload these files):

| Asset | File path | Where in Console |
|---|---|---|
| **App icon** (512×512) | `store_assets/app_icon_1024.png` — Play Console will auto-resize, OR resize to 512 first | App icon |
| **Feature graphic** (1024×500) | `store_assets/feature_graphic.png` | Feature graphic |
| **Phone screenshots** (need 2-8) | `store_assets/screenshots/01_menu.png` through `06_timer.png` | Phone screenshots |

**Pick these 6 for the best impression:**
1. `01_menu.png` — main menu with logo
2. `02_game.png` — game screen Level 1
3. `04_midgame.png` — Level 4 mid-puzzle (shows neon arrows)
4. `03_levels.png` — level select with locks
5. `06_timer.png` — Timer Attack start
6. `05_daily.png` — Daily Challenge calendar

### Categorization:
- **App category:** Games → **Puzzle**
- **Tags:** Brain Games, Casual

### Contact details:
- **Email:** your real email (required)
- **Phone / website:** optional

### Privacy policy:
- Paste: `https://modajxx.github.io/ArrowPuzzle/store_assets/privacy_policy.html`

Save.

---

## STEP 4: Upload the AAB (10 min)

Sidebar → **Release** → **Testing** → **Internal testing**

### 4.1 Create a release
- Click **Create new release**
- App bundles section → **Upload** → choose:
  ```
  /Users/apple/arrow_puzzle/build/app/outputs/bundle/release/app-release.aab
  ```
- Wait for upload + processing (~30 sec)

### 4.2 Release name
- Auto-fills as `1 (1.0.0)` — leave as is

### 4.3 Release notes
```
First release of Arrow Puzzle.

• 60 hand-crafted levels
• Timer Attack mode
• Daily Challenge with calendar
• Dark + light themes
• Fully offline, no ads, no tracking
```

### 4.4 Save → Review release → Start rollout to Internal testing

### 4.5 Add testers
- Internal testing → Testers tab
- Create email list (you + 2-3 friends)
- Save → copy the **opt-in URL** Play Console gives you
- Send that URL to your testers — they click it in their browser → "Become a tester" → install via Play Store
- App will be available to internal testers in ~1 hour

---

## STEP 5: Promote to Production (after internal testing OK)

Once you've tested the internal release and it's working:

1. Sidebar → **Release** → **Production**
2. **Create new release**
3. Use the SAME AAB that's in Internal Testing (Play Console lets you copy)
4. Countries/regions: **All countries** (or pick India + others)
5. Release notes — same as internal
6. **Review release** → **Start rollout to Production**
7. Google reviews (typically **1-7 days**)
8. Once approved → app is LIVE on Play Store at:
   ```
   https://play.google.com/store/apps/details?id=com.jtpl.arrowpuzzle
   ```

---

## Common Rejection Reasons (and how we already avoided them)

| Issue | How we handled |
|---|---|
| Missing privacy policy | ✓ Hosted on GitHub Pages |
| Apps that collect data without disclosure | ✓ We collect nothing — disclosed in Data Safety |
| Misleading screenshots | ✓ Real device captures |
| Broken installation | ✓ AAB signed, R8-minified, tested on physical device |
| Permission abuse | ✓ Only notification + alarm permissions, justified in policy |
| Target SDK too old | ✓ Flutter handles, latest SDK |

---

## After Launch — Quick Wins (Step 15)

1. Replace the Play Store URL placeholder in `lib/services/share_service.dart` with the real URL once live, then rebuild + upload v1.0.1
2. Submit the app to indie game directories (itch.io, IndieDB)
3. Cross-promote in your other two WhatsApp-niche apps once they launch
4. Track first-week installs in Play Console → **Statistics**
5. Respond to reviews (Play Console → **Reviews**) — engagement boosts ASO

---

## Emergency: I lost the keystore!

If you ever lose `/Users/apple/keystores/arrow-puzzle-release.jks` or the password:
- You cannot ever update this app — Play Store will reject all future uploads
- You'd have to publish under a NEW package name (e.g., `com.jtpl.arrowpuzzle2`)
- Users would lose their progress
- **This is why I told you to back it up in 3 places. Do it now.**

Keystore: `/Users/apple/keystores/arrow-puzzle-release.jks`
Password: stored in `android/key.properties` on your dev machine (gitignored).
         **If you ever need to recover it, only your local copy has it — back it up offline.**
SHA1: `CA:CE:4C:EC:8C:D9:E0:8E:EA:02:B4:11:6A:EF:E7:ED:0D:43:CD:53`
