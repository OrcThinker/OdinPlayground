package main

import "core:fmt"
import rl "vendor:raylib"
import b2 "vendor:box2d"
import "core:math"
import "core:slice"

main :: proc() {
	fmt.println("Hellope!")
    gameLoop()
    return
    }
//Basic function/method semantics
//fnName :: proc(t1:T1, t2:T2) -> (returnType1, returnType2)
//The return values may be named like (ret1:retT1, ret2:retT2)
//Then the are pre-initialized and default return will return those values
vector2 :: struct {
    x: f32,
    y: f32
}
bullet :: struct {
    position: vector2,
    normilizedDirection: vector2,
    speed: f32
}

gameLoop :: proc() {
    rl.InitWindow(800,600, "odin test")
    // defer rl.CloseWindow()
    rl.DisableCursor()
    bullets: [dynamic]bullet
    targetFps:i32
    targetFps = 144
    rl.SetTargetFPS(targetFps)
    logicFps:i32
    logicFps = 30
    fpsPerLogic := targetFps/logicFps
    i,x,y:i32 //This is my first int value :)
    fpsCount:i32
    bx,by:i32 //For bullet only
    bulletExists:bool
    bxv,byv:i32
    for !rl.WindowShouldClose(){
        fpsCount +=1
        if fpsPerLogic < fpsCount{
            fpsCount = 0
            i+=5
            logic()
        }
        if rl.IsKeyDown(rl.KeyboardKey.RIGHT) || rl.IsKeyDown(rl.KeyboardKey.D){
            x +=2;
        }
        if rl.IsKeyDown(rl.KeyboardKey.LEFT) || rl.IsKeyDown(rl.KeyboardKey.A){
            x -=2;
        }
        if rl.IsKeyDown(rl.KeyboardKey.UP) || rl.IsKeyDown(rl.KeyboardKey.W){
            y -=2;
        }
        if rl.IsKeyDown(rl.KeyboardKey.DOWN) || rl.IsKeyDown(rl.KeyboardKey.S){
            y +=2;
        }
        rl.BeginDrawing()
        rl.ClearBackground({255,190,0,255})
        rl.DrawRectangle(0,0,400,300,{255,255,255,255})
        rl.DrawRectangle(400,300,400,300,{255,255,255,255})
        for &item in bullets {
            item.position = getChangedPosition(item)
            rl.DrawRectangle(i32(item.position.x), i32(item.position.y), 20,20, {50,150,50,255})
        }
        if i < 400{
            rl.DrawRectangle(i,i,50,50, {0,0,0,255})
        }
        rl.DrawRectangle(x,y,50,50, {150,0,0,255})
        {
            rl.DrawRectangle(auto_cast rl.GetMouseX()-1, rl.GetMouseY()-10, 2, 20, {0,0,0,255})
            rl.DrawRectangle(auto_cast rl.GetMouseX()-10, rl.GetMouseY()-1, 20, 2, {0,0,0,255})
        }
        if rl.IsMouseButtonPressed(rl.MouseButton.LEFT){
            xDiff:f32 = auto_cast(rl.GetMouseX() - x)
            yDiff:f32 = auto_cast(rl.GetMouseY() - y)
            c :f32= math.sqrt(math.pow(xDiff,2) + math.pow(yDiff,2))
            xDiff /= c
            yDiff /= c
            blt:bullet = {
                {f32(x + 25), f32(y + 25)},
                {xDiff, yDiff},
                5
            }
            append(&bullets, blt)
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
