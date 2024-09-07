package main

import "core:fmt"
import "core:math"
import "core:slice"
import rl "vendor:raylib"
import b2 "vendor:box2d"


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
    game()
    return
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

game :: proc() {
    // defer rl.CloseWindow()
    playerPos: vector2 = {0,0}
    bullets: [dynamic]bullet
    for !rl.WindowShouldClose(){
        if rl.IsKeyDown(rl.KeyboardKey.RIGHT) || rl.IsKeyDown(rl.KeyboardKey.D){
            playerPos.x +=2;
        }
        if rl.IsKeyDown(rl.KeyboardKey.LEFT) || rl.IsKeyDown(rl.KeyboardKey.A){
            playerPos.x -=2;
        }
        if rl.IsKeyDown(rl.KeyboardKey.UP) || rl.IsKeyDown(rl.KeyboardKey.W){
            playerPos.y -=2;
        }
        if rl.IsKeyDown(rl.KeyboardKey.DOWN) || rl.IsKeyDown(rl.KeyboardKey.S){
            playerPos.y +=2;
        }
        rl.BeginDrawing()
        {
            rl.ClearBackground({255,190,0,255})
            //Draw player at the very end
            defer rl.DrawRectangle(auto_cast(windowSize.x/2 - entitySize.x/2), auto_cast(windowSize.y/2 - entitySize.y/2),
                            auto_cast(entitySize.x),auto_cast(entitySize.y),{0,50,255,255})
            rl.DrawRectangle(auto_cast(0-playerPos.x),auto_cast(0-playerPos.y),400,300,{255,255,255,255})
            rl.DrawRectangle(auto_cast(400-playerPos.x),auto_cast(300-playerPos.y),400,300,{255,255,255,255})
            #reverse for &item, index in bullets {
                item.position = getChangedPosition(item)
                rl.DrawRectangle(i32(item.position.x - playerPos.x), i32(item.position.y-playerPos.y), 20,20, {50,150,50,255})
                if item.position.x < 0 || item.position.x > 800 || item.position.y < 0 || item.position.y > 600
                {
                    ordered_remove(&bullets, index)
                    fmt.println("removing bullet...")
                    fmt.println(bullets)
                }
            }
            if rl.IsMouseButtonPressed(rl.MouseButton.LEFT){
                xDiff:f32 = auto_cast(rl.GetMouseX() - i32(windowSize.x/2))
                yDiff:f32 = auto_cast(rl.GetMouseY() - i32(windowSize.y/2))
                c :f32= math.sqrt(math.pow(xDiff,2) + math.pow(yDiff,2))
                xDiff /= c
                yDiff /= c
                blt:bullet = {
                    {f32(playerPos.x + windowSize.x/2), f32(playerPos.y  + windowSize.y/2)},
                    {xDiff, yDiff},
                    5
                }
                append(&bullets, blt)
            }
        }
        rl.EndDrawing()
    }
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

logic :: proc() {}
