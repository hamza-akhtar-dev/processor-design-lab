module hazard_unit 
(
    // forwarding
    input  logic        rf_en_mem,
    input  logic        rf_en_wb,
    input  logic [ 4:0] rs1_ex,
    input  logic [ 4:0] rs2_ex,
    input  logic [ 4:0] rd_mem,
    input  logic [ 4:0] rd_wb,
    output logic [ 1:0] forward_a,
    output logic [ 1:0] forward_b,

    // stalling for data hazards
    input  logic [ 4:0] rd_ex,
    input  logic [ 4:0] rs1_id,
    input  logic [ 4:0] rs2_id,
    input  logic [ 1:0] sel_wb_ex,
    output logic        stall_if,
    output logic        stall_id,
    output logic        flush_ex,

    // stalling for control hazards
    input  logic        br_taken,
    output logic        flush_id
);

    logic stall_lw;

    always_comb
    begin
        if (((rs1_ex == rd_mem) & rf_en_mem) & (rs1_ex != 0))
        begin 
            forward_a = 2'b10;
        end
        else if (((rs1_ex == rd_wb) & rf_en_wb) & (rs1_ex != 0))
        begin 
            forward_a = 2'b01;
        end
        else 
        begin
            forward_a = 2'b00;
        end
    end

    always_comb
    begin
        if (((rs2_ex == rd_mem) & rf_en_mem) & (rs2_ex != 0))
        begin 
            forward_b = 2'b10;
        end
        else if (((rs2_ex == rd_wb) & rf_en_wb) & (rs2_ex != 0))
        begin 
            forward_b = 2'b01;
        end
        else 
        begin
            forward_b = 2'b00;
        end
    end

    always_comb
    begin
        if((sel_wb_ex == 2'b01) & ((rs1_id == rd_ex) | (rs2_id == rd_ex)))
        begin
            stall_lw = 1'b1;
        end
        else
        begin
            stall_lw = 1'b0;
        end
    end

    assign stall_if = stall_lw;
    assign stall_id = stall_lw;

    assign flush_id = br_taken;
    assign flush_ex = (stall_lw | br_taken);

endmodule