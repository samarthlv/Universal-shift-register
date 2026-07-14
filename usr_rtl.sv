/////////////////////////////////////////////Specifications of Universal Shift Register//////////////////////////////////////////////////////////

/*A Universal Shift Register (USR) is a digital sequential circuit that can perform multiple operations on data bits, including:

              1)Parallel Load – Load all 4 bits simultaneously from input.

              2)Shift Left – Shift bits to the left (toward MSB), with a new bit entering from the right (LSB).

              3)Shift Right – Shift bits to the right (toward LSB), with a new bit entering from the left (MSB).

              4)Clear – Reset the register to 0000.                                    
*/


/*
| Signal         | Type       | Description                                                             |
| -------------- | ---------- | ----------------------------------------------------------------------- |
| `clr`          | input      | Active-high asynchronous clear. When high, resets the output to `0000`. |
| `clk`          | input      | Clock signal (posedge-sensitive)                                        |
| `sel[1:0]`     | input      | Select signal to determine operation mode                               |
| `shift_en`     | input      | Enable signal for shifting                                              |
| `data_in[3:0]` | input      | 4-bit input data                                                        |
| `out[3:0]`     | output reg | 4-bit register output                                                   |

*/

/*

| `sel` | Mode                               | Description                                                               |
| ----- | ---------------------------------- | ------------------------------------------------------------------------- |
| `00`  | Parallel Load + Logical Shift Left | Loads `data_in`, and if `shift_en` is high, shifts left and pads 0 at LSB |
| `01`  | Logical Shift Left + Serial-In     | Shifts left with serial-in from `data_in[i]` if `shift_en` is high        |
| `10`  | Logical Shift Right + Serial-In    | Shifts right with serial-in from `data_in[i]` if `shift_en` is high       |
| `11`  | Load or Invalid                    | If `shift_en` is high → load `data_in`, else → output becomes `4'bxxxx`   |

*/



///////////////////////RTL/////////////////////////////////////////////

module usr(clr,clk,sel,shift_en,data_in,out);
     input clr,clk,shift_en;
     input [1:0]sel;
     input [3:0]data_in;
     output reg[3:0]out;
     integer i;

  always @(posedge clk)
    begin
      if(clr)
        out=4'b0000;

     else
        begin
           if (sel == 2'b00)
             begin
               out <= data_in;
                 if(shift_en)
                  begin
                     for(i=0;i<3;i=i+1)
                       begin
                          out[i] <= out[i+1];
                       end
                   out[3] <= 1'b0;
                  end
                 else
                    out <= data_in;
              end
           else if (sel==2'b01)
             begin
                 if(shift_en)
                     for(i=0;i<4;i=i+1)
                       begin
                         out[i] <= out[i+1];
                         out[3] <= data_in[i];
                       end
                 else
                    out <= data_in;
             end
	
           else if (sel==2'b10)
             begin
                if(shift_en)
                    for(i=3;i>-1;i=i-1)
                       begin
                          out[3] <= out[2];
                          out[2] <= out[1];
                          out[1] <= out[0];
                          out[0] <= data_in[i];
                        end
                 else
                     out <= data_in;
             end

           else
              begin
                 if(shift_en)
                     out <= data_in;
                 else
                     out <= 4'dx;
              end
       end
   end
endmodule
