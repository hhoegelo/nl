#pragma once

#include <proxies/hwui/controls/ControlWithChildren.h>

class TextEditUsageMode;

class TextEditControl : public ControlWithChildren
{
 private:
  typedef ControlWithChildren super;

 public:
  TextEditControl(const Rect &pos, std::shared_ptr<TextEditUsageMode> textUsageMode);
};
