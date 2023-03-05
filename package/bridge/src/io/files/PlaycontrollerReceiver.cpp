#include <io/files/PlaycontrollerReceiver.h>
#include "Application.h"
#include "BBBBOptions.h"
#include "MessageParser.h"
#include <giomm.h>
#include <string.h>
#include <cstdio>
#include <cstdlib>
#include <bitset>
#include <iomanip>
#include <iterator>
#include <iostream>

PlaycontrollerReceiver::PlaycontrollerReceiver()
    : super(Application::get().getOptions()->getFromPlaycontrollerPath().c_str(),
            MessageParser::getNumInitialBytesNeeded())
    , m_parser(std::make_unique<MessageParser>())
{
}

PlaycontrollerReceiver::~PlaycontrollerReceiver() = default;

namespace Heartbeat
{
  constexpr auto messageType = 0x0B00;
  constexpr auto headerSize = 4;
  constexpr auto payloadSize = 8;
  constexpr auto messageSize = headerSize + payloadSize;
}

namespace Log
{

  static constexpr uint16_t BB_MSG_TYPE_SENSORS_RAW = 0x0E00;   // raw sensor values (13 words)
  static constexpr uint16_t BB_MSG_TYPE_RAW_UINT16_T = 0xFFFF;  // raw binary data, arbitrary length (words)

  void logMessage(const Glib::RefPtr<Glib::Bytes> &bytes)
  {
    gsize msgLength = 0;
    auto rawMsg = bytes->get_data(msgLength);
    auto rawWords = reinterpret_cast<const uint16_t *>(rawMsg);

    switch(rawWords[0])
    {
      case BB_MSG_TYPE_SENSORS_RAW:  // all raw sensor values, updates in same line
      {
        if((msgLength >= 4) && (rawWords[1] != 13))
          return;
        printf("BB_MSG_TYPE_SENSORS_RAW: ");
        // Pedal detect bits (Pedal_4...Pedal_1) :
        std::bitset<4> binbits(rawWords[2] & 0x000F);
        std::cout << binbits;
        // Pedal ADC values (TIP1 and RING1 ... TIP4 and RING4, four pairs) :
        printf(" %4d %4d %4d %4d %4d %4d %4d %4d ", rawWords[3], rawWords[4], rawWords[5], rawWords[6], rawWords[7],
               rawWords[8], rawWords[9], rawWords[10]);
        // Pitchbender, Aftertouch, Ribbon 1, Ribbon 2 :
        printf("%4d %4d %4d %4d", rawWords[11], rawWords[12], rawWords[13], rawWords[14]);
        printf("\n\033[1A");  // send "cursor up one line"
        fflush(stdout);       // flush output, so that piping updates nicely when used via SSH
        break;
      }
      case BB_MSG_TYPE_RAW_UINT16_T:  // raw hex data, second word is # of words sent
      {
        printf("\nBB_MSG_TYPE_RAW_UINT16_T:");
        if(msgLength >= 4)
          for(int i = 2; i < 2 + rawWords[1]; i++)
            printf(" %04X", rawWords[i]);
        printf("\n");
        // printf("\n\033[1A");  // send "LF and cursor up one line"
        fflush(stdout);  // flush output, so that piping updates nicely when used via SSH
        break;
      }
    }
  }

  void logHeartbeat(const char *desc, const Glib::RefPtr<Glib::Bytes> &bytes)
  {
    gsize msgLength = 0;
    auto rawMsg = bytes->get_data(msgLength);
    auto rawBytes = reinterpret_cast<const uint8_t *>(rawMsg);
    auto rawWords = reinterpret_cast<const uint16_t *>(rawBytes);

    const auto msgType = rawWords[0];

    if(msgLength == Heartbeat::messageSize && msgType == Heartbeat::messageType)
    {
      auto playcontrollerHeartBeatPtr = reinterpret_cast<const uint64_t *>(rawBytes + Heartbeat::headerSize);
      auto playcontrollerHeartBeat = *playcontrollerHeartBeatPtr;
      std::cout << desc << std::hex << playcontrollerHeartBeat << '\n';
    }
  }
}
void PlaycontrollerReceiver::onDataReceived(Glib::RefPtr<Glib::Bytes> bytes)
{
  const static bool logPlaycontrollerRaw = Application::get().getOptions()->logPlaycontrollerRaw();
  const static bool logHeartbeat = Application::get().getOptions()->logHeartBeat();

  gsize numBytes = 0;
  auto data = reinterpret_cast<const uint8_t *>(bytes->get_data(numBytes));

  if(auto numBytesMissing = m_parser->parse(data, numBytes))
  {
    setBlockSize(numBytesMissing);
  }
  else
  {
    g_assert(m_parser->isFinished());

    auto message = m_parser->getMessage();

    if(logPlaycontrollerRaw)
      Log::logMessage(message);
    if(logHeartbeat)
      Log::logHeartbeat("Playcontroller heartbeat:\t", message);

    message = interceptHeartbeat(message);

    super::onDataReceived(message);
    m_parser = std::make_unique<MessageParser>();
    setBlockSize(MessageParser::getNumInitialBytesNeeded());
  }
}

Glib::RefPtr<Glib::Bytes> PlaycontrollerReceiver::interceptHeartbeat(Glib::RefPtr<Glib::Bytes> msg)
{
  gsize msgLength = 0;
  auto rawMsg = msg->get_data(msgLength);
  auto rawBytes = reinterpret_cast<const uint8_t *>(rawMsg);
  auto rawWords = reinterpret_cast<const uint16_t *>(rawBytes);

  if(msgLength == Heartbeat::messageSize && rawWords[0] == Heartbeat::messageType)
  {
    auto playcontrollerHeartBeatPtr = reinterpret_cast<const uint64_t *>(rawBytes + Heartbeat::headerSize);
    auto playcontrollerHeartBeat = *playcontrollerHeartBeatPtr;
    auto chainHeartBeat = playcontrollerHeartBeat + m_heartbeat++;

    uint8_t scratch[Heartbeat::messageSize];
    memcpy(scratch, rawBytes, Heartbeat::messageSize);
    memcpy(scratch + Heartbeat::headerSize, &chainHeartBeat, Heartbeat::payloadSize);

    return Glib::Bytes::create(scratch, Heartbeat::messageSize);
  }

  return msg;
}
