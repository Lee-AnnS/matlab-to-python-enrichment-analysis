# VB6 Code Examples for Vertical Asteroids Game

## Complete Code Templates

### 1. Form_Load Event (Game Initialization)

```vb
Private Sub Form_Load()
    ' Set up the form
    Me.Width = 8000   ' Adjust as needed
    Me.Height = 6000  ' Adjust as needed
    Me.Caption = "Dodge the Asteroids!"
    
    ' Position ship at bottom center
    Ship.Top = Me.ScaleHeight - Ship.Height - 100
    Ship.Left = (Me.ScaleWidth - Ship.Width) / 2
    
    ' Initialize game variables
    Score = 0
    GameRunning = True
    
    ' Create initial asteroids
    Dim i As Integer
    For i = 0 To MaxAsteroids - 1
        CreateAsteroid i
    Next i
    
    ' Start game timer (set Interval to 20-50 for smooth gameplay)
    GameTimer.Interval = 30  ' 30ms = ~33 FPS
    GameTimer.Enabled = True
End Sub
```

---

### 2. Keyboard Input Handling

```vb
' Variables at top of form (in General Declarations)
Private LeftKeyPressed As Boolean
Private RightKeyPressed As Boolean

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
    Select Case KeyCode
        Case vbKeyLeft
            LeftKeyPressed = True
        Case vbKeyRight
            RightKeyPressed = True
        Case vbKeySpace
            ' Optional: Shoot bullets
            If GameRunning Then FireBullet
    End Select
End Sub

Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)
    Select Case KeyCode
        Case vbKeyLeft
            LeftKeyPressed = False
        Case vbKeyRight
            RightKeyPressed = False
    End Select
End Sub
```

---

### 3. Main Game Loop (Timer Event)

```vb
Private Sub GameTimer_Timer()
    If Not GameRunning Then Exit Sub
    
    ' ===== UPDATE SHIP =====
    Const SHIP_SPEED = 8
    
    ' Move ship based on key presses
    If LeftKeyPressed Then
        Ship.Left = Ship.Left - SHIP_SPEED
        If Ship.Left < 0 Then Ship.Left = 0
    End If
    
    If RightKeyPressed Then
        Ship.Left = Ship.Left + SHIP_SPEED
        If Ship.Left + Ship.Width > Me.ScaleWidth Then
            Ship.Left = Me.ScaleWidth - Ship.Width
        End If
    End If
    
    ' ===== UPDATE ASTEROIDS =====
    Dim i As Integer
    For i = 0 To MaxAsteroids - 1
        If Asteroid(i).Visible Then
            ' Move asteroid down
            Asteroid(i).Top = Asteroid(i).Top + AsteroidSpeed(i)
            
            ' Optional: Add horizontal drift
            Asteroid(i).Left = Asteroid(i).Left + AsteroidDrift(i)
            
            ' Bounce off side walls (optional)
            If Asteroid(i).Left < 0 Or Asteroid(i).Left + Asteroid(i).Width > Me.ScaleWidth Then
                AsteroidDrift(i) = -AsteroidDrift(i)  ' Reverse drift
            End If
            
            ' Check if asteroid went off bottom
            If Asteroid(i).Top > Me.ScaleHeight Then
                ' Player survived this asteroid - award points
                Score = Score + 10
                lblScore.Caption = "Score: " & Score
                ' Respawn asteroid at top
                CreateAsteroid i
            End If
            
            ' Check collision with ship
            If CheckCollision(Asteroid(i), Ship) Then
                GameOver
                Exit Sub
            End If
        End If
    Next i
    
    ' ===== UPDATE BULLETS (Optional) =====
    For i = 0 To MaxBullets - 1
        If Bullet(i).Visible Then
            ' Move bullet up
            Bullet(i).Top = Bullet(i).Top - 10
            
            ' Remove if off screen
            If Bullet(i).Top < 0 Then
                Bullet(i).Visible = False
            End If
            
            ' Check if bullet hits asteroid
            Dim j As Integer
            For j = 0 To MaxAsteroids - 1
                If Asteroid(j).Visible Then
                    If CheckCollision(Bullet(i), Asteroid(j)) Then
                        ' Hit! Remove both
                        Bullet(i).Visible = False
                        Score = Score + 50  ' More points for shooting
                        lblScore.Caption = "Score: " & Score
                        CreateAsteroid j  ' Respawn asteroid
                        Exit For
                    End If
                End If
            Next j
        End If
    Next i
End Sub
```

---

### 4. Asteroid Creation Function

```vb
' Variables at top of form (General Declarations)
Private Const MaxAsteroids = 5  ' Adjust number of asteroids
Private AsteroidSpeed(0 To 4) As Single
Private AsteroidDrift(0 To 4) As Single

Private Sub CreateAsteroid(Index As Integer)
    ' Random horizontal position at top
    Asteroid(Index).Left = Rnd * (Me.ScaleWidth - Asteroid(Index).Width)
    
    ' Start above screen so it "enters" smoothly
    Asteroid(Index).Top = -Asteroid(Index).Height - (Rnd * 500)
    
    ' Random falling speed (adjust for difficulty)
    AsteroidSpeed(Index) = 3 + (Rnd * 4)  ' Speed between 3-7
    
    ' Optional: Random horizontal drift for variety
    AsteroidDrift(Index) = (Rnd * 2 - 1) * 2  ' Drift between -2 and 2
    
    ' Make visible
    Asteroid(Index).Visible = True
End Sub
```

---

### 5. Collision Detection

```vb
Private Function CheckCollision(Obj1 As Control, Obj2 As Control) As Boolean
    ' Get boundaries of first object
    Dim left1 As Single, right1 As Single
    Dim top1 As Single, bottom1 As Single
    
    left1 = Obj1.Left
    right1 = Obj1.Left + Obj1.Width
    top1 = Obj1.Top
    bottom1 = Obj1.Top + Obj1.Height
    
    ' Get boundaries of second object
    Dim left2 As Single, right2 As Single
    Dim top2 As Single, bottom2 As Single
    
    left2 = Obj2.Left
    right2 = Obj2.Left + Obj2.Width
    top2 = Obj2.Top
    bottom2 = Obj2.Top + Obj2.Height
    
    ' Check if rectangles overlap
    If right1 < left2 Then CheckCollision = False: Exit Function
    If left1 > right2 Then CheckCollision = False: Exit Function
    If bottom1 < top2 Then CheckCollision = False: Exit Function
    If top1 > bottom2 Then CheckCollision = False: Exit Function
    
    ' If we get here, they're colliding
    CheckCollision = True
End Function
```

---

### 6. Game Over and Restart

```vb
Private Sub GameOver()
    ' Stop the game
    GameRunning = False
    GameTimer.Enabled = False
    
    ' Show game over message
    Dim msg As String
    msg = "Game Over!" & vbCrLf & vbCrLf
    msg = msg & "Your Score: " & Score & vbCrLf & vbCrLf
    msg = msg & "Play Again?"
    
    Dim response As Integer
    response = MsgBox(msg, vbYesNo + vbExclamation, "Game Over")
    
    If response = vbYes Then
        RestartGame
    Else
        Unload Me  ' Close the form
    End If
End Sub

Private Sub RestartGame()
    Dim i As Integer
    
    ' Reset score
    Score = 0
    lblScore.Caption = "Score: 0"
    
    ' Reset ship position
    Ship.Top = Me.ScaleHeight - Ship.Height - 100
    Ship.Left = (Me.ScaleWidth - Ship.Width) / 2
    
    ' Reset key states
    LeftKeyPressed = False
    RightKeyPressed = False
    
    ' Reset all asteroids
    For i = 0 To MaxAsteroids - 1
        CreateAsteroid i
    Next i
    
    ' Reset all bullets (if using)
    For i = 0 To MaxBullets - 1
        Bullet(i).Visible = False
    Next i
    
    ' Restart game
    GameRunning = True
    GameTimer.Enabled = True
End Sub
```

---

### 7. Optional: Bullet Shooting System

```vb
' Variables at top of form (General Declarations)
Private Const MaxBullets = 10
Private NextBullet As Integer

Private Sub FireBullet()
    ' Find next available bullet
    Bullet(NextBullet).Left = Ship.Left + (Ship.Width / 2) - (Bullet(NextBullet).Width / 2)
    Bullet(NextBullet).Top = Ship.Top
    Bullet(NextBullet).Visible = True
    
    ' Move to next bullet slot
    NextBullet = (NextBullet + 1) Mod MaxBullets
End Sub
```

---

### 8. Complete Variable Declarations (Top of Form)

```vb
' ===== Place at top of form in General Declarations =====

' Game state
Private GameRunning As Boolean
Private Score As Long

' Ship control
Private LeftKeyPressed As Boolean
Private RightKeyPressed As Boolean

' Asteroids
Private Const MaxAsteroids = 5
Private AsteroidSpeed(0 To 4) As Single
Private AsteroidDrift(0 To 4) As Single

' Bullets (optional)
Private Const MaxBullets = 10
Private NextBullet As Integer

' You may need to adjust the array sizes based on how many
' asteroid and bullet controls you create on your form
```

---

## Setting Up Your Form (Design View)

### Controls You Need:

1. **Ship (Image or Shape)**
   - Name: `Ship`
   - Position: Will be set in code
   - Size: About 400x400 twips (adjust as needed)

2. **Asteroids (Image or Shape Array)**
   - Name: `Asteroid`
   - Index: 0 to 4 (creates control array)
   - Size: About 600x600 twips each
   - Visible: False (will be shown in code)

3. **Bullets (Image or Shape Array) - Optional**
   - Name: `Bullet`
   - Index: 0 to 9
   - Size: About 100x200 twips each
   - Visible: False

4. **Score Label**
   - Name: `lblScore`
   - Caption: "Score: 0"
   - Position: Top of form
   - Font: Large and readable

5. **Game Timer**
   - Name: `GameTimer`
   - Interval: 30 (30 milliseconds)
   - Enabled: False (will be enabled in Form_Load)

### Creating Control Arrays:

To create a control array (multiple asteroids):
1. Create first asteroid control, name it `Asteroid`
2. Set its Index property to 0
3. Copy it (Ctrl+C)
4. Paste it (Ctrl+V)
5. VB6 will ask "You already have a control named 'Asteroid'. Do you want to create a control array?" - Click **Yes**
6. Repeat paste for each additional asteroid (will auto-increment index)

---

## Difficulty Settings

### Easy Mode
```vb
Private Const MaxAsteroids = 3
AsteroidSpeed(Index) = 2 + (Rnd * 2)  ' Speed 2-4
AsteroidDrift(Index) = 0  ' No drift
```

### Medium Mode
```vb
Private Const MaxAsteroids = 5
AsteroidSpeed(Index) = 3 + (Rnd * 4)  ' Speed 3-7
AsteroidDrift(Index) = (Rnd * 2 - 1) * 1.5  ' Small drift
```

### Hard Mode
```vb
Private Const MaxAsteroids = 8
AsteroidSpeed(Index) = 5 + (Rnd * 6)  ' Speed 5-11
AsteroidDrift(Index) = (Rnd * 2 - 1) * 3  ' More drift
```

---

## Progressive Difficulty (Gets Harder Over Time)

```vb
' Add to General Declarations
Private GameTime As Long
Private DifficultyMultiplier As Single

' In Form_Load
DifficultyMultiplier = 1

' In GameTimer_Timer (add at end)
GameTime = GameTime + 1

' Every 10 seconds (333 ticks at 30ms), increase difficulty
If GameTime Mod 333 = 0 Then
    DifficultyMultiplier = DifficultyMultiplier + 0.1
    
    ' Update all asteroid speeds
    Dim i As Integer
    For i = 0 To MaxAsteroids - 1
        AsteroidSpeed(i) = AsteroidSpeed(i) * 1.05  ' 5% faster
    Next i
End If
```

---

## Enhancements You Can Add

### 1. Sound Effects (Using API)
```vb
' Add to General Declarations
Private Declare Function PlaySound Lib "winmm.dll" Alias "PlaySoundA" _
    (ByVal lpszName As String, ByVal hModule As Long, ByVal dwFlags As Long) As Long

Private Const SND_ASYNC = &H1
Private Const SND_FILENAME = &H20000

' Play sound
PlaySound "C:\path\to\explosion.wav", 0, SND_ASYNC Or SND_FILENAME
```

### 2. Lives System
```vb
' Add to General Declarations
Private Lives As Integer

' In Form_Load
Lives = 3
lblLives.Caption = "Lives: " & Lives

' Replace GameOver() with:
Private Sub LoseLife()
    Lives = Lives - 1
    lblLives.Caption = "Lives: " & Lives
    
    If Lives <= 0 Then
        GameOver
    Else
        ' Flash ship or show damage
        Ship.Visible = False
        DoEvents
        Sleep 200  ' Need to declare Sleep API
        Ship.Visible = True
        
        ' Reset ship position
        Ship.Left = (Me.ScaleWidth - Ship.Width) / 2
    End If
End Sub
```

### 3. Power-Ups
```vb
' Add shield power-up that makes you invincible for 5 seconds
Private ShieldActive As Boolean
Private ShieldTime As Long

' When collecting power-up
ShieldActive = True
ShieldTime = GameTime + 167  ' 5 seconds at 30ms timer

' In collision detection
If CheckCollision(Asteroid(i), Ship) Then
    If Not ShieldActive Then
        GameOver
    End If
End If

' In game loop
If ShieldActive And GameTime >= ShieldTime Then
    ShieldActive = False
End If
```

---

## Troubleshooting Common Issues

### Issue: Asteroids don't appear
**Solution**: Make sure `Asteroid(i).Visible = True` is set in CreateAsteroid

### Issue: Ship moves too fast/slow
**Solution**: Adjust `SHIP_SPEED` constant (try values 5-15)

### Issue: Game is too easy/hard
**Solution**: Adjust `MaxAsteroids` and asteroid speed ranges

### Issue: Collisions not detected
**Solution**: Check that object names match in CheckCollision function

### Issue: Asteroids spawn on top of each other
**Solution**: Add staggered spawn delays in CreateAsteroid

---

## Performance Tips

1. Use Shapes instead of Images if possible (faster rendering)
2. Keep MaxAsteroids reasonable (5-10 max)
3. Set timer interval to 20-50ms (not less than 20)
4. Use `Me.AutoRedraw = False` for better performance
5. Minimize calculations in game loop

---

Good luck with your assignment! These code examples should give you everything you need.
