DEFINE += +define+SIMU
 VCS_COMPILE_OPTS = -full64 
#VCS_COMPILE_OPTS += -P ${VERDI_HOME}/share/PLI/VCS/linux64/novas.tab ${VERDI_HOME}/share/PLI/VCS/linux64/pli.a 
 VCS_COMPILE_OPTS  += -debug_access -sverilog ${DEFINE}
 VCS_COMPILE       += -ucli2Proc
 VCS_COMPILE       += +lint=PCWM

 VCS_COMMON_OPTS += -ucli 
 VCS_COMMON_OPTS += +cli+2
 VCS_COMMON_OPTS += +fsdb+mda=on
# VCS_COMMON_OPTS += +vcs+loopreport
# VCS_COMMON_OPTS += +vcs+loopdetect

 VCS_RUN_OPTS = 

#VERDI_OPTS = -workMode protocolDebug
 VERDI_OPTS = -workMode hardwareDebug ${DEFINE}

VCS_OPTS= -full64 -P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab  ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a
vcs: compile run

compile:
	vcs  -f flist.f  ${VCS_COMPILE_OPTS} ${VCS_COMMON_OPTS} -l sim.log 
run:
	./simv   ${VCS_COMMON_OPTS} ${VCS_RUN_OPTS} -l run.log
verdi:
	verdi -f flist.f -sv ${VERDI_OPTS}

