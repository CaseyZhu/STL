# Coding Guide
## File Extensions
Use the .sv extension for SystemVerilog files (or .svh for files that are included via the preprocessor).

File extensions have the following meanings:

.sv indicates a SystemVerilog file defining a module or package.
.svh indicates a SystemVerilog header file intended to be included in another file using a preprocessor `include directive.
.v indicates a Verilog-2001 file defining a module or package.
.vh indicates a Verilog-2001 header file.
Only .sv and .v files are intended to be compilation units. .svh and .vh files may only be `include-ed into other files.

With exceptions of netlist files, each .sv or .v file should contain only one module, and the name should be associated. For instance, file foo.sv should contain only the module foo.

## Naming

### Summary

| Construct                            | Style                   |
| ------------------------------------ | ----------------------- |
| Declarations (module, class, package, interface) | `lower_snake_case` |
| Instance names                       | `lower_snake_case`      |
| Signals (nets and ports)             | `lower_snake_case`      |
| Variables, functions, tasks          | `lower_snake_case`      |
| Named code blocks                    | `lower_snake_case`      |
| \`define macros                      | `ALL_CAPS`              |
| Tunable parameters for parameterized modules, classes, and interfaces | `UpperCamelCase` |
| Constants                            | `ALL_CAPS` or `UpperCamelCase` |
| Enumeration types                    | `lower_snake_case_e`    |
| Other typedef types                  | `lower_snake_case_t`    |
| Enumerated value names               | `UpperCamelCase`        |

### Suffixes

Suffixes are used in several places to give guidance to intent. The following
table lists the suffixes that have special meaning.

| Suffix(es)        | Arena | Intent |
| ---               | :---: | ---    |
| `_e`              | typedef     | Enumerated types |
| `_t`              | typedef     | Other typedefs, including signal clusters |
| `_n`              | signal name | Active low signal |
| `_n`, `_p`        | signal name | Differential pair, active low and active high |
| `_d`, `_q`        | signal name | Input and output of register |
| `_q2`,`_q3`, etc  | signal name | Pipelined versions of signals; `_q` is one cycle of latency, `_q2` is two cycles, `_q3` is three, etc |
| `_i`, `_o`, `_io` | signal name | Module inputs, outputs, and bidirectionals |
| `_hsk`,`_rden`,`_wren`| signal name | hand shake, read/write enable  |
When multiple suffixes are necessary use the following guidelines:

* Guidance suffixes are added together and not separated by additional `_`
  characters (`_ni` not `_n_i`)
* If the signal is active low `_n` will be the first suffix
* If the signal is a module input/output the letters will come last.
* It is not mandatory to propagate `_d` and `_q` to module boundaries.
  

### Clocks

***All clock signals must begin with `clk`.***

The main system clock for a design must be named `clk`. It is acceptable to use
`clk` to refer to the default clock that the majority of the logic in a module
is synchronous with.

If a module contains multiple clocks, the clocks that are not the system clock
should be named with a unique identifier, preceded by the `clk_` prefix. For
example: `clk_dram`, `clk_axi`, etc. Note that this prefix will be
used to identify other signals in that clock domain.

### Resets

***Resets are active-low and asynchronous. The default name is `rst_n`.***

Chip wide all resets are defined as active low and asynchronous. Thus they are
defined as tied to the asynchronous reset input of the associated standard
cell registers.

The default name is `rst_n`. If they must be distinguished by their clock, the
clock name should be included in the reset name like `rst_domain_n`.

***data can use none-rest Dffs to save power. 
The control register signal is better to use Macro, this is easy to shift between FPGA and ASIC***  

For example:  
    \`define ALWAYS_CLK(clk, rst_n) always@(posedge clk or negedge rst_n)   declare  this macro in a common file. We can change the aynchronous reset block to synchronous  reset by redefine the macro to   \`define ALWAYS_CLK(clk, rst_n) always@(posedge clk)

    ```systemverilog
    `ALWAYS_CLK(clk, rst_n)
    if (!rst_n) begin
        q <= 1'b0;
    end else begin
        q <= d;
    end
    ```
## Language Features

### Preferred SystemVerilog Constructs

Use these SystemVerilog constructs instead of their Verilog-2001 equivalents:

-   `always_comb` is required over `always @*`.
-   `logic` is preferred over `reg` and `wire`.
-   Top-level `parameter` declarations are preferred over `` `define`` globals.

### Module Declaration

***Use the Verilog-2001 full port declaration style, and use the format
below.***

Use the Verilog-2001 combined port and I/O declaration style. Do not use the
Verilog-95 list style. The port declaration in the module statement should fully
declare the port name, type, and direction.

The opening parenthesis should be on the same line as the module declaration,
and the first port should be declared on the following line.

The closing parenthesis should be on its own line, in column zero.

Indentation for module declaration follows the standard indentation
rule of two space indentation.

The clock port(s) must be declared first in the port list, followed by any and
all reset inputs.  

Example with parameters:

&#x1f44d;
```systemverilog {.good}
module foo #(
  parameter  WIDTH = 8
) (
  input                    clk,
  input                    rst_n,
  input [Width-1:0]        d_i,
  output logic [Width-1:0] q_o
);
```

### Module Instantiation

***Use named ports to fully specify all instantiations.***

When connecting signals to ports for an instantiation, use the named port style,
like this:

```systemverilog
my_module i_my_instance (
  .clk (clk),
  .rst_n(rst_n),
  .d_i   (from_here),
  .q_o   (to_there)
);
```
All declared ports must be present in the instantiation blocks. Unconnected
outputs must be explicitly written as no-connects (for example:
`.output_port()`), and unused inputs must be explicitly tied to ground (for
example: `.unused_input_port(8'd0)`)

`.*` is not permitted.

Do not use positional arguments to connect signals to ports.

### Constants

***It is recommended to use symbolicly named constants instead of
raw numbers.***

Try to give commonly used constants symbolic names rather than repeatedly typing
raw numbers.

Local constants should always be declared using `localparam`.

Global constants should always be declared in a separate `.vh` or `.svh` include
file.

For SystemVerilog code, global constants should always be declared as package
parameters. For Verilog-2001 compatible code, top-level parameters are not
supported and `` `define`` macros must be used instead.

### Blocking and Non-blocking Assignments

***Sequential logic must use non-blocking assignments.  Combinational
blocks must use blocking assignments.***

Never mix assignment types within a block declaration.

A sequential block (a block that latches state on a clock edge) must exclusively
use non-block assignments, as defined in the Sequential Logic section below.

Purely combinational blocks must exclusively use blocking assignments.

This is one of Cliff Cumming's [Golden Rules of
Verilog](http://www.ece.cmu.edu/~ece447/s13/lib/exe/fetch.php?media=synth-verilog-cummins.pdf).

### Delay Modeling

***Do not use `#delay` in synthesizable design modules.***

Synthesizable design modules must be designed around a zero-delay simulation
methodology. All forms of `#delay`, including `#0`, are not permitted.

See Cliff Cumming's [Verilog Nonblocking Assignments With Delays, Myths &
Mysteries](http://www.sunburst-design.com/papers/CummingsSNUG2002Boston_NBAwithDelays.pdf)
for details.

### Sequential Logic (Latches)

***The use of latches is discouraged - use flip-flops when possible.***

Unless absolutely necessary, use flops/registers instead of latches.

If you must use a latch, use `always_latch` over `always`, and use non-blocking
assignments (`<=`). Never use blocking assignments (`=`).

### Sequential Logic (Registers)

***Use the standard format for declaring sequential blocks.***

In a sequential always block, only use non-blocking assignments (`<=`). Never
use blocking assignments (`=`).

Designs that mix blocking and non-blocking assignments for registers simulate
incorrectly because some simulators process some of the blocking assignments in
an always block as occurring in a separate simulation event as the non-blocking
assignment. This process makes some signals jump registers, potentially leading
to total protonic reversal. That's bad.

Sequential statements for state assignments should only contain reset values and
a next-state to state assignment, use a separate combinational-only block to
generate that next-state value.

### Combinational Logic

***Avoid sensitivity lists, and use a consistent assignment type.***

Use `always_comb` for SystemVerilog combinational blocks. Use `always @*` if
only Verilog-2001 is supported. Never explicitly declare sensitivity lists for
combinational logic.

Prefer assign statements wherever practical.

Example:

```systemverilog
assign final_value = xyz ? value_a : value_b;
```

Where a case statement is needed, enclose it in its own `always_comb` block.

Synthesizable combinational logic blocks should only use blocking assignments.

Do not use three-state logic (`Z` state) to accomplish on-chip logic such as
muxing.

Do not infer a latch inside a function, as this may cause a simulation /
synthesis mismatch.

### Generate 
* generate for/if. Naming each nest explicitly. For example:
  ```
  for(genvar i;i<8;i++) begin:FOR_LOOP
     sv code...
  end:FOR_LOOP
  ```
* for loop in always_comb are discouraged

### Split Combinational and Sequential Logic
&#x1f44d;
```systemverilog {.good}
assign c_d = a_q + b_q;
always_ff@(posedge clk )
   c_q <= c_d;
```
&#x1f44e;
```systemverilog {.bad}
always_ff@(posedge clk )
   c_q <= a_q + b_q;
```
### No need reset on data
When using data the control signal must be checked first.  

&#x1f44d;
```systemverilog {.good}
assign c_d = a_q + b_q;
always_ff@(posedge clk )
   c_q <= c_d;
```
### Add update condition when necessary 
In this sytle synthesis tool can add ICG automatically.   

&#x1f44d;&#x1f44d;
```systemverilog {.good}
assign c_d = a_q + b_q;
always_ff@(posedge clk )
  if(hsk)
    c_q <= c_d;
```

## Design Conventions

### Summary

The key ideas in this section include:

*   Declare all signals and use `logic`: `logic foo;`
*   Packed arrays are little-endian: `logic [7:0] byte;`
*   Unpacked arrays are big-endian: `byte_t arr[0:N-1];` and this is discouraged
*   Prefer to register module outputs.
*   Declare FSMs consistently.

### Declare all signals

***Do not rely on inferred nets.***

All signals **must** be explicitly declared before use. All declared signals
must specify a data type. A correct design contains no inferred nets.

### Use `logic` for synthesis

***Use `logic` for synthesis. `wire` is allowed when necessary.***

All signals in synthesizable RTL must be implemented in terms of 4-state data
types. This means that all signals must ultimately be constructed of nets with
the storage type of `logic`. While SystemVerilog does provide other data
primitives with 4-state storage (ie. `integer`), those primitives are prone to
misunderstandings and misuse.

For example:

&#x1f44d;
```systemverilog {.good}
logic signed [31:0] x_velocity;  // say what you mean: a signed 32-bit integer.
typedef logic [7:0] byte_t;
```

&#x1f44e;
```systemverilog {.bad}
bit signed [63:0] stars_in_the_sky;  // 2-state logic doesn't belong in RTL
int grains_of_sand;  // Or wait, did I mean integer?  Easy to confuse!
```

### Logical vs. Bitwise

***Prefer logical constructs for logical comparisons, bit-wise for data.***

Logical operators (`!`, `||`, `&&`, `==`, `!=`) should be used for all
constructs that are evaluating logic (true or false) values, such as
if clauses and ternary assignments.  Prefer bit-wise operators (`~`, `|`,
`&`, `^`) for all data constructs, even if scalar. Exceptions can be made
where it is clear that the evaluated expression is to be used in a logical
context.

### Packed Ordering

***Bit vectors and packed arrays must be little-endian.***

When declaring bit vectors and packed arrays, the index of the most-significant
bound (left of the colon) must be greater than or equal to the least-significant
bound (right of the colon).

This style of bit vector declaration keeps packed variables little-endian.

For example:

```systemverilog
typedef logic [7:0] u8_t;
logic [31:0] u32_word;
u8_t [1:0] u16_word;
u8_t byte3, byte2, byte1, byte0;
assign u16_word = {byte1, byte0};
assign u32_word = {byte3, byte2, u16_word};
```

### Finite State Machines

***State machines use an enum to define states, and be implemented with
two process blocks: a combinational block and a clocked block.***

Every state machine description has three parts:

1.  An enum that declares and describes the states.
1.  A combinational process block that decodes state to produce next state and
    other combinational outputs.
1.  A clocked process block that updates state from next state.

*Enumerating States*

The enum statement for the state machine should list each state in the state
machine. Comments describing the states should be deferred to case statement in
the combinational process block, below.

States should be named in `UpperCamelCase`, like other
[enumeration constants](#enumerations).

Barring special circumstances, the initial idle state of the state
machines will be named `Idle` or `StIdle`. (Alternate names are acceptable
if they improve clarity.)

Ideally, each module should only contain one state machine. If your module needs
more than one state machine, you will need to add a unique prefix (or suffix) to
the states of each state machine, to distinguish which state is associated with
which state machine. For example, a module with a "reader" machine and a
"writer" machine might have a `StRdIdle` state and a `StWrIdle` state.

*Combinational Decode of State*

The combinational process block should contain:

-   A case statement that decodes state to produce next state and combinational
    outputs. For clarity, only cases where the output value deviates from the
    default should be coded.
-   Before the case statement should be a block of code that defines default
    values for every combinational output, including "next state."
-   The default value for the "next state" variable should be the current state.
    The case statement that decodes state will then only assign to "next state"
    when transitioning between states.
-   Within the case statement, each state alternative should be preceded with a
    comment that describes the function of that state within the state machine.

*The State Register*

No logic except for reset should be performed in this process. The state
variable should latch the value of the "next state" variable.

*Other Guidelines*

When possible, try to choose state names that differ near the beginning of their
name, to make them more readable when viewing waveform traces.

*Example*

&#x1f44d;
```systemverilog {.good}
// Define the states
typedef enum {
  StIdle, StFrameStart, StDynInstrRead, StBandCorr, StAccStoreWrite, StBandEnd
} alcor_state_e;

alcor_state_e alcor_state_d, alcor_state_q;

// Combinational decode of the state
always_comb begin
  alcor_state_d = alcor_state_q;
  foo = 1'b0;
  bar = 1'b0;
  bum = 1'b0;
  unique case (alcor_state_q)
    // StIdle: waiting for frame_start
    StIdle:
      if (frame_start) begin
        foo = 1'b1;
        alcor_state_d = StFrameStart;
      end
    // StFrameStart: Reset accumulators
    StFrameStart: begin
      // ... etc ...
    end
    // may be empty or used to catch parasitic states
    default: alcor_state_d = StIdle;
  endcase
end

// Register the state
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    alcor_state_q <= StIdle;
  end else begin
    alcor_state_q <= alcor_state_d;
  end
end
```

### Active-Low Signals

***The `_n` suffix indicates an active-low signal.***

If active-low signals are used, they must have the `_n` suffix in their
name. Otherwise, all signals are assumed to be active-high.

### Differential Pairs

***Use the `_p` and `_n` suffixes to indicate a differential pair.***

For example, `in_p` and `in_n` comprise a differential pair set.

### Delays

***Signals delayed by a single clock cycle should end in a `_q` suffix.***

If one signal is only a delayed version of another signal, the `_q` suffix
should be used to indicate this relationship.

If another signal is then delayed by another clock cycle, the next signal should
be identifed with the `_q2` suffix, and then `_q3` and so on.

Example:

```systemverilog
always_ff @(posedge clk) begin
  data_valid_q <= data_valid_d;
  data_valid_q2 <= data_valid_q;
  data_valid_q3 <= data_valid_q2;
end
```

### Wildcard import of packages

The wildcard import syntax, e.g. `import ip_pkg::*;` is only allowed where the
package is part of the same IP as the module that uses that package.  Wildcard
import statement must be placed in the module header or in the module body.

&#x1f44d;
```systemverilog {.good}
// mod_a_pkg.sv and mod_a.sv are in the same IP.
// Packages can be imported in the module declaration if access to
// unqualified types is needed in the port list.

// mod_a_pkg.sv
package mod_a_pkg;

  typedef struct packed {
    ...
  } a_req_t;
endpackage

// mod_a.sv
module mod_a
  import mod_a_pkg::*;
(
  ...
  a_req_t a_req,
  ...
);

endmodule
```
### Assertion Macros

It is encouraged to use SystemVerilog assertions (SVAs) throughout the design to
check functional correctness and flag invalid conditions. In order to increase
productivity and keep the assertions short and concise, the following assertion
macros can be used:

```systemverilog
// immediate assertion, to be placed within a process.
`ASSERT_I(<name>, <property>)
// immediate assertion wrapped within an initial block. can be used for things
// like parameter checking.
`ASSERT_INIT(<name>, <property>)
// concurrent assertion to be used for functional assertions.
`ASSERT(<name>, <property>, <clk>, <reset condition>)
// concurrent assertion that checks that a signal has a known value after reset
// (i.e. that the signal is not `X`).
`ASSERT_KNOWN(<name>, <signal>, <clk>, <reset condition>)
```

## Appendix - Condensed Style Guide

This is a short summary of the Comportable style guide. Refer to the main text
body for explanations examples, and exceptions.

### Basic Style Elements

* Use SystemVerilog-2012 conventions, files named as module.sv, one file
  per module
* Only ASCII, **100** chars per line, **no** tabs, **two** spaces per
  indent for all paired keywords.
* C++ style comments `//`
* For multiple items on a line, **one** space must separate the comma
  and the next character
* Include **whitespace** around keywords and binary operators
* **No** space between case item and colon, function/task/macro call
  and open parenthesis
* Line wraps should indent by **four** spaces
* `begin` must be on the same line as the preceding keyword and end
  the line
* `end` must start a new line

### Construct Naming

* Use **lower\_snake\_case** for instance names, signals, declarations,
  variables, types
* Use **UpperCamelCase** for tunable parameters, enumerated value names
* Use **ALL\_CAPS** for constants and define macros
* Main clock signal is named `clk`. All clock signals must start with `clk_`
* Reset signals are **active-low** and **asynchronous**, default name is
  `rst_n`
* Signal names should be descriptive and be consistent throughout the
  hierarchy

### Suffixes for signals and types

* Add `_i` to module inputs, `_o` to module outputs or `_io` for
  bi-directional module signals
* The input (next state) of a registered signal should have `_d` and
  the output `_q` as suffix
* Pipelined versions of signals should be named `_q2`, `_q3`, etc. to
  reflect their latency
* Active low signals should use `_n`. When using differential signals use
  `_p` for active high
* Enumerated types should be suffixed with `_e`
* Multiple suffixes will not be separated with `_`. `n` should come first
  `i`, `o`, or `io` last

### Language features

* Use **full port declaration style** for modules, any clock and reset
  declared first
* Use **named parameters** for instantiation, all declared ports must
  be present, no `.*`
* Top-level parameters is preferred over `` `define`` globals
* Use **symbolically named constants** instead of raw numbers
* Local constants should be declared `localparam`, globals in a separate
  **.svh** file.
* `logic` is preferred over `reg` and `wire`, declare all signals
  explicitly
* `always_comb`, `always_ff` and `always_latch` are preferred over `always`
* Interfaces are discouraged
* Sequential logic must use **non-blocking** assignments
* Combinational blocks must use **blocking** assignments
* Use of latches is discouraged, use flip-flops when possible
* The use of `X` assignments in RTL is strongly discouraged, make use of SVAs
  to check invalid behavior instead.
* Prefer `assign` statements wherever practical.
* Use `unique case` and always define a `default` case
* Use available signed arithmetic constructs wherever signed arithmetic
  is used
* When printing use `0b` and `0x` as a prefix for binary and hex. Use
  `_` for clarity
* Use logical constructs (i.e `||`) for logical comparison, bit-wise
  (i.e `|`) for data comparison
* Bit vectors and packed arrays must be little-endian, unpacked arrays
  must be big-endian
* FSMs: **no logic** except for reset should be performed in the process
  for the state register
* A combinational process should first define **default value** of all
  outputs in the process
* Default value for next state variable should be the current state

