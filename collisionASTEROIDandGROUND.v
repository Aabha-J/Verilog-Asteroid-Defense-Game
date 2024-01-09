
module collisionASTEROIDandGROUND(
start,
clock, 
reset,                                                                                                                                                                                                
asteroid_move_done,
gameover);

input start;
input clock; 
input reset; 
input asteroid_move_done;
output reg gameover; 


reg [3:0] current_state, next_state; 

localparam S_wait=  3'd0, S_check= 3'd1;



always @(posedge clock)  begin 

case(current_state) 
S_wait:
begin
if (start)
begin 
next_state=S_check; 
end 
else
begin 
next_state=S_wait; 
end 
end 





S_check: 
begin
gameover=asteroid_move_done;
//state only checks if the rocket and the asteroid collides 
begin 
next_state=S_wait; //should it go to splay state or swait state?
end 
end
 


endcase 
end 

//datapath control signals 

always@(posedge clock)
    begin
        if(reset)
            current_state <= S_wait;
        else
            current_state <= next_state;
    end // state_FFS


endmodule


