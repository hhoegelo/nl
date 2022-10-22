#pragma once

#include "playground.h"
#include <libsoup/soup.h>
#include <glibmm/refptr.h>

class HTTPServer;
class HTTPRequest;

class ServedStream
{
 public:
  ServedStream(HTTPServer &server, std::shared_ptr<HTTPRequest> request);
  virtual ~ServedStream();

  virtual void startServing() = 0;
  bool matches(SoupMessage *msg) const;

 protected:
  void sendNotFoundResponse();
  void startResponseFromStream(Glib::RefPtr<Gio::InputStream> stream);

  std::shared_ptr<HTTPRequest> m_request;
  Glib::RefPtr<Gio::Cancellable> m_cancellable;

 private:
  gsize writeReadBytesToResponse(gsize numBytes);
  void doAsyncReadFromStream(Glib::RefPtr<Gio::InputStream> stream);
  void onAsyncStreamRead(Glib::RefPtr<Gio::AsyncResult> res, Glib::RefPtr<Gio::InputStream> stream);
  void serveStream(const Glib::RefPtr<Gio::InputStream> &stream);

  HTTPServer &m_server;
  guint8 m_readBuffer[1024];
};
