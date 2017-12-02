`define C_S_AXI_DATA_WIDTH 32

module top;

    logic [63:0] s_axis_video_tdata_in;
    logic        s_axis_video_tvalid_in;
    wire         s_axis_video_tready_out;
    logic        s_axis_video_tuser_in;
    logic        s_axis_video_tlast_in;
    wire  [63:0] s_axis_video_tdata_out;
    wire         s_axis_video_tvalid_out;
    logic        s_axis_video_tready_in;
    wire         s_axis_video_tuser_out;
    wire         s_axis_video_tlast_out;
    logic        aclk, aclken, aresetn;
    logic ENABLE_KEYSTONE;
    logic SW_RESET;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H11;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H12;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H13;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H21;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H22;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H23;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H31;
    logic [`C_S_AXI_DATA_WIDTH-1 : 0] H32;

Keystone dut(.s_axis_video_tdata_in(s_axis_video_tdata_in),
             .s_axis_video_tvalid_in(s_axis_video_tvalid_in),
             .s_axis_video_tready_out(s_axis_video_tready_out),
             .s_axis_video_tuser_in(s_axis_video_tuser_in),
             .s_axis_video_tlast_in(s_axis_video_tlast_in),
             .s_axis_video_tdata_out(s_axis_video_tdata_out),
             .s_axis_video_tvalid_out(s_axis_video_tvalid_out),
             .s_axis_video_tready_in(s_axis_video_tready_in),
             .s_axis_video_tuser_out(s_axis_video_tuser_out),
             .s_axis_video_tlast_out(s_axis_video_tlast_out),
             .aclk(aclk), 
             .aclken(aclken), 
             .aresetn(aresetn),
             .ENABLE_KEYSTONE(ENABLE_KEYSTONE),
             .SW_RESET(SW_RESET),
             .H11(H11),
             .H12(H12),
             .H13(H13),
             .H21(H21),
             .H22(H22),
             .H23(H23),
             .H31(H31),
             .H32(H32));

    initial begin
        aclk = 1'b0;
        aclken = 1'b1;
        aresetn = 1'b1;
        SW_RESET = 1'b0;
        ENABLE_KEYSTONE = 1'b1;

        H11 = 1'b1;
        H22 = 1'b1;

        H12 = 1'b0;
        H13 = 1'b0;
        H21 = 1'b0;
        H23 = 1'b0;
        H31 = 1'b0;
        H32 = 1'b0;

        forever #5 aclk = ~aclk;
    end

    initial begin

    	$monitor("data_in: %x, valid_in: %b, ready_out: %b, SOF_in: %b, EOL_in: %b\n",
    		s_axis_video_tdata_in,s_axis_video_tvalid_in,s_axis_video_tready_out,s_axis_video_tuser_in,s_axis_video_tlast_in,
    		     "data_out: %x, valid_out: %b, ready_in: %b, SOF_out: %b, EOL_out: %b\n",
    		s_axis_video_tdata_out,s_axis_video_tvalid_out,s_axis_video_tready_in,s_axis_video_tuser_out,s_axis_video_tlast_out);

        aresetn <= 1'b0;
        @(posedge aclk);
        aresetn <= 1'b1;
        @(posedge aclk);

        s_axis_video_tdata_in  <= 64'hFFFF_FFFF_FFFF_FFFF;
        s_axis_video_tvalid_in <= 1'b1;
        s_axis_video_tuser_in  <= 1'b1;
        s_axis_video_tlast_in  <= 1'b0;
        s_axis_video_tready_in <= 1'b1;

        @(posedge aclk);

        s_axis_video_tuser_in <= 1'b0;

        #10000 $finish;
    end

endmodule: top