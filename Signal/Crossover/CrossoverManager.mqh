//+------------------------------------------------------------------+
//|                                             CrossoverManager.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../_SignalManager.mqh"
#include "../_Indicators/Ichimoku.mqh"
#include "Crossover.mqh"

class CrossoverManager : public SignalManager {
 private:  
   Crossover m_Crossovers[];
   
 	Crossover::State m_CurrState;

   void UpdateCrossover(const bool p_IsNewCrossover, const datetime p_Time, const double p_Value);
   
   Crossover::State GetStateByIchimokuComparer(IchimokuSettings &p_IchimokuSetting, const int p_TraceLineA, const int p_TraceLineB);
 public:
	CrossoverManager(const int p_MaxTrends = 1, const string p_ManagerID = "CrossoverManager");
	
	Crossover::State AnalyzeByIchimokuComparer(IchimokuSettings &p_IchimokuSetting, const int p_TraceLineA, const int p_TraceLineB);
	
	Crossover::State GetCurrentState() const { return(m_CurrState); }
	
   Crossover* GetSelectedCrossover() { return(&m_Crossovers[GetSignalPointer()]); }
};

CrossoverManager::CrossoverManager(const int p_MaxCrossovers, const string p_ManagerID)
   : SignalManager(p_MaxCrossovers, p_ManagerID), m_CurrState(Crossover::State::INVALID_CROSSOVER) {
   if(ArrayResize(m_Crossovers, p_MaxCrossovers) != -1) {
      PrintFormat("Crossover array initialized succesfully with size %d", GetMaxSignals());
   } else {
      Print("Crossover array initialization failed with error %", GetLastError());
   }
}

void CrossoverManager::UpdateCrossover(const bool p_IsNewCrossover, const datetime p_Time, const double p_Value) {
	const int _SignalPointer = GetSignalPointer();

   if(p_IsNewCrossover) {
      m_Crossovers[_SignalPointer] = Signal(StringFormat("%s_%d", GetManagerId(), _SignalPointer), p_Time, p_Value);
   } else {
      m_Crossovers[_SignalPointer].SetEnd(p_Time, p_Value);
   } 
}

Crossover::State CrossoverManager::AnalyzeByIchimokuComparer(IchimokuSettings &p_IchimokuSetting, const int p_TraceLineA, const int p_TraceLineB) {
   const Crossover::State _PreviousState = m_CurrState;
   
   if((m_CurrState = GetStateByIchimokuComparer(p_IchimokuSetting, p_TraceLineA, p_TraceLineB)) != Crossover::State::INVALID_CROSSOVER) {
      if(_PreviousState != m_CurrState) { // Is new Crossover?
         SelectNextSignal();
      } 
      
      UpdateCrossover(_PreviousState != m_CurrState, _Time, Bid);
   }
   
   return(m_CurrState);
}

Crossover::State CrossoverManager::GetStateByIchimokuComparer(IchimokuSettings &p_IchimokuSetting, const int p_TraceLineA, const int p_TraceLineB) {
   Ichimoku _CurrIchimoku(&p_IchimokuSetting);
   Ichimoku _PrevIchimoku(&p_IchimokuSetting);
   
   SetIchimoku(_CurrIchimoku.ptr_IchimokuSettings, 1, _CurrIchimoku.TenkanSen, _CurrIchimoku.KijunSen, _CurrIchimoku.ChinkouSpan, _CurrIchimoku.SenkouSpanA, _CurrIchimoku.SenkouSpanB);
   SetIchimoku(_PrevIchimoku.ptr_IchimokuSettings, 2, _PrevIchimoku.TenkanSen, _PrevIchimoku.KijunSen, _PrevIchimoku.ChinkouSpan, _PrevIchimoku.SenkouSpanA, _PrevIchimoku.SenkouSpanB);
   
   if((_PrevIchimoku.TenkanSen > _PrevIchimoku.KijunSen && _CurrIchimoku.TenkanSen < _CurrIchimoku.KijunSen) ||
      (_PrevIchimoku.TenkanSen < _PrevIchimoku.KijunSen && _CurrIchimoku.TenkanSen > _CurrIchimoku.KijunSen)) { 
      return(Crossover::State::VALID_CROSSOVER); 
   }
   
   return(Crossover::State::INVALID_CROSSOVER);
}