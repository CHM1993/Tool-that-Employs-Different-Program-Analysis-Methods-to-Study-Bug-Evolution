#!/usr/bin/env bash

version="$1"
tool="$2"
echo "${version:0:1}"
firstl="${version:0:1}"
end=$((SECONDS+80))
#first cloc
if [[ "$firstl" = "b" ]]
then
	wget https://ftp.gnu.org/gnu/binutils/${version}.tar.gz
	tar -xvf ${version}.tar.gz
fi
if [[ "$firstl" = "c" ]]
then
	wget https://ftp.gnu.org/gnu/binutils/${version}.tar.gz
	tar -xvf ${version}.tar.gz
fi

#cloc the version
if [[ "$firstl" = "b" ]]
then
	cloc ${version} >> cloc_${version}.txt
	mkdir -p ~/Utils/Binutils/${version}/cloc
	mv cloc_${version}.txt ~/Utils/Binutils/${version}/cloc
fi

if [[ "$firstl" = "c" ]]
then
	cloc ${version} >> cloc_${version}.txt
	mkdir -p ~/Utils/Coreutils/${version}/cloc
	mv cloc_${version}.txt ~/Utils/Coreutils/${version}/cloc
fi

#flawfinder
if [[ $tool == "flawfinder" ]]
then
	if [[ "$firstl" = "b" ]]
	then
		flawfinder --minlevel=4 --falsepositive ${version}/binutils/  >  flawfinder_results_${version}.txt
		mkdir -p ~/Utils/Binutils/${version}/flawfinder
		mv flawfinder_results_${version}.txt ~/Utils/Binutils/${version}/flawfinder
	fi
	if [[ "$firstl" = "c" ]]
	then
		flawfinder --minlevel=4 --falsepositive ${version}/src/  >  flawfinder_results_${version}.txt
		mkdir -p ~/Utils/Coreutils/${version}/flawfinder
		mv flawfinder_results_${version}.txt ~/Utils/Coreutils/${version}/flawfinder
	fi
#klee
elif [[ $tool == "klee" ]]
then
	if [[ "$firstl" = "b" ]]
	then

		cd ${version}
		pip install --upgrade wllvm
		export LLVM_COMPILER=clang
		mkdir obj-llvm
		cd obj-llvm
		CC=wllvm ../configure --disable-nls CFLAGS="-g"
		CC=wllvm make
		CC=wllvm make -C binutils all
		cd binutils
		find . -executable -type f | xargs -I '{}' extract-bc '{}'
		for i in *.bc 
		do
			klee --libc=uclibc --posix-runtime "${i%}" --sym-arg 3 3 10
			yes "" | command 
		done
		mkdir -p ~/Utils/Binutils/${version}/klee
		for i in klee-*
		do
			mv ${i%} ~/Utils/Binutils/${version}/klee
		done
	fi
	if [ "$firstl" = "c" ]
	then

		cd ${version}
		pip install --upgrade wllvm
		export LLVM_COMPILER=clang
		sudo mkdir obj-llvm
		cd obj-llvm
		CC=wllvm ../configure --disable-nls CFLAGS="-g"
		CC=wllvm make
		CC=wllvm make -C src all
		cd src
		find . -executable -type f | xargs -I '{}' extract-bc '{}'
		for i in *.bc 
		do
			if [ $i != "tail.bc" ] && [ $i != "vdir.bc" ]
			then
				klee --libc=uclibc --posix-runtime "${i%}" --sym-arg 3 3 10
#				yes "" | command
			fi 
		done
		sudo mkdir -p ~/Utils/Coreutils/${version}/klee
		for i in klee-*
		do
			sudo mv "${i%}" ~/Utils/Coreutils/${version}/klee
		done
	fi

elif [[ $tool == "afl" ]]
then
	if [[ "$firstl" = "b" ]]
	then
		cd ~/
		wget https://ftp.gnu.org/gnu/binutils/${version}.tar.gz
		cp ${version}.tar.gz ~/afl-2.52b
		cd ~/afl-2.52b
		tar -xvf ${version}.tar.gz
		cd ${version}
		CC=afl-clang-fast ./configure
		make
		#make clean all
		cd binutils
		#preparation for AFL

		#cd /sys/devices/system/cpu
		#echo performance | tee cpu*/cpufreq/scaling_governor
		#sudo -s bash -c 'echo core.%e.%p > /proc/sys/kernel/core_pattern'
		#echo core.%e.%p > /proc/sys/kernel/core_pattern

		mkdir results
		sudo echo performance
		i=0
		for j in *
		do
			if [ -f ${j} ] && [ -x ${j} ]
			then
				echo "${j}"
				i=$((i+1))
				echo ${i}
				timeout 20m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_nm-new -m none ./binutils/nm-new -a @@
				timeout 20m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_objdump -m none ./binutils/objdump -a @@
				timeout 20m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_strings -m none ./binutils/strings -a @@
				timeout 20m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_readelf -m none ./binutils/readelf -a @@
				timeout 20m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_addr2line -m none ./binutils/addr2line -e @@
				timeout 20m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_objcopy -m none ./binutils/objcopy -S @@
				timeout 20m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_size -m none ./binutils/size -A @@
				timeout 20m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_strip-new -m none ./binutils/strip-new -s @@
			fi
		done
		mkdir -p ~/Utils/Binutils/${version}/afl
		for i in ${PWD}/results_*
		do
			mv "${i%}" ~/Utils/Binutils/${version}/afl
		done
	fi
	if [[ "$firstl" = "c" ]]
	then
		cd ~/
		wget https://ftp.gnu.org/gnu/coreutils/${version}.tar.xz
		cp ${version}.tar.xz ~/afl-2.52b
		cd ~/afl-2.52b
		tar -xvf ${version}.tar.xz
		cd ${version}
		CC=afl-clang-fast ./configure
		make
		cd src
		#preparation for AFL

		#cd /sys/devices/system/cpu
		#echo performance | tee cpu*/cpufreq/scaling_governor
		#sudo -s bash -c 'echo core.%e.%p > /proc/sys/kernel/core_pattern'
		#echo core.%e.%p > /proc/sys/kernel/core_pattern
		mkdir results
		i=0
		for j in *
		do
			if [ -f ${j} ] && [ -x ${j} ]
			then
				echo "${j}"
				i=$((i+1))
				echo ${i}
				if [ -f ${j} ] && [ -x ${j} ]
				then
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_base64 -m none ./src/base64 -d @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_cat -m none ./src/cat -A @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_cksum -m none ./src/cksum @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_date -m none ./src/date -f @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_expand -m none ./src/expand -i @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_fmt -m none ./src/fmt -c @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_fold -m none ./src/fold -b @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_md5sum -m none ./src/md5sum -b @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_od -m none ./src/od -v @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_paste -m none ./src/paste -s @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_ptx -m none ./src/ptx -A @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_sha1sum -m none ./src/sha1sum -b @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_shuf -m none ./src/shuf -z @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_split -m none ./src/split -d @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_sum -m none ./src/sum -r @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_tac -m none ./src/tac -b @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_unexpand -m none ./src/unexpand -a @@
					timeout 60m afl-fuzz -i /home/harry/afl-2.52b/testcases -o results_wc -m none ./src/wc -m @@


				fi
			fi
		done
		mkdir -p ~/Utils/Coreutils/${version}/afl
		for i in ${PWD}/results_*
		do
			mv "${i%}" ~/Utils/Coreutils/${version}/afl
		done
	fi
fi

# to run : yes | ./run_tools.sh binutils-2.27/2.27.1 klee/afl
