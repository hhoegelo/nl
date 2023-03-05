#pragma once

#include <sstream>
#include <stdlib.h>
#include <glibmm/ustring.h>

namespace UNDO
{
  class StringTools
  {
   private:
    static inline void formatString_getNthPart(std::stringstream &str, int n)
    {
    }

    template <typename tFirst> static void formatString_getNthPart(std::stringstream &str, int n, const tFirst &first)
    {
      if(n == 0)
        str << first;
    }

    template <typename tFirst, typename... tParts>
    static void formatString_getNthPart(std::stringstream &str, int n, const tFirst &first, const tParts &... parts)
    {
      if(n == 0)
        str << first;
      else
        formatString_getNthPart(str, n - 1, parts...);
    }

    static inline void buildString_unpackStrings(std::stringstream &str)
    {
    }

    template <typename tFirst, typename... tParts>
    static inline void buildString_unpackStrings(std::stringstream &str, const tFirst &f, const tParts &... parts)
    {
      str << f;
      buildString_unpackStrings(str, parts...);
    }

   public:
    template <typename... tParts>
    static Glib::ustring formatString(const Glib::ustring &format, const tParts &... parts)
    {
      std::stringstream str;

      for(Glib::ustring::const_iterator it = format.begin(); it != format.end(); it++)
      {
        if(*it != '%')
        {
          gchar txt[6];
          gint numBytes = g_unichar_to_utf8(*it, txt);
          str.write(txt, numBytes);
        }
        else
        {
          Glib::ustring::const_iterator next = it;
          next++;

          if(next != format.end())
          {
            if(*next == '%')
              str << '%';
            else
              formatString_getNthPart(str, std::atoi(&(*next.base())), parts...);

            it = next;
          }
        }
      }

      return str.str();
    }

    template <typename... tParts> static Glib::ustring buildString(const tParts &... parts)
    {
      std::stringstream str;
      buildString_unpackStrings(str, parts...);
      return str.str();
    }
  };
} /* namespace UNDO */
