`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
//
// Create Date: 04/12/2023
// Design Name:
// Module Name: testbench
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`include "./case_000/case_000.svh"
`include "./case_002/case_002.svh"

module testbench;

localparam  CLOCK_FREQUENCY             =   50_000_000;
localparam  CLOCK_PERIOD                =   1e9/CLOCK_FREQUENCY;
localparam  NUMBER_OF_RMII_PORTS        =   2;
localparam  NUMBER_OF_VIRTUAL_PORTS     =   0;
localparam  RECEIVE_QUE_SLOTS           =   2;

logic                                           clock                           =   0;
logic                                           reset_n                         =   1;
logic [7:0]                                     ethernet_message [0:888];
logic [NUMBER_OF_RMII_PORTS-1:0][1:0]           ethernet_transmit_data          =   0;
logic [NUMBER_OF_RMII_PORTS-1:0]                ethernet_transmit_data_valid    =   0;


initial begin
    clock   =   0;
    forever begin
        #(CLOCK_PERIOD/2);
        clock   =   ~clock;
    end
end

initial begin
    reset_n =   0;
    repeat(5) @(posedge clock);
    reset_n =   1;
end

initial begin
    wait(reset_n);

    repeat(100) @(posedge clock);

    $display("Running case 000");
    case_000();

    /*
    $display("Running case 002");
    case_002();
    */

    $stop();
end


wire                                    switch_core_clock;
wire                                    switch_core_reset_n;
wire    [NUMBER_OF_RMII_PORTS-1:0][1:0] switch_core_rmii_phy_receive_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]      switch_core_rmii_phy_receive_data_enable;
wire    [NUMBER_OF_RMII_PORTS-1:0]      switch_core_rmii_phy_receive_data_error;
wire    [NUMBER_OF_RMII_PORTS-1:0][1:0] switch_core_rmii_phy_transmit_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]      switch_core_rmii_phy_transmit_data_valid;
wire    [NUMBER_OF_RMII_PORTS-1:0]      switch_core_rmii_phy_reference_clock;

switch_core #(
    .NUMBER_OF_RMII_PORTS       (NUMBER_OF_RMII_PORTS),
    .NUMBER_OF_VIRTUAL_PORTS    (NUMBER_OF_VIRTUAL_PORTS),
    .RECEIVE_QUE_SLOTS          (RECEIVE_QUE_SLOTS)
)
switch_core(
    .clock                          (switch_core_clock),
    .reset_n                        (switch_core_reset_n),
    .rmii_phy_receive_data          (switch_core_rmii_phy_receive_data),
    .rmii_phy_receive_data_enable   (switch_core_rmii_phy_receive_data_enable),
    .rmii_phy_receive_data_error    (switch_core_rmii_phy_receive_data_error),

    .rmii_phy_transmit_data         (switch_core_rmii_phy_transmit_data),
    .rmii_phy_transmit_data_vaid    (switch_core_rmii_phy_transmit_data_valid),
    .rmii_phy_reference_clock       (switch_core_rmii_phy_reference_clock)
);


wire            rmii_byte_packager_clock;
wire            rmii_byte_packager_reset_n;
wire    [1:0]   rmii_byte_packager_data;
wire            rmii_byte_packager_data_enable;
wire    [8:0]   rmii_byte_packager_packaged_data;
wire    [1:0]   rmii_byte_packager_speed_code;
wire            rmii_byte_packager_packaged_data_valid;
wire            rmii_byte_packager_data_error;

rmii_byte_packager rmii_byte_packager(
    .clock                  (rmii_byte_packager_clock),
    .reset_n                (rmii_byte_packager_reset_n),
    .data                   (rmii_byte_packager_data),
    .data_enable            (rmii_byte_packager_data_enable),
    .data_error             (rmii_byte_packager_data_error),

    .speed_code             (rmii_byte_packager_speed_code),
    .packaged_data          (rmii_byte_packager_packaged_data),
    .packaged_data_valid    (rmii_byte_packager_packaged_data_valid)
);


assign  switch_core_clock                               =   clock;
assign  switch_core_reset_n                             =   reset_n;
assign  switch_core_rmii_phy_receive_data[0]            =   ethernet_transmit_data[0];
assign  switch_core_rmii_phy_receive_data_enable[0]     =   ethernet_transmit_data_valid[0];
assign  switch_core_rmii_phy_receive_data_error[0]      =   0;

assign  switch_core_rmii_phy_receive_data[1]            =   ethernet_transmit_data[1];
assign  switch_core_rmii_phy_receive_data_enable[1]     =   ethernet_transmit_data_valid[1];
assign  switch_core_rmii_phy_receive_data_error[1]      =   0;

assign  rmii_byte_packager_clock        =   clock;
assign  rmii_byte_packager_reset_n      =   reset_n;
assign  rmii_byte_packager_data         =   switch_core_rmii_phy_transmit_data[0];
assign  rmii_byte_packager_data_enable  =   switch_core_rmii_phy_transmit_data_valid[0];
assign  rmii_byte_packager_data_error   =   0;

endmodule