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

   void UpdateCrossover(const datetime p_Time, const double p_Value);
   
   Crossover::State GetStateByValueComparer(double &p_InValuesA[], double &p_InValuesB[], double &p_OutMinValue, double &p_OutMaxValue);
 public:
	CrossoverManager(const int p_MaxTrends = 1, const string p_ManagerID = "CrossoverManager");
	
	Crossover::State AnalyzeByValueComparer(const datetime p_Time, double &p_InValuesA[], double &p_InValuesB[]);
	
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

void CrossoverManager::UpdateCrossover(const datetime p_Time, const double p_Value) {
	const int _SignalPointer = GetSignalPointer();

   m_Crossovers[_SignalPointer] = Signal(StringFormat("%s_%d", GetManagerId(), _SignalPointer), p_Time, p_Value);
   m_Crossovers[_SignalPointer].SetEnd(p_Time, p_Value);
}

Crossover::State CrossoverManager::AnalyzeByValueComparer(const datetime p_Time, double &p_InValuesA[], double &p_InValuesB[]) {
   double _MinValue = DBL_EPSILON, _MaxValue = DBL_EPSILON;
   
   if((m_CurrState = GetStateByValueComparer(p_InValuesA, p_InValuesB, _MinValue, _MaxValue)) != Crossover::State::INVALID_CROSSOVER) {
      SelectNextSignal();
      
      UpdateCrossover(p_Time, _MinValue);
   }
   
   return(m_CurrState);
}

Crossover::State CrossoverManager::GetStateByValueComparer(double &p_InValuesA[], double &p_InValuesB[], double &p_OutMinValue, double &p_OutMaxValue) {
   for(uint i = 1; i < (uint)ArraySize(p_InValuesA) && i < (uint)ArraySize(p_InValuesB); ++i) {
      if((p_InValuesA[i - 1] >= p_InValuesB[i - 1] && p_InValuesA[i] <= p_InValuesB[i]) ||
      (p_InValuesA[i - 1] <= p_InValuesB[i - 1] && p_InValuesA[i] >= p_InValuesB[i])) {
         p_OutMinValue = MathMin(p_InValuesA[ArrayMinimum(p_InValuesA)], p_InValuesB[ArrayMinimum(p_InValuesB)]);
         p_OutMaxValue = MathMax(p_InValuesA[ArrayMaximum(p_InValuesA)], p_InValuesB[ArrayMaximum(p_InValuesB)]);
         
         return(Crossover::State::VALID_CROSSOVER); 
      }
   }

   return(Crossover::State::INVALID_CROSSOVER);
}