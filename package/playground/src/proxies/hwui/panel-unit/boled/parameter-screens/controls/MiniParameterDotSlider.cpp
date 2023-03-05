#include <proxies/hwui/panel-unit/boled/parameter-screens/controls/MiniParameterDotSlider.h>
#include <proxies/hwui/FrameBuffer.h>

MiniParameterDotSlider::MiniParameterDotSlider(Parameter *param, const Rect &rect)
    : super(param, rect)
{
}

bool MiniParameterDotSlider::hasBorder() const
{
  return false;
}

bool MiniParameterDotSlider::redraw(FrameBuffer &fb)
{
  Rect r = getPosition();

  if(isHighlight())
    fb.setColor(FrameBufferColors::C128);
  else
    fb.setColor(FrameBufferColors::C103);

  fb.fillRect(r.getX(), r.getTop(), r.getWidth(), r.getHeight());
  super::redraw(fb);

  return true;
}
