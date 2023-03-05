#include "BBBBOptions.h"
#include <glibmm/optiongroup.h>
#include <glibmm/optioncontext.h>
#include <nltools/logging/Log.h>
#include <giomm.h>
#include <nltools/ErrorCodes.h>

namespace OptionDetail
{
  template <typename T>
  inline Glib::OptionEntry createOption(Glib::OptionGroup& ctx, const char* l, char s, const char* desc, T& dest)
  {
    Glib::OptionEntry entry;
    entry.set_long_name(l);
    entry.set_short_name(s);
    entry.set_description(desc);
    ctx.add_entry(entry, dest);
    return entry;
  }
}

BBBBOptions::BBBBOptions(int& argc, char**& argv)
{
  Glib::OptionGroup mainGroup("common", "common options");
  Glib::OptionContext ctx;

  OptionDetail::createOption(mainGroup, "timestamps", 't', "measure turn around time encoder -> playground -> oled",
                             m_doTimeStamps);
  OptionDetail::createOption(mainGroup, "playground-host", 'p', "where to find the playground", m_playgroundHost);
  OptionDetail::createOption(mainGroup, "audioengine-host", 'a', "where to find the audio engine", m_audioengineHost);

  OptionDetail::createOption(mainGroup, "log-heart-beat", 'h', "log playcontroller heart beat to console",
                             m_logHeartBeat);
  OptionDetail::createOption(mainGroup, "log-playcontroller-raw", 'l', "log raw playcontroller messages to console",
                             m_logPlaycontrollerRaw);

  OptionDetail::createOption(mainGroup, "to-playcontroller-driver", 'o', "to playcontroller driver file",
                             m_toPlaycontrollerDriverPath);
  OptionDetail::createOption(mainGroup, "from-playcontroller-driver", 'i', "from playcontroller driver file",
                             m_fromPlaycontrollerDriverPath);

  ctx.set_main_group(mainGroup);
  ctx.set_help_enabled(true);

  try
  {
    ctx.parse(argc, argv);
  }
  catch(const Glib::OptionError& optErr)
  {
    nltools::Log::error(optErr.what());
    std::exit(static_cast<int>(nltools::ErrorCode::UnknownOptionKeyError));
  }
  catch(const Glib::ConvertError& convErr)
  {
    nltools::Log::error(convErr.what());
    std::exit(static_cast<int>(nltools::ErrorCode::OptionConvertError));
  }
  catch(...)
  {
    std::stringstream ss;
    for(auto i = 0; i < argc; i++)
      ss << argv[i] << " ";
    nltools::Log::error(__FILE__, __FUNCTION__, __LINE__, "Could not parse args:", ss.str());
    std::exit(static_cast<int>(nltools::ErrorCode::UnknownOptionKeyError));
  }
}

Glib::ustring BBBBOptions::getPlaygroundHost() const
{
  return m_playgroundHost;
}

Glib::ustring BBBBOptions::getAudioEngineHost() const
{
  return m_audioengineHost;
}

bool BBBBOptions::doTimeStamps() const
{
  return m_doTimeStamps;
}

bool BBBBOptions::logPlaycontrollerRaw() const
{
  return m_logPlaycontrollerRaw;
}

bool BBBBOptions::logHeartBeat() const
{
  return m_logHeartBeat;
}

Glib::ustring BBBBOptions::getFromPlaycontrollerPath() const
{
  return m_fromPlaycontrollerDriverPath;
}

Glib::ustring BBBBOptions::getToPlaycontrollerPath() const
{
  return m_toPlaycontrollerDriverPath;
}
