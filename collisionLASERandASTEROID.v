module collisionLASERandASTEROID
(
clock, 
reset,
start,
rocketx ,
rockety,
asteroidx, 
asteroidy,
laser_x, 
laser_y, 
asteroid_move_done, 
asteroid_destroyed, 
laser_move_done, 
laser_destroyed, 
fire,  
destroy_laser, 
destroy_asteroid);

input clock;
input reset;
input start;
input [7:0]  rocketx;
input [6:0]  rockety;
input [7:0]  asteroidx;
input [6:0] asteroidy;
input [7:0]  laser_x;
input [6:0]  laser_y;
input asteroid_move_done;
input asteroid_destroyed;
input laser_move_done;
input laser_destroyed;
input fire;
output reg destroy_laser;
output reg destroy_asteroid; 
reg [8:0] score; 


//score= 4'b0000;

reg [4:0] current_state, next_state; 

localparam 
S_nothing=4'd0,
S_play=4'd1,
S_wait_fire= 4'd2,
S_check= 4'd3, 
S_destroy=4'd4;

always @(posedge clock)  
begin 

case (current_state) 
S_nothing:
begin
if (start)
begin 
next_state=S_play; 
end
else 
begin 
next_state=S_nothing; //stays in s_nothing state
end 
end 


S_play: 
begin
if (fire)
begin 
next_state=S_wait_fire; 
end
else 
begin 
next_state=S_play; //if laser is not fired it stays in the s_play state
end 
end 


S_wait_fire: 
begin 
if (!fire) // s wait fire only goes to s check when fire is pulsed down to zero 
begin 
next_state= S_check; 
end
else 
begin 
next_state= S_wait_fire; 
end //for else 
end //for state 


S_check:
begin 
if (laser_move_done) 
begin //then goes to splay state to wait for fire to be shot again because nothing was shot and laser reached the end of the screen
next_state=S_play; 
end
//now check if the locations of the laser and asteroids are same 
else if ((laser_x==asteroidx) && (laser_y==(asteroidy+9)))
begin 
next_state=S_destroy; //it will destroy the laser and asteroid and increase the score 
end 
else 
begin next_state=S_check; 
end 
end //end for state



S_destroy: //increases score and sends destroy signal 
begin 
next_state=S_play; //after destroying it goes to check if laser is shot again 
end



endcase 
end 




//datapath control signals 

always@(posedge clock) 
begin

destroy_laser=1'b0;
destroy_asteroid=1'b0;


case (current_state)


S_nothing: 
begin 
score= 9'b000000000;
end


S_play:
begin 
end


S_wait_fire:
begin 
end


S_check:
begin 
end 


S_destroy: //score is incremented here 
begin 
destroy_laser=1'b1;
destroy_asteroid=1'b1;
score<=score+1;
end 

endcase 
end 



always@(posedge clock)
    begin
        if(reset)
            current_state <= S_nothing;
        else
            current_state <= next_state;
    end // state_FFS


endmodule



















