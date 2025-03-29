# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="ps")
    #初始化信号
    dut.rst_n.value=1;
    dut.i_encoder_a.value=0;
    dut.i_encoder_b.value=1;
    dut.i_orthogonal_en.value=1;
    cocotb.start_soon(clock.start())
    #结束复位
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value=0;
    # 后向移动
    for i in range(10):
        #两个脉冲后产生脉冲信号
        dut.i_encoder_a.value=1-dut.i_encoder_a.value;
        await ClockCycles(dut.clk, 3)
        assert dut.o_step_back.value == 1
        # 只产生一个时钟的信号，下一个时钟已经为低
        await ClockCycles(dut.clk, 1)
        assert dut.o_step_back.value == 0
        #两个脉冲后产生脉冲信号
        dut.i_encoder_b.value=1-dut.i_encoder_b.value;
        await ClockCycles(dut.clk, 3)
        assert dut.o_step_back.value == 1
        # 只产生一个时钟的信号，下一个时钟已经为低
        await ClockCycles(dut.clk, 1)
        assert dut.o_step_back.value == 0
    # 前向移动
    for i in range(10):
        #两个脉冲后产生脉冲信号
        dut.i_encoder_b.value=1-dut.i_encoder_b.value;
        await ClockCycles(dut.clk, 3)
        assert dut.o_step_forward.value == 1
        # 只产生一个时钟的信号，下一个时钟已经为低
        await ClockCycles(dut.clk, 1)
        assert dut.o_steo_step_forwardp_back.value == 0
        #两个脉冲后产生脉冲信号
        dut.i_encoder_a.value=1-dut.i_encoder_a.value;
        await ClockCycles(dut.clk, 3)
        assert dut.o_step_forward.value == 1
        # 只产生一个时钟的信号，下一个时钟已经为低
        await ClockCycles(dut.clk, 1)
        assert dut.o_steo_step_forwardp_back.value == 0
    # # Reset
    # dut._log.info("Reset")
    # dut.ena.value = 1
    # dut.ui_in.value = 0
    # dut.uio_in.value = 0
    # dut.rst_n.value = 0
    # await ClockCycles(dut.clk, 10)
    # dut.rst_n.value = 1

    # dut._log.info("Test project behavior")

    # # Set the input values you want to test
    # dut.ui_in.value = 20
    # dut.uio_in.value = 30

    # # Wait for one clock cycle to see the output values
    # await ClockCycles(dut.clk, 1)

    # # The following assersion is just an example of how to check the output values.
    # # Change it to match the actual expected output of your module:
    # #assert dut.uo_out.value == 50

    # # Keep testing the module by changing the input values, waiting for
    # # one or more clock cycles, and asserting the expected output values.
