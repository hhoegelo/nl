#pragma once

#include "DeviceInformationItem.h"

class DateTimeInfo : public DeviceInformationItem
{
 public:
  explicit DateTimeInfo(DeviceInformation *parent);
  ~DateTimeInfo();

  virtual void writeDocument(Writer &writer, tUpdateID knownRevision) const override;

 private:
  Glib::ustring get() const override;
  Glib::ustring getDisplayString() const override;
  bool onTimeChanged();

  sigc::connection m_signalMinutePassed;
};
