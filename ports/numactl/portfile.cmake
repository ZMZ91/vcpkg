include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO numactl/numactl
    REF v2.0.12
    SHA512 3814efd924d1c9152a30f6ae5b665afc20648226cd475d72b933c0ec4f30249af4e25110de17f144734b787ed765644dca09a657219806ab5c9c550abd45bf8e
    HEAD_REF master
)

if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(FATAL_ERROR "Package only supports linux platform.")
endif()

message(
"numactl currently requires the following libraries from the system package manager:
    autoconf libtool
These can be installed on Ubuntu systems via sudo apt install autoconf libtool"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(SHARED_STATIC --enable-static --disable-shared)
else()
    set(SHARED_STATIC --disable-static --enable-shared)
endif()

set(OPTIONS ${SHARED_STATIC})
vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/autogen.sh
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME setup-${TARGET_TRIPLET}
)

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
set(CFLAGS "${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_DEBUG} -fPIC -O0 -g -I${SOURCE_PATH}/include")
set(LDFLAGS "${VCPKG_LINKER_FLAGS}")
vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/configure --prefix=${CURRENT_PACKAGES_DIR}/debug ${OPTIONS} --with-sysroot=${CURRENT_INSTALLED_DIR}/debug
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
    LOGNAME configure-${TARGET_TRIPLET}-dbg
)
message(STATUS "Building ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND make -j install "CFLAGS=${CFLAGS}" "LDFLAGS=${LDFLAGS}"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
    LOGNAME install-${TARGET_TRIPLET}-dbg
)

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
set(CFLAGS "${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_RELEASE} -fPIC -O3 -I${SOURCE_PATH}/include")
set(LDFLAGS "${VCPKG_LINKER_FLAGS}")
vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/configure --prefix=${CURRENT_PACKAGES_DIR} ${OPTIONS} --with-sysroot=${CURRENT_INSTALLED_DIR}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME configure-${TARGET_TRIPLET}-rel
)
message(STATUS "Building ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND make -j install "CFLAGS=${CFLAGS}" "LDFLAGS=${LDFLAGS}"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME install-${TARGET_TRIPLET}-rel
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
configure_file(${SOURCE_PATH}/README.md ${CURRENT_PACKAGES_DIR}/share/numactl/copyright COPYONLY)
