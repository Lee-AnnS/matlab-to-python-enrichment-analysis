# Asteroids Game Modification Guide
## Converting from Classic Asteroids to Vertical Falling Asteroids

### Overview
This guide will help you modify a classic VB6 Asteroids game into a vertical falling asteroids game where:
- Asteroids fall from top to bottom
- Spaceship moves horizontally at the bottom
- Player must dodge asteroids to survive

---

## Key Changes Required

### 1. **Spaceship Movement (Form Code - Usually Form1.frm)**

#### Original Movement System
The classic asteroids game typically has:
- Rotation (turning left/right)
- Forward thrust in the direction the ship is facing
- Momentum/inertia physics
- Free movement in all directions

#### New Movement System Required
- Remove rotation mechanics
- Keep spaceship at fixed Y position (near bottom)
- Only allow horizontal (left/right) movement
- Set boundaries so ship can't leave the screen

#### Code Sections to Modify:

**a) In Form_KeyDown or Form_KeyPress event:**

```vb
' REMOVE or COMMENT OUT:
' - Rotation code (usually Left/Right arrow keys rotating ship angle)
' - Forward thrust code (usually Up arrow applying velocity in direction)
' - Any code calculating ship.dx, ship.dy based on angle

' REPLACE WITH:
Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
    Const SHIP_SPEED = 10  ' Adjust speed as needed
    
    Select Case KeyCode
        Case vbKeyLeft
            ' Move ship left
            Ship.Left = Ship.Left - SHIP_SPEED
            ' Keep ship on screen
            If Ship.Left < 0 Then Ship.Left = 0
            
        Case vbKeyRight
            ' Move ship right
            Ship.Left = Ship.Left + SHIP_SPEED
            ' Keep ship on screen
            If Ship.Left > Me.ScaleWidth - Ship.Width Then
                Ship.Left = Me.ScaleWidth - Ship.Width
            End If
            
        ' Optional: Add shooting with spacebar
        Case vbKeySpace
            FireBullet
    End Select
End Sub
```

**b) In Form_Load or initialization:**

```vb
Private Sub Form_Load()
    ' Position ship at bottom center
    Ship.Top = Me.ScaleHeight - Ship.Height - 50  ' 50 pixels from bottom
    Ship.Left = (Me.ScaleWidth - Ship.Width) / 2   ' Center horizontally
    
    ' Lock ship's vertical position
    ' Make sure no other code moves Ship.Top during gameplay
End Sub
```

**c) Remove ship momentum/physics:**
- Find any Timer event or game loop that updates ship position based on velocity
- Remove lines like: `Ship.Left = Ship.Left + shipVelocityX`
- Remove lines like: `Ship.Top = Ship.Top + shipVelocityY`
- The ship should ONLY move when keys are pressed, not drift

---

### 2. **Asteroid Generation and Movement**

#### Original System
- Asteroids spawn randomly across screen
- Move in random directions at random angles
- Bounce or wrap around screen edges

#### New System Required
- Asteroids spawn at top of screen
- Fall straight down (vertical movement only)
- Respawn at top when they reach bottom
- Random horizontal positions

#### Code Sections to Modify:

**a) In CreateAsteroid or SpawnAsteroid function:**

```vb
Private Sub CreateAsteroid(Index As Integer)
    ' Random horizontal position at TOP of screen
    Asteroid(Index).Left = Rnd * (Me.ScaleWidth - Asteroid(Index).Width)
    Asteroid(Index).Top = -Asteroid(Index).Height  ' Start above screen
    
    ' Vertical falling speed (positive = down)
    AsteroidSpeedY(Index) = 3 + Rnd * 5  ' Random speed between 3-8
    
    ' Remove horizontal movement
    AsteroidSpeedX(Index) = 0  ' No horizontal drift
    ' OR add slight horizontal drift:
    ' AsteroidSpeedX(Index) = (Rnd * 2 - 1) * 1.5  ' Small random drift
    
    Asteroid(Index).Visible = True
End Sub
```

**b) In Timer event or game loop (asteroid update):**

```vb
Private Sub GameTimer_Timer()
    Dim i As Integer
    
    ' Update each asteroid
    For i = 0 To MaxAsteroids - 1
        If Asteroid(i).Visible Then
            ' REMOVE: Complex angle-based movement
            ' REMOVE: Screen wrapping logic
            ' REMOVE: Bounce logic
            
            ' ADD: Simple vertical falling
            Asteroid(i).Top = Asteroid(i).Top + AsteroidSpeedY(i)
            
            ' Optional: Add slight horizontal drift
            ' Asteroid(i).Left = Asteroid(i).Left + AsteroidSpeedX(i)
            
            ' Check if asteroid went off bottom of screen
            If Asteroid(i).Top > Me.ScaleHeight Then
                ' Respawn at top
                CreateAsteroid i
                ' Optional: Award points for surviving
                Score = Score + 10
                UpdateScore
            End If
            
            ' Check collision with ship
            If CheckCollision(Asteroid(i), Ship) Then
                GameOver
            End If
        End If
    Next i
End Sub
```

**c) Remove screen wrapping:**
- Find code that wraps asteroids to opposite side
- Replace with respawn logic shown above

---

### 3. **Collision Detection**

#### Check Collision Function:

```vb
Private Function CheckCollision(Obj1 As Object, Obj2 As Object) As Boolean
    ' Simple rectangle collision detection
    Dim left1 As Single, right1 As Single, top1 As Single, bottom1 As Single
    Dim left2 As Single, right2 As Single, top2 As Single, bottom2 As Single
    
    left1 = Obj1.Left
    right1 = Obj1.Left + Obj1.Width
    top1 = Obj1.Top
    bottom1 = Obj1.Top + Obj1.Height
    
    left2 = Obj2.Left
    right2 = Obj2.Left + Obj2.Width
    top2 = Obj2.Top
    bottom2 = Obj2.Top + Obj2.Height
    
    ' Check if rectangles overlap
    CheckCollision = Not (right1 < left2 Or left1 > right2 Or _
                          bottom1 < top2 Or top1 > bottom2)
End Function
```

---

### 4. **Game Over Logic**

```vb
Private Sub GameOver()
    GameTimer.Enabled = False  ' Stop game loop
    
    MsgBox "Game Over! Your Score: " & Score, vbExclamation, "Game Over"
    
    ' Option to restart
    Dim response As Integer
    response = MsgBox("Play Again?", vbYesNo, "Game Over")
    
    If response = vbYes Then
        RestartGame
    Else
        End  ' Close game
    End If
End Sub

Private Sub RestartGame()
    Dim i As Integer
    
    ' Reset score
    Score = 0
    UpdateScore
    
    ' Reset ship position
    Ship.Top = Me.ScaleHeight - Ship.Height - 50
    Ship.Left = (Me.ScaleWidth - Ship.Width) / 2
    
    ' Reset all asteroids
    For i = 0 To MaxAsteroids - 1
        CreateAsteroid i
    Next i
    
    ' Restart game loop
    GameTimer.Enabled = True
End Sub
```

---

### 5. **Difficulty Progression (Optional Enhancement)**

```vb
' Add to game loop
Private GameTime As Integer
Private DifficultyLevel As Integer

Private Sub GameTimer_Timer()
    GameTime = GameTime + 1
    
    ' Increase difficulty every 500 ticks (about 10 seconds at 50ms timer)
    If GameTime Mod 500 = 0 Then
        DifficultyLevel = DifficultyLevel + 1
        ' Increase asteroid speed
        For i = 0 To MaxAsteroids - 1
            AsteroidSpeedY(i) = AsteroidSpeedY(i) * 1.1  ' 10% faster
        Next i
        ' Or spawn more asteroids
        ' SpawnNewAsteroid
    End If
    
    ' ... rest of game loop
End Sub
```

---

## Step-by-Step Implementation Order

### Phase 1: Ship Movement (Start Here)
1. Open your main Form file (.frm)
2. Find Form_KeyDown or Form_KeyPress
3. Comment out all rotation and thrust code
4. Add simple left/right movement code
5. Test: Run the game and verify ship only moves horizontally

### Phase 2: Fix Ship Position
1. Find Form_Load
2. Set ship's Top position to bottom of screen
3. Find any code that updates ship position in game loop
4. Remove velocity-based movement
5. Test: Verify ship stays at bottom

### Phase 3: Asteroid Falling
1. Find asteroid spawn/creation function
2. Change spawn position to top of screen
3. Set vertical speed (positive value)
4. Remove or zero-out horizontal speed/angle
5. Test: Asteroids should fall straight down

### Phase 4: Asteroid Respawn
1. Find asteroid update code in game loop
2. Remove screen wrapping logic
3. Add check for asteroid going off bottom
4. Respawn asteroid at top when it exits
5. Test: Asteroids should continuously fall

### Phase 5: Collision Detection
1. Find or create collision detection function
2. Add call to collision check in game loop
3. Implement game over when collision occurs
4. Test: Verify game ends when ship hits asteroid

### Phase 6: Polish
1. Add score display
2. Add restart functionality
3. Adjust speeds for gameplay balance
4. Add sound effects (optional)
5. Test entire game flow

---

## Common Variable Names to Look For

In typical VB6 asteroids games, look for these variable names:
- `Ship` or `Player` - the spaceship object
- `Asteroid()` - array of asteroid objects
- `angle` or `rotation` - ship rotation (remove this)
- `dx`, `dy` or `velocityX`, `velocityY` - movement velocities
- `GameTimer` or `Timer1` - main game loop
- `Score` - player score
- `Lives` - player lives (may want to set to 1)

---

## Files You'll Likely Need to Edit

1. **Form1.frm** (or similar) - Main game form
   - Contains visual controls (ship, asteroids)
   - Contains game loop (Timer event)
   - Contains keyboard input handling

2. **Module1.bas** (if exists) - Game logic module
   - May contain collision detection
   - May contain score/game state management

3. **Form1.frx** (graphics file)
   - Binary file, don't edit directly
   - Contains images for ship/asteroids

---

## Testing Checklist

- [ ] Ship moves left with Left arrow
- [ ] Ship moves right with Right arrow
- [ ] Ship cannot move off screen edges
- [ ] Ship stays at bottom (doesn't move vertically)
- [ ] Asteroids spawn at top
- [ ] Asteroids fall downward
- [ ] Asteroids respawn at top after reaching bottom
- [ ] Game detects collision between ship and asteroid
- [ ] Game ends when collision occurs
- [ ] Score increases (if implemented)
- [ ] Game can be restarted after game over

---

## Tips for Your Assignment

1. **Document Your Changes**: Add comments explaining what you changed
2. **Keep Original Code**: Comment out old code instead of deleting it
3. **Test Incrementally**: Test after each major change
4. **Adjust Values**: Tweak speed and spawn rates for fun gameplay
5. **Add Your Own Features**: Consider adding:
   - Power-ups
   - Different asteroid sizes/speeds
   - High score system
   - Lives system (3 hits before game over)
   - Shooting asteroids to destroy them

---

## Quick Reference: Key Code Changes

### Before (Classic Asteroids):
```vb
' Ship rotates and thrusts
Ship.Angle = Ship.Angle + rotationSpeed
Ship.dx = Ship.dx + thrust * Cos(Ship.Angle)
Ship.dy = Ship.dy + thrust * Sin(Ship.Angle)
Ship.Left = Ship.Left + Ship.dx
Ship.Top = Ship.Top + Ship.dy
```

### After (Vertical Fall):
```vb
' Ship moves horizontally only
If LeftKeyPressed Then
    Ship.Left = Ship.Left - SHIP_SPEED
ElseIf RightKeyPressed Then
    Ship.Left = Ship.Left + SHIP_SPEED
End If
Ship.Top = FIXED_BOTTOM_POSITION  ' Never changes
```

### Before (Asteroid Movement):
```vb
' Asteroids move at angles
Asteroid.Left = Asteroid.Left + Asteroid.dx
Asteroid.Top = Asteroid.Top + Asteroid.dy
' Wrap around screen edges
If Asteroid.Left > ScreenWidth Then Asteroid.Left = 0
```

### After (Asteroid Movement):
```vb
' Asteroids fall straight down
Asteroid.Top = Asteroid.Top + AsteroidSpeed  ' Only vertical
' Respawn at top when off bottom
If Asteroid.Top > ScreenHeight Then
    Asteroid.Top = -Asteroid.Height
    Asteroid.Left = Rnd * ScreenWidth
End If
```

---

Good luck with your assignment! Start with Phase 1 and work through each phase systematically.
