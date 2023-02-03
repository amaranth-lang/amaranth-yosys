attribute \generator "Amaranth"
attribute \top 1
attribute \amaranth.hierarchy "top"
module \top
  attribute \src "<stdin>:1"
  wire width 1 input 0 \i
  attribute \init 1'0
  attribute \src "<stdin>:1"
  wire width 1 output 1 \o
  attribute \src "<stdin>:1"
  wire width 1 \o$next
  attribute \src "/home/whitequark/Projects/amaranth/amaranth/hdl/ir.py:527"
  wire width 1 input 2 \clk
  attribute \src "/home/whitequark/Projects/amaranth/amaranth/hdl/ir.py:527"
  wire width 1 input 3 \rst
  attribute \src "<stdin>:1"
  wire width 1 $1
  attribute \src "<stdin>:1"
  cell $not $2
    parameter \A_SIGNED 0
    parameter \A_WIDTH 1
    parameter \Y_WIDTH 1
    connect \A \i
    connect \Y $1
  end
  process $group_0
    assign \o$next \o
    assign \o$next $1
    attribute \src "/home/whitequark/Projects/amaranth/amaranth/hdl/xfrm.py:516"
    switch \rst
      case 1'1
        assign \o$next 1'0
    end
  end
  cell $dff $3
    parameter \CLK_POLARITY 1
    parameter \WIDTH 1
    connect \CLK \clk
    connect \D \o$next
    connect \Q \o
  end
end
