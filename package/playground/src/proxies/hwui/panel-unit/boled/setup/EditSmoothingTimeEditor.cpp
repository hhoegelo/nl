#include <Application.h>
#include <device-settings/Settings.h>
#include <device-settings/EditSmoothingTime.h>
#include <proxies/hwui/panel-unit/boled/setup/EditSmoothingTimeEditor.h>
#include <proxies/hwui/HWUI.h>
#include <proxies/hwui/FrameBuffer.h>
#include "SetupLabel.h"

EditSmoothingTimeEditor::EditSmoothingTimeEditor()
    : super(Rect(0, 0, 0, 0))
{
  Application::get().getSettings()->getSetting<EditSmoothingTime>()->onChange(
      mem_fun(this, &EditSmoothingTimeEditor::onSettingChanged));
}

EditSmoothingTimeEditor::~EditSmoothingTimeEditor()
{
}

bool EditSmoothingTimeEditor::redraw(FrameBuffer &fb)
{
  super::redraw(fb);

  fb.setColor(FrameBufferColors::C179);
  fb.drawRect(getPosition());
  return true;
}

void EditSmoothingTimeEditor::setBackgroundColor(FrameBuffer &fb) const
{
  fb.setColor(FrameBufferColors::C103);
}

Font::Justification EditSmoothingTimeEditor::getJustification() const
{
  return Font::Justification::Left;
}

void EditSmoothingTimeEditor::setFontColor(FrameBuffer &fb) const
{
  fb.setColor(FrameBufferColors::C255);
}

void EditSmoothingTimeEditor::onSettingChanged(const Setting *s)
{
  if(auto p = dynamic_cast<const EditSmoothingTime *>(s))
    setText(p->getDisplayString());
}

bool EditSmoothingTimeEditor::onButton(Buttons i, bool down, ButtonModifiers modifiers)
{
  return false;
}

bool EditSmoothingTimeEditor::onRotary(int inc, ButtonModifiers modifiers)
{
  Application::get().getSettings()->getSetting<EditSmoothingTime>()->incDec(inc, modifiers);
  return true;
}
