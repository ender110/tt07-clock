`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//! @title      编码器步骤解析 功能单元(TSP Encoder Step Parse)
//! @copyright  Next Vision Tech
//! @author     Mxt
//! @version    1.1
//! @date       2024.08.20

//! 根据编码器输入，对编码器当前运动状态进行解析
//! * 当前模块运行时钟(s_clk)与编码器周期之间无关联，运行时钟周期远远快于编码器周期
//! * 当前模块支持的编码器设备为 <font color=red>ATOM2T1(G1光栅尺编码器)</font>
//! * 对编码器输入的前两个周期状态进行判断，得到当前周期编码器运动的状态(前进/后退)
//! * 兼容正交频率使能时编码器的运动状态,正交频率使能一般不打开
//! * 编码器周期状态的判定可查看svn上编码器部分的图片说明
//! * **输出的前进/后退信号与模块运行时钟(s_clk)同步，与编码器周期无关**
//!
//!  **正向(前进，非正交模式)**状态下编码器波形
//! { signal: [
//!     { name: "CLK",  wave:   "P...............X.........." , period:0.5  },     
//!     { name: "COMPLETE CYCLE(T)",  wave:   "==x", data:["T0","T1"] , period:8 }, 
//!     { name: "A",  wave:   "P.X" , period:8 },
//!     { name: "B",  wave:   "P..X" , period:8 , phase:6 },
//!     { name: "PHASE",  wave:   "========x...", data:["10","11","01","00","10","11","01","00","10","11","01","00"] , period:2},
//!     { name: "STEP FORWARD",  wave:   "0.....10......10..x...."}
//! ]}
//!
//!  **反向(后退，非正交模式)**状态下编码器波形
//! { signal: [
//!     { name: "CLK",  wave:   "P...............X.........." , period:0.5  },   
//!     { name: "COMPLETE CYCLE(T)",  wave:   "==x", data:["T0","T1"] , period:8 }, 
//!     { name: "A",  wave:   "P.X" , period:8 },
//!     { name: "B",  wave:   "P..X" , period:8 , phase:2 },
//!     { name: "BACK PHASE",  wave:   "========x...", data:["11","10","00","01","11","10","00","01","11","10","00","01"] , period:2},
//!     { name: "STEP BACK",  wave:   "0.....10......10..x..."}
//! ]}
//! ----------------------------------------------------------------------------
//! 版本历史:
//! | version   | author    | date      | description   |
//! | :---:     | :---:     | :---:     | ---           |
//! | 1.0       | Mxt       | 2024.4.2  | 初版设计      |
//! | 1.1       | Mxt       | 2024.8.20 | 接口优化  |
//!
// -----------------------------------------------------------------------------
/*
使用示例：
tsp_enc_step_parse  tsp_enc_step_parse_inst (
    .clk            (clk),              // 1-bit input: 输入时钟
    .rstp           (rstp),             // 1-bit input: 复位信号，高有效
    .i_encoder_a    (i_encoder_a),      // 1-bit input: 编码器输入源A
    .i_encoder_b    (i_encoder_b),      // 1-bit input: 编码器输入源B
    .i_orthogonal_en(i_orthogonal_en),  // 1-bit input: 正交频率使能，参数配置
    .o_step_forward (o_step_forward),   // 1-bit output: 正向(前进)信号,同步信号(脉冲) 
    .o_step_back    (o_step_back)       // 1-bit output: 反向(后退)信号，同步信号(脉冲) 
  );
*/

module tsp_enc_step_parse(
    
    //! 时钟
    input   logic               clk,
    //! 复位(高有效)
    input   logic               rstp,

    //! 编码器输入源A
    input   logic               i_encoder_a,
    //! 编码器输入源B
    input   logic               i_encoder_b,
    //! 正交频率使能(正交频率是信号频率的4倍)，参数配置
    input   logic               i_orthogonal_en,


    //! 正向(前进)信号
    output logic                o_step_forward,
    //! 反向(后退)信号
    output logic                o_step_back
);

/*********************************************************************************************************/
/**********************************************localparam*************************************************/
/*********************************************************************************************************/

    //! 定义编码器组合状态1
    logic   [1:0]   phase0;            
    //! 定义编码器组合状态2
    logic   [1:0]   phase1; 
    //! 定义编码器组合状态3
    logic   [1:0]   phase2;
    //! 定义编码器组合状态4
    logic   [1:0]   phase3;
    
    assign  phase0  =   2'b00;  
    assign  phase1  =   2'b10;  
    assign  phase2  =   2'b11;
    assign  phase3  =   2'b01;  

    //! 定义编码器AB项组合当前状态
    logic   [1:0]	phase;
    //! 定义编码器AB项组合延迟1个周期
    logic   [1:0]	phase_d1;
    //! 定义编码器AB项组合延迟2个周期
    logic   [1:0]	phase_d2;

    assign  phase   =   {i_encoder_a,i_encoder_b};  

    //! 寄存两个周期的组合情况，根据前两个周期的组合情况来判断当前周期的状态
    always@(posedge clk)    begin
        phase_d1 <= phase;
        phase_d2 <= phase_d1;
    end

/*********************************************************************************************************/
/**************************************正交频率使能，编码器状态判断******************************************/
/*********************************************************************************************************/
    //! 定义正交频率模式下的正向(前进)状态判断
    logic   orth_step_forward;
    //! 定义正交频率模式下的反向(后退)状态判断
    logic   orth_step_back;

    assign  orth_step_forward   =   (phase_d1 == phase1 && phase_d2 == phase0) ||
							        (phase_d1 == phase2 && phase_d2 == phase1) ||
							        (phase_d1 == phase3 && phase_d2 == phase2) ||
							        (phase_d1 == phase0 && phase_d2 == phase3) ;
    
    assign	orth_step_back      =   (phase_d1 == phase0 && phase_d2 == phase1) || 
							        (phase_d1 == phase1 && phase_d2 == phase2) ||
							        (phase_d1 == phase2 && phase_d2 == phase3) ||
							        (phase_d1 == phase3 && phase_d2 == phase0) ;
					   						

/*********************************************************************************************************/
/*************************************非正交频率使能，编码器状态判断*****************************************/
/*********************************************************************************************************/

    /*
    取完整状态中的一个位置的状态作为 一个编码器完整周期 的标识即可，参考此款编码器说明图片

    forward模式下，2个周期前 01 ，1个周期前 00 ，当前周期(10)时出判定信号
    back模式下，2个周期前 00 ，1个周期前 01 ，当前周期(11)时出判定信号

    此信号的产生不依赖于一个完整的编码器周期,只要满足此状态即可产生
    */

    //! 定义非正交频率模式(普通模式)下的正向(前进)状态判断
    logic   per_step_forward;
    //! 定义非正交频率模式(普通模式)下的反向(后退)状态判断
    logic   per_step_back;

    assign  per_step_forward    = (phase_d1 == phase0 && phase_d2 == phase3) ;
    assign  per_step_back       = (phase_d1 == phase3 && phase_d2 == phase0) ; 						 

/*********************************************************************************************************/
/********************************************** 输出 *****************************************************/
/*********************************************************************************************************/

    //! 正向(前进)信号，延迟1周期，优化时序
    logic   step_forward;
    //! 反向(后退)信号，延迟1周期，优化时序
    logic   step_back;

    // 普通模式和正交模式的选择，正向(前进)
    assign  step_forward    = i_orthogonal_en ? orth_step_forward	: per_step_forward;
    // 普通模式和正交模式的选择，反向(后退)
    assign	step_back       = i_orthogonal_en ? orth_step_back	    : per_step_back;

    //! 对信号进行寄存，优化时序
    always@(posedge clk)    begin
        o_step_forward    <= step_forward;
        o_step_back       <= step_back;
    end

endmodule
