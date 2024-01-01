module imm_gen
(
    input  logic [31:0] inst,
    input  logic [ 2:0] imm_type,
    output logic [31:0] imm
);
    logic [31:0] i_imm;
    logic [31:0] j_imm;
    logic [31:0] b_imm;
    logic [31:0] s_imm;

    always_comb
    begin
        i_imm = {{20{inst[31]}}, inst[31:20]};
        s_imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        b_imm = {{19{inst[31]}}, inst[31], inst[ 7], inst[30:25], inst[11:8], 1'b0};
        j_imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
    end

    always_comb
    begin
        case(imm_type)
            3'b000: imm = i_imm;
            3'b001: imm = s_imm;
            3'b010: imm = b_imm;
            3'b011: imm = j_imm;
        endcase
    end

endmodule