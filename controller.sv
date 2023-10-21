module controller
(
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    input  logic [6:0] opcode,
    output logic       rf_en,
    output logic       dm_en,
    output logic       sel_opr_a,
    output logic       sel_opr_b,
    output logic       sel_pc,
    output logic [1:0] sel_wb,
    output logic [2:0] imm_type,
    output logic [3:0] aluop
);
    always_comb
    begin
        case(opcode)
            // R-Type
            7'b0110011:
            begin
                // memory controls
                rf_en = 1'b1;
                dm_en = 1'b0;

                // mux controls
                sel_opr_a = 1'b0;
                sel_opr_b = 1'b0;
                sel_pc    = 1'b0;
                sel_wb    = 2'b00;

                // immediate controls
                imm_type  = 3'b000;

                // operation controls
                case(funct3)
                    3'b000: 
                    begin
                        case(funct7)
                            7'b0000000: aluop = 4'b0000; // add
                            7'b0100000: aluop = 4'b0001; // sub
                        endcase
                    end
                    3'b001: aluop = 4'b0110; // sll
                    3'b010: aluop = 4'b0011; // slt
                    3'b011: aluop = 4'b0100; // sltu
                    3'b100: aluop = 4'b0000; // xor
                    3'b101:
                    begin
                        case(funct7)
                            7'b0000000: aluop = 4'b0000; // add
                            7'b0100000: aluop = 4'b0001; // sub
                        endcase
                    end
                    3'b110: aluop = 4'b1001; // or
                    3'b111: aluop = 4'b1010; // and
                endcase
            end
            // I-Type Memory
            7'b0000011:
            begin
                // memory controls
                rf_en = 1'b1;
                dm_en = 1'b0;

                // mux controls
                sel_opr_a = 1'b0;
                sel_opr_b = 1'b1;
                sel_pc    = 1'b1;
                sel_wb    = 2'b01;

                // immediate controls
                imm_type  = 3'b000;

                // operation controls
                aluop = 4'b0000; // add
            end
            // I-Type Jump
            7'b1100111:
            begin
                // memory controls
                rf_en = 1'b1;
                dm_en = 1'b0;

                // mux controls
                sel_opr_a = 1'b0;
                sel_opr_b = 1'b1;
                sel_pc    = 1'b1;
                sel_wb    = 2'b10;

                // immediate controls
                imm_type  = 3'b000;

                // operation controls
                aluop = 4'b0000; // add
            end
            // J-Type
            7'b1101111: // J-Type
            begin
                // memory controls
                rf_en = 1'b0;
                dm_en = 1'b0;

                // mux controls
                sel_opr_a = 1'b0;
                sel_opr_b = 1'b1;
                sel_pc    = 1'b1;
                sel_wb    = 2'b00;

                // immediate controls
                imm_type  = 3'b001;

                // operation controls
                aluop = 4'b0000; // add
            end
            default:
            begin
                // memory controls
                rf_en     = 1'b0;
                dm_en     = 1'b0;

                // mux controls
                sel_opr_a = 1'b0;
                sel_opr_b = 1'b0;
                sel_pc    = 1'b0;
                sel_wb    = 2'b00;

                // immediate controls
                imm_type  = 3'b000;

                // operation controls
                aluop = 4'b0000; // add
            end
        endcase
    end

endmodule