#include <catch.hpp>

#include <recorder/FlacFrameStorage.h>
#include <recorder/FlacDecoder.h>
#include <recorder/FlacEncoder.h>
#include <recorder/Recorder.h>
#include <recorder/RecorderInput.h>
#include <recorder/RecorderOutput.h>

#include <glibmm.h>

#include <algorithm>
#include <thread>
#include <recorder/Bitstream.h>
#include <recorder/FlacEncoder.h>
#include <nltools/logging/Log.h>

TEST_CASE("Recorder FlacDecoder")
{
  FlacFrameStorage storage(100000);
  FlacEncoder enc(48000, [&](auto frame, auto header) { storage.push(std::move(frame), header); });

  auto numFrames = 48000;
  SampleFrame buf[numFrames];
  std::fill(buf, buf + numFrames, SampleFrame { 0.0f, 0.0f });

  buf[0].left = 1.0f;
  buf[1].left = 0.5f;
  buf[2].left = 0.25f;
  buf[3].left = 0.125f;

  enc.push(buf, numFrames);

  REQUIRE(storage.getFrames().size() > 5);

  FlacDecoder dec(&storage, 3, 10);

  SampleFrame out[numFrames];
  dec.popAudio(out, numFrames);

  REQUIRE(out[0].left == Approx(1.0f));
  REQUIRE(out[1].left == Approx(0.5f));
  REQUIRE(out[2].left == Approx(0.25f));
  REQUIRE(out[3].left == Approx(0.125f));
}

TEST_CASE("Recorder FlacDecoder In=Out")
{
  auto numFrames = 4096;

  FlacFrameStorage storage(100000);
  FlacEncoder enc(48000, [&](auto frame, auto header) { storage.push(std::move(frame), header); });

  SampleFrame in[numFrames + 1];
  SampleFrame out[numFrames];

  g_random_set_seed(0);

  for(int i = 0; i < numFrames; i++)
  {
    in[i].left = g_random_double_range(-1, 1);
    in[i].right = g_random_double_range(-1, 1);
  }

  enc.push(in, numFrames + 1);

  FlacDecoder dec(&storage, 0, std::numeric_limits<FrameId>::max());
  auto res = dec.popAudio(out, numFrames);

  REQUIRE(res == 4096);

  for(int i = 0; i < numFrames; i++)
  {
    REQUIRE(std::abs(in[i].left - out[i].left) < 0.00001f);
    REQUIRE(std::abs(in[i].right - out[i].right) < 0.00001f);
  }
}

TEST_CASE("Recorder Ring")
{
  RingBuffer<int> ring(50);

  int inVal = 0;
  int outVal = 0;

  for(auto i = 0; i < 1000; i++)
  {
    auto numIn = g_random_int_range(1, ring.getFreeSpace());
    int in[numIn];
    std::generate(in, in + numIn, [&] { return inVal++; });
    ring.push(in, numIn);

    auto numOut = g_random_int_range(1, ring.avail());
    int out[numOut];
    numOut = ring.pop(out, numOut);

    for(auto k = 0; k < numOut; k++)
    {
      if(out[k] != outVal)
        G_BREAKPOINT();

      REQUIRE(out[k] == outVal);
      outVal++;
    }
  }
}

TEST_CASE("Recorder InOut")
{
  auto sr = 44100;
  auto recordLength = 10;  // seconds
  auto numFrames = sr * recordLength;
  auto chunkSize = 1000;
  auto numChunks = numFrames / chunkSize;

  Recorder r(sr);
  r.getInput()->setPaused(false);

  SampleFrame in[numFrames];

  g_random_set_seed(0);

  for(auto i = 0; i < numFrames; i++)
  {
    in[i].left = g_random_double_range(-1, 1);
    in[i].right = g_random_double_range(-1, 1);
  }

  auto inWalker = in;
  for(auto i = 0; i < numChunks; i++)
  {
    r.process(inWalker, chunkSize);
    r.getInput()->TEST_waitForSettling();
    inWalker += chunkSize;
  }

  r.getInput()->TEST_waitForSettling();

  r.getInput()->togglePause();
  auto first = r.getStorage()->getFrames().front()->id;
  r.getOutput()->setPlayPos(first);
  r.getOutput()->start();

  SampleFrame out[numFrames];
  std::fill(out, out + numFrames, SampleFrame { 0, 0 });

  auto outWalker = out;

  // don't be exact with the number of chunks here, because a chunk is only commited
  // at boundaries of 4096, so it may happen, that there are less chunks popped then pushed
  for(auto i = 0; i < numChunks / 2; i++)
  {
    r.getOutput()->TEST_waitForBuffersFilled(chunkSize);
    r.process(outWalker, chunkSize);
    outWalker += chunkSize;
  }

  // don't be exact with the number of frames here, because a frames
  // can only be generated by 'full' frames at frame boundaries
  for(auto i = 0; i < numFrames / 4; i++)
  {
    REQUIRE(std::abs(in[i].left - out[i].left) < 0.00001f);
    REQUIRE(std::abs(in[i].right - out[i].right) < 0.00001f);
  }
}

TEST_CASE("Recorder Bitstream")
{
  auto numBytes = 2000;
  std::vector<uint8_t> buffer(numBytes);
  memset(buffer.data(), 0, buffer.size());

  Bitstream writer(buffer);
  Bitstream reader(buffer);
  uint64_t writerPos = 123;
  writer.patch(writerPos, 12, 0xFFFFFFFFFFFFFFFF);

  uint64_t readerPos = 120;
  REQUIRE(reader.read(readerPos, 3) == 0);
  REQUIRE(reader.read(readerPos, 12) == 0xFFF);
  REQUIRE(reader.read(readerPos, 5) == 0);

  writer.patch(writerPos, 7, 100);

  readerPos = 120 + 3 + 12;
  REQUIRE(reader.read(readerPos, 7) == 100);
}

TEST_CASE("Recorder Bitstream on FlacHeader")
{
  // audacity egnerated header
  std::vector<uint8_t> flacHeader
      = { 0x66, 0x4c, 0x61, 0x43, 0x00, 0x00, 0x00, 0x22, 0x10, 0x00, 0x10, 0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00,
          0x0a, 0xc4, 0x42, 0xf0, 0x00, 0x00, 0x00, 0x00, 0xd4, 0x1d, 0x8c, 0xd9, 0x8f, 0x00, 0xb2, 0x04, 0xe9, 0x80,
          0x09, 0x98, 0xec, 0xf8, 0x42, 0x7e, 0x84, 0x00, 0x00, 0x28, 0x20, 0x00, 0x00, 0x00, 0x72, 0x65, 0x66, 0x65,
          0x72, 0x65, 0x6e, 0x63, 0x65, 0x20, 0x6c, 0x69, 0x62, 0x46, 0x4c, 0x41, 0x43, 0x20, 0x31, 0x2e, 0x33, 0x2e,
          0x33, 0x20, 0x32, 0x30, 0x31, 0x39, 0x30, 0x38, 0x30, 0x34, 0x00, 0x00, 0x00, 0x00 };

  Bitstream s(flacHeader);
  uint64_t pos = 0;

  REQUIRE(s.read(pos, 8) == 'f');
  REQUIRE(s.read(pos, 8) == 'L');
  REQUIRE(s.read(pos, 8) == 'a');
  REQUIRE(s.read(pos, 8) == 'C');
  REQUIRE(s.read(pos, 1) == 0);          // not the last meta data block
  REQUIRE(s.read(pos, 7) == 0);          // block type STREAMINFO
  REQUIRE(s.read(pos, 24) == 34);        // header length
  REQUIRE(s.read(pos, 16) == 4096);      // min block size
  REQUIRE(s.read(pos, 16) == 4096);      // max block size
  REQUIRE(s.read(pos, 24) == 0xffffff);  // min frame size
  REQUIRE(s.read(pos, 24) == 0);         // max frame size
  REQUIRE(s.read(pos, 20) == 44100);     // sample rate
  REQUIRE(s.read(pos, 3) == 1);          // num channels - 2
  REQUIRE(s.read(pos, 5) == 15);         // bits - 1
  REQUIRE(s.read(pos, 36) == 0);         // numFrames

  Bitstream patchLength(flacHeader);
  pos = 172;
  patchLength.patch(pos, 36, 1234567890);

  Bitstream check(flacHeader);
  pos = 0;
  REQUIRE(check.read(pos, 8) == 'f');
  REQUIRE(check.read(pos, 8) == 'L');
  REQUIRE(check.read(pos, 8) == 'a');
  REQUIRE(check.read(pos, 8) == 'C');
  REQUIRE(check.read(pos, 1) == 0);            // not the last meta data block
  REQUIRE(check.read(pos, 7) == 0);            // block type STREAMINFO
  REQUIRE(check.read(pos, 24) == 34);          // header length
  REQUIRE(check.read(pos, 16) == 4096);        // min block size
  REQUIRE(check.read(pos, 16) == 4096);        // max block size
  REQUIRE(check.read(pos, 24) == 0xffffff);    // min frame size
  REQUIRE(check.read(pos, 24) == 0);           // max frame size
  REQUIRE(check.read(pos, 20) == 44100);       // sample rate
  REQUIRE(check.read(pos, 3) == 1);            // num channels - 2
  REQUIRE(check.read(pos, 5) == 15);           // bits - 1
  REQUIRE(check.read(pos, 36) == 1234567890);  // numFrames
}

TEST_CASE("Recorder Bitstream utf8 numbers reading")
{
  uint64_t expectedFrameNumber = 0;
  FlacEncoder encoder(48000, [&](auto frame, bool isHeader) {
    if(isHeader)
      return;

    Bitstream s(frame->buffer);
    uint64_t pos = 32;

    REQUIRE(s.readUtf8(pos) == expectedFrameNumber);
    expectedFrameNumber++;
  });

  SampleFrame v[48000];

  while(expectedFrameNumber < 1234)
    encoder.push(v, 48000);
}

TEST_CASE("Recorder Bitstream utf8 numbers writing")
{
  auto numBytes = 8;
  std::vector<uint8_t> buffer(numBytes);
  memset(buffer.data(), 0, buffer.size());

  for(int pos : { 0, 3, 7, 8, 9 })
  {
    for(uint64_t n : { 0, 1, 7, 127, 128, 129, 1024, 1239834 })
    {
      Bitstream writer(buffer);
      Bitstream reader(buffer);

      uint64_t writerPos = pos;
      uint64_t readerPos = pos;

      writer.patchUtf8(writerPos, 4, n);
      REQUIRE(reader.readUtf8(readerPos) == n);
    }
  }
}

TEST_CASE("Recorder CRC8")
{
  FlacEncoder encoder(48000, [&](auto frame, bool isHeader) {
    if(isHeader)
      return;

    Bitstream s(frame->buffer);

    uint64_t blocksizeBitsPos = 16;
    auto blockSizeBits = s.read(blocksizeBitsPos, 4);
    REQUIRE(blockSizeBits == 0x0C);

    uint64_t samplerateBitsPos = 20;
    auto samplerateBits = s.read(samplerateBitsPos, 4);
    REQUIRE(samplerateBits == 0x0A);

    uint64_t frameNumberPos = 32;
    auto frameNumberLength = s.readLengthOfUtf8EncodedField(frameNumberPos);

    if(frameNumberLength == 0)
      frameNumberLength = s.readLengthOfUtf8EncodedField(frameNumberPos);

    REQUIRE(frameNumberLength >= 1);
    s.readUtf8(frameNumberPos);  // skip the frame number
    auto crc8 = s.read(frameNumberPos, 8);

    REQUIRE(crc8 == s.crc8(0, 4 + frameNumberLength));
  });

  SampleFrame v[48000];

  for(int i = 0; i < 100; i++)
    encoder.push(v, 48000);
}

TEST_CASE("Recorder CRC16")
{
  FlacEncoder encoder(48000, [&](auto frame, bool isHeader) {
    if(isHeader)
      return;

    Bitstream s(frame->buffer);
    auto footerBytePos = frame->buffer.size() - 2;
    auto footerBitPos = footerBytePos * 8;
    auto crc16 = s.read(footerBitPos, 16);
    REQUIRE(crc16 == s.crc16(0, footerBytePos));
  });

  SampleFrame v[48000];

  for(int i = 0; i < 100; i++)
    encoder.push(v, 48000);
}

TEST_CASE("Recorder API should not stall")
{
  Recorder r(48000);
  r.getInput()->setPaused(false);

  SampleFrame v[48000];
  for(auto &frame : v)
  {
    frame.left = g_random_double_range(-1, 1);
    frame.right = g_random_double_range(-1, 1);
  }

  while(r.getStorage()->getMemUsage() < 250 * 1024 * 1024)
    r.process(v, 48000);

  auto start = std::chrono::steady_clock::now();
  auto info = r.api({ { "get-info", {} } });
  auto firstFrame = info.at("storage").at("first").at("id");
  auto lastFrame = info.at("storage").at("last").at("id");
  auto res = r.api({ { "query-frames", { { "begin", firstFrame }, { "end", lastFrame } } } });
  auto end = std::chrono::steady_clock::now();
  auto diff = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
  REQUIRE(diff < 100);
}