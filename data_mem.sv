module data_mem
(
    input  logic        clk,
    input  logic        dm_en,
    input  logic [31:0] addr,
    input  logic [31:0] data_in,
    output logic [31:0] data_out
);

    // memory of row width 32bits and there total 1000 rows. 32x1000
    logic [31:0] mem [1000];

    // asynchronous read
    assign data_out = mem[addr[31:2]];

    // synchronous write
    always_ff @(posedge clk)
    begin
        if(dm_en)
        begin
            mem[addr[31:2]] <= data_in;
        end
    end

endmodule