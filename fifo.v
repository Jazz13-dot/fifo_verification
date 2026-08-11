module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 8,
    parameter ADDR_WIDTH = 3
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  wr_en,
    input  wire                  rd_en,
    input  wire [DATA_WIDTH-1:0] din,
    output reg  [DATA_WIDTH-1:0] dout,
    output reg                   full,
    output reg                   empty
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;
    reg [ADDR_WIDTH:0]   count;

    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            dout   <= {DATA_WIDTH{1'b0}};
            empty  <= 1'b1;
            full   <= 1'b0;
        end
        else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1;   // write only
                2'b01: count <= count - 1;   // read only
                default: count <= count;     // no change or simultaneous
            endcase

            if (wr_en && !full) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1;
            end

            if (rd_en && !empty) begin
                dout <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
            end

            empty <= (count == 1 && rd_en && !wr_en) ? 1'b1 :
                     (count == 0)                   ? 1'b1 : 1'b0;

            full  <= (count == DEPTH-1 && wr_en && !rd_en) ? 1'b1 :
                     (count == DEPTH)                     ? 1'b1 : 1'b0;
        end
    end

endmodule