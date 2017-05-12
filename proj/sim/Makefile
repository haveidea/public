VCS_OPTS= -full64 -P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab  ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a
vcs:
	vcs ${VCS_OPTS} -f flist.f -sverilog -l vcs.log

verdi:
	verdi -f flist.f -sv

