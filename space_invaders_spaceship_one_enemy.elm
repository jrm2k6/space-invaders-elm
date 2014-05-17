import Keyboard
import Window
import Debug

(gameWidth,gameHeight) = (600,800)
(halfWidth,halfHeight) = (300,400)


type Input = {space:Bool, dir:Int, delta:Time}
type Spaceship = {x:Float, y:Float, rotation:Float}
type Ball = {x:Float, y:Float, vx:Float, vy:Float, angle:Float, status:FlyingElementState}
type Enemy = {x:Float, y:Float, vx:Float, vy:Float, status:FlyingElementState}
data FlyingElementState = Flying | Colliding | ReadyToFly

type Game = {spaceship:Spaceship, ball:Ball, enemy:Enemy}

defaultGame : Game
defaultGame = 
  {
    spaceship = {x=0, y=-halfHeight+40, rotation=90},
    ball = {x=0, y=-halfHeight+40, vx=200, vy=200, angle=90, status=ReadyToFly},
    enemy = {x=100, y=halfHeight-40, vx=200, vy=200, status=Flying}
  }


delta = inSeconds <~ fps 35 
input = sampleOn delta (Input <~ Keyboard.space
                               ~ lift .x Keyboard.arrows
                               ~ delta)

stepGame : Input -> Game -> Game
stepGame ({space, dir, delta} as input) ({spaceship, ball, enemy} as game) =
      let spaceship' = moveSpaceship spaceship dir
          ball' = moveBall ball space delta spaceship.rotation
          enemy' = moveEnemy enemy delta ball
      in { game | spaceship  <- spaceship', ball <- ball', enemy <- enemy'}


moveSpaceship : Spaceship -> Int -> Spaceship
moveSpaceship spaceship angle = let rotation' = spaceship.rotation - ((toFloat angle) * 5)
                        in {spaceship | rotation <- rotation'}

moveEnemy : Enemy -> Time -> Ball -> Enemy
moveEnemy ({x,y,vx,vy} as enemy) delta ball = let y' = if (y > -halfHeight && y < halfHeight && not (isColliding enemy ball))
                                                        then y - vy * delta 
                                                        else halfHeight-40 
                        in {enemy | y <- y'}

isColliding : Enemy -> Ball -> Bool                       
isColliding enemy ball = (abs (enemy.x - ball.x)) < 30 && (abs (enemy.y - ball.y)) < 30

moveBall : Ball -> Bool -> Time -> Float -> Ball
moveBall ({x,y,vx,vy} as ball) space delta angle = let (x',y') = updateBallPosition ball delta
                                                       status' = updateBallState ball space 
                                                       angle' =  if ball.status == ReadyToFly then angle else ball.angle
                                                   in {ball | x <- x', y <- y', angle <- angle', status <- status' }

updateBallState : Ball -> Bool -> FlyingElementState 
updateBallState ball spacePressed = if ball.y > halfHeight || ball.x < -halfWidth || ball.x > halfWidth then ReadyToFly
                       else if (ball.status == ReadyToFly) && spacePressed then Flying
                       else ball.status


updateBallPosition : Ball -> Time -> (Float,Float)
updateBallPosition ({x,y,vx,vy,angle,status} as ball) delta= case (x, y, status) of
                                                                   (_,_,ReadyToFly)  -> (0, -halfHeight+40)
                                                                   (_,_,Flying)      -> (x + vx * delta * cos (convertDegreesToRadian angle), y + vy * delta * sin (convertDegreesToRadian ball.angle))

convertDegreesToRadian : Float -> Float
convertDegreesToRadian angleInDegree = angleInDegree / 180 * pi

drawSpaceship : Spaceship -> Color -> Form
drawSpaceship spaceship clr = (rotate (degrees spaceship.rotation) ( move (spaceship.x, spaceship.y) (filled clr (ngon 3 20))))

drawBall : Ball -> Color -> Form
drawBall ball clr = ( move (ball.x, ball.y) (filled clr (circle 4)))

drawEnemy : Enemy -> Color -> Form
drawEnemy enemy clr = move (enemy.x, enemy.y) (filled clr (ngon 4 15))


display : (Int, Int) -> Game -> Input -> Element
display (w,h) {spaceship, ball, enemy} i  = collage w h [
                move (0, 0) (filled yellow (rect gameWidth gameHeight)),
                (drawSpaceship spaceship red),
                (drawBall ball blue),
                (drawEnemy enemy green),
                (toForm (asText ball.status))
                ]

gameState : Signal Game
gameState = foldp stepGame defaultGame input

main = lift3 display Window.dimensions gameState input
