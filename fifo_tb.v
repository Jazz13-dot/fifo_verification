`timescale 1ns/1ps

module fifo_tb;

    // Parameters
    localparam DATA_WIDTH = 8;
    localparam DEPTH      = 8;
    localparam ADDR_WIDTH = 3;

    // DUT signals
    reg                   clk;
    reg                   rst;
    reg                   wr_en;
    reg                   rd_en;
    reg  [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire                  full;
    wire                  empty;

    // Instantiate FIFO
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk   = 0;
        rst   = 1;
        wr_en = 0;
        rd_en = 0;
        din   = 0;

        // Apply reset
        #20;
        rst = 0;

        // ----------------------------
        // WRITE 5 VALUES
        // ----------------------------
        repeat (5) begin
            @(posedge clk);
            wr_en = 1;
            din   = din + 8'd1;
        end
        @(posedge clk);
        wr_en = 0;

        // ----------------------------
        // IDLE
        // ----------------------------
        repeat (2) @(posedge clk);

        // ----------------------------
        // READ 5 VALUES
        // ----------------------------
        repeat (5) begin
            @(posedge clk);
            rd_en = 1;
        end
        @(posedge clk);
        rd_en = 0;

        // ----------------------------
        // SIMULTANEOUS READ & WRITE
        // ----------------------------
        repeat (3) begin
            @(posedge clk);
            wr_en = 1;
            rd_en = 1;
            din   = din + 8'd1;
        end
        @(posedge clk);
        wr_en = 0;
        rd_en = 0;

        // ----------------------------
        // END SIMULATION
        // ----------------------------
        #50;
        $finish;
    end

endmodule