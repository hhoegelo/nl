#include "Rect.h"
#include "FrameBuffer.h"

Rect::Rect(int x, int y, int w, int h)
    : m_leftTop(x, y)
    , m_width(w)
    , m_height(h)
{
}

Rect::Rect(const Point &leftTop, const Point &rightBottom)
    : m_leftTop(leftTop)
{
  setRightBottom(rightBottom);
}

Rect::~Rect()
{
}

void Rect::setRightBottom(const Point &p)
{
  setRightBottom(p.getX(), p.getY());
}

void Rect::setRightBottom(int r, int b)
{
  setRight(r);
  setBottom(b);
}

bool Rect::contains(int x, int y) const
{
  return x >= getLeft() && x <= getRight() && y >= getTop() && y <= getBottom();
}

void Rect::setTop(int y)
{
  m_leftTop.setY(y);
}

void Rect::setLeft(int x)
{
  m_leftTop.setX(x);
}

void Rect::setRight(int r)
{
  m_width = r - getLeft() + 1;
}

void Rect::setBottom(int b)
{
  m_height = b - getTop() + 1;
}

const Point &Rect::getPosition() const
{
  return m_leftTop;
}

int Rect::getX() const
{
  return m_leftTop.getX();
}

int Rect::getY() const
{
  return m_leftTop.getY();
}

int Rect::getLeft() const
{
  return m_leftTop.getX();
}

int Rect::getTop() const
{
  return m_leftTop.getY();
}

int Rect::getRight() const
{
  return getLeft() + getWidth() - 1;
}

int Rect::getBottom() const
{
  return getTop() + getHeight() - 1;
}

void Rect::setWidth(int w)
{
  m_width = w;
}

void Rect::setHeight(int h)
{
  m_height = h;
}

int Rect::getWidth() const
{
  return std::max(0, m_width);
}

int Rect::getHeight() const
{
  return std::max(0, m_height);
}

Point Rect::getCenter() const
{
  return Point(getX() + getWidth() / 2, getY() + getHeight() / 2);
}

void Rect::reduceByMargin(int i)
{
  m_leftTop.moveBy(i, i);
  m_width -= i * 2;
  m_height -= i * 2;
}

void Rect::drawRounded(FrameBuffer &fb) const
{
  fb.drawHorizontalLine(getX() + 2, getY(), getWidth() - 4);
  fb.drawHorizontalLine(getX() + 2, getBottom(), getWidth() - 4);

  fb.drawVerticalLine(getX(), getY() + 2, getHeight() - 4);
  fb.drawVerticalLine(getRight(), getY() + 2, getHeight() - 4);

  fb.setPixel(getX() + 1, getY() + 1);
  fb.setPixel(getX() + 1, getBottom() - 1);
  fb.setPixel(getRight() - 1, getY() + 1);
  fb.setPixel(getRight() - 1, getBottom() - 1);
}

void Rect::moveBy(int x, int y)
{
  m_leftTop.moveBy(x, y);
}

void Rect::normalize()
{
  if(getWidth() < 0)
  {
    setLeft(getLeft() + getWidth());
    setWidth(-getWidth());
  }

  if(getHeight() < 0)
  {
    setTop(getTop() + getHeight());
    setHeight(-getHeight());
  }
}

Rect Rect::getMovedBy(const Point &p) const
{
  Rect r(*this);
  r.moveBy(p.getX(), p.getY());
  return r;
}

bool Rect::isEmpty() const
{
  return m_width <= 0 || m_height <= 0;
}

Rect Rect::getIntersection(const Rect &other) const
{
  auto left = std::max(other.getLeft(), getLeft());
  auto top = std::max(other.getTop(), getTop());

  if(other.isEmpty() || isEmpty())
    return Rect(left, top, 0, 0);

  auto right = std::min(other.getRight(), getRight());
  auto bottom = std::min(other.getBottom(), getBottom());

  right = std::max(left - 1, right);
  bottom = std::max(top - 1, bottom);

  return Rect(left, top, (right - left) + 1, (bottom - top) + 1);
}

Rect Rect::getMargined(int h, int v) const
{
  return Rect(getLeft() + h / 2, getTop() + v / 2, getWidth() - h, getHeight() - v);
}

void Rect::addMargin(int left, int top, int right, int bottom)
{
  m_leftTop.moveBy(left, top);
  m_width -= left + right;
  m_height -= top + bottom;
}