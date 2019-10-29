# Tool that Employs Different Program Analysis Methods to Study Bug Evolution

## Introduction
We created a tool in order to examine the evolution of bugs
found in two well-known sets
of libraries, namely:
the [gnu Binary Utilities](https://www.gnu.org/software/binutils/)
and [gnu Core Utilities](https://www.gnu.org/software/coreutils/).
Contrary to other studies we utilize
multiple well-established tools
that implement different approaches
to discover bugs.
To do so,
we have developed an automated method
that given a program analysis tool and
the repository of a software project,
it analyzes all project versions
with the tool and stores all results.

This provided us with the opportunity
to not only check the evolution
of bugs found in popular libraries,
but also examine the different kinds of bugs
each tool detects.
In addition,
we have performed a qualitative analysis
on the results of each tool to observe the persistence
of the bugs and identify corresponding [CVE](https://www.cvedetails.com/)
(Common Vulnerabilities and Exposure) entries.

We examined 13 versions of Binary Utilities,
from 2.11 to 2.32 (the most recent ones).
Notably,
we omitted versions from 2.15 to 2.21
because they were experimental ones
and they did not include all utilities.
Furthermore,
we analyzed the 7 latest versions of Core Utilities.
We decided to focus on the latest versions
because the previous ones have
been extensively examined before.
We left out versions 8.15 to 8.19 because they
were incomplete, experimental releases.

## Tool Setup

Our Tool is able to use :
  - [Flawfinder](https://dwheeler.com/flawfinder/) - (static analyzer),
  - [Klee](http://klee.github.io/) - (symbolic execution tool),
  - [AFL](http://lcamtuf.coredump.cx/afl/) - (Fuzzer)

We installed all three tools
on an Ubuntu machine with
Intel Core i7 with 12 GB of RAM.
In particular,
we employed the latest versions
of both afl
(**afl-2.52b**)
and Flawfinder (**2.0.8**).
In the case of klee,
we used a **docker image**
available in the project's web site (version 1.4).
For each case we did a specific setup.
We configured Flawfinder to search for threats
of a high risk level
and the arguments for **AFL**
were configured differently
for every utility.
Specifically,
we searched the manual pages of each
utility and used the arguments that every
function works well with.
Finally,
we have extended afl to automatically
run the test cases
that the tool produces
(i.e. afl generates
a test case when the target application crashes)
and examine the reasons behind the crashes.

## Run the Tool

In order to run the Tool you should define the **Coreutils** or **Binutils** version that you want to examine and then define whether you want to use **Flawfinder**, **Klee** or **AFL**. Here is an example:

    ./run_tools.sh binutils-2.27 klee

Results are stored in a JSON format file. The results can be shown in a graph form by running the commands below:

    python ./core_errors.py Utils/Coreutils/
and:

    python ./bin_errors.py Utils/Binutils/
    
