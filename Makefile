SHELL=/bin/bash
CMT=../cmt
LOG=../dep_compile_logs

inject_cmt:
		@if [ ! -d ${LOG} ]; then mkdir ${LOG} ; fi
		@if [ -d ${CMT} ]; then 																				\
			FOLDERS=$$(find ./ -mindepth 1 -maxdepth 2 -type d | grep -v '.git' | grep -v 'General/Upsilon'); 	\
			echo "Injecting code.."; 																			\
			LOG_FILE="${LOG}/inject.log_$$(date +%Y-%m-%d_%H-%M-%S)"; 											\
			for FOLDER in $${FOLDERS}; do 																		\
				echo ".. into $${FOLDER}";																		\
				${CMT}/cmt-inject.py --folder-path $${FOLDER} >> $${LOG_FILE};									\
			done;																								\
		else 																									\
			echo "Failure: ${CMT} does not exists."; 															\
		fi
