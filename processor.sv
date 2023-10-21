module processor 
(
    input logic clk,
    input logic rst
); 
    // wires
    logic        rf_en;
    logic        dm_en;

    logic        sel_pc;
    logic        sel_opr_a;
    logic        sel_opr_b;
    logic [ 1:0] sel_wb;

    logic [ 2:0] imm_type;

    logic [31:0] pc_out;
    logic [31:0] inst;
    
    logic [ 4:0] rd;
    logic [ 4:0] rs1;
    logic [ 4:0] rs2;
    
    logic [ 6:0] opcode;
    logic [ 2:0] funct3;
    logic [ 6:0] funct7;
    
    logic [ 3:0] aluop;

    logic [31:0] wdata;
    logic [31:0] rdata1;
    logic [31:0] rdata2;
    
    logic [31:0] imm;
    logic [31:0] opr_res;
    
    logic [31:0] mux_out_pc;
    logic [31:0] mux_out_opr_a;
    logic [31:0] mux_out_opr_b;

    logic [31:0] dmem_out;

    // pc selection mux
    assign mux_out_pc = sel_pc ? wdata : (pc_out + 32'd4);

    // program counter
    pc pc_i
    (
        .clk   ( clk            ),
        .rst   ( rst            ),
        .pc_in ( mux_out_pc     ),
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
        .opcode    ( opcode         ),
        .funct3    ( funct3         ),
        .funct7    ( funct7         ),
        .rf_en     ( rf_en          ),
        .dm_en     ( dm_en          ),
        .sel_opr_a ( sel_opr_a      ),
        .sel_opr_b ( sel_opr_b      ),
        .sel_pc    ( sel_pc         ),
        .sel_wb    ( sel_wb         ),
        .imm_type  ( imm_type       ),
        .aluop     ( aluop          )
    );

    // immediate generator
    imm_gen imm_gen_i
    (
        .inst      ( inst           ),
        .imm_type  ( imm_type       ),
        .imm       ( imm            )
    );

    // operand a selection mux
    assign mux_out_opr_a = sel_opr_a ? pc_out : rdata1;

    // operand b selection mux
    assign mux_out_opr_b = sel_opr_b ? imm    : rdata2;

    // alu
    alu alu_i
    (
        .aluop   ( aluop          ),
        .opr_a   ( mux_out_opr_a  ),
        .opr_b   ( mux_out_opr_b  ),
        .opr_res ( opr_res        )
    );

    // data memory
    data_mem data_mem_i
    (
        .clk      ( clk           ),
        .dm_en    ( dm_en         ),
        .addr     ( wdata         ),
        .data_in  ( rdata2        ),
        .data_out ( dmem_out      )
    );

    // write back selection mux
    always_comb
    begin
        case(sel_wb)
            2'b00: wdata = opr_res;
            2'b01: wdata = dmem_out;
            2'b10: wdata = pc_out + 32'd4;
            2'b11: wdata = 32'd0;
        endcase
    end
    
endmodule