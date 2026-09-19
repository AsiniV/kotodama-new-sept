# Kotodama (言霊) — User Manual

## Welcome to Kotodama!

**Kotodama** is your personal AI-powered game studio that turns your ideas into playable games in minutes. Whether you dream of a cyberpunk detective story, a cozy farming simulator, or an epic space adventure, Kotodama's multi-agent AI system handles everything: writing code, creating art, designing quests, composing dialogues, and building levels. You focus on creativity; we handle the technical magic. No coding required—just imagine, customize, and play!

---

## 🚀 First Launch: Getting Started

### Step 1: Start the Service

Open your terminal and run:

```bash
docker compose up -d
```

This launches all Kotodama components: the AI brain, database, storage, and web interface.

### Step 2: Wait for Initialization (2-3 minutes)

The first launch takes extra time as the system:
- Downloads AI models (Ollama)
- Initializes the vector database (PGVector) for Lore storage
- Sets up storage buckets (MinIO)

**How to know it's ready:**
- Open `http://localhost:3000` in your browser
- When you see the welcome screen (not a loading spinner), you're ready!

> 💡 **Tip:** Check logs with `docker compose logs -f` if you're curious. Look for "Application startup complete" in the backend logs.

### Step 3: Create Your First Account

1. Click **"Sign Up"** in the top-right corner
2. Enter your email and create a password
3. Verify your email (check your inbox)
4. Log in!

You'll start with **50 free credits** to explore the platform.

---

## 🎮 Creating a Game: The 14-Step Wizard

Click **"Create New Game"** to begin your journey. You have two modes:

### 🌟 Classic Wizard (Step-by-Step)

Perfect for full creative control. Let's walk through all 14 steps:

#### **Step 1: Genre**
*What type of game do you want?*

- **Action** — Fast-paced combat and reflexes (platformers, shooters)
- **Adventure** — Story-driven exploration (point-and-click, narrative)
- **RPG** — Character progression and choices (JRPG, action RPG)
- **Puzzle** — Brain teasers and logic challenges
- **Simulation** — Life, farming, city building
- **Strategy** — Tactical thinking and planning
- **Horror** — Survival and atmosphere
- **Visual Novel** — Interactive storytelling

> 💡 **Chat Hint:** Type *"I want something like Stardew Valley"* and AI will suggest "Simulation + Farming" automatically.

---

#### **Step 2: Perspective**
*How does the player see the world?*

- **2D Side-Scroller** — Classic Mario-style view
- **Top-Down** — Zelda-like overhead view
- **Isometric** — 3D-looking 2D (Diablo, Disco Elysium)
- **First-Person** — Through the player's eyes
- **Third-Person** — Behind the character's shoulder
- **Point-and-Click** — Static screens with clickable areas

⚠️ **Compatibility Note:** Some genres lock certain perspectives (e.g., Visual Novels only support Point-and-Click).

---

#### **Step 3: Art Style**
*Visual aesthetics of your game*

Browse visual previews for each style:

- **Pixel Art** — Retro 8-bit/16-bit charm
- **Hand-Drawn** — Artistic, painterly look
- **Minimalist** — Clean shapes, limited colors
- **Cyberpunk** — Neon, high-tech, dark futures
- **Fantasy** — Magical, medieval, enchanted
- **Sci-Fi** — Futuristic, space, technology
- **Cartoon** — Exaggerated, colorful, animated
- **Realistic** — Lifelike proportions and textures
- **Low Poly** — Geometric 3D aesthetic
- **Anime** — Japanese animation style

Click any preview to enlarge it. This choice guides the AI art generation.

---

#### **Step 4: Setting**
*Where does your story take place?*

Choose from presets or describe your own:

- **Space Station** — Orbital facilities, sci-fi isolation
- **Medieval Kingdom** — Castles, villages, fantasy realms
- **Cyberpunk City** — Neon streets, corporate dystopia
- **Post-Apocalyptic Wasteland** — Survival after disaster
- **Enchanted Forest** — Magic, creatures, mystery
- **Underwater Colony** — Deep sea exploration
- **Haunted Mansion** — Horror, ghosts, secrets
- **Desert Oasis** — Sand, trade routes, ancient ruins
- **Floating Islands** — Skybound adventure
- **Custom** — Write your own (AI will interpret)

---

#### **Step 5: Scale**
*How big is your game world?*

- **Micro** — Single room or small arena (5-10 min playtime)
- **Small** — One building or village (30-60 min)
- **Medium** — Multiple areas or towns (2-4 hours)
- **Large** — Entire region or planet (5-10 hours)
- **Epic** — Massive world with multiple acts (10+ hours)

> ⚠️ **Credit Warning:** Larger scales cost more credits and take longer to generate.

---

#### **Step 6: Controls**
*How does the player interact?*

- **Keyboard Only** — WASD + keys (PC classic)
- **Keyboard + Mouse** — Movement + aiming/clicking
- **Gamepad** — Controller support (Xbox/PlayStation style)
- **Touch** — Mobile-friendly tap/swipe controls
- **Hybrid** — Supports multiple input methods

---

#### **Step 7: Saving**
*Should players be able to save their progress?*

- **No Saving** — Arcade-style, one session only
- **Yes, Enable Save/Load** — Players can save anytime

✅ **Choosing "Yes"** automatically generates a Save System module that stores:
- Player position and health
- Inventory items
- Quest progress
- Dialogue choices
- World state (opened doors, defeated enemies)

---

#### **Step 8: Monetization (Optional)**
*Planning to publish and earn?*

Templates for future export:

- **Free-to-Play** — No cost, optional donations
- **One-Time Purchase** — Fixed price on app stores
- **Demo + Full Version** — Free trial, paid upgrade
- **In-App Purchases** — Buy items, cosmetics, expansions
- **Subscription** — Monthly access fee

> 💡 This step only adds templates. Actual monetization requires manual setup during export.

---

#### **Step 9: Quest Complexity** ⭐ NEW
*How deep should the quest system be?*

| Level | Description | Generated Content |
|-------|-------------|-------------------|
| **None** | No quests, pure exploration | 0 quests |
| **Simple** | 1-2 straightforward tasks | 1-2 linear quests |
| **Branching** | Choices affect outcomes | 2-3 quests with decision points |
| **Epic** | Complex web of dependencies | 4-6 quests with side stories, multiple endings |

**Example:**
- *Simple:* "Find the key, open the door"
- *Branching:* "Help the merchant OR the thief—each leads to different rewards"
- *Epic:* "Restore power → Unlock medbay → Rescue scientist → Discover conspiracy → Choose faction ending"

---

#### **Step 10: Dialogue Depth** ⭐ NEW
*How rich are character interactions?*

| Level | Description | Features |
|-------|-------------|----------|
| **None** | Silent game | No text boxes |
| **Linear** | Simple NPC messages | Text boxes only, no choices |
| **Branching** | Player choices matter | 2-3 dialogue options per conversation |
| **Full RPG** | Complex conversations | Conditions, flags, quest triggers, world-state changes |

**Example:**
- *Linear:* NPC says "The reactor is broken." (end)
- *Branching:* "The reactor is broken." → [Ask how to fix] OR [Leave]
- *Full RPG:* "The reactor is broken." → [If you have toolkit: "I can help!"] → [Gives item] → [Starts quest]

---

#### **Step 11: Lore (Your Universe)**
*Connect your game to a custom world*

**Options:**
- **Skip** — Generate a generic standalone story
- **Select Existing Lore** — Choose from your saved universes
- **Create New Lore** — Opens Lore Manager (see section below)

Lore includes characters, locations, world rules, history, and factions. The AI uses this to make your game feel unique and consistent.

---

#### **Step 12: Text Description**
*Tell the AI your vision in plain language*

Write freely! Examples:

> *"A cat astronaut who crash-lands on a alien planet. She must repair her ship while befriending local creatures. Pixel art, lighthearted tone."*

> *"Detective noir in 1940s Chicago, but everyone is a ghost. Solve murders by talking to spirits. Dark atmosphere, hand-drawn art."*

> *"Flappy Bird, but you're a dragon breathing fire to destroy obstacles. Add power-ups and boss battles."*

The AI analyzes this text to fine-tune all generated content.

---

#### **Step 13: Confirmation & Cost Estimation**

Review your choices:

```
┌─────────────────────────────────────┐
│ GAME SUMMARY                        │
├─────────────────────────────────────┤
│ Genre: Action-Adventure             │
│ Perspective: 2D Side-Scroller       │
│ Art Style: Pixel Art + Cyberpunk    │
│ Setting: Space Station              │
│ Scale: Medium (2-4 hours)           │
│ Quest Complexity: Branching         │
│ Dialogue Depth: Full RPG            │
│ Lore: "Nebula Wars" universe        │
├─────────────────────────────────────┤
│ ESTIMATED COST: 45 credits          │
│ ESTIMATED TIME: 8-12 minutes        │
└─────────────────────────────────────┘
```

Click **"Confirm & Start Generation"** to begin.

---

#### **Step 14: Live Preview Warning** ⚠️

Before generation starts, you'll see:

> ⚠️ **Building and loading the web version takes about 30 seconds. Enjoy the process of creating magic!**

This is normal! The system is:
1. Generating all game modules (code, art, quests, dialogues)
2. Compiling the Godot project
3. Exporting to WebAssembly (HTML5)
4. Uploading to the preview server

**Don't close the tab!** You'll see a progress bar and live logs from the AI agents.

---

### 🎨 Remix Mode (Clone & Modify)

Want to make "Flappy Bird, but with my cat in cyberpunk"?

1. Click **"Remix / Clone"** on the dashboard
2. Search for existing games (yours or community creations)
3. Select a base game
4. Modify any parameters:
   - Change art style
   - Add quests
   - Swap characters
   - Adjust difficulty

The AI preserves the core mechanics while regenerating content to match your new vision. **Much faster than starting from scratch!**

---

## 📚 Lore Management (RAG System)

Lore is your personal knowledge base that makes every game conceptually unique.

### Creating a Universe

1. Go to **"Lore Library"** in the sidebar
2. Click **"Create New Universe"**
3. Fill in:
   - **Name:** "Nebula Wars"
   - **Description:** "A galactic conflict between three factions..."
   - **Tags:** sci-fi, space-opera, political

### Adding Characters

Click **"Add Character"**:

```
Name: Commander Kai
Role: Rebel leader
Personality: Stubborn, loyal, secretive
Backstory: Former imperial officer who defected...
Relationships: Rival to Admiral Vex, mentor to Nova
Appearance: Scar over left eye, wears worn uniform
Voice: Gruff, speaks in short sentences
```

### Adding Locations

```
Name: Station Prometheus
Type: Space station
Description: Abandoned research facility orbiting a black hole
Key Features: Reactor core, medbay, cryo-chambers
Atmosphere: Eerie, dimly lit, malfunctioning systems
```

### Adding World Rules

```
- Faster-than-light travel requires "Void Crystals"
- Magic exists but drains life force
- AI robots gained consciousness in year 2347
- Three moons cause extreme tides on ocean planets
```

### How Lore Affects Generation

When you select a universe during game creation:

1. **Character Integration:** NPCs use names, personalities, and relationships from your Lore
2. **Quest Context:** Quests reference faction conflicts, historical events, and world rules
3. **Dialogue Flavor:** Conversations include lore-specific terms and references
4. **Visual Consistency:** Art prompts include descriptions of factions, architecture, and technology
5. **World Logic:** Game mechanics respect your rules (e.g., if "no magic in tech zones," quests won't require spells there)

> 💡 **Pro Tip:** Richer Lore = More unique games. The AI vectorizes all text, so even subtle details influence generation.

---

## 👁️ Live Preview

### The 30-Second Warning

After confirming your game, you'll see:

> ⚠️ **Building and loading the web version takes about 30 seconds. Enjoy the process of creating magic!**

**What's happening:**
- AI agents generate code, art, quests, dialogues, and levels
- Godot compiles the project
- Export to HTML5 (WebAssembly)
- Upload to preview server

**Progress indicators:**
- 📝 Designer: Writing game design document
- 🏗️ Architect: Planning scene structure
- 🎨 Art Director: Generating sprites and backgrounds
- 💻 Coder: Writing GDScript modules
- ✅ QA: Checking syntax and connections
- 🎮 Playtester: Running automated tests
- 📦 Builder: Compiling and exporting

### Playing the Preview

Once ready, click **"Play Now"**:

- **Controls:** Use keyboard/mouse as specified in wizard
- **Objective:** Test core mechanics, explore the world
- **Limitations:** Preview is watermarked ("Made with Kotodama") and may have placeholder sounds

**Playtester Report:**
After you play (or automatically), you'll see metrics:
- ✅ Stability Score: 85/100
- ✅ Reachability: Start → End verified
- ✅ Items Collectible: 5/5 found
- ✅ Dialogues Functional: 3/3 triggered
- ⚠️ FPS: Average 45 (target 60)

### Downloading the Build

Finished testing? Download your game:

1. Click **"Export"** in the project dashboard
2. Choose format:
   - **Web (HTML5)** — Play in browser, shareable link
   - **APK (Android)** — Install on phones/tablets
   - **Windows (.exe)** — Desktop executable
   - **macOS (.app)** — Mac application
   - **Linux (.x86_64)** — Linux binary

3. For APK/iOS: Configure signing certificates (one-time setup)
4. Click **"Build"** and wait (2-5 minutes depending on size)
5. Download or publish directly to app stores

> 💡 **Free Tier:** Web export only. Upgrade to Starter ($9.99/mo) for APK without watermark.

---

## 🔄 Incremental Updates

Want to change your game after generation? No need to start over!

### How to Request Changes

1. Open your project dashboard
2. Click **"Request Update"**
3. Describe the change:

   *"Add a new quest where the player rescues the engineer from the reactor room. Make it branching with two possible endings."*

4. System analyzes impact:
   - Affected modules: QuestManager, DialogueSystem
   - Unaffected: PlayerController, Art assets (preserved!)
   - Estimated cost: 15 credits
   - Estimated time: 4-6 minutes

5. Confirm and watch the AI work!

### The Two-Attempt Rule 🛡️

Kotodama protects you from failed updates:

**Attempt 1 (Failed):**
- ❌ Generation fails (syntax error, broken connection)
- 💰 **Credits NOT charged**
- 🔄 Automatic rollback to previous stable version
- ⚠️ Warning shown: "Update failed. Retrying with adjusted parameters..."
- System automatically simplifies request and retries

**Attempt 2 (Failed):**
- ❌ Second attempt also fails
- 💰 **Credits ARE charged** (AI effort was expended)
- 🚫 Escalation: Task flagged for human review
- 💡 Suggestion: "Consider simplifying: remove branching, reduce quest complexity"

### How Rollback Works

Every successful generation is saved as a git commit:

```
Commit History:
├─ v1.0 (Initial generation) ✅
├─ v1.1 (Added save system) ✅
├─ v1.2 (Failed update - rolled back) ❌
└─ v1.3 (Current stable version) ✅
```

If an update fails:
1. System detects errors via QA agent
2. Reverts workspace to last stable commit
3. Preserves generated assets (sprites, textures never deleted)
4. Restores playable version instantly

> 💡 **Asset Preservation:** Art is committed separately. Even if code generation fails twice, your beautiful character sprites remain safe!

---

## 💰 Monetization & Economy

### Credits System

Credits are consumed when generating or updating games:

| Action | Base Cost | Multipliers |
|--------|-----------|-------------|
| New Game (Simple) | 30 credits | — |
| New Game (Complex) | 60 credits | — |
| Incremental Update | 10-20 credits | Depends on scope |
| Quest: Epic | ×1.5 | Added to base |
| Dialogue: Full RPG | ×1.3 | Added to base |
| HD Assets | ×1.2 | Optional upgrade |

**Refill Options:**
- Monthly subscription (see below)
- One-time purchase: $5 = 50 credits
- Sell modules on Marketplace (earn credits)

### Subscription Plans

| Plan | Price | Credits/Month | Features |
|------|-------|---------------|----------|
| **Free** | $0 | 50 | Watermark, Web export only, Basic generation |
| **Starter** | $9.99/mo | 50 | No watermark, APK export, Priority queue |
| **Pro** | $29.99/mo | 200 | HD assets, Server saves, Complex modules, All exports |
| **Studio** | $99.99/mo | 1000 | White-label, API access, Unlimited Lore, B2B support |

> 💡 **Rollover:** Unused credits roll over for 1 month (except Free tier).

### Module Marketplace

Buy and sell pre-made modules created by the community!

**Examples:**
- 🛒 "Advanced Inventory System" — 15 credits
- 🗡️ "Boss Battle Framework" — 25 credits
- 💬 "Romance Dialogue Pack" — 20 credits
- 🌍 "Procedural Dungeon Generator" — 30 credits

**Selling Modules:**
1. Create a module in your game
2. Click **"Publish to Marketplace"**
3. Set price (10-100 credits)
4. Pass security scan (automatic)
5. Earn 70-75% of sales (platform takes 25-30% commission)

**Security Guarantee:**
All modules undergo:
- AST code analysis (blocks malicious code)
- Asset plagiarism check (perceptual hashing)
- Functional testing (QA agent)

---

## ❓ FAQ (Frequently Asked Questions)

### 1. **Do I own the games I create?**
Yes! You receive full commercial rights to all games and unique assets created on paid tiers. Free tier games are yours but include a "Made with Kotodama" watermark. See our [Terms of Service](/tos) for details.

### 2. **Can I edit the generated code manually?**
Absolutely! Download the full Godot project and modify it in the Godot editor. However, manual edits won't sync back to Kotodama's incremental update system. Think of Kotodama as your starting point, not a walled garden.

### 3. **What if I don't like the generated art?**
Three options:
- **Regenerate:** Click "Regenerate Assets" in the project dashboard (costs 5 credits)
- **Upload Custom:** Replace generated sprites with your own art files
- **Remix:** Tweak the art style prompt and regenerate specific slots (player, enemy, etc.)

### 4. **How long does generation take?**
- Simple game (Micro scale, no quests): 3-5 minutes
- Medium game (Branching quests, dialogues): 8-12 minutes
- Epic game (Full RPG, large world): 15-20 minutes

Live Preview adds ~30 seconds for web build and upload.

### 5. **Can I collaborate with friends?**
Currently, projects are single-user. Team features (shared workspaces, role-based permissions) are planned for Phase 10. For now, share your exported Godot project and collaborate offline.

### 6. **Is my Lore private?**
Yes! Your Lore universes are stored encrypted in your private database. They're only used when YOU select them for generation. We never train public AI models on your Lore data.

### 7. **What happens if generation fails mid-process?**
The Two-Attempt Rule protects you (see section above). Attempt 1 failures are free with automatic rollback. If both attempts fail, you're charged but get human support to resolve the issue.

### 8. **Can I export to iOS?**
Yes! Pro and Studio tiers support iOS export. You'll need:
- Apple Developer account ($99/year)
- Signing certificates (we guide you through setup)
- macOS for final build (or use our cloud build service)

### 9. **Are there content restrictions?**
We prohibit:
- Hate speech, harassment, discrimination
- Sexually explicit content involving minors
- Real-world political propaganda
- Copyrighted characters (Nintendo, Disney, etc.)

Our AI filters detect violations before generation. Violators risk account suspension.

### 10. **How do I cancel my subscription?**
Go to **Account Settings → Billing → Cancel Subscription**. You retain access until the end of your billing period. Unused credits expire 30 days after cancellation (except purchased credit packs).

---

## 🔧 Troubleshooting

### Problem 1: "Game Is Not Generated" (Stuck at 0%)

**Symptoms:**
- Progress bar frozen
- Logs show "Waiting for agent..."
- Timeout after 10 minutes

**Solutions:**
1. **Check Ollama status:** Run `docker compose ps` — ensure `ollama` container is "Up"
2. **Restart backend:** `docker compose restart backend`
3. **Verify model download:** Logs should show "pulling model qwen2.5-coder:32b" — if stuck, run `docker compose exec ollama ollama pull qwen2.5-coder:32b`
4. **Reduce complexity:** Try a simpler request (Micro scale, Simple quests) to test the pipeline
5. **Check credits:** Ensure you have enough credits (bottom-left of dashboard)

---

### Problem 2: "Preview Does Not Load" (White Screen)

**Symptoms:**
- Click "Play Now" → white screen
- Browser console shows CORS errors
- Loading spinner infinite

**Solutions:**
1. **Wait 30 seconds:** Web builds take time — the warning is real!
2. **Clear cache:** Press Ctrl+Shift+R (hard refresh)
3. **Try incognito mode:** Extensions sometimes block WebAssembly
4. **Check browser compatibility:** Use Chrome, Firefox, or Edge (Safari has limited WebAssembly support)
5. **Download instead:** Click "Download Web Build" and open `index.html` locally

---

### Problem 3: "Assets Are Not Displayed" (Missing Sprites)

**Symptoms:**
- Purple checkerboard placeholders
- Console error: "Resource not found: res://assets/player.png"
- Art looks pixelated or stretched

**Solutions:**
1. **Regenerate assets:** Click "Art" tab → "Regenerate All" (5 credits)
2. **Check MinIO:** Run `docker compose ps` — ensure `minio` is running
3. **Manual upload:** Download placeholder pack from dashboard, edit in Photoshop/Aseprite, re-upload via "Assets" tab
4. **Verify slot mapping:** Art Director uses 10 fixed slots (player, enemy, background, etc.). If you renamed files manually, revert to original names
5. **Disable hardware acceleration:** In Godot preview, go to Project Settings → Renderer → Disable "GPU Skinning"

---

### Problem 4: "Credit Errors" (Insufficient Funds)

**Symptoms:**
- Red banner: "Not enough credits"
- Generation won't start
- Update request rejected

**Solutions:**
1. **Check balance:** Dashboard bottom-left shows current credits
2. **Estimate cost:** Before confirming, review the cost breakdown (Step 13 of wizard)
3. **Simplify request:** Reduce scale, lower quest/dialogue complexity
4. **Purchase credits:** Go to Billing → "Buy Credits" ($5 = 50 credits)
5. **Sell modules:** Publish unused modules to Marketplace for quick credits
6. **Wait for monthly refill:** Subscribers get credits on billing date

---

### Problem 5: "Rollback Happened Unexpectedly"

**Symptoms:**
- Update failed, reverted to old version
- Warning: "Attempt 1 failed, rolling back"
- Changes not applied

**Solutions:**
1. **Read the error log:** Click "View Details" to see what broke (syntax error? missing signal?)
2. **Simplify request:** If you asked for "Epic quest with 5 branching paths," try "Simple quest" first
3. **Split into multiple updates:** Instead of "Add quests + dialogues + new area," do three separate updates
4. **Contact support:** If rollback happens 3+ times on simple requests, our team will manually fix your project
5. **Check asset compatibility:** New art might conflict with old code — try "Regenerate Code Only" option

---

## 📞 Need More Help?

- **Documentation:** [docs.kotodama.ai](https://docs.kotodama.ai)
- **Community Discord:** [discord.gg/kotodama](https://discord.gg/kotodama) — Chat with other creators
- **Email Support:** support@kotodama.ai (24-48h response)
- **Status Page:** [status.kotodama.ai](https://status.kotodama.ai) — Check server health

---

## 🎉 Ready to Create Magic?

You now have everything needed to bring your game ideas to life. Remember:

> **"The best game is the one you actually finish."** — Kotodama Team

Start small, iterate often, and let the AI handle the heavy lifting. Your imagination is the only limit.

**Happy creating!** 🚀✨

---

*Kotodama (言霊) — Where Words Become Worlds*  
© 2026 Kotodama Labs. All rights reserved.
