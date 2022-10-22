#pragma once

namespace UNDO
{
  class Transaction;
}

class UndoTransactionClient
{
 public:
  virtual void assignTransaction(UNDO::Transaction *transaction, bool selected, bool current) = 0;
};
