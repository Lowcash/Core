//+------------------------------------------------------------------+
//|                                               _SignalManager.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../Include/Common.mqh"
#include "_Signal.mqh"

class SignalManager {
 private:
   const string m_ManagerID;

   const int m_MaxSignals;

   int m_SignalPointer;
 protected:
   void SelectNextSignal();
   
   string GetManagerId() const { return(m_ManagerID); }
   
   int GetSignalPointer() const { return(m_SignalPointer); }
   int GetMaxSignals() const { return(m_MaxSignals); }

 	SignalManager(const int m_MaxSignals = 10, const string p_ManagerID = "SignalManager");  
};

SignalManager::SignalManager(const int p_MaxSignals, const string p_ManagerID)
   : m_ManagerID(p_ManagerID), m_MaxSignals(p_MaxSignals), m_SignalPointer(0) {}

void SignalManager::SelectNextSignal(void) {
   SelectNext(m_SignalPointer, m_MaxSignals);
}