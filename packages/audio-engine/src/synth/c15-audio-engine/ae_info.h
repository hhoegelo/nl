#pragma once

/******************************************************************************/
/** @file       ae_info.h
    @date
    @version    1.7-0
    @author     M. Seeber
    @brief      common audio engine structures used by sections and their
components
    @todo
*******************************************************************************/

#include "ae_potential_improvements.h"
#include "parameter_declarations.h"
#include "signal_storage_dual.h"

using GlobalSignals = MonoSignalStorage<C15::Signals::Global_Signals>;
using PolySignals = PolySignalStorage<C15::Signals::Truepoly_Signals,
                                      C15::Signals::Quasipoly_Signals>;
using MonoSignals = MonoSignalStorage<C15::Signals::Mono_Signals>;
