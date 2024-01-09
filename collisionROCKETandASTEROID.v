
module collisionROCKETandASTEROID(
start,
clock, 
reset,
rocketx ,
rockety,
asteroidx, 
asteroidy, // is asteroid y coming in as y+9 ?? or should i do that here 
gameover, 
destroyasteroid); 

input start;
input clock;
input reset;
input [7:0] rocketx;
input [6:0] rockety;
input [7:0] asteroidx;
input [6:0] asteroidy;
output reg gameover;
output reg destroyasteroid; 

reg [3:0] current_state, next_state; 

localparam S_wait=  3'd0, S_destroy=3'd2, S_play=3'd3;

always @(posedge clock)  begin 

case(current_state) 
S_wait:
begin
if (start) 
begin
next_state=S_play;
end 
else 
begin 
next_state=S_wait; 
end 
end 


 

S_play:  
begin
//state only checks if the rocket and the asteroid collides
if ((rocketx==asteroidx) && ( rockety==asteroidy+9))
begin
next_state=S_destroy; 
end 
else 
begin
next_state=S_play;
end 
end 


S_destroy:
begin
next_state=S_wait;
end



endcase 
end 

//datapath control signals 

always@(posedge clock) 
begin

gameover=1'b0;
destroyasteroid=1'b0;

case (current_state)
S_wait: 
begin 
end 

S_play: 
begin 
end


S_destroy:
begin
gameover=1'b1;
destroyasteroid=1'b1;
end 



endcase

end //for always block 

always@(posedge clock)
    begin
        if(reset)
            current_state <= S_wait;
        else
            current_state <= next_state;
    end // state_FFS


endmodule





