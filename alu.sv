module alu 
(
    input  logic [ 3:0] aluop,
    input  logic [31:0] opr_a,
    input  logic [31:0] opr_b,
    output logic [31:0] opr_res
);
    
    always_comb
    begin
        case(aluop)
            4'b0000: opr_res = opr_a + opr_b;
            4'b0001: opr_res = opr_a - opr_b;
        endcase
    end

endmodule