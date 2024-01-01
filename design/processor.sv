module processor 
(
    input logic clk,
    input logic rst
); 
    // wires

    logic [ 2:0] imm_type;

    logic        rf_en_id;
    logic        rf_en_ex;
    logic        rf_en_mem;

    logic [ 4:0] rd_id;
    logic [ 4:0] rd_ex;
    logic [ 4:0] rd_mem;
    logic [ 4:0] rd_wb;

    logic [ 4:0] rs1_id;
    logic [ 4:0] rs1_ex;

    logic [ 4:0] rs2_id;
    logic [ 4:0] rs2_ex;

    logic [ 6:0] opcode;
    logic [ 2:0] funct3;
    logic [ 6:0] funct7;

    logic [31:0] mux_out_pc;
    logic [31:0] mux_out_opr_a;
    logic [31:0] mux_out_opr_b;

    logic stall_if;
    logic stall_id;

    logic flush_id;
    logic flush_ex;

    logic [1:0] forward_opr_a;
    logic [1:0] forward_opr_b;

    logic dm_en_id;
    logic dm_en_ex;
    logic dm_en_mem;

    logic br_taken;

    logic sel_opr_a_id;
    logic sel_opr_a_ex;

    logic sel_opr_b_id;
    logic sel_opr_b_ex;

    logic [ 1:0] sel_wb_id;
    logic [ 1:0] sel_wb_ex;
    logic [ 1:0] sel_wb_mem;
    logic [ 1:0] sel_wb_wb;

    logic [31:0] pc_out_if;
    logic [31:0] pc_out_id;
    logic [31:0] pc_out_ex;
    logic [31:0] pc_out_mem;
    logic [31:0] pc_out_wb;

    logic [31:0] inst_if;
    logic [31:0] inst_id;
    
    logic [ 3:0] aluop_id;
    logic [ 3:0] aluop_ex;

    logic [ 2:0] brop_id;
    logic [ 2:0] brop_ex;

    logic [31:0] wdata_wb;
    logic [31:0] wdata_id;

    logic [31:0] rdata1_id;
    logic [31:0] rdata1_ex;

    logic [31:0] rdata2_id;
    logic [31:0] rdata2_ex;
    logic [31:0] rdata2_mem;

    logic [31:0] forwarded_opr_a;
    logic [31:0] forwarded_opr_b;
    
    logic [31:0] imm_id;
    logic [31:0] imm_ex;

    logic [31:0] opr_res_if;
    logic [31:0] opr_res_ex;
    logic [31:0] opr_res_mem;
    logic [31:0] opr_res_wb;

    logic [31:0] dmem_out_mem;
    logic [31:0] dmem_out_wb;

    // --------------------- Instruction Fetch ---------------------

    // pc selection mux
    assign mux_out_pc = br_taken ? opr_res_if : (pc_out_if + 32'd4);

    // program counter
    pc pc_i
    (
        .clk   ( clk            ),
        .rst   ( rst            ),
        .en    ( ~stall_if      ),
        .pc_in ( mux_out_pc     ),
        .pc_out( pc_out_if      )
    );

    // instruction memory
    inst_mem inst_mem_i
    (
        .addr  ( pc_out_if      ),
        .data  ( inst_if        )
    );

    // -------------------------------------------------------------


    // IF <-> ID
    always_ff @( posedge clk ) 
    begin
        if(rst)
        begin
            inst_id   <= 0;
            pc_out_id <= 0;
        end
        else if(flush_id)
        begin   
            inst_id   <= 32'h00000013;
            pc_out_id <= 'b0;
        end
        else if (~stall_id)
        begin
            inst_id   <= inst_if;
            pc_out_id <= pc_out_if;
        end
    end

    // --------------------- Instruction Decode ---------------------

    // instruction decoder
    inst_dec inst_dec_i
    (
        .inst  ( inst_id        ),
        .rs1   ( rs1_id         ),
        .rs2   ( rs2_id         ),
        .rd    ( rd_id          ),
        .opcode( opcode         ),
        .funct3( funct3         ),
        .funct7( funct7         )
    );

    // register file
    reg_file reg_file_i
    (
        .rst   ( rst            ),
        .clk   ( clk            ),
        .rf_en ( rf_en_id       ),
        .rd    ( rd_wb          ),
        .rs1   ( rs1_id         ),
        .rs2   ( rs2_id         ),
        .rdata1( rdata1_id      ),
        .rdata2( rdata2_id      ),
        .wdata ( wdata_id       )
    );

    // controller
    controller controller_i
    (
        .opcode    ( opcode       ),
        .funct3    ( funct3       ),
        .funct7    ( funct7       ),
        .rf_en     ( rf_en_id     ),
        .dm_en     ( dm_en_id     ),
        .sel_opr_a ( sel_opr_a_id ),
        .sel_opr_b ( sel_opr_b_id ),
        .sel_wb    ( sel_wb_id    ),
        .imm_type  ( imm_type     ),
        .aluop     ( aluop_id     ),
        .brop      ( brop_id      )
    );

    // immediate generator
    imm_gen imm_gen_i
    (
        .inst      ( inst_id        ),
        .imm_type  ( imm_type       ),
        .imm       ( imm_id         )
    );

    // ID <-> EX
    always_ff @( posedge clk ) 
    begin
        if(rst | flush_ex)
        begin
            pc_out_ex    <= 0;
            rdata1_ex    <= 0;
            rdata2_ex    <= 0;
            imm_ex       <= 0;
            rs1_ex       <= 0;
            rs2_ex       <= 0;
            rd_ex        <= 0;

            // control signals
            rf_en_ex     <= 0;
            dm_en_ex     <= 0;
            sel_opr_a_ex <= 0;
            sel_opr_b_ex <= 0;
            sel_wb_ex    <= 0;
            aluop_ex     <= 0;
            brop_ex      <= 0;
        end
        else
        begin
            pc_out_ex    <= pc_out_id;
            rdata1_ex    <= rdata1_id;
            rdata2_ex    <= rdata2_id;
            imm_ex       <= imm_id;
            rs1_ex       <= rs1_id;
            rs2_ex       <= rs2_id;
            rd_ex        <= rd_id;
            
            // control signals
            rf_en_ex     <= rf_en_id;
            dm_en_ex     <= dm_en_id;
            sel_opr_a_ex <= sel_opr_a_id;
            sel_opr_b_ex <= sel_opr_b_id;
            sel_wb_ex    <= sel_wb_id;
            aluop_ex     <= aluop_id;
            brop_ex      <= brop_id;
        end
    end

    // --------------------- Execute ---------------------

    always_comb
    begin
        case(forward_opr_a)
            2'b00:   forwarded_opr_a = rdata1_ex;
            2'b01:   forwarded_opr_a = opr_res_mem;
            2'b10:   forwarded_opr_a = opr_res_wb;
            default: forwarded_opr_a = 'b0;
        endcase
    end

    always_comb
    begin
        case(forward_opr_b)
            2'b00:   forwarded_opr_b = rdata2_ex;
            2'b01:   forwarded_opr_b = opr_res_mem;
            2'b10:   forwarded_opr_b = opr_res_wb;
            default: forwarded_opr_b = 'b0;
        endcase
    end

    // operand a selection mux
    assign mux_out_opr_a = sel_opr_a_ex ? pc_out_ex : forwarded_opr_a;

    // operand b selection mux
    assign mux_out_opr_b = sel_opr_b_ex ?    imm_ex :       rdata2_ex;

    // alu
    alu alu_i
    (
        .aluop   ( aluop_ex       ),
        .opr_a   ( mux_out_opr_a  ),
        .opr_b   ( mux_out_opr_b  ),
        .opr_res ( opr_res_ex     )
    );

    br_comparator br_comparator_i
    (
        .br_type  ( brop_ex       ),
        .opr_a    ( mux_out_opr_a ),
        .opr_b    ( mux_out_opr_b ),
        .br_taken ( br_taken      )
    );

    // EX <-> MEM
    always_ff @( posedge clk ) 
    begin
        if(rst)
        begin
            pc_out_mem  <= 0;
            opr_res_mem <= 0;
            rdata2_mem  <= 0;
            rd_mem      <= 0;

            // control signals
            dm_en_mem   <= 0;
            sel_wb_mem  <= 0;
        end
        else
        begin
            pc_out_mem  <= pc_out_ex;
            opr_res_mem <= opr_res_ex;
            rdata2_mem  <= rdata2_ex;
            rd_mem      <= rd_ex;

            // control signals
            dm_en_mem   <= dm_en_ex;
            sel_wb_mem  <= sel_wb_ex;
        end
    end

    // ----------------------- Memory ------------------------

    // data memory
    data_mem data_mem_i
    (
        .rst      ( rst           ),
        .clk      ( clk           ),
        .dm_en    ( dm_en_mem     ),
        .addr     ( opr_res_mem   ),
        .data_in  ( rdata2_mem    ),
        .data_out ( dmem_out_mem  )
    );

    always_comb
    begin
        opr_res_if = opr_res_mem;
    end

    // MEM <-> WB
    always_ff @( posedge clk ) 
    begin
        if(rst)
        begin
            pc_out_wb   <= 0;
            opr_res_wb  <= 0;
            dmem_out_wb <= 0;
            rd_wb       <= 0;

            sel_wb_wb   <= 0;
        end
        else
        begin
            pc_out_wb   <= pc_out_mem;
            opr_res_wb  <= opr_res_mem;
            dmem_out_wb <= dmem_out_mem;
            rd_wb       <= rd_mem;

            sel_wb_wb   <= sel_wb_mem;
        end
    end

    // --------------------- Write Back ---------------------

    // write back selection mux
    always_comb
    begin
        case(sel_wb_wb)
            2'b00: wdata_wb = opr_res_wb;
            2'b01: wdata_wb = dmem_out_wb;
            2'b10: wdata_wb = pc_out_wb + 32'd4;
            2'b11: wdata_wb = 32'd0;
        endcase
    end

    // Feedback from WB to ID
    always_comb
    begin
        wdata_id = wdata_wb;
    end

    // ------------------- Hazard Unit -----------------------------

    hazard_unit hazard_unit_i 
    (
        .rf_en_mem ( rf_en_mem     ),
        .rf_en_wb  ( rf_en_wb      ),
        .rs1_ex    ( rs1_ex        ),
        .rs2_ex    ( rs2_ex        ),
        .rd_mem    ( rd_mem        ),
        .rd_wb     ( rd_wb         ),
        .forward_a ( forward_opr_a ),
        .forward_b ( forward_opr_b ),

        .sel_wb_ex ( sel_wb_ex     ),
        .rd_ex     ( rd_ex         ),
        .rs1_id    ( rs1_id        ),
        .rs2_id    ( rs2_id        ),
        .stall_if  ( stall_if      ),
        .stall_id  ( stall_id      ),
        .flush_ex  ( flush_ex      ),

        .br_taken  ( br_taken      ),
        .flush_id  ( flush_id      )
    );
    
endmodule