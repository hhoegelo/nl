#include "ParameterMessageFactory.h"

namespace ParameterMessageFactory
{

  namespace detail
  {
    nltools::msg::UnmodulateableParameterChangedMessage createMessage(const Parameter *param)
    {
      return nltools::msg::UnmodulateableParameterChangedMessage { param->getID().getNumber(),
                                                                   param->getControlPositionValue(),
                                                                   param->getID().getVoiceGroup() };
    }

    nltools::msg::ModulateableParameterChangedMessage createMessage(const ModulateableParameter *param)
    {
      auto range = param->getModulationRange(false);
      auto msg = nltools::msg::ModulateableParameterChangedMessage { param->getID().getNumber(),
                                                                 param->getControlPositionValue(),
                                                                 param->getModulationSource(),
                                                                 param->getModulationAmount(),
                                                                 range.second,
                                                                 range.first,
                                                                 param->getID().getVoiceGroup() };
      return msg;
    }

    nltools::msg::MacroControlChangedMessage createMessage(const MacroControlParameter *param)
    {
      return nltools::msg::MacroControlChangedMessage { param->getID().getNumber(), param->getControlPositionValue() };
    }

    nltools::msg::HWAmountChangedMessage createMessage(const ModulationRoutingParameter *param)
    {
      return nltools::msg::HWAmountChangedMessage { param->getID().getNumber(), param->getControlPositionValue() };
    }

    nltools::msg::HWSourceChangedMessage createMessage(const PhysicalControlParameter *param)
    {
      return nltools::msg::HWSourceChangedMessage { param->getID().getNumber(), param->getControlPositionValue(),
                                                    param->getReturnMode(), param->isLocalEnabled() };
    }

    nltools::msg::HWSourceSendChangedMessage createMessage(const HardwareSourceSendParameter* param)
    {
      return nltools::msg::HWSourceSendChangedMessage {
        param->getID().getNumber(),
        param->getSiblingParameter()->getID().getNumber(),
        param->getControlPositionValue(),
        param->getReturnMode(), param->isLocalEnabled()
      };
    }
  }
}
