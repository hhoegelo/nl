#include <proxies/hwui/controls/LeftAlignedLabel.h>
#include "GenericPresetList.h"
#include "Application.h"
#include "presets/PresetManager.h"
#include "presets/Preset.h"
#include "presets/Bank.h"
#include <proxies/hwui/FrameBuffer.h>

GenericPresetList::GenericPresetList(const Point &p)
    : ControlWithChildren({ p.getX(), p.getY(), 128, 50 })
{
  sanitizePresetPtr();

  m_restoreHappened = Application::get().getPresetManager()->onRestoreHappened([&]() { signalChanged(); });
  m_numBanks = Application::get().getPresetManager()->onNumBanksChanged([&](size_t numB) { signalChanged(); });

  signalChanged();
}

GenericPresetList::~GenericPresetList()
{
  m_restoreHappened.disconnect();
  m_numBanks.disconnect();
}

void GenericPresetList::incBankSelection()
{
  auto old = m_selectedPreset;

  if(!sanitizePresetPtr())
    return;

  auto bank = (Bank *) m_selectedPreset->getParent();
  auto pm = (PresetManager *) bank->getParent();
  auto nextBank = pm->getBankAt(pm->getBankPosition(bank->getUuid()) + 1);
  if(nextBank)
    m_selectedPreset = nextBank->getPresetAt(0);

  if(old != m_selectedPreset)
    signalChanged();
}

void GenericPresetList::decBankSelection()
{
  auto old = m_selectedPreset;

  if(!sanitizePresetPtr())
    return;
  auto bank = (Bank *) m_selectedPreset->getParent();
  auto pm = (PresetManager *) bank->getParent();
  auto nextBank = pm->getBankAt(pm->getBankPosition(bank->getUuid()) - 1);
  if(nextBank)
    m_selectedPreset = nextBank->getPresetAt(0);

  if(old != m_selectedPreset)
    signalChanged();
}

void GenericPresetList::incPresetSelection()
{
  auto old = m_selectedPreset;

  if(!sanitizePresetPtr())
    return;
  auto bank = (Bank *) m_selectedPreset->getParent();
  if(auto candidate = bank->getPresetAt(bank->getPresetPosition(m_selectedPreset) + 1))
    m_selectedPreset = candidate;

  if(m_selectedPreset != old)
    signalChanged();
}

void GenericPresetList::decPresetSelection()
{
  auto old = m_selectedPreset;
  auto bank = (Bank *) m_selectedPreset->getParent();
  if(auto candidate = bank->getPresetAt(bank->getPresetPosition(m_selectedPreset) - 1))
    m_selectedPreset = candidate;

  if(old != m_selectedPreset)
    signalChanged();
}

Preset *GenericPresetList::getPresetAtSelected() const
{
  return m_selectedPreset;
}

bool GenericPresetList::redraw(FrameBuffer &fb)
{

  const Rect &r = getPosition();
  fb.setColor(FrameBufferColors::C103);
  fb.drawRect(r.getLeft(), r.getTop(), r.getWidth(), r.getHeight());

  if(!sanitizePresetPtr())
    return false;

  drawPresets(fb, m_selectedPreset);

  return true;
}

sigc::connection GenericPresetList::onChange(const sigc::slot<void, GenericPresetList *> &pl)
{
  return m_signalChanged.connect(pl);
}

void GenericPresetList::signalChanged()
{
  m_signalChanged.emit(this);
  setDirty();
}

void GenericPresetList::drawPresets(FrameBuffer &fb, Preset *middle)
{
  if(middle == nullptr)
  {
    fb.setColor(FrameBufferColors::C43);
    fb.fillRect(getPosition());
    return;
  }

  auto pos = getPosition();
  auto third = pos.getHeight() / 3;
  auto pBank = dynamic_cast<Bank *>(middle->getParent());
  auto currentPos = pBank->getPresetPosition(middle);
  auto prev = pBank->getPresetAt(currentPos - 1);
  auto next = pBank->getPresetAt(currentPos + 1);

  auto createAndDrawControl = [&](Preset *p, int index, bool hightlight) {
    auto basePos = getPosition();
    auto numPos = Rect { basePos.getLeft() + 5, basePos.getTop() + index * third + 1, 15, third - 1 };
    auto namePos
        = Rect { basePos.getLeft() + 20, basePos.getTop() + index * third + 1, basePos.getWidth() - 21, third - 1 };

    if(p == nullptr)
    {

      fb.setColor(FrameBufferColors::C43);
      fb.fillRect(numPos);
      fb.fillRect(namePos);
      return;
    }

    auto bank = dynamic_cast<Bank *>(p->getParent());
    auto presetNum = bank->getPresetPosition(p);

    auto number = addControl(new LeftAlignedLabel({ std::to_string(presetNum), 0 }, numPos));
    auto name = addControl(new LeftAlignedLabel({ p->getName(), 0 }, namePos));

    fb.setColor(FrameBufferColors::C43);
    fb.fillRect(numPos);
    fb.fillRect(namePos);

    if(hightlight)
    {
      auto rect = getPosition();
      rect.setTop(rect.getTop() + index * third);
      rect.setHeight(third);
      rect.addMargin(2, 2, 2, 2);
      fb.setColor(FrameBufferColors::C103);
      fb.fillRect(rect);

      fb.setColor(FrameBufferColors::C204);
      fb.drawRect({ getPosition().getLeft(), basePos.getTop() + index * third, basePos.getWidth(), third });
    }

    number->setFontColor(hightlight ? FrameBufferColors::C255 : FrameBufferColors::C179);
    number->redraw(fb);

    name->setFontColor(hightlight ? FrameBufferColors::C255 : FrameBufferColors::C179);
    name->redraw(fb);

    remove(number);
    remove(name);
  };

  createAndDrawControl(middle, 1, true);
  createAndDrawControl(prev, 0, false);
  createAndDrawControl(next, 2, false);
}

bool GenericPresetList::sanitizePresetPtr()
{
  if(m_selectedPreset == nullptr)
  {
    if(auto bank = Application::get().getPresetManager()->getSelectedBank())
    {
      if(auto preset = bank->getSelectedPreset())
      {
        m_selectedPreset = preset;
      }
    }
  }

  return m_selectedPreset != nullptr;
}
