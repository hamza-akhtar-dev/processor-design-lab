module processor 
(
    input logic clk,
    input logic rst
); 
    // wires
    logic        rf_en;
    logic [31:0] pc_out;
    logic [31:0] inst;
    logic [ 4:0] rd;
    logic [ 4:0] rs1;
    logic [ 4:0] rs2;
    logic [ 6:0] opcode;
    logic [ 2:0] funct3;
    logic [ 6:0] funct7;
    logic [31:0] rdata1;
    logic [31:0] rdata2;
    logic [31:0] wdata;
    logic [3 :0] aluop;

    // program counter
    pc pc_i
    (
        .clk   ( clk            ),
        .rst   ( rst            ),
        .pc_in ( pc_out + 32'd4 ),
        .pc_out( pc_out         )
    );

    // instruction memory
    inst_mem inst_mem_i
    (
        .addr  ( pc_out         ),
        .data  ( inst           )
    );

    // instruction decoder
    inst_dec inst_dec_i
    (
        .inst  ( inst           ),
        .rs1   ( rs1            ),
        .rs2   ( rs2            ),
        .rd    ( rd             ),
        .opcode( opcode         ),
        .funct3( funct3         ),
        .funct7( funct7         )
    );

    // register file
    reg_file reg_file_i
    (
        .clk   ( clk            ),
        .rf_en ( rf_en          ),
        .rd    ( rd             ),
        .rs1   ( rs1            ),
        .rs2   ( rs2            ),
        .rdata1( rdata1         ),
        .rdata2( rdata2         ),
        .wdata ( wdata          )
    );

    // controller
    controller controller_i
    (
        .opcode( opcode         ),
        .funct3( funct3         ),
        .funct7( funct7         ),
        .aluop ( aluop          ),
        .rf_en ( rf_en          )
    );

    // alu
    alu alu_i
    (
        .aluop   ( aluop          ),
        .opr_a   ( rdata1         ),
        .opr_b   ( rdata2         ),
        .opr_res ( wdata          )
    );
    
endmodule