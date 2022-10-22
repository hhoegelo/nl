#pragma once

#include "proxies/hwui/controls/ButtonMenu.h"

class SoundMenu : public ButtonMenu
{
 public:
  explicit SoundMenu(const Rect &r);

 protected:
  void bruteForce() override;
};

class SingleSoundEditMenuLegacy : public SoundMenu
{
 private:
  typedef SoundMenu super;

 public:
  explicit SingleSoundEditMenuLegacy(const Rect &rect);
  virtual void init();

 protected:
  Font::Justification getDefaultButtonJustification() const override;
};
