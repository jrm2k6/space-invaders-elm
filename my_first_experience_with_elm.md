My first experience building a small game using Elm

In this post, I will explain how I build a small game (nothing crazy) using Elm and FRP.
I won't go too much in details, for different reasons.
First one, I am a beginner using FRP and Elm, I don't understand all the concepts in details.
Secondly, what I wanted to achieve was to build a small game quickly, grasping the main concepts of Elm and
having fun at the same time.


Some background here, I am a developer, having worked almost exclusively with imperative languages in production.
I have an interest for functional programming. I took few Coursera classes about it (Functional principles in Scala and
Programming Languages, that I can only recomment). I have also been playing a bit with Haskell, but mainly doing small homework
assignment. Nothing crazy, even if I plan to build something bigger, and useful (not always the case when it comes to my side projects) soon, but this is not the topic of this article.

Let's get started.

What I wanted to build was a small space invader game. You have a spaceship that you can rotate, and you can shoot enemies coming at you. If an enemy cross the imaginary line where you stand, you lose.

Having that said, we have now an idea of how we should build our game.
We can divide the implementation into three parts: the model, the updates, and the views.


What are those?

The model is a set of properties defining our game. In our case, it will be some input from the user, size of the game, position
of the different elements, number of elements and so on.

The updates are the way the elements of the games (model) are changing. How do we change the position of an element, depending on the inputs we received. This can sound a bit abstract, but it will be easy to understand later on.

Finally, the views are the visual representation of our model, what we are going to draw on the screen, the visual feedback we give to the user.


Moreover, the way I described the game gives us a nice way of implementing it.
We are going to take care of the spaceship first, the missiles after, and finally the enemies.


Implementation of the spaceship model, view, and the way we are going to interact with it?

Our game will contain a unique spaceship, located at the bottom center of our scene.
To represent it, we decided on drawing a triangle.

First, how are we going to represent our spaceship?

Our spaceship has a position, which is going to be represented by x, y. But, it also has a rotation property, because we want the spaceship to be able to turn:

we can then represent our spaceship using the following in Elm:

type Spaceship = {x:Float, y:Float, rotation:Float}

and we can also create our Game type

type Game = {spaceship:Spaceship}

We create a record having the type Spaceship. This is comparable to having a class in OOP. For more information, you should check this documentation (http://elm-lang.org/learn/Records.elm). It is going to be useful for the rest of this post.

Now that we have our model, we should create the view for it. I said we were going to use a triangle to represent our spaceship.
Let's see how we can do that in Elm.

We need to create a Form in Elm to represent our spaceship. 
http://elm-lang.org/learn/courses/beginner/Graphics.elm

It is pretty easy to do.
drawSpaceship spaceship clr = (filled clr (ngon 3 20))

ngon is a function taking two integers as parameters. The first one represents the number of sides that our polygon has, the second one the width of it. So in our case, (ngon 3 20) means a polygon with 3 sides, 20 pixels of width, therefore it gives us a triangle. Great, now let's give it some style. We just want it to be full of one color, so we are just using the function filled, that we compose with our initial triangle. We could have styled it in some other ways, but for this, you are free to check the documentation.

Great, we have our spaceship but we don't see anything on the screen yet. Let's display it, and we will fix it after.

To display elements on the screen, we are going to use a collage, as explained in the introduction to graphics referenced earlier.

So let's check our first version of display:

display : (Int, Int) -> Game -> Input -> Element
display (w,h) {spaceship}  i = collage w h [
                move (0, 0) (filled yellow (rect gameWidth gameHeight)),
                (drawSpaceship spaceship red)
                ]

OK. A lot of stuff here. 
display is a method taking a pair of ints representing the dimension of our window, a Game record as defined previously, and Input record, that you can ignore for now, and it returns an displayable Element.




