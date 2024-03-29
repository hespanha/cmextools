# CmexTools

## Table of Contents

* [Description](#description)
* [Installation](#installation)
* [Usage](#usage)
* [Issues](#issues)
* [Contact Information](#contact-information)
* [License Information](#license-information)

## Description

The *CmexTools* *Matlab* toolbox is part of the *TensCalc* *Matlab* toolbox
but is useful on its own right. It is used to create a set of gateway
cmex functions (which we call *cmex-functions*) that internally call C
functions (which we call the *c-functions*) that actually perform the
necessary computations.

The inputs an outputs to the cmex-functions are specified by a
*template* that specifies the types and sizes of the input-output
*Matlab* arrays.  The sizes may be left as variables, which are
determined at run-time, in which case the "unknown" sizes must also be
passed as inputs to the c-functions. 

The cmex-functions may (optionally) be encapsulated as a *Matlab*
*class*, which is automatically created. When the c-functions are part
of a dynamic library, this permits the cmex-functions to share
variables that are retained across multiple calls to the
cmex-functions.

Several options are possible for how the cmex-functions call the c-function

1. The c-functions may be included directly into the mex-functions
   code; and called directly from the gateway function.  In this case,
   source code must be provided for each c-function to be included in
   the gateway function using a #include preprocessor directive.

2. The c-functions are part of a dynamic library that is linked to the
   cmex-functions in run time.  In this case, source code for the
   dynamic Library must be provided as a single file, which will be
   compiled as a dynamic library.

3. Each c-function is compiled as a standalone executable, that is
   executed from within the corresponding cmex-function, using the
   system() command.  Data is passed between the cmex-function and the
   c-function by writing to a file.

4. All c-functions are compiled to a standalone executable, which acts
   a server that calls the c-functions at request of the client
   cmex-functions.  Data is passed between clients and server through
   a socket, which permits clients and server to run on different
   computers.

## Installation

The *CmexTools* toolbox supports *Matlab* running under:

- OSX (tested extensivly)
- linux (tested lightly)
- Microsoft Windows (very little testing)

To install

1. Make sure that you *Matlab*'s `mex` function properly configured.

	* In OSX, `mex` should be configured to use *Xcode with Clang* for
	  C language compilation. To verify that this is so, type at the
	  *Matlab* prompt:
	  
	  ```matlab
	  mex -setup C
	  ```
	  
	  You should see something like
	  
	  > \>\> mex -setup C
	  >
	  > MEX configured to use 'Xcode with Clang' for C language compilation.
	  >
      > Warning: The MATLAB C and Fortran API has changed to support MATLAB
	  >	         variables with more than 2^32-1 elements. In the near future
	  >	         you will be required to update your code to utilize the
	  >	         new API. You can find more information about this at:
	  >	         http://www.mathworks.com/help/matlab/matlab_external/upgrading-mex-files-to-use-64-bit-api.html.

	  For this to work you need to have Xcode installed, which you can download from https://developer.apple.com/xcode/
	  
	  Tested for *Matlab R2017a* and *Xcode 9.3.1*

	* In linux, `mex` should be configured to use `gcc` for C language
	  compilation.  To verify that this is so, type at the *Matlab*
	  prompt:
	
	  ```matlab
	  mex -setup C
	  ```
	  You should see something like

	  > \>\> mex -setup C
	  >
	  > MEX configured to use 'gcc' for C language compilation.
	  > Warning: The MATLAB C and Fortran API has changed to support MATLAB
	  > 	 variables with more than 2^32-1 elements. You will be required
	  > 	 to update your code to utilize the new API.
	  > 	 You can find more information about this at:
	  > 	 https://www.mathworks.com/help/matlab/matlab_external/upgrading-mex-files-to-use-64-bit-api.html.

      *Matlab 2018a* requires gcc version 6.3, which you can install using the instructions at https://gist.github.com/application2000/73fd6f4bf1be6600a2cf9f56315a2d91
	  
	  However, more recent versions of gcc (e.g., 7.5.0) seem to work,
      in spite of the scary warning messages.
		  
	  In addition to gcc, cmex also uses `clang` to generate
      dynamics libraries which is much faster for large source
      files. E.g., in ubuntu, you can install `clang` using
	  
	  ```sh
	  sudo apt-get install clang
	  ```
	  
	* In Microsoft Windows 10, `mex` should be configured for
	  *Microsoft Visual C++ 2017 (C)* for C language compilation.  To
	  verify that this is so, type at the *Matlab* prompt:
	
	  ```matlab
	  mex -setup C
	  ```

	  You should see something like

	  > \>\> mex -setup C
	  >
	  > MEX configured to use 'Microsoft Visual C++ 2017 (C)' for C language compilation.
	  > Warning: The MATLAB C and Fortran API has changed to support MATLAB
	  > 	 variables with more than 2^32-1 elements. You will be required
	  > 	 to update your code to utilize the new API.
	  > 	 You can find more information about this at:
	  > 	 https://www.mathworks.com/help/matlab/matlab_external/upgrading-mex-files-to-use-64-bit-api.html.

      *Microsoft Visual Studio Community 2017* is a free IDE for
      students, open-source and individual developers, which can be
      downloaded from: https://www.visualstudio.com/vs/ 
	  
	  Within the *Microsoft Visual Studio Community 2017*, make sure
      that you install the *Desktop development with C++*. Look under
      the menu item *Tools/Get Tools and Features...* to confirm that
      you did.

	  Tested for *Matlab 2018a* and *Microsoft Visual Studio Community
	  2017*.  See
	  https://www.mathworks.com/matlabcentral/answers/335092-can-i-use-microsoft-visual-studio-2017-with-matlab
	  if you are using an older version of *Matlab*

2. Install [FunParTools](../../../funpartools) if you have not yet done so.

3. Download *CmexTools* using one of the following options:

	1. downloading it as a zip file from
		https://github.com/hespanha/cmextools/archive/master.zip
	   and unziping to an appropriate location

	2. cloning this repository with svn, e.g., using the shell command
	   ```sh
	   svn checkout https://github.com/hespanha/cmextools.git
	   ```
	  
	3. checking out this repository with Git, e.g., using the shell command
	   ```sh
       git clone https://github.com/hespanha/cmextools.git
       ```

	The latter two options are recommended because you can
    subsequently use `svn update` or `git pull` to upgrade *CmexTools*
    to the latest version. Under Windows 10, we use the
    following git client: https://git-scm.com/download/win

	After this, you should have at least the following folders:

	* `cmextools`
	* `cmextools/lib`
	* `cmextools/examples`


4. Enter `cmextools` and execute the following command at the *Matlab* prompt:

	```matlab
	install_cmextools
	```

	This will only succeed after if you have already installed [FunParTools](../../../funpartools)
    (steps 2 above).


5. To test if all is well, go to `cmextools/examples` and execute

	```matlab
	templateFromFile
	templateFromStruct
	templateFromStruct_dylib
	```
	
	For this to work, MATLAB must have write permissions to the folder
    `cmextools/examples`

## Usage

The *templates* used to specify the inputs an outputs to the
cmex-functions can take the form of a file or a *Matlab* structure. 

A typical template file is of the form:

```matlab
#ifdef createGateway
MEXfunction MEXmtimes
Cfunction   Cmtimes
method      mtimes
include     Cmtimes.c

inputs
	double X1 [m,k]
	uint32 S1 [1]
	double X2 [k,n]
	uint32 S2 [1]

outputs
	double Y [m,n]

preprocess(V1,V2)
 { ... Matlab code ...}

MEXfunction MEXplus
Cfunction   Cplus
method      plus
include     Cplus.c

inputs
	double X1 [m,n]
	uint32 S1 [1]
	double X2 [m,n]
	uint32 S2 [1]

outputs
	double Y [m,n]

preprocess(V1,V2)
 { ... Matlab code ...}

#endif

void Cmtimes(double *X1,uint32_t *S1,double *X2,uint32_t *S2,double *Y,
              mwSize m,mwSize k,mwSize n)
{ ... C code ... }

void Cplus(double *X1,uint32_t *S1,double *X2,uint32_t *S2,double *Y,
           mwSize mmwSize n)
{ ... C code ... }
```

The `MEXfunction` statement defines the name of the cmex-function
to be created. The same template may define several cmex-functions,
each definition starts with a `MEXfunction` statement.

The `inputs` section defines inputs to the cmex-function. Pointers to
the storage space of these variables will be available to the c-function.

The `outputs` section defines the outputs of the cmex-function,
these variable will be created and pointers to the storage space of
these variables will be available to the c-function.

Each entry of the `inputs` and `outputs` section is of the form
   `{matlab type} {variable name} [ {array size} ]`

The `{array size}` may contain specific numerical values, or
size-variable names. When the same size-variable appears multiple
times, the C gateway function will check for consistency.  The
size-variable will be available with the C gateway with type `mwSize`.
In the `inputs` section, the `{array size}` may contain the symbol `~`
for some of the dimensions, which means that the dimension will not be
checked by the gateway function.

In the `outputs` section, the `{array size}` may contain valid C
expressions involving size-variables.  If the `{array size}` of the
outputs section is equal to `~`, then the C gateway function will not
allocate storage space, which will have to be done by the C function.

The (optional) `preprocess` section defines *Matlab* code that
will be executed after the cmex function is created, but before
the gateway function is written to the file. The code will be evaluated
as a function with the given arguments as input parameters.
This *Matlab* code may be used to generate C code. When this code
is appended to the file `cmexfunction`, it will appear after
the `defines`, but before the gateway function.

The (optional) `include` section defines functions that
should be included (via `#include` directives) just before the gateway function.
More than one `include` section are possible, resulting in multiple
includes.

The `Cfunction` statement defines the name of the
C function that carries out the computations. This function will
be called from inside the gateway function with arguments determined
from the `inputs` section, including:
  1) pointers to the input variables (data portion)
  2) pointers to the output variables (data portion)
     (automatically allocated)
  3) variables with array sizes

The (optional) method statement defines the name of the method
that calls the cmex function, when the parameter `className` is non-empty,
in which case a *Matlab* class is created to call all the cmex-functions.

The initial `#ifdef` and the final `#endif` are optional. When present,
only the portion of the file between these commands is processed,
otherwise the whole file is processed.

Given such a template, the cmex-functions are created by the function

```matlab
	[...]=createGateway('parameter name 1',value,'parameter name 2',value,...);
```

Full documentation for this function can be found with

```matlab
	createGateway help
```

## Issues

* While most *Matlab* scripts are agnostic to the underlying operating
  systems (OSs), the use of `mex` functions depends heavily on the
  operating systems.

  Our goal is to build a toolbox that works across multiple OSs; at
  least under OSX, linux, and Microsft Windows. However, most of our
  testing was done under OSX so one should expect some bugs under the
  other OSs. Sorry about that.

* The next biggest issue is the relatively poor documentation.

## Contact Information

Joao Hespanha (hespanha@ece.ucsb.edu)

http://www.ece.ucsb.edu/~hespanha

University of California, Santa Barbara
	
## License Information

This file is part of Tencalc.

Copyright (C) 2010-21 The Regents of the University of California
(author: Dr. Joao Hespanha).  All rights reserved.

See LICENSE.txt
