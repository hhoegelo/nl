#include "HighPriorityTask.h"
#include <mutex>
#include <nltools/logging/Log.h>
#include <nltools/threading/Threading.h>

HighPriorityTask::HighPriorityTask(int bindToCore, std::function<void()> cb) {
  m_thread = std::thread([this, bindToCore, cb = std::move(cb)]() {
    setupPrios(bindToCore);
    cb();
  });
}

HighPriorityTask::~HighPriorityTask() {
  if (m_thread.joinable())
    m_thread.join();
}

void HighPriorityTask::setupPrios(int bindToCore) {
  static std::mutex m;
  std::lock_guard<std::mutex> g(m);

  prioritizeThread();

  if (bindToCore >= 0)
    setThreadAffinity(bindToCore);
}

void HighPriorityTask::prioritizeThread() {
  nltools::threading::setThisThreadPrio(nltools::threading::Priority::Realtime);
}

void HighPriorityTask::setThreadAffinity(int bindToCore) {
  cpu_set_t set;
  CPU_ZERO(&set);
  CPU_SET(bindToCore, &set);

  if (sched_setaffinity(0, sizeof(cpu_set_t), &set) < 0)
    nltools::Log::warning("Could not set thread affinity");
}
