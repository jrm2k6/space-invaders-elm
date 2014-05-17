import Keyboard
import Window
import Debug

(gameWidth,gameHeight) = (600,800)
(halfWidth,halfHeight) = (300,400)


type Input = {dir:Int}
type Spaceship = {x:Float, y:Float, rotation:Float}
type Game = {spaceship:Spaceship}

defaultGame : Game
defaultGame = 
{ 
	spaceship = {x=0, y=-halfHeight+40, rotation=90}
}


delta = inSeconds <~ fps 35 
input = sampleOn delta (Input <~ lift .x Keyboard.arrows)

stepGame : Input -> Game -> Game
stepGame ({dir} as input) ({spaceship} as game) =
      let spaceship' = moveSpaceship spaceship dir
      in { game | spaceship  <- spaceship'}


moveSpaceship : Spaceship -> Int -> Spaceship
moveSpaceship spaceship angle = let rotation' = spaceship.rotation - ((toFloat angle) * 5)
                        in {spaceship | rotation <- rotation'}


drawSpaceship : Spaceship -> Color -> Form
drawSpaceship spaceship clr = (rotate (degrees spaceship.rotation) ( move (spaceship.x, spaceship.y) (filled clr (ngon 3 20))))


display : (Int, Int) -> Game -> Input -> Element
display (w,h) {spaceship} i  = collage w h [
                move (0, 0) (filled yellow (rect gameWidth gameHeight)),
                (drawSpaceship spaceship red)
                ]

gameState : Signal Game
gameState = foldp stepGame defaultGame input

main = lift3 display Window.dimensions gameState input
