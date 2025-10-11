# Quick Start Checklist for Modifying VB6 Asteroids Game

## 🎯 Goal
Transform classic asteroids game → Vertical falling asteroids with horizontal dodging

---

## 📋 Step-by-Step Checklist

### ✅ Step 1: Backup Original Code
- [ ] Make a copy of all original .frm, .bas, and .vbp files
- [ ] Name backup folder "Original_Code" or similar

### ✅ Step 2: Open Project in VB6
- [ ] Open the .vbp project file
- [ ] Locate the main form (usually Form1.frm)
- [ ] View the code (F7 key)

### ✅ Step 3: Modify Ship Movement
- [ ] Find `Form_KeyDown` or `Form_KeyPress` event
- [ ] **Comment out** (add ' at start of line):
  - [ ] Ship rotation code (angle calculations)
  - [ ] Forward thrust code
  - [ ] Any `Ship.Angle`, `Ship.dx`, `Ship.dy` updates
- [ ] **Add new code**:
  - [ ] Left arrow → `Ship.Left = Ship.Left - 8`
  - [ ] Right arrow → `Ship.Left = Ship.Left + 8`
  - [ ] Boundary checks (keep ship on screen)
- [ ] **Test**: Run game, verify ship moves left/right only

### ✅ Step 4: Fix Ship Position
- [ ] Find `Form_Load` event
- [ ] **Add code** to position ship at bottom:
  ```vb
  Ship.Top = Me.ScaleHeight - Ship.Height - 100
  Ship.Left = (Me.ScaleWidth - Ship.Width) / 2
  ```
- [ ] Find game loop (Timer event)
- [ ] **Remove** any code that updates `Ship.Top` based on velocity
- [ ] **Test**: Run game, ship should stay at bottom

### ✅ Step 5: Make Asteroids Fall Vertically
- [ ] Find asteroid creation/spawn function
- [ ] **Change spawn position**:
  ```vb
  Asteroid(i).Top = -Asteroid(i).Height  ' Start at top
  Asteroid(i).Left = Rnd * Me.ScaleWidth  ' Random X
  ```
- [ ] **Remove**:
  - [ ] Angle calculations
  - [ ] Random direction code
  - [ ] Any `Asteroid.dx` or horizontal velocity
- [ ] **Test**: Run game, asteroids should appear at top

### ✅ Step 6: Update Asteroid Movement
- [ ] Find game loop (Timer event)
- [ ] Locate asteroid update code
- [ ] **Replace movement code** with:
  ```vb
  Asteroid(i).Top = Asteroid(i).Top + AsteroidSpeed(i)
  ```
- [ ] **Remove**:
  - [ ] Screen wrapping (teleport to opposite side)
  - [ ] Bounce logic
  - [ ] Angle-based movement
- [ ] **Test**: Asteroids should fall straight down

### ✅ Step 7: Add Respawn Logic
- [ ] In asteroid update code (game loop)
- [ ] **Add check** for when asteroid goes off bottom:
  ```vb
  If Asteroid(i).Top > Me.ScaleHeight Then
      Asteroid(i).Top = -Asteroid(i).Height
      Asteroid(i).Left = Rnd * Me.ScaleWidth
      Score = Score + 10  ' Optional: award points
  End If
  ```
- [ ] **Test**: Asteroids should reappear at top after falling

### ✅ Step 8: Implement Collision Detection
- [ ] Find or create `CheckCollision` function (see CODE_EXAMPLES.md)
- [ ] In game loop, **add collision check**:
  ```vb
  If CheckCollision(Asteroid(i), Ship) Then
      GameOver
  End If
  ```
- [ ] **Test**: Game should end when ship hits asteroid

### ✅ Step 9: Add Game Over Logic
- [ ] Create `GameOver` subroutine (see CODE_EXAMPLES.md)
- [ ] **Add**:
  - [ ] Stop game timer
  - [ ] Show message box with score
  - [ ] Ask to play again
- [ ] Create `RestartGame` subroutine
- [ ] **Test**: Game should end and offer restart on collision

### ✅ Step 10: Add Score Display
- [ ] Add label to form (if not present)
- [ ] Name it `lblScore`
- [ ] In Form_Load: `lblScore.Caption = "Score: 0"`
- [ ] Update score when asteroids are dodged/destroyed
- [ ] **Test**: Score should update during gameplay

### ✅ Step 11: Polish and Balance
- [ ] Adjust ship speed (increase/decrease movement speed)
- [ ] Adjust asteroid speed (make easier/harder)
- [ ] Adjust number of asteroids
- [ ] Test for fun factor
- [ ] **Test**: Game should be challenging but playable

### ✅ Step 12: Document Changes
- [ ] Add comments explaining your modifications
- [ ] Note what you changed from original
- [ ] Explain why you made each change
- [ ] **Important for assignment submission!**

---

## 🔍 What to Look For in Original Code

### Files to Open:
1. **Form1.frm** (or similar) - Main game code
2. **Module1.bas** (if exists) - Helper functions

### Key Functions/Subs to Find:
- [ ] `Form_Load` - Game initialization
- [ ] `Form_KeyDown` or `Form_KeyPress` - Keyboard input
- [ ] `Timer1_Timer` or `GameTimer_Timer` - Main game loop
- [ ] `CreateAsteroid` or `SpawnAsteroid` - Asteroid generation
- [ ] Any function with "Update" or "Move" in name

### Variables to Look For:
- [ ] `Ship` - Spaceship control
- [ ] `Asteroid()` - Asteroid array
- [ ] `angle` or `rotation` - Remove these
- [ ] `dx`, `dy` or `velocityX`, `velocityY` - Modify these
- [ ] `Score` - Keep and use
- [ ] `Lives` - Optional to use

---

## 🎮 Testing Checklist

After all modifications, verify:

### Ship Controls:
- [ ] Left arrow moves ship left
- [ ] Right arrow moves ship right
- [ ] Ship cannot go off left edge
- [ ] Ship cannot go off right edge
- [ ] Ship does NOT move up/down
- [ ] Ship does NOT rotate
- [ ] Ship stays at bottom of screen

### Asteroid Behavior:
- [ ] Asteroids spawn at top
- [ ] Asteroids fall downward
- [ ] Asteroids do NOT move in random directions
- [ ] Asteroids respawn after reaching bottom
- [ ] Multiple asteroids are active at once

### Game Mechanics:
- [ ] Collision is detected accurately
- [ ] Game ends when ship hits asteroid
- [ ] Score is displayed
- [ ] Score increases during gameplay
- [ ] Game can be restarted after game over

### Overall:
- [ ] Game runs without errors
- [ ] Game is playable and fun
- [ ] Difficulty is reasonable
- [ ] All controls respond smoothly

---

## ⚠️ Common Mistakes to Avoid

1. **DON'T delete original code** - Comment it out instead
2. **DON'T forget to set ship position** in Form_Load
3. **DON'T leave rotation code active** - It will interfere
4. **DON'T forget boundary checks** - Ship will fly off screen
5. **DON'T use negative speed** for asteroids - Must be positive to fall
6. **DON'T forget to enable timer** in Form_Load
7. **DON'T test everything at once** - Test each step individually

---

## 🚀 Suggested Order of Implementation

```
1. Ship horizontal movement (30 min)
   ↓
2. Fix ship at bottom (15 min)
   ↓
3. Asteroids spawn at top (20 min)
   ↓
4. Asteroids fall down (20 min)
   ↓
5. Asteroids respawn (15 min)
   ↓
6. Collision detection (30 min)
   ↓
7. Game over logic (20 min)
   ↓
8. Score system (15 min)
   ↓
9. Testing & polish (30 min)
   ↓
10. Documentation (20 min)

Total estimated time: 3-4 hours
```

---

## 📝 Variables Declaration Template

Add these at the top of your form (General Declarations section):

```vb
' Game state
Private GameRunning As Boolean
Private Score As Long

' Ship control
Private LeftKeyPressed As Boolean
Private RightKeyPressed As Boolean

' Asteroids (adjust size based on your control array)
Private Const MaxAsteroids = 5
Private AsteroidSpeed(0 To 4) As Single
Private AsteroidDrift(0 To 4) As Single  ' Optional: for slight horizontal movement
```

---

## 🎯 Key Code Snippets (Quick Reference)

### Ship Movement (in Form_KeyDown):
```vb
If KeyCode = vbKeyLeft Then
    Ship.Left = Ship.Left - 8
    If Ship.Left < 0 Then Ship.Left = 0
End If
```

### Asteroid Falling (in Timer):
```vb
Asteroid(i).Top = Asteroid(i).Top + AsteroidSpeed(i)
If Asteroid(i).Top > Me.ScaleHeight Then
    Asteroid(i).Top = -Asteroid(i).Height
    Asteroid(i).Left = Rnd * Me.ScaleWidth
End If
```

### Collision Check (in Timer):
```vb
If CheckCollision(Asteroid(i), Ship) Then
    GameOver
End If
```

---

## 📚 Additional Resources

- **MODIFICATION_GUIDE.md** - Detailed explanation of all changes
- **CODE_EXAMPLES.md** - Complete code templates you can copy

---

## ✨ Optional Enhancements (After Basic Game Works)

- [ ] Add shooting mechanics (spacebar to fire)
- [ ] Add lives system (3 hits before game over)
- [ ] Add power-ups (shields, speed boost)
- [ ] Add different asteroid sizes
- [ ] Add increasing difficulty over time
- [ ] Add high score tracking
- [ ] Add sound effects
- [ ] Add visual effects (explosions)
- [ ] Add pause functionality (P key)

---

## 💡 Tips for Assignment Success

1. **Keep it simple first** - Get basic game working before adding extras
2. **Comment your code** - Explain what each section does
3. **Test frequently** - Don't wait until end to test
4. **Document changes** - Create a list of what you modified
5. **Make it your own** - Add unique features or visuals
6. **Check requirements** - Ensure you meet all assignment criteria

---

Good luck! Follow this checklist step by step, and you'll have your modified game working in no time! 🚀
