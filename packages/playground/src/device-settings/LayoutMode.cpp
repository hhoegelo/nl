
#include "LayoutMode.h"

LayoutMode::LayoutMode(Settings* parent)
    : EnumSetting<LayoutVersionMode>(*parent, LayoutVersionMode::Mixed)
{
}

const std::vector<Glib::ustring>& LayoutMode::enumToString() const
{
  static std::vector<Glib::ustring> s_modeNames = { "Old", "Mixed", "New" };
  return s_modeNames;
}

const std::vector<Glib::ustring>& LayoutMode::enumToDisplayString() const
{
  static std::vector<Glib::ustring> s_displayStrings = { "Old", "Mixed favor New", "New" };
  return s_displayStrings;
}

void LayoutMode::load(const Glib::ustring& text, Initiator initiator)
{
  EnumSetting::load(toString(LayoutVersionMode::Mixed), initiator);
}
