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
        assert dut.o_step_forward.value == 0
        #两个脉冲后产生脉冲信号
        dut.i_encoder_a.value=1-dut.i_encoder_a.value;
        await ClockCycles(dut.clk, 3)
        assert dut.o_step_forward.value == 1
        # 只产生一个时钟的信号，下一个时钟已经为低
        await ClockCycles(dut.clk, 1)
        assert dut.o_step_forward.value == 0
    #模拟抖动
    #后向移动,产生一个脉冲
    dut.i_encoder_a.value=1-dut.i_encoder_a.value;
    await ClockCycles(dut.clk, 3)
    assert dut.o_step_forward.value == 1
    # 只产生一个时钟的信号，下一个时钟已经为低
    await ClockCycles(dut.clk, 1)
    assert dut.o_step_forward.value == 0
    #同一信号抖动不应该产生脉冲
    for i in range(10):
            dut.i_encoder_a.value=1-dut.i_encoder_a.value;
            for i in range(1):
                await ClockCycles(dut.clk, 1)
                # assert dut.o_step_forward.value == 0
                # assert dut.o_step_back.value == 0
    # 编码器抖动情况
    