




module game
	(
		CLOCK_50, SW,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY, LEDR, HEX0, HEX1, HEX4, HEX5,HEX3,					// On Board Keys
		
		// Bidirectionals
		PS2_CLK,
		PS2_DAT,
		

		VGA_CLK,   						
		VGA_HS,							
		VGA_VS,							
		VGA_BLANK_N,						
		VGA_SYNC_N,						
		VGA_R,   						
		VGA_G,	 						
		VGA_B   						
	);

//keyboard and vga adapters provided by UofT

	input			CLOCK_50;				
	input	[3:0]	KEY;	output [9:0] LEDR; input [9:0] SW;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX4;
	output [6:0] HEX5,HEX3;
	
	// Bidirectionals
	inout				PS2_CLK;
	inout				PS2_DAT;
	
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   					
	output			VGA_HS;					
	output			VGA_VS;					
	output			VGA_BLANK_N;				
	output			VGA_SYNC_N;				
	output	[7:0]	VGA_R;   				
	output	[7:0]	VGA_G;	 				
	output	[7:0]	VGA_B;   				
	
	wire resetn;
	

	wire writeEn, left, right, start, shoot, enter;
	
	//makes it so the hex display prints them as numbers not hex
	
	
       wire [3:0] digit0;
    wire [3:0] digit1;
    wire [3:0] digit2;


        assign digit0 = score % 10;
        assign digit1 = (score / 10) % 10;
        assign digit2 = score / 100;
   

    // Instantiate hex_decoder for each digit
 hex_decoder H1(
	.c(digit0),
	.display(HEX3)
);

	 hex_decoder H2(
	.c(digit1),
	.display(HEX4)
);
    	hex_decoder H3(
	.c(digit2),
	.display(HEX5)
);

	
	keyboard kb1 (
		.CLOCK_50(CLOCK_50), 
		.KEY(KEY), 
	.PS2_CLK(PS2_CLK),
	.PS2_DAT(PS2_DAT),
	.HEX0(HEX0),
		.HEX1(HEX1),
		.isleft(left), 
		.isright(right), 
		.isshoot(fire), 
		.isstart(enter),
		.LEDR(LEDR)
		);
		
		send_start ss(
			.reset(resetn),
			.enter(enter),
			.start(start),
			.clock(CLOCK_50)
		);
		
		
wire fire;

assign shoot = (!moving_rocket) ? fire:1'b0;
wire asteroidrocket;
wire destroy_asteroid2;

collisionLASERandASTEROID col3
(
.clock(CLOCK_50), 
.reset(resetn),  
.start(start),
.rocketx(current_x_rocket),
.rockety(current_y_rocket),
.asteroidx(current_x_asteroid),
.asteroidy(current_y_asteroid),
.laser_x(current_x_laser),
.laser_y( current_y_laser),
.asteroid_move_done(move_done_asteroid),
.asteroid_destroyed(destroyed_asteroid),
.laser_move_done(move_done_laser),
.laser_destroyed(desroyed_laser),
.fire(shoot), 
.destroy_laser(destroy_laser),
.destroy_asteroid(destroy_asteroid)
);

score_calc(
.reset(resetn),
.clock(CLOCK_50),
.score(score),
.laserhits(destroy_laser)
);


collisionASTEROIDandGROUND col2
(
.start(start),
.clock(CLOCK_50),
.reset(resetn),                                                                                                                                                                                              
.asteroid_move_done(move_done_asteroid),
.gameover(asteroidground)
);

collisionROCKETandASTEROID col1
(
.start(start),
.clock(CLOCK_50), //correct clock ?
.reset(resetn), //correct resetn??
.rocketx(current_x_rocket),
.rockety(current_y_rocket),
.asteroidx(current_x_asteroid),
.asteroidy(current_y_asteroid), // is asteroid y coming in as y+9 ?? or should i do that here 
.gameover(asteroidrocket),
.destroyasteroid(destroy_asteroid2)
);


	
	//to test on board
	//assign start = ~KEY[1];
	//assign left = ~KEY[3];
	//assign right = ~KEY[2];
	
	assign resetn = SW[0]; //active low
	
	wire restart;
 wire [8:0] score;
	
//	assign LEDR[0] = move_done;
//	assign LEDR[9:1] = current_x;
	
	
//for drawing screen
	wire [2:0] colour;
wire [7:0] draw_x_rocket, draw_x_asteroid, draw_x_laser, x;
wire [6:0] draw_y_rocket, draw_y_asteroid, draw_y_laser, y;
wire draw_rocket, draw_asteroid, draw_laser;
wire [2:0] iColor_rocket, iColor_asteroid, iColor_laser;

wire draw_done_rocket, draw_done_laser, draw_done_asteroid;

//collsion dector
wire [7:0] current_x_rocket, current_x_asteroid, current_x_laser;
wire [7:0] current_y_rocket, current_y_asteroid, current_y_laser;
wire move_done_rocket, move_done_asteroid, move_done_laser;
wire destroy_asteroid, destroy_laser, destroyed_asteroid, destroyed_laser;
wire game_over;
wire draw_done_clear;


wire moving_rocket;
rocket #(50_000_000, 22) rk (
	.clock(CLOCK_50), 
	.reset(resetn),
	.start(start),
	.left(left),
	.right(right),
	.draw(draw_rocket),
	.draw_x(draw_x_rocket),
	.draw_y(draw_y_rocket),
	.iColor(iColor_rocket),
	.current_x(current_x_rocket),
	.current_y(current_y_rocket),
	.draw_done(draw_done_rocket),
	.done(move_done_rocket),
	.moving_rocket(moving_rocket)

);



asteroid #(50_000_000, 1150_000, 10) a (
	.clock(CLOCK_50), 
	.reset(resetn),
	.start(start),
	.draw(draw_asteroid),
	.draw_x(draw_x_asteroid),
	.draw_y(draw_y_asteroid),
	.iColor(iColor_asteroid),
	.current_x(current_x_asteroid),
	.current_y(current_y_asteroid),
	.draw_done(draw_done_asteroid),
	.destroy(destroy_asteroid),
	.destroyed(destroyed_asteroid),
	.done(move_done_asteroid)

);

wire reset_drawl;

	laser #(50_000_000,100_000) l(
	.clock(CLOCK_50), 
	.reset(resetn),
	.start(start),
	.rocket_x(current_x_rocket),
	.rocket_y(current_y_rocket),
	.draw(draw_laser),	
	.fire(shoot), 
	.hit(destroy_laser), 
	.destroyed(destroyed_laser),
	.draw_x(draw_x_laser),
	.draw_y(draw_y_laser),
	.iColor(iColor_laser),
	.current_x(current_x_laser),
	.current_y(current_y_laser),
	.draw_done(draw_done_laser),
	.reset_draw(reset_drawl),
	.done(move_done_laser) //move done
);



assign game_over = move_done_asteroid ||destroy_asteroid2 ||asteroidrocket; 
assign restart = draw_done_clear;


draw_screen #(50_000_000) ds(
.clock(CLOCK_50), 
.reset(resetn), 

.start(start),
.game_over(game_over),

.draw_asteroid(draw_asteroid),
.draw_laser(draw_laser),
.draw_rocket(draw_rocket),

.draw_x_laser(draw_x_laser+7'd6), 
.draw_y_laser(draw_y_laser), 
.iColor_laser(iColor_laser),

 .draw_x_asteroid(draw_x_asteroid), 
.draw_y_asteroid(draw_y_asteroid), 
.iColor_asteroid(iColor_asteroid),

.draw_x_rocket(draw_x_rocket), 
.draw_y_rocket(draw_y_rocket), 
.iColor_rocket(iColor_rocket),


//output wire done_end_screen,
.draw_done_asteroid(draw_done_asteroid),
.draw_done_laser(draw_done_laser),
.draw_done_rocket(draw_done_rocket),

//done clearing screen
.draw_done_clear(draw_done_clear),

.oX(x),
.oY(y),
.oColor(colour),
.writeEn(writeEn)
 );




	
	vga_adapter VGA(
			.resetn(~resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	
	
	
endmodule



