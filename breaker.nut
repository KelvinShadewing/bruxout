/*------------*\
| BRICK BUSTER |
\*------------*/
setWindowTitle("Bruxout");

//Import actor lib
donut("src/actors.nut");

//Load sprites
spBall <- newSprite("res/break-ball.png", 8, 8, 0, 0, 4, 4, 0);
spBrick <- newSprite("res/break-bricks.png", 16, 8, 0, 0, 0, 0, 0);
spPaddle <- newSprite("res/break-paddle.png", 32, 8, 0, 0, 16, 0, 0);
spStage <- newSprite("res/break-stage.png", 320, 240, 0, 0, 0, 0, 0);

//Globals
quit <- false;

//Actors
Ball <- class extends Actor
{
	hspeed = 0.0;
	vspeed = -1.0;

	constructor(_x, _y)
	{
		base.constructor(_x, _y);
		x = x.tofloat();
		y = y.tofloat();
		hspeed = 0.0;
		vspeed = -1.0;
	}

	function step()
	{
		//Motion
		if(y <= 12) vspeed = abs(vspeed);
		if(x <= 12) hspeed = abs(hspeed);
		if(x >= 308) hspeed = -(abs(hspeed));

		//Collision
		for(local mi = 0; mi < 8; mi++)
		{
			x += hspeed / 8;
			y += vspeed / 8;

			foreach(i in actor)
			{
				if(typeof i == "Paddle")
				{
					if(x >= i.x - 18 && x <= i.x + 18 && y >= 230 && vspeed > 0)
					{
						vspeed = -(vspeed);
						if(vspeed > -2) vspeed -= 0.1;
						hspeed = (x - i.x) / 10.0;
					}
				}

				if(typeof i == "Brick")
				{
					local hx = x;
					local hy = y;

					if(x < i.x) hx = i.x;
					else if(x > i.x + 16) hx = i.x + 16;
					else hx = x;

					if(y < i.y) hy = i.y;
					else if(y > i.y + 8) hy = i.y + 8;
					else hy = y;

					if(distance2(x, y, hx, hy) <= 4)
					{
						while(distance2(x, y, hx, hy) == 0)
						{
							x -= hspeed / 8;
							y -= vspeed / 8;
						}
						//Get nearest edge
						local ax = x - hx;
						local ay = y - hy;

						if(ax == 0) vspeed = -vspeed;
						else if(ay == 0) hspeed = -hspeed;
						else
						{
							vspeed = (ay < 0) ? -abs(vspeed) : abs(vspeed);
							hspeed = (ax < 0) ? -abs(hspeed) : abs(hspeed);
						}

						//Delete other
						deleteActor(i.id);
					}
				}
			}
		}

		//Out of bounds
		if(y > 244)
		{
			vspeed = -10;
			local pad = findActor("Paddle");
			if(pad != -1) x = actor[pad].x;
			else x = 160;
			y = 232;
		}

		//Draw
		drawSprite(spBall, 0, x, y);
	}

	function _typeof(){ return "Ball"; }
}

Brick <- class extends Actor
{
	frame = 0;

	constructor(_x, _y)
	{
		base.constructor(_x, _y);

		frame = randInt(16);
	}

	function step(){
		drawSprite(spBrick, frame, x, y);
	}

	function _typeof(){ return "Brick"; }
}

Paddle <- class extends Actor
{
	constructor(_x, _y)
	{
		x = 160;
		y = 232;
	}

	function step()
	{
		//Control
		if(keyDown(k_left) && x > 24) x -= 3;
		if(keyDown(k_right) && x < 296) x += 3;

		//Draw
		drawSprite(spPaddle, 0, x, y);
	}

	function _typeof(){ return "Paddle"; }
}

//Create scene
newActor(Paddle, 160, 232);
newActor(Ball, 160, 228);
for(local i = 0; i < 19; i++)
{
	for(local j = 0; j < 8; j++)
	{
		newActor(Brick, 8 + (i * 16), 32 + (j * 8));
	}
}

//Main loop
while(!quit)
{
	drawSprite(spStage, 0, 0, 0);

	runActors();

	if(keyPress(k_escape)) quit = true;
	update();
}