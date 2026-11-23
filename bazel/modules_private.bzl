# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022 The Android Open Source Project

"""
This module contains a full list of kernel modules
 compiled by GKI.
"""

visibility("private")

_COMMON_GKI_MODULES_LIST = [
    # keep sorted
    "drivers/misc/open-dice.ko",
    "drivers/android/binder/rust_binder.ko",
    "drivers/block/zram/zram.ko",
    "drivers/bluetooth/btbcm.ko",
    "drivers/bluetooth/hci_uart.ko",
    "drivers/gnss/gnss.ko",
    "drivers/net/macsec.ko",
    "drivers/net/ppp/bsd_comp.ko",
    "drivers/net/ppp/ppp_deflate.ko",
    "drivers/net/ppp/ppp_generic.ko",
    "drivers/net/ppp/ppp_mppe.ko",
    "drivers/net/ppp/pppox.ko",
    "drivers/net/ppp/pptp.ko",
    "drivers/net/slip/slhc.ko",
    "drivers/pps/pps_core.ko",
    "drivers/ptp/ptp.ko",
    "drivers/usb/class/cdc-acm.ko",
    "drivers/usb/serial/ftdi_sio.ko",
    "drivers/usb/serial/usbserial.ko",
    "fs/netfs/netfs.ko",
    "kernel/kheaders.ko",
    "lib/crypto/libarc4.ko",
    "mm/zsmalloc.ko",
    "net/8021q/8021q.ko",
    "net/9p/9pnet.ko",
    "net/9p/9pnet_fd.ko",
    "net/bluetooth/bluetooth.ko",
    "net/bluetooth/hidp/hidp.ko",
    "net/bluetooth/rfcomm/rfcomm.ko",
    "net/l2tp/l2tp_core.ko",
    "net/l2tp/l2tp_ppp.ko",
    "net/nfc/nfc.ko",
    "net/rfkill/rfkill.ko",
]

_ARM_GKI_MODULES_LIST = [
    # keep sorted
]

_ARM64_GKI_MODULES_LIST = [
    # keep sorted
    "drivers/perf/dwc_pcie_pmu.ko",
]

_X86_GKI_MODULES_LIST = [
    # keep sorted
]

_X86_64_GKI_MODULES_LIST = [
    # keep sorted
]

def _apply(map_each, lst):
    if not map_each:
        return lst
    ret = []
    for elem in lst:
        mapped = map_each(elem)
        if mapped:
            ret.append(mapped)
    return ret

def _get_gki_modules_list_minus_select(arch, map_each):
    """ Provides the list of GKI modules, minus those in select() branches.

    Args:
        arch: One of [arm, arm64, i386, x86_64].
        map_each: A function that takes the module name as parameter, and returns
            the mapped value. If the module should be filtered out, the function
            should return None.

    Returns:
        The list of GKI modules for the given |arch|.
    """
    if not arch in ("arm64", "x86_64", "arm", "i386"):
        fail("{}: arch {} not supported. Use one of [arm, arm64, i386, x86_64]".format(
            str(native.package_relative_label(":x")).removesuffix(":x"),
            arch,
        ))

    if arch == "arm":
        return _apply(map_each, _COMMON_GKI_MODULES_LIST + _ARM_GKI_MODULES_LIST)

    if arch == "i386":
        return _apply(map_each, _COMMON_GKI_MODULES_LIST + _X86_GKI_MODULES_LIST)

    gki_modules_list = _apply(map_each, [] + _COMMON_GKI_MODULES_LIST)
    if arch == "arm64":
        gki_modules_list += _apply(map_each, _ARM64_GKI_MODULES_LIST)
    elif arch == "x86_64":
        gki_modules_list += _apply(map_each, _X86_64_GKI_MODULES_LIST)

    return gki_modules_list

# buildifier: disable=unnamed-macro
def get_gki_modules_list(arch = None, map_each = None):
    """Provides the list of GKI modules.

    Args:
        arch: One of [arm, arm64, i386, x86_64].
        map_each: A function that takes the module name as parameter, and
            returns the mapped value. If the module should be filtered out, the
            function should return None.

    Returns:
        An opaque expression that represents the list of GKI modules for the
        given |arch|. Do not treat the returned value as a list (e.g. use
        list comprehension); instead, use the |map_each| argument.
    """

    return select({
        "//conditions:default": _get_gki_modules_list_minus_select(arch, map_each),
    })

# buildifier: disable=unnamed-macro
def get_gki_modules_superset(arch = None, map_each = None):
    """Provides the list of superset of GKI modules.

    This includes all modules on each branch of the conditionals. For example,
    Rust modules may always be included regardless of the value of
    --kasan_sw_tags.

    Args:
        arch: One of [arm, arm64, i386, x86_64].
        map_each: A function that takes the module name as parameter, and
            returns the mapped value. If the module should be filtered out, the
            function should return None.

    Returns:
        A list that contains the superset of GKI modules for the given |arch|.
    """
    return _get_gki_modules_list_minus_select(arch, map_each)

_KUNIT_FRAMEWORK_MODULES = [
]

# Modules defined by tools/testing/kunit/configs/android/kunit_defconfig
_KUNIT_COMMON_MODULES_LIST = [
    # keep sorted
    # "mm/kfence/kfence_test.ko",
]

# Modules defined by tools/testing/kunit/configs/android/kunit_clk_defconfig
_KUNIT_CLK_MODULES_LIST = [
]

def _get_kunit_modules_list_minus_select(arch, map_each):
    """ Provides the list of KUnit modules, minus those in select() branches.

    Args:
        arch: One of [arm, arm64, i386, x86_64].
        map_each: A function that takes the module name as parameter, and returns
            the mapped value. If the module should be filtered out, the function
            should return None.
    Returns:
        The list of KUnit modules for the given |arch|.
    """
    if not arch in ("arm64", "x86_64", "arm", "i386"):
        fail("{}: arch {} not supported. Use one of [arm, arm64, i386, x86_64]".format(
            str(native.package_relative_label(":x")).removesuffix(":x"),
            arch,
        ))

    kunit_modules_list = _KUNIT_FRAMEWORK_MODULES + _KUNIT_COMMON_MODULES_LIST
    if arch == "arm":
        kunit_modules_list += _KUNIT_CLK_MODULES_LIST
    elif arch == "arm64":
        kunit_modules_list += _KUNIT_CLK_MODULES_LIST
    elif arch == "i386":
        kunit_modules_list.append("drivers/clk/clk_kunit_helpers.ko")
    elif arch == "x86_64":
        kunit_modules_list.append("drivers/clk/clk_kunit_helpers.ko")

    return _apply(map_each, kunit_modules_list)

# buildifier: disable=unnamed-macro
def get_kunit_modules_list(arch = None, map_each = None):
    """ Provides the list of KUnit modules.

    Args:
        arch: One of [arm, arm64, i386, x86_64].
        map_each: A function that takes the module name as parameter, and returns
            the mapped value. If the module should be filtered out, the function
            should return None.

    Returns:
        An opaque expression that represents the list of Kunit modules for the
        given |arch|. Do not treat the returned value as a list (e.g. use
        list comprehension); instead, use the |map_each| argument.
    """

    return select({
        "//conditions:default": _get_kunit_modules_list_minus_select(arch, map_each),
    })

# buildifier: disable=unnamed-macro
def get_kunit_modules_superset(arch = None, map_each = None):
    """Provides the list of superset of KUnit modules.

    This includes all modules on each branch of the conditionals.

    Args:
        arch: One of [arm, arm64, i386, x86_64].
        map_each: A function that takes the module name as parameter, and
            returns the mapped value. If the module should be filtered out, the
            function should return None.

    Returns:
        A list of superset of KUnit modules for the given |arch|.
    """
    return _get_kunit_modules_list_minus_select(arch, map_each)

_COMMON_UNPROTECTED_MODULES_LIST = [
    "drivers/block/zram/zram.ko",
    "drivers/hwtracing/coresight/coresight.ko",
    "drivers/hwtracing/coresight/coresight-etm4x.ko",
    "drivers/hwtracing/coresight/coresight-funnel.ko",
    "drivers/hwtracing/coresight/coresight-replicator.ko",
    "drivers/hwtracing/coresight/coresight-trbe.ko",
    "mm/zsmalloc.ko",
]

# buildifier: disable=unused-variable
def get_gki_unprotected_modules_list(arch = None):
    return select({
        "//conditions:default": _COMMON_UNPROTECTED_MODULES_LIST,
    })

# buildifier: disable=unnamed-macro
def get_gki_kunit_modules(arch, page_size = None):
    """Returns the list of labels pointing to the GKI modules for KUnit.

    Args:
        arch: one of arm64, x86_64
        page_size: if arch is arm64, the page_size ("4k" or "16k")

    Returns:
        The list of labels pointing to the GKI modules for KUnit.
    """
    if arch == "arm64":
        if page_size == "16k":
            return get_kunit_modules_list(arch, map_each = lambda e: ":kernel_aarch64_16k/" + e)
        if page_size == "4k":
            return get_kunit_modules_list(arch, map_each = lambda e: ":kernel_aarch64/" + e)
    if arch == "x86_64":
        return get_kunit_modules_list(arch, map_each = lambda e: ":kernel_x86_64/" + e)

    fail("{}: arch {} (page_size {}) not supported. Use one of [arm64, x86_64]".format(
        str(native.package_relative_label(":x")).removesuffix(":x"),
        arch,
        page_size,
    ))
