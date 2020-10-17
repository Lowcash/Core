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
   
   Crossover::State GetStateByValueComparer(double &p_ValuesA[], double &p_ValuesB[]);
 public:
	CrossoverManager(const int p_MaxTrends = 1, const string p_ManagerID = "CrossoverManager");
	
	Crossover::State AnalyzeByValueComparer(double &p_ValuesA[], double &p_ValuesB[]);
	
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

Crossover::State CrossoverManager::AnalyzeByValueComparer(double &p_ValuesA[], double &p_ValuesB[]) {
   const Crossover::State _PreviousState = m_CurrState;
   
   if((m_CurrState = GetStateByValueComparer(p_ValuesA, p_ValuesB)) != Crossover::State::INVALID_CROSSOVER) {
      if(_PreviousState != m_CurrState) { // Is new Crossover?
         SelectNextSignal();
      } 
      
      UpdateCrossover(_PreviousState != m_CurrState, _Time, Bid);
   }
   
   return(m_CurrState);
}

Crossover::State CrossoverManager::GetStateByValueComparer(double &p_ValuesA[], double &p_ValuesB[]) {
   for(uint i = 1; i < (uint)ArraySize(p_ValuesA) && i < (uint)ArraySize(p_ValuesB); ++i) {
      if((p_ValuesA[i - 1] > p_ValuesB[i - 1] && p_ValuesA[i] < p_ValuesB[i]) ||
      (p_ValuesA[i - 1] < p_ValuesB[i - 1] && p_ValuesA[i] > p_ValuesB[i])) { 
         return(Crossover::State::VALID_CROSSOVER); 
      }
   }

   return(Crossover::State::INVALID_CROSSOVER);
}