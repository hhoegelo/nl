#include "DottedLine.h"
#include <proxies/hwui/FrameBuffer.h>

DottedLine::DottedLine(const Rect &rect)
    : super(rect)
{
}

bool DottedLine::redraw(FrameBuffer &fb)
{
  if(isHighlight())
    fb.setColor(FrameBufferColors::C128);
  else
    fb.setColor(FrameBufferColors::C204);

  Rect r = getPosition();
  Point c = r.getCenter();

  for(int i = r.getLeft(); i <= r.getRight(); i += 2)
    fb.setPixel(i, r.getY());

  return true;
}
