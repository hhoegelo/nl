#include "PendingHTTPRequests.h"
#include "HTTPRequest.h"

PendingHTTPRequests::PendingHTTPRequests()
{
}

PendingHTTPRequests::~PendingHTTPRequests()
{
}

void PendingHTTPRequests::addPendingMessage(tRequest msg)
{
  m_pendingMessages.insert(msg);
}

PendingHTTPRequests::tMessageSet PendingHTTPRequests::expropriateFromPendingMessages()
{
  tMessageSet copy;
  std::swap(copy, m_pendingMessages);
  return copy;
}

bool PendingHTTPRequests::removeIfExists(SoupMessage *msg)
{
  for(auto it = m_pendingMessages.begin(); it != m_pendingMessages.end(); ++it)
  {
    auto networkRequest = *it;
    if(auto httpRequest = std::dynamic_pointer_cast<HTTPRequest>(networkRequest))
    {
      if(httpRequest->matches(msg))
      {
        m_pendingMessages.erase(it);
        return true;
      }
    }
  }
  return false;
}