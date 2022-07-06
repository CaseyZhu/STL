#!/usr/bin/perl
# ---------------------------------------------------------------------
#
# FILE NAME    : run.pl
# AUTHOR       : zhuzhiqi
# EMAIL        : zhuzhiqi@sensetime.com
#
# ---------------------------------------------------------------------
#
# Release history
# 0.1  2019-06-10     zhuzhiqi   initial coding
#
# ---------------------------------------------------------------------
$top = "tb";

use Getopt::Long;
GetOptions ("h","c","r","cl","d","lr","cov","pn=i","cfg","v=s","rdm","rdmc","rdmcs","tn=s", "dir=s");

sub show_help
{
  print "//===============================================================================
   gen_case_cfg.pl -h    : show help info 
                   -c    : compile
                   -cov  : compile or run test case with coverage
                   -l    : run test case list
                   -lr   : run test case with reset
                   -r    : run regression
                   -v    : run one test case
                   -rdm  : run test in random mode
                   -rdmc : run test in random mode, the case is multi-layer
                   -rdmcs : run test in random mode, the case is multi-layer
                   -rdm_n: how many test case to run in random mode, 0 means always run untill fail, default is 0
                   -d    : fsdb dump enable
                   -pn   : specify PU_NUM when compile default is 8
                   -cfg  : run the test case with configure eanble(configure vpu internal register)
  //=============================================================================\n";    
}


if($opt_h or ( not(defined($opt_c))  and 
               not(defined($opt_l))  and 
               not(defined($opt_cl)) and 
               not(defined($opt_r))  and 
               not(defined($opt_v))  and
               not(defined($opt_rdm)) and
               not(defined($opt_rdmc))and
               not(defined($opt_rdmcs))and
               not(defined($opt_cov))
             ) )
{
  &show_help;
  exit;
}


if(defined($opt_cl))
{
  `rm -rf *.log sim* vc_hdrs.h verdiLog ucli.key race* novas.rc csrc run.fsdb *.daidir`;
  exit;
}
if(defined($opt_c))
{
  &run_compile();
  exit;
}


if(defined($opt_r))
{
  #&run_compile();
  &run_l();
  exit;    
}
#if(defined($opt_cov))
#{
  #&run_compile();
  #exit;
#}
sub run_compile
{
    $RTL_F = "./flist";
    `mkdir -p ./csrc`;
    #$ENV_F = $ENV{ENV_F};
    $com_opt  = "-l ./compile.log  ";
    #$com_opt .= "-ntb_opts uvm -full64 ";
    $com_opt  = "-full64 ";
    $com_opt .= "-sverilog ";
    #$com_opt .= "+define+UVM_PACKER_MAX_BYTES=1500000 ";
    #$com_opt .= "+define+UVM_DISABLE_AUTO_ITEM_RECORDING ";
    $com_opt .= "-timescale=1ns/1ps ";
    #$com_opt .= "+plusarg_save +vcs+initreg+random ";
    $com_opt .= "-debug_access+all+reverse ";
    $com_opt .= "-debug_region=cell+encrypt -notice ";
    #$com_opt .= "-work mylib	";
    #$com_opt .= "-Mdir=./csrc	";
    #$com_opt .= "-Mlib=./csrc	";
    #$com_opt .= "+radincr	";
    #$com_opt .= "-race	";
    #$com_opt .= "+vcs+flush+all	";
    $com_opt .= "+vcs+loopdetect +vcs+loopreport ";
    #$com_opt .= "+define+SVT_UVM_TECHNOLOGY ";
    #$com_opt .= "+define+SYNOPSYS_SV ";
    #$com_opt .= "+define+WAVES_DVE ";
    #$com_opt .= "+define+WAVES=\"dve\" ";
    #$com_opt .= "+define+ASIC_VERSION	";
    #$com_opt .= "+define+TSMC_CM_UNIT_DELAY	";
    #$com_opt .= "+define+TSMC_CM_NO_WARNING	";
    $com_opt .= "-kdb 	";
    $com_opt .= "-lca 	";
    $com_opt .= "+vcs+lic+wait	";
    #$com_opt .= "-hsopt=elabpart ";
    #$com_opt .= "+define+NDS_IO_SLAVEPORT	";
    #$com_opt .= "+define+CUSTOM_MASTER	";
    #$com_opt .= "+define+RAM_AS_REG	";
    #$com_opt .= "-hsopt=j28		";
    #$com_opt .= "-hsopt=gates		";
    $com_opt .= "-o	sim_stpu	";
    #$com_opt .= "-assert disable_assert ";
    #$com_opt .= "+define+RM_EN   "; 
    #$com_opt .= "+define+NO_FSDB ";
    $com_opt .= "+incdir+../../Common/rtl/ ";
    $com_opt .= "-top $top -f $RTL_F  -assert	svaext ";
    $com_opt .= "-cm line+cond+tgl+branch " if(defined($opt_cov));
	  $com_opt .= "-cm_dir ./sim_dir/simv.vdb " if(defined($opt_cov));
    $com_opt .= "-cm_hier ./tcl/cov.cfg " if(defined($opt_cov));
    system("vcs $com_opt | tee compile.log ");
    
}




sub run_l
{
    #open IN, "< $case_list" or die "can not open $case_list $!\n";
    #@case = <IN>;
    #$case_cnt = $#case;
    `mkdir -p ./tcl`;
    `echo "fsdbDumpfile run.fsdb" > ./tcl/dump.tcl`;
    `echo "fsdbDumpMDA 0 $top"  >> ./tcl/dump.tcl`;
    `echo "fsdbDumpvars 0 $top"  >> ./tcl/dump.tcl`;
    `echo "fsdbDumpvars +all"  >> ./tcl/dump.tcl`;
    `echo "run"  >> ./tcl/dump.tcl`;
    `echo "quit"  >> ./tcl/dump.tcl`;
    
    #$run_opt  = "+vcs+initreg+0 +vcs+initmem+0 -l vcs.log ";
    #$run_opt .= "+uvm_set_severity=*svt_axi_base_slave_common.svp*,*svt_err_check_stats*,ALL,ALL,UVM_WARNING,UVM_ERROR ";
    #$run_opt .= "+UVM_VERBOSITY=UVM_NONE ";
    $run_opt .= "-cm line+cond+tgl+branch " if(defined($opt_cov));
    #$run_opt .= "+case_num=$case_cnt ";
    $run_opt .= "+TC_NAME=$opt_tn +TC_DIR=$opt_dir  " if(defined($opt_tn));
    $run_opt .= "+vcs+loopreport -ucli -do ./tcl/dump.tcl " ;
    if(-e "./sim_stpu"){
        system("./sim_stpu $run_opt | tee vcs.log ");
    }
    else {
        print "No sim_stpu, compile first\n";
        &run_compile();
        system("./sim_stpu $run_opt | tee vcs.log ");
    }

}


