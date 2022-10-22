#include "BaseUnitEditMode.h"
#include "Application.h"
#include "device-settings/Settings.h"
#include "device-settings/ParameterEditModeRibbonBehaviour.h"
#include "proxies/playcontroller/PlaycontrollerProxy.h"
#include "groups/HardwareSourcesGroup.h"

void BaseUnitEditMode::toggleTouchBehaviour()
{
  auto p = Application::get().getPlaycontrollerProxy();

  if(p->getLastTouchedRibbonParameterID() == HardwareSourcesGroup::getUpperRibbonParameterID().getNumber())
    toggleParameterEditModeRibbonBehaviour();
  else
    super::toggleTouchBehaviour();
}

void BaseUnitEditMode::toggleParameterEditModeRibbonBehaviour()
{
  Application::get().getSettings()->getSetting<ParameterEditModeRibbonBehaviour>()->inc(1, true);
}
