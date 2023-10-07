module controller
(
    input  logic [6:0] opcode,
    input  logic [6:0] funct7,
    input  logic [2:0] funct3,
    output logic [3:0] aluop,
    output logic       rf_en
);
    always_comb
    begin
        case(opcode)
            7'b0110011: //R-Type
            begin
                rf_en = 1'b1;
                case(funct3)
                    3'b000: 
                    begin
                        case(funct7)
                            7'b0000000: aluop = 4'b0000; //ADD
                            7'b0100000: aluop = 4'b0001; //SUB
                        endcase
                    end
                    3'b001: aluop = 4'b0110; //SLL
                    3'b010: aluop = 4'b0011; //SLT
                    3'b011: aluop = 4'b0100; //SLTU
                    3'b100: aluop = 4'b0000; //XOR
                    3'b101:
                    begin
                        case(funct7)
                            7'b0000000: aluop = 4'b0000; //ADD
                            7'b0100000: aluop = 4'b0001; //SUB
                        endcase
                    end
                    3'b110: aluop = 4'b1001; //OR
                    3'b111: aluop = 4'b1010; //AND
                endcase
            end
            default:
            begin
                rf_en = 1'b0;
            end
        endcase
    end

endmodule