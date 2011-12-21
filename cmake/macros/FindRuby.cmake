# - Find Ruby
# This module finds if Ruby is installed and determines where the include files
# and libraries are. Ruby 1.8 and 1.9 are supported.
#
# The minimum required version of Ruby can be specified using the
# standard syntax, e.g. FIND_PACKAGE(Ruby 1.8)
#
# It also determines what the name of the library is. This
# code sets the following variables:
#
#  RUBY_EXECUTABLE   = full path to the ruby binary
#  RUBY_INCLUDE_DIRS = include dirs to be used when using the ruby library
#  RUBY_LIBRARY      = full path to the ruby library
#  RUBY_VERSION      = the version of ruby which was found, e.g. "1.8.7"
#  RUBY_FOUND        = set to true if ruby ws found successfully
#
#  RUBY_INCLUDE_PATH = same as RUBY_INCLUDE_DIRS, only provided for compatibility reasons, don't use it

#=============================================================================
# Copyright 2004-2009 Kitware, Inc.
# Copyright 2008-2009 Alexander Neundorf <neundorf@kde.org>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

#   RUBY_ARCHDIR=`$RUBY -r rbconfig -e 'printf("%s",Config::CONFIG@<:@"archdir"@:>@)'`
#   RUBY_SITEARCHDIR=`$RUBY -r rbconfig -e 'printf("%s",Config::CONFIG@<:@"sitearchdir"@:>@)'`
#   RUBY_SITEDIR=`$RUBY -r rbconfig -e 'printf("%s",Config::CONFIG@<:@"sitelibdir"@:>@)'`
#   RUBY_LIBDIR=`$RUBY -r rbconfig -e 'printf("%s",Config::CONFIG@<:@"libdir"@:>@)'`
#   RUBY_LIBRUBYARG=`$RUBY -r rbconfig -e 'printf("%s",Config::CONFIG@<:@"LIBRUBYARG_SHARED"@:>@)'`

# uncomment the following line to get debug output for this file
SET(_RUBY_DEBUG_OUTPUT TRUE)

# Determine the list of possible names of the ruby executable depending
# on which version of ruby is required
SET(_RUBY_POSSIBLE_EXECUTABLE_NAMES ruby)

# if 1.9 is required, don't look for ruby18 and ruby1.8, default to version 1.8
IF(Ruby_FIND_VERSION_MAJOR  AND  Ruby_FIND_VERSION_MINOR)
   SET(Ruby_FIND_VERSION_SHORT_NODOT "${Ruby_FIND_VERSION_MAJOR}${RUBY_FIND_VERSION_MINOR}")
ELSE(Ruby_FIND_VERSION_MAJOR  AND  Ruby_FIND_VERSION_MINOR)
   SET(Ruby_FIND_VERSION_SHORT_NODOT "18")
ENDIF(Ruby_FIND_VERSION_MAJOR  AND  Ruby_FIND_VERSION_MINOR)

SET(_RUBY_POSSIBLE_EXECUTABLE_NAMES ${_RUBY_POSSIBLE_EXECUTABLE_NAMES} ruby1.9 ruby19)

# if we want a version below 1.9, also look for ruby 1.8
IF("${Ruby_FIND_VERSION_SHORT_NODOT}" VERSION_LESS "19")
   SET(_RUBY_POSSIBLE_EXECUTABLE_NAMES ${_RUBY_POSSIBLE_EXECUTABLE_NAMES} ruby1.8 ruby18)
ENDIF("${Ruby_FIND_VERSION_SHORT_NODOT}" VERSION_LESS "19")

FIND_PROGRAM(RUBY_EXECUTABLE NAMES ${_RUBY_POSSIBLE_EXECUTABLE_NAMES})


IF(RUBY_EXECUTABLE  AND NOT  RUBY_MAJOR_VERSION)
  # query the ruby version
   EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "print RbConfig::CONFIG['MAJOR']"
      OUTPUT_VARIABLE RUBY_VERSION_MAJOR)

   EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "print RbConfig::CONFIG['MINOR']"
      OUTPUT_VARIABLE RUBY_VERSION_MINOR)

   EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "print RbConfig::CONFIG['TEENY']"
      OUTPUT_VARIABLE RUBY_VERSION_PATCH)

   # query the different directories
   EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "print RbConfig::CONFIG['archdir']"
      OUTPUT_VARIABLE RUBY_ARCH_DIR)

   EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "print RbConfig::CONFIG['arch']"
      OUTPUT_VARIABLE RUBY_ARCH)

   EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "print RbConfig::CONFIG['rubyhdrdir']"
      OUTPUT_VARIABLE RUBY_HDR_DIR)

   EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "print RbConfig::CONFIG['libdir']"
      OUTPUT_VARIABLE RUBY_POSSIBLE_LIB_DIR)

   EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "print RbConfig::CONFIG['rubylibdir']"
      OUTPUT_VARIABLE RUBY_RUBY_LIB_DIR)

   # site_ruby
   EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "print RbConfig::CONFIG['sitearchdir']"
      OUTPUT_VARIABLE RUBY_SITEARCH_DIR)

   EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "print RbConfig::CONFIG['sitelibdir']"
      OUTPUT_VARIABLE RUBY_SITELIB_DIR)

   # vendor_ruby available ?
   EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r vendor-specific -e "print 'true'"
      OUTPUT_VARIABLE RUBY_HAS_VENDOR_RUBY  ERROR_QUIET)

   IF(RUBY_HAS_VENDOR_RUBY)
      EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "print RbConfig::CONFIG['vendorlibdir']"
         OUTPUT_VARIABLE RUBY_VENDORLIB_DIR)

      EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rbconfig -e "print RbConfig::CONFIG['vendorarchdir']"
         OUTPUT_VARIABLE RUBY_VENDORARCH_DIR)
   ENDIF(RUBY_HAS_VENDOR_RUBY)

   # save the results in the cache so we don't have to run ruby the next time again
   SET(RUBY_VERSION_MAJOR    ${RUBY_VERSION_MAJOR}    CACHE PATH "The Ruby major version" FORCE)
   SET(RUBY_VERSION_MINOR    ${RUBY_VERSION_MINOR}    CACHE PATH "The Ruby minor version" FORCE)
   SET(RUBY_VERSION_PATCH    ${RUBY_VERSION_PATCH}    CACHE PATH "The Ruby patch version" FORCE)
   SET(RUBY_ARCH_DIR         ${RUBY_ARCH_DIR}         CACHE PATH "The Ruby arch dir" FORCE)
   SET(RUBY_HDR_DIR          ${RUBY_HDR_DIR}          CACHE PATH "The Ruby header dir (1.9)" FORCE)
   SET(RUBY_POSSIBLE_LIB_DIR ${RUBY_POSSIBLE_LIB_DIR} CACHE PATH "The Ruby lib dir" FORCE)
   SET(RUBY_RUBY_LIB_DIR     ${RUBY_RUBY_LIB_DIR}     CACHE PATH "The Ruby ruby-lib dir" FORCE)
   SET(RUBY_SITEARCH_DIR     ${RUBY_SITEARCH_DIR}     CACHE PATH "The Ruby site arch dir" FORCE)
   SET(RUBY_SITELIB_DIR      ${RUBY_SITELIB_DIR}      CACHE PATH "The Ruby site lib dir" FORCE)
   SET(RUBY_HAS_VENDOR_RUBY  ${RUBY_HAS_VENDOR_RUBY}  CACHE BOOL "Vendor Ruby is available" FORCE)
   SET(RUBY_VENDORARCH_DIR   ${RUBY_VENDORARCH_DIR}   CACHE PATH "The Ruby vendor arch dir" FORCE)
   SET(RUBY_VENDORLIB_DIR    ${RUBY_VENDORLIB_DIR}    CACHE PATH "The Ruby vendor lib dir" FORCE)

   MARK_AS_ADVANCED(
     RUBY_ARCH_DIR
     RUBY_ARCH
     RUBY_HDR_DIR
     RUBY_POSSIBLE_LIB_DIR
     RUBY_RUBY_LIB_DIR
     RUBY_SITEARCH_DIR
     RUBY_SITELIB_DIR
     RUBY_HAS_VENDOR_RUBY
     RUBY_VENDORARCH_DIR
     RUBY_VENDORLIB_DIR
     RUBY_VERSION_MAJOR
     RUBY_VERSION_MINOR
     RUBY_VERSION_PATCH
     )
ENDIF(RUBY_EXECUTABLE  AND NOT  RUBY_MAJOR_VERSION)

# In case RUBY_EXECUTABLE could not be executed (e.g. cross compiling) 
# try to detect which version we found. This is not too good.
IF(NOT RUBY_VERSION_MAJOR)
   # by default assume 1.8.0
   SET(RUBY_VERSION_MAJOR 1)
   SET(RUBY_VERSION_MINOR 8)
   SET(RUBY_VERSION_PATCH 0)
   # check whether we found 1.9.x
   IF(${RUBY_EXECUTABLE} MATCHES "ruby1.?9"  OR  RUBY_HDR_DIR)
      SET(RUBY_VERSION_MAJOR 1)
      SET(RUBY_VERSION_MINOR 9)
   ENDIF(${RUBY_EXECUTABLE} MATCHES "ruby1.?9"  OR  RUBY_HDR_DIR)
ENDIF(NOT RUBY_VERSION_MAJOR)


SET(RUBY_VERSION "${RUBY_VERSION_MAJOR}.${RUBY_VERSION_MINOR}.${RUBY_VERSION_PATCH}")
SET(_RUBY_VERSION_SHORT "${RUBY_VERSION_MAJOR}.${RUBY_VERSION_MINOR}")
SET(_RUBY_VERSION_SHORT_NODOT "${RUBY_VERSION_MAJOR}${RUBY_VERSION_MINOR}")
SET(_RUBY_NODOT_VERSION "${RUBY_VERSION_MAJOR}${RUBY_VERSION_MINOR}${RUBY_VERSION_PATCH}")

FIND_PATH(RUBY_INCLUDE_DIR
   NAMES ruby.h
   HINTS
   ${RUBY_HDR_DIR}
   ${RUBY_ARCH_DIR}
   /usr/lib/ruby/${_RUBY_VERSION_SHORT}/i586-linux-gnu/ )

SET(RUBY_INCLUDE_DIRS ${RUBY_INCLUDE_DIR} )

# if ruby > 1.8 is required or if ruby > 1.8 was found, search for the config.h dir
IF( ${Ruby_FIND_VERSION_SHORT_NODOT} GREATER 18  OR  ${_RUBY_VERSION_SHORT_NODOT} GREATER 18  OR  RUBY_HDR_DIR)
   FIND_PATH(RUBY_CONFIG_INCLUDE_DIR
     NAMES ruby/config.h  config.h
     HINTS 
     ${RUBY_HDR_DIR}/${RUBY_ARCH}
     ${RUBY_ARCH_DIR} 
     )

   SET(RUBY_INCLUDE_DIRS ${RUBY_INCLUDE_DIRS} ${RUBY_CONFIG_INCLUDE_DIR} )
ENDIF( ${Ruby_FIND_VERSION_SHORT_NODOT} GREATER 18  OR  ${_RUBY_VERSION_SHORT_NODOT} GREATER 18  OR  RUBY_HDR_DIR)


# Determine the list of possible names for the ruby library
SET(_RUBY_POSSIBLE_LIB_NAMES ruby ruby-static ruby${_RUBY_VERSION_SHORT})

IF(WIN32)
   SET( _RUBY_MSVC_RUNTIME "" )
   IF( MSVC60 )
     SET( _RUBY_MSVC_RUNTIME "60" )
   ENDIF( MSVC60 )
   IF( MSVC70 )
     SET( _RUBY_MSVC_RUNTIME "70" )
   ENDIF( MSVC70 )
   IF( MSVC71 )
     SET( _RUBY_MSVC_RUNTIME "71" )
   ENDIF( MSVC71 )
   IF( MSVC80 )
     SET( _RUBY_MSVC_RUNTIME "80" )
   ENDIF( MSVC80 )
   IF( MSVC90 )
     SET( _RUBY_MSVC_RUNTIME "90" )
   ENDIF( MSVC90 )

   LIST(APPEND _RUBY_POSSIBLE_LIB_NAMES
               "libmsvcr${_RUBY_MSVC_RUNTIME}-ruby${_RUBY_NODOT_VERSION}-dll"
               "libmsvcrt-ruby${_RUBY_NODOT_VERSION}-dll")
   
   # little hack to let it find the ruby .a file
   set(CMAKE_FIND_LIBRARY_SUFFIXES "${CMAKE_FIND_LIBRARY_SUFFIXES};.a;.so")
ENDIF(WIN32)

FIND_LIBRARY(RUBY_LIBRARY NAMES ${_RUBY_POSSIBLE_LIB_NAMES} HINTS ${RUBY_POSSIBLE_LIB_DIR} )

INCLUDE(FindPackageHandleStandardArgs)


SET(_RUBY_REQUIRED_VARS RUBY_EXECUTABLE RUBY_INCLUDE_DIR RUBY_LIBRARY)
IF(_RUBY_VERSION_SHORT_NODOT GREATER 18)
   LIST(APPEND _RUBY_REQUIRED_VARS RUBY_CONFIG_INCLUDE_DIR)
ENDIF(_RUBY_VERSION_SHORT_NODOT GREATER 18)

IF (UNIX OR MSYS)
    # Execute ln in *nix and MSYS to ensure the include of the ruby/config.h file
    # ln -s ${RUBY_ARCH_DIR}/ruby/config.h ${RUBY_HDR_DIR}/ruby/config.h
    EXECUTE_PROCESS(COMMAND ln -s ${RUBY_ARCH_DIR}/ruby/config.h ${RUBY_HDR_DIR}/ruby/config.h)
ENDIF()

SET(RICE_LIBRARY "")
SET(RICE_INCLUDE_DIR "")

IF (RUBY_EXECUTABLE)
    EXECUTE_PROCESS(COMMAND ${RUBY_EXECUTABLE} -r rubygems -e "rice_ = Gem::Specification.find_by_name 'rice'; ric_ = rice_.name + '-' + rice_.version.to_s; print ric_"
      OUTPUT_VARIABLE RICE_VERSION)
    
    EXECUTE_PROCESS(COMMAND gem environment gemdir
      OUTPUT_VARIABLE GEM_DIR)
    
    STRING(STRIP ${GEM_DIR} GEM_DIR)
      
    SET(RICE_DIR ${GEM_DIR}/gems/${RICE_VERSION})
    SET(RICE_INCLUDE_DIR ${RICE_DIR}/ruby/lib/include)
    SET(RICE_LIBRARY ${RICE_DIR}/ruby/lib/lib/librice.a)
    
    IF(RICE_VERSION AND GEM_DIR)
        MESSAGE(STATUS "Found rice: " ${RICE_VERSION})
        MESSAGE(STATUS "Rice include directory: " ${RICE_INCLUDE_DIR})
        MESSAGE(STATUS "Rice library: " ${RICE_LIBRARY})
    ENDIF()
ENDIF()

IF(_RUBY_DEBUG_OUTPUT)
   MESSAGE(STATUS "--------FindRuby.cmake debug------------")
   MESSAGE(STATUS "_RUBY_POSSIBLE_EXECUTABLE_NAMES: ${_RUBY_POSSIBLE_EXECUTABLE_NAMES}")
   MESSAGE(STATUS "_RUBY_POSSIBLE_LIB_NAMES: ${_RUBY_POSSIBLE_LIB_NAMES}")
   MESSAGE(STATUS "RUBY_ARCH_DIR: ${RUBY_ARCH_DIR}")
   MESSAGE(STATUS "RUBY_HDR_DIR: ${RUBY_HDR_DIR}")
   MESSAGE(STATUS "RUBY_POSSIBLE_LIB_DIR: ${RUBY_POSSIBLE_LIB_DIR}")
   MESSAGE(STATUS "Found RUBY_VERSION: \"${RUBY_VERSION}\" , short: \"${_RUBY_VERSION_SHORT}\", nodot: \"${_RUBY_VERSION_SHORT_NODOT}\"")
   MESSAGE(STATUS "_RUBY_REQUIRED_VARS: ${_RUBY_REQUIRED_VARS}")
   MESSAGE(STATUS "Ruby Library Path: ${RUBY_LIBRARY}")
   MESSAGE(STATUS "--------------------")
ENDIF(_RUBY_DEBUG_OUTPUT)

LIST(APPEND _RUBY_REQUIRED_VARS RICE_LIBRARY RICE_INCLUDE_DIR)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(Ruby  REQUIRED_VARS  ${_RUBY_REQUIRED_VARS} )

MARK_AS_ADVANCED(
  RUBY_EXECUTABLE
  RUBY_LIBRARY
  RUBY_INCLUDE_DIR
  RUBY_CONFIG_INCLUDE_DIR
  )
  
# Set some variables for compatibility with previous version of this file
SET(RUBY_POSSIBLE_LIB_PATH ${RUBY_POSSIBLE_LIB_DIR})
SET(RUBY_RUBY_LIB_PATH ${RUBY_RUBY_LIB_DIR})
SET(RUBY_INCLUDE_PATH ${RUBY_INCLUDE_DIRS})