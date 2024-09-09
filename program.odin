package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:slice"
import "core:time"
import rl "vendor:raylib"
import b2 "vendor:box2d"
import "core:strings"


targetFps:i32: 144
windowSize:vector2: {800,600}
entitySize:vector2: {40,60}

// getMiddle :: proc() -> vector2{
//     return {windowSize.x/2, windowSize.y/2}
// }

main :: proc() {
	fmt.println("Hellope!")
    rl.InitWindow(auto_cast(windowSize.x), auto_cast(windowSize.y), "odin test")
    rl.SetTargetFPS(targetFps)
    // rl.DisableCursor()

    //Data I need:
    //Camera - Player placement -> everything in the data will be moved according to the position of the player
    //List of Renderables -> List of all the data needed to render a damn thing
    //Logic loop -> things that happen when the game playes
    //
    //Procs I may need
    //Render by player position
    //Render (by camera position)
    game()
    return
}

color :: struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8
}

vector2 :: struct {
    x: f32,
    y: f32
}

bullet :: struct {
    position: vector2,
    normilizedDirection: vector2,
    speed: f32
}

character :: struct {
    position: vector2,
    speed: f32,
    health: i32
}

DrawRectangleByPlayer :: proc() {
    //For now only draws player rect but will be changed to drawing more thing if neccessary
    rl.DrawRectangle(auto_cast(windowSize.x/2 - entitySize.x/2), auto_cast(windowSize.y/2 - entitySize.y/2),
                        auto_cast(entitySize.x),auto_cast(entitySize.y),{0,50,255,255})
}

DrawRectangleOnMap :: proc(pos:vector2, playerPos:vector2, size:vector2, col:color = {255,35,35,255}) {
    rl.DrawRectangle(auto_cast(pos.x-playerPos.x),auto_cast(pos.y-playerPos.y),i32(size.x),i32(size.y), {col.r,col.g,col.b,col.a})
}

Level:=0
EnemiesLeft:=0

game :: proc() {
    // defer rl.CloseWindow()
    playerPos: vector2 = {windowSize.x/2, windowSize.y/2}
    initPlayerPos: vector2 = {windowSize.x/2, windowSize.y/2}
    nextLevelDoorOpen := false
    bullets: [dynamic]bullet
    enemies: [dynamic]character
    EnemiesLeft = 5
    // for i in 0..<1{
    //     enemy:character = {{600,300 + f32(i*200)}, 1, 30}
    //     append(&enemies, enemy)
    // }
    for !rl.WindowShouldClose(){
        playerPos = movementLogic(playerPos);
        rl.BeginDrawing()
        {
            rl.ClearBackground({255,190,0,255})
            //Draw player at the very end
            defer DrawRectangleByPlayer()
            levelText:cstring = fmt.ctprintf("Level: %v", Level)
            defer rl.DrawText(cstring(levelText), 20,20, 32, {0,0,0,255})
            enemiesLeftText:cstring = fmt.ctprintf("Enemies left: %v", EnemiesLeft)
            defer rl.DrawText(enemiesLeftText, 20,60, 32, {0,0,0,255})
            drawBackground(playerPos)

            #reverse for &item, index in bullets {
                item.position = getChangedPosition(item)
                playerPosWithoutOffset :vector2= {playerPos.x - initPlayerPos.x, playerPos.y - initPlayerPos.y}
                DrawRectangleOnMap(item.position, playerPosWithoutOffset, {14,14}, {50,150,50,255} )
                if item.position.x < -1000 || item.position.x > 2000 || item.position.y < -1000 || item.position.y > 2000
                {
                    ordered_remove(&bullets, index)
                }
                #reverse for &enemy, eIndex in enemies {
                    toPrint := item.position.x - enemy.position.x
                    if math.abs(item.position.x - enemy.position.x - entitySize.x/2 + 14) <= entitySize.x/2  &&
                        math.abs(item.position.y - enemy.position.y - entitySize.y/2 + 7) <= entitySize.y/2 + 7
                    {
                        ordered_remove(&bullets, index)
                        enemy.health -=10
                        if enemy.health <= 0
                        {
                            ordered_remove(&enemies, eIndex)
                            EnemiesLeft -=1
                            if EnemiesLeft == 0{
                                nextLevelDoorOpen = true
                            }
                        }
                    }
                }
            }

            if nextLevelDoorOpen {
                DrawRectangleOnMap({500,300}, {playerPos.x - initPlayerPos.x, playerPos.y - initPlayerPos.y}, {80,80},{50,255,50,255})
                if playerPos.x > 500 && playerPos.x < 580 && playerPos.y > 300 && playerPos.y < 380{
                    nextLevelDoorOpen = false
                    playerPos = initPlayerPos
                    Level += 1
                    EnemiesLeft = 5 + Level
                }
            }

            if len(enemies) == 0 && EnemiesLeft > 0{
                newEnemyPosition :vector2= {f32(rand.int31_max(8)*100), f32(rand.int31_max(5) * 100)}
                enemy:character = {newEnemyPosition, 1, 30}
                append(&enemies, enemy)
            }
            #reverse for &enemy, index in enemies {
                xDiff:f32 = playerPos.x - enemy.position.x
                yDiff:f32 = playerPos.y - enemy.position.y
                c := math.sqrt(math.pow(xDiff,2) + math.pow(yDiff,2))
                change :=  vector2_getChangedPosition(enemy.position, {xDiff/c, yDiff/c}, enemy.speed)
                enemy.position = change
                playerPosWithoutOffset :vector2= {playerPos.x - initPlayerPos.x, playerPos.y - initPlayerPos.y}
                DrawRectangleOnMap(enemy.position, playerPosWithoutOffset, {30,60})
            }

            if rl.IsMouseButtonPressed(rl.MouseButton.LEFT){
                xDiff:f32 = auto_cast(rl.GetMouseX() - i32(windowSize.x/2))
                yDiff:f32 = auto_cast(rl.GetMouseY() - i32(windowSize.y/2))
                c :f32= math.sqrt(math.pow(xDiff,2) + math.pow(yDiff,2))
                xDiff /= c
                yDiff /= c
                playerPosWithoutOffset :vector2= {playerPos.x - initPlayerPos.x, playerPos.y - initPlayerPos.y}
                blt:bullet = {
                    {f32(playerPosWithoutOffset.x + windowSize.x/2), f32(playerPosWithoutOffset.y  + windowSize.y/2)},
                    {xDiff, yDiff},
                    5
                }
                append(&bullets, blt)
            }
        }
        rl.EndDrawing()
    }


}

drawBackground :: proc(playerPos:vector2){
    //800x600 -> lets have 30x30 tiles so we need about 29~30 horizontally AND 22 vertically
    tileSize:vector2 = {30,30}
    //the -50 ~ 50 is how many tiles to render
    //Could actually only render tiles on screen -> less draw calls
    //Could change the for loop so that instead of using range we would use a certain amount based on window size or some constant
    for x in -50..=50{
        for y in -50..=50{
            col:color = {255,255,255,55}
            if (x+y) % 2 == 0 {
                col = {200,200,200,255}
            }
            rl.DrawRectangle(auto_cast(f32(x)*tileSize.x - playerPos.x), auto_cast(f32(y)*tileSize.y - playerPos.y), auto_cast(tileSize.x), auto_cast(tileSize.y), {col.r,col.g,col.b,col.a})
        }
    }
    rl.DrawRectangleLines(-50 - i32(playerPos.x),-50 - i32(playerPos.y),1500,1500, {0,0,0,255})
}

movementLogic :: proc(playerPos:vector2) -> vector2 {
    playerPos := playerPos
    if rl.IsKeyDown(rl.KeyboardKey.RIGHT) || rl.IsKeyDown(rl.KeyboardKey.D){
        playerPos.x +=2
        if playerPos.x > 1500-50-windowSize.x/2-entitySize.x/2{
            playerPos.x -=2
        }
    }
    if rl.IsKeyDown(rl.KeyboardKey.LEFT) || rl.IsKeyDown(rl.KeyboardKey.A){
        playerPos.x -=2;
        if playerPos.x < -50-windowSize.x/2+entitySize.x/2 {
            playerPos.x +=2
        }
    }
    if rl.IsKeyDown(rl.KeyboardKey.UP) || rl.IsKeyDown(rl.KeyboardKey.W){
        playerPos.y -=2;
        if playerPos.y < -50-windowSize.y/2+entitySize.y/2 {
            playerPos.y +=2
        }
    }
    if rl.IsKeyDown(rl.KeyboardKey.DOWN) || rl.IsKeyDown(rl.KeyboardKey.S){
        playerPos.y +=2;
        if playerPos.y > 1500-50-windowSize.y/2-entitySize.y/2{
            playerPos.y -=2
        }
    }
    return playerPos
}

getChangedPosition :: proc{
    bullet_getChangedPosition,
    vector2_getChangedPosition}

bullet_getChangedPosition :: proc(b: bullet) -> vector2{
    return vector2_getChangedPosition({b.position.x, b.position.y}, {b.normilizedDirection.x, b.normilizedDirection.y}, b.speed)
}
vector2_getChangedPosition :: proc(pos:vector2, dir:vector2, speed:f32) -> (newPos:vector2) {
    posChange:vector2 = {f32(dir.x*speed), f32(dir.y*speed)}
    newPos = {pos.x + posChange.x, pos.y + posChange.y}
    return
}
