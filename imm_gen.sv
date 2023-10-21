module imm_gen
(
    input  logic [31:0] inst,
    input  logic [ 2:0] imm_type,
    output logic [31:0] imm
);
    logic [31:0] i_imm;
    logic [31:0] j_imm;

    always_comb
    begin
        i_imm = {{20{inst[31]}}, inst[19:12]};
        j_imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
    end

    always_comb
    begin
        case(imm_type)
            3'b000: imm = i_imm;
            3'b001: imm = j_imm;
        endcase
    end

endmodule