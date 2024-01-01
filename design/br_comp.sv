module br_comparator
(
    input  logic        [ 2:0] br_type,
    input  logic signed [31:0] opr_a,
    input  logic signed [31:0] opr_b,
    output logic               br_taken
);

    always_comb
    begin
        case(br_type)
            3'b000: br_taken = 1'b0;
            3'b001: br_taken = (          opr_a  ==           opr_b );
            3'b010: br_taken = (          opr_a  !=           opr_b );
            3'b011: br_taken = (          opr_a   <           opr_b );
            3'b100: br_taken = (          opr_a  >=           opr_b );
            3'b101: br_taken = ($unsigned(opr_a)  < $unsigned(opr_b));
            3'b110: br_taken = ($unsigned(opr_a) >= $unsigned(opr_b));
            3'b111: br_taken = 1'b1;
        endcase
    end
    
endmodule