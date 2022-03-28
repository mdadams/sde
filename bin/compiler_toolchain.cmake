# message("Toolchain file")

# Note: I think that CMAKE_SYSTEM_NAME should only be set if crosscompiling.
#set(CMAKE_SYSTEM_NAME Linux)
#set(CMAKE_CROSSCOMPILING OFF CACHE BOOL "" FORCE)

################################################################################
#
################################################################################

set(__SDE_TEST_CASE 0)
set(__SDE_DEBUG 0)

#set(__SDE_TEST_CASE 1) # GCC Release
#set(__SDE_TEST_CASE 2) # GCC Trunk
#set(__SDE_TEST_CASE 3) # GCC Release
#set(__SDE_TEST_CASE 4) # Clang Trunk

if(__SDE_TEST_CASE GREATER_EQUAL 1)
	set(__SDE_TOP_DIR "/usr/mdadams/sde/sde-4.10.0")
	if(__SDE_TEST_CASE EQUAL 1)
		# GCC release
		set(__SDE_COMPILER_NAME gcc)
		set(__SDE_COMPILER_VNAME 11.2.0)
		set(__SDE_COMPILER_TRUNK FALSE)
	elseif(__SDE_TEST_CASE EQUAL 2)
		# GCC trunk
		set(__SDE_COMPILER_NAME gcc)
		set(__SDE_COMPILER_VNAME trunk)
		set(__SDE_COMPILER_TRUNK TRUE)
	elseif(__SDE_TEST_CASE EQUAL 3)
		# Clang release
		set(__SDE_COMPILER_NAME clang)
		set(__SDE_COMPILER_VNAME 14.0.0)
		set(__SDE_COMPILER_TRUNK FALSE)
	elseif(__SDE_TEST_CASE EQUAL 4)
		# Clang trunk
		set(__SDE_COMPILER_NAME clang)
		set(__SDE_COMPILER_VNAME trunk)
		set(__SDE_COMPILER_TRUNK TRUE)
	else()
		message(FATAL_ERROR "invalid test case")
	endif()
	set(__SDE_USE_LIBCPP FALSE)
	set(__SDE_USE_LIBFMT TRUE)
endif()

# Set the values of the following variables:
#     __SDE_TOP_DIR
#     __SDE_COMPILER_NAME
#     __SDE_COMPILER_VERSION
#     __SDE_COMPILER_TRUNK
#     __SDE_USE_LIBCPP
#     __SDE_USE_LIBFMT

# __SDE_INSERT_HERE

if(__SDE_DEBUG GREATER_EQUAL 2)
	message("__SDE_COMPILER_NAME: ${__SDE_COMPILER_NAME}")
	message("__SDE_COMPILER_VNAME: ${__SDE_COMPILER_VNAME}")
	message("__SDE_COMPILER_TRUNK: ${__SDE_COMPILER_TRUNK}")
	message("__SDE_USE_LIBCPP: ${__SDE_USE_LIBCPP}")
	message("__SDE_USE_LIBFMT: ${__SDE_USE_LIBFMT}")
endif()

################################################################################
#
################################################################################

set(__SDE_PKG_DIR "${__SDE_TOP_DIR}/packages")

if(__SDE_COMPILER_NAME STREQUAL "gcc")
	#set(__SDE_COMPILER_ID GNU)
	set(__SDE_COMPILER_CXX_BASE g++)
	set(__SDE_COMPILER_C_BASE gcc)
elseif(__SDE_COMPILER_NAME STREQUAL "clang")
	#set(__SDE_COMPILER_ID Clang)
	set(__SDE_COMPILER_CXX_BASE clang++)
	set(__SDE_COMPILER_C_BASE clang)
else()
	message(FATAL_ERROR "unexpected error")
endif()

# Note: This variable must end with a slash.
set(__SDE_COMPILER_PREFIX
  ${__SDE_PKG_DIR}/${__SDE_COMPILER_NAME}-${__SDE_COMPILER_VNAME}/bin/)

set(CMAKE_CXX_COMPILER "${__SDE_COMPILER_PREFIX}${__SDE_COMPILER_CXX_BASE}"
  CACHE FILEPATH "C++ Compiler")
set(CMAKE_C_COMPILER "${__SDE_COMPILER_PREFIX}${__SDE_COMPILER_C_BASE}"
  CACHE FILEPATH "C Compiler")
set(CMAKE_ASM_COMPILER "${__SDE_COMPILER_PREFIX}${__SDE_COMPILER_C_BASE}"
  CACHE FILEPATH "Assembler")
#set(CMAKE_CXX_LINKER_EXECUTABLE "${__SDE_COMPILER_PREFIX}${__SDE_COMPILER_CXX_BASE}" CACHE FILEPATH "Linker")

# Determine the compiler version.
execute_process(
  COMMAND "${CMAKE_CXX_COMPILER}" "--version"
  RESULT_VARIABLE __SDE_status
  OUTPUT_VARIABLE __SDE_buffer
)
if(NOT (__SDE_status EQUAL 0))
	message(FATAL_ERROR "Cannot determine compiler version.")
endif()
string(REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]" __SDE_COMPILER_VERSION
  "${__SDE_buffer}")
if(__SDE_DEBUG GREATER_EQUAL 1)
	message("__SDE_COMPILER_VERSION: ${__SDE_COMPILER_VERSION}")
endif()

################################################################################
#
################################################################################

# This is a hack so that the CMAKE_PREFIX_PATH environment variable
# does not need to be used to locate packages.
set(CMAKE_SYSTEM_PREFIX_PATH ${CMAKE_SYSTEM_PREFIX_PATH}
  "${__SDE_PKG_DIR}/boost"
  "${__SDE_PKG_DIR}/catch"
  "${__SDE_PKG_DIR}/gsl"
  "${__SDE_PKG_DIR}/CGAL"
  "${__SDE_PKG_DIR}/fmtlib"
  "${__SDE_PKG_DIR}/jasper"
)

# The CGAL_DIR variable is mentioned in the CGAL documentation:
#     https://doc.cgal.org/latest/Manual/installation.html
set(CGAL_DIR "${__SDE_PKG_DIR}/CGAL/lib64/cmake/CGAL")

# We should only need to specify include directories via the -I option
# if these directories are for libraries that would not be found by
# find_package.
# So, I think that this list should be empty.
set(__SDE_CPP_INC_DIRS
  #"${__SDE_PKG_DIR}/gsl/include"
)

# We should only need to specify library directories via the -L option
# if these directories are for libraries that would not be found by
# find_package.
# So, I think that this list should be empty (except maybe for compiler
# runtime libraries?).
set(__SDE_CPP_LIB_DIRS
  #"${__SDE_PKG_DIR}/gsl/lib64"
)

if(__SDE_USE_LIBCPP)
	# This determines the version of libc++ used if enabled.
	set(__SDE_LIBCPP_LIB_DIR "${__SDE_PKG_DIR}/clang/lib")
	set(__SDE_LIBCPP_INC_DIR "${__SDE_PKG_DIR}/clang/include")
endif()

if(__SDE_USE_LIBCPP)
	if(__SDE_COMPILER_NAME STREQUAL "clang")
		if(__SDE_COMPILER_VERSION VERSION_GREATER_EQUAL 15.0.0)
			message(WARNING "Disabling libfmt.")
			set(__SDE_USE_LIBFMT FALSE)
		endif()
	endif()
endif()

set(__SDE_RPATH
  ${__SDE_PKG_DIR}/boost/lib
  #${__SDE_PKG_DIR}/musl/lib
  ${__SDE_PKG_DIR}/fmtlib/lib64
  ${__SDE_PKG_DIR}/${__SDE_COMPILER_NAME}-${__SDE_COMPILER_VNAME}/lib64
  ${__SDE_PKG_DIR}/${__SDE_COMPILER_NAME}-${__SDE_COMPILER_VNAME}/lib
)
if(__SDE_USE_LIBCPP)
	set(__SDE_RPATH ${__SDE_RPATH} ${__SDE_LIBCPP_LIB_DIR})
endif()

################################################################################
# Set Compiler ID and Version
################################################################################

# CMake appears to detect the presence of Clang or GCC and set the
# following values (overriding them if previously set):
#     CMAKE_CXX_COMPILER_ID
#     CMAKE_CXX_COMPILER_VERSION

#set(CMAKE_CXX_COMPILER_ID ${__SDE_COMPILER_ID})
#set(CMAKE_CXX_COMPILER_VERSION ${__SDE_COMPILER_VERSION})

#set(CMAKE_C_COMPILER_ID ${__SDE_COMPILER_ID})
#set(CMAKE_C_COMPILER_VERSION ${__SDE_COMPILER_VERSION})

#set(CMAKE_ASM_COMPILER_ID ${__SDE_COMPILER_ID})
#set(CMAKE_ASM_COMPILER_VERSION ${__SDE_COMPILER_VERSION})


################################################################################
# Basic C++ Compiler Settings
################################################################################

# The following will be overridden by CMake since compiler ID is known?
#set(CMAKE_CXX_STANDARD_COMPUTED_DEFAULT 11)
#set(CMAKE_CXX11_STANDARD_COMPILE_OPTION  "-std=c++11")
#set(CMAKE_CXX11_EXTENSION_COMPILE_OPTION "-std=gnu++11")
#set(CMAKE_CXX17_STANDARD_COMPILE_OPTION  "-std=c++17")
#set(CMAKE_CXX17_EXTENSION_COMPILE_OPTION "-std=gnu++17")
#set(CMAKE_CXX20_STANDARD_COMPILE_OPTION  "-std=c++20")
#set(CMAKE_CXX20_EXTENSION_COMPILE_OPTION "-std=gnu++20")
#set(CMAKE_CXX23_STANDARD_COMPILE_OPTION  "-std=c++23")
#set(CMAKE_CXX23_EXTENSION_COMPILE_OPTION "-std=gnu++23")

# Set default C++ compiler flags.
if(__SDE_USE_LIBCPP)
	set(__SDE_CPPSTDLIB_FLAG "-stdlib=libc++")
else()
	# Note: GCC may complain about -stdlib=libstdc+ being an invalid option.
	if(${__SDE_COMPILER_NAME} STREQUAL "clang")
		set(__SDE_CPPSTDLIB_FLAG "-stdlib=libstdc++")
	endif()
endif()
set(CMAKE_CXX_FLAGS_INIT "${__SDE_CPPSTDLIB_FLAG}")
foreach(dir ${__SDE_CPP_INC_DIRS})
	set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -I${dir}")
endforeach()
set(CMAKE_CXX_FLAGS_DEBUG_INIT "-g3 -Og -Wall -pedantic -DDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "-O3 -Wall")
set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "-Os -Wall")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT  "-O2 -g -Wall")

################################################################################
# Basic C Compiler Settings
################################################################################

#set(CMAKE_C_STANDARD_COMPUTED_DEFAULT 11)
#set(CMAKE_C11_STANDARD_COMPILE_OPTION "-std=c11")
#set(CMAKE_C11_EXTENSION_COMPILE_OPTION "-std=gnu11")
#set(CMAKE_C17_STANDARD_COMPILE_OPTION "-std=c17")
#set(CMAKE_C17_EXTENSION_COMPILE_OPTION "-std=gnu17")
#set(CMAKE_C23_STANDARD_COMPILE_OPTION "-std=c23")
#set(CMAKE_C23_EXTENSION_COMPILE_OPTION "-std=gnu23")

# Set Default C Compiler Flags
set(CMAKE_C_FLAGS_DEBUG_INIT "-g3 -Og -Wall -pedantic -DDEBUG")
set(CMAKE_C_FLAGS_RELEASE_INIT "-O3 -Wall")
set(CMAKE_C_FLAGS_MINSIZEREL_INIT "-Os -Wall")
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT  "-O2 -g -Wall")

################################################################################
#
################################################################################

set(CMAKE_CXX_STANDARD_LIBRARIES "")
set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES "")
if(__SDE_USE_LIBFMT)
	set(CMAKE_CXX_STANDARD_LIBRARIES ${CMAKE_CXX_STANDARD_LIBRARIES}
	  "${__SDE_PKG_DIR}/fmtlib/lib64/libfmt.a")
	set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES
	  ${CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES}
	  "${__SDE_PKG_DIR}/fmtlib/include")
endif()

################################################################################
# Run-Time Path (Rpath) Settings
################################################################################

# use, i.e. don't skip the full RPATH for the build tree
set(CMAKE_SKIP_BUILD_RPATH FALSE)

# when building, don't use the install RPATH already
# (but later on when installing)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

set(CMAKE_BUILD_RPATH ${__SDE_RPATH})

set(CMAKE_INSTALL_RPATH
  ${CMAKE_BUILD_RPATH}
  "${CMAKE_INSTALL_PREFIX}/lib"
  "${CMAKE_INSTALL_PREFIX}/lib64"
)

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

################################################################################
#
################################################################################

# The following variables might also be useful:
# CMAKE_LIBRARY_PATH
# CMAKE_SYSTEM_LIBRARY_PATH
# CMAKE_SHARED_LINKER_FLAGS_INIT
# CMAKE_EXE_LINKER_FLAGS_INIT
# CMAKE_CXX_IMPLICIT_LINK_LIBRARIES
# CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES

################################################################################
#
################################################################################

#message("End of toolchain file")
