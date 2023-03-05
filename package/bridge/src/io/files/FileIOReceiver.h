#pragma once

#include <io/Receiver.h>
#include <glibmm/iochannel.h>

class FileIOReceiver : public Receiver
{
 public:
  FileIOReceiver(const char *path, size_t blockSize);
  virtual ~FileIOReceiver();

 protected:
  void setBlockSize(size_t blockSize);

 private:
  bool onChunk(Glib::IOCondition condition);

  void onFileOpened(Glib::RefPtr<Gio::AsyncResult> &result, Glib::RefPtr<Gio::File> file);
  void readStream(Glib::RefPtr<Gio::InputStream> stream);
  void onStreamRead(Glib::RefPtr<Gio::AsyncResult> &result, Glib::RefPtr<Gio::InputStream> stream);

  Glib::RefPtr<Gio::Cancellable> m_cancel;
  size_t m_blockSize;
};
