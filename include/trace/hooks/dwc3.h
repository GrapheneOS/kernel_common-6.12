/* SPDX-License-Identifier: GPL-2.0 */
#undef TRACE_SYSTEM
#define TRACE_SYSTEM dwc3

#undef TRACE_INCLUDE_PATH
#define TRACE_INCLUDE_PATH trace/hooks

#if !defined(_TRACE_HOOK_DWC3_H) || defined(TRACE_HEADER_MULTI_READ)
#define _TRACE_HOOK_DWC3_H

#include <trace/hooks/vendor_hooks.h>

struct dwc3;
struct usb_hcd;

#ifndef SOFT_RESET_PHASE
#define SOFT_RESET_PHASE
enum soft_reset_phase {
	PRE_SOFT_RESET,
	SOFT_RESET_INITIATED,
	POST_SOFT_RESET
};
#endif /* SOFT_RESET_PHASE */

/*
 * Following tracepoints are not exported in tracefs and provide a
 * mechanism for vendor modules to hook and extend functionality
 */

DECLARE_HOOK(android_vh_dwc3_core_soft_reset,
	     TP_PROTO(struct dwc3 *dwc, enum soft_reset_phase phase),
	     TP_ARGS(dwc, phase));

DECLARE_HOOK(android_vh_dwc3_xhci_soft_reset,
	     TP_PROTO(struct usb_hcd *hcd, enum soft_reset_phase phase),
	     TP_ARGS(hcd, phase));

#endif /*  _TRACE_HOOK_DWC3_H */
/*  This part must be outside protection */
#include <trace/define_trace.h>
