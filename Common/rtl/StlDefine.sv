// ---------------------------------------------------------------------
//
// FILE NAME    : StlDefine.v
// AUTHOR       : zhuzhiqi
// EMAIL        : zhuzhiqi2021@163.com
//
// ---------------------------------------------------------------------
//
// Release history
// 0.1  2022-06-26     zhuzhiqi   initial coding
//
// ---------------------------------------------------------------------
`define ALWAYS_CLK(clk, rst_n) always_ff@(posedge clk or negedge rst_n)


//start_date: the date you add the todo list. format:YMD, for example 20220624
//days: if this todo list not done in days you set simulation will stop.
//for example you want to finish this todo item in 30 days from 20220624
//add this macro " `NEEDTODO_INTIME(20220624,30,revise_param) " in your code
//Warnning: space are not allowed in msg
`define NEEDTODO_INTIME(start_date,days,msg)        \
(* translate_off *)                                 \
initial begin                                       \
    int current_date,current_days,start_days;       \
    integer file;                                   \
    $system("date +%Y%m%d > tmp_time.txt");         \
    file=$fopen("tmp_time.txt","r");                \
    $fscanf(file,"%d",current_date);                \
    $fclose(file);                                  \
    $system("rm tmp_time.txt");                     \
    current_days =  (current_date%100) +            \
                    ((current_date/100)%100)*30 +   \
                    (current_date/10000)*12*30;     \
    start_days   =  (start_date%100) +              \
                    ((start_date/100)%100)*30  +    \
                    (start_date/10000)*12*30 +      \
                    days;                           \
    assert(current_days < start_days)               \
    else $fatal("%m TODO: msg not done in time ."); \
                                                    \
end                                                 \
(* translate_on *)

