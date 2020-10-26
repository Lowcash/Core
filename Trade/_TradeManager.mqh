//+------------------------------------------------------------------+
//|                                                _TradeManager.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>

class _TradeManager {
 protected:
   CTrade _TradeFunc;
 public:
   virtual void HandleOrderSend(const ulong p_Ticket) = NULL;
   virtual void HandleOrderDelete(const ulong p_Ticket) = NULL;
   virtual void HandleMakeDeal(const ulong p_Ticket) = NULL;
};
