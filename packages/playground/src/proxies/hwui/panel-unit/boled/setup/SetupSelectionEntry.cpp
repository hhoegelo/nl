#include <proxies/hwui/panel-unit/boled/setup/SetupSelectionEntry.h>
#include <proxies/hwui/FrameBuffer.h>

SetupSelectionEntry::SetupSelectionEntry(int i, const Rect &pos)
    : super(pos)
{
}

void SetupSelectionEntry::assign(Control *s, bool selectMode)
{
  m_selectMode = selectMode;
  setHighlight(s->isHighlight());
  addControl(s);
  s->setPosition(Rect(0, 0, getPosition().getWidth(), getPosition().getHeight()));
}

bool SetupSelectionEntry::redraw(FrameBuffer &fb)
{
  super::redraw(fb);

  if(isHighlight() && !m_selectMode)
  {
    fb.setColor(FrameBufferColors::C179);
    fb.drawRect(getPosition());
  }
  return true;
}

void SetupSelectionEntry::setBackgroundColor(FrameBuffer &fb) const
{
  if(isHighlight() && m_selectMode)
    fb.setColor(FrameBufferColors::C103);
  else
    super::setBackgroundColor(fb);
}
