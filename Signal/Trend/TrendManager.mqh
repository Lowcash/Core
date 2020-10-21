//+------------------------------------------------------------------+
//|                                                 TrendManager.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../../Include/Common.mqh"
#include "../_SignalManager.mqh"
#include "../_Indicators/Ichimoku.mqh"
#include "Trend.mqh"

class TrendManager : public SignalManager {
 private:  
   Trend m_Trends[];
   
 	Trend::State m_CurrState;

   void UpdateTrend(const bool p_IsNewTrend, const Trend::State p_TrendState, const datetime p_Time, const double p_Value);
   
   Trend::State GetTrendByCandlePosition(const double p_CandleValue, double &p_Values[], const int p_CritValueIdx, const bool p_CheckOrderedValues, const bool p_CheckCritValueFarthest);
   Trend::State GetStateByLineDirection(const double p_PrevValue, const double p_CurrValue);
 public:
	TrendManager(const int p_MaxTrends = 1, const string p_ManagerID = "TrendManager");
	
	Trend::State AnalyzeByTrendByCandlePosition(const double p_CandleValue, double &p_Values[], const int p_CritValueIdx, const bool p_CheckOrderedValues, const bool p_CheckCritValueFarthest);
	Trend::State AnalyzeByLineDirection(const double p_PrevValue, const double p_CurrValue);
	
	Trend::State GetCurrentState() const { return(m_CurrState); }
	
   Trend* GetSelectedTrend() { return(&m_Trends[GetSignalPointer()]); }
};

TrendManager::TrendManager(const int p_MaxTrends, const string p_ManagerID)
   : SignalManager(p_MaxTrends, p_ManagerID), m_CurrState(Trend::State::INVALID_TREND) {
   if(ArrayResize(m_Trends, p_MaxTrends) != -1) {
      PrintFormat("Trend array initialized succesfully with size %d", GetMaxSignals());
   } else {
      Print("Trend array initialization failed with error %", GetLastError());
   }
}

void TrendManager::UpdateTrend(const bool p_IsNewTrend, const Trend::State p_TrendState, const datetime p_Time, const double p_Value) {
	const int _SignalPointer = GetSignalPointer();

   if(p_IsNewTrend) {
      m_Trends[_SignalPointer] = Signal(StringFormat("%s_%d", GetManagerId(), _SignalPointer), p_Time, p_Value);
      m_Trends[_SignalPointer].SetState(p_TrendState);
   } else {
      m_Trends[_SignalPointer].SetEnd(p_Time, p_Value);
   } 
}

Trend::State TrendManager::AnalyzeByTrendByCandlePosition(const double p_CandleValue, double &p_Values[], const int p_CritValueIdx, const bool p_CheckOrderedValues, const bool p_CheckCritValueFarthest) {
   const Trend::State _PreviousState = m_CurrState;
   
   if((m_CurrState = GetTrendByCandlePosition(p_CandleValue, p_Values, p_CritValueIdx, p_CheckOrderedValues, p_CheckCritValueFarthest)) != Trend::State::INVALID_TREND) {
      if(_PreviousState != m_CurrState) { // Is new Trend?
         SelectNextSignal();
      } 
      
      UpdateTrend(_PreviousState != m_CurrState, m_CurrState, _Time, Bid);
   }
   
   return(m_CurrState);
}

Trend::State TrendManager::AnalyzeByLineDirection(const double p_PrevValue, const double p_CurrValue) {
   const Trend::State _PreviousState = m_CurrState;
   
   if((m_CurrState = GetStateByLineDirection(p_PrevValue, p_CurrValue)) != Trend::State::INVALID_TREND) {
      if(_PreviousState != m_CurrState) { // Is new Trend?
         SelectNextSignal();
      } 
      
      UpdateTrend(_PreviousState != m_CurrState, m_CurrState, _Time, Bid);
   }
   
   return(m_CurrState);
}

Trend::State TrendManager::GetTrendByCandlePosition(const double p_CandleValue, double &p_Values[], const int p_CritValueIdx, const bool p_CheckOrderedValues, const bool p_CheckCritValueFarthest) {
   switch(m_CurrState) {
      case Trend::State::VALID_UPTREND:
         if(p_CandleValue > p_Values[p_CritValueIdx]) { return(Trend::State::VALID_UPTREND); }
   
         break;
      case Trend::State::VALID_DOWNTREND:
         if(p_CandleValue < p_Values[p_CritValueIdx]) { return(Trend::State::VALID_DOWNTREND); }
   
         break;
      case Trend::State::INVALID_TREND: {
         const bool _IsOrderedValuesConditionOK = !p_CheckOrderedValues || (p_CheckOrderedValues && GetArraySortDirection(p_Values) != ArraySortDirection::NOT_SORTED);
         const bool _IsCritValueFarthestConditionOK = !p_CheckCritValueFarthest || (p_CheckCritValueFarthest && GetFarthest(p_Values, p_CandleValue) == p_Values[p_CritValueIdx]);
         
         if(_IsOrderedValuesConditionOK && _IsCritValueFarthestConditionOK) {
            if(p_CandleValue > p_Values[p_CritValueIdx]) { return(Trend::State::VALID_UPTREND); }
	         if(p_CandleValue < p_Values[p_CritValueIdx]) { return(Trend::State::VALID_DOWNTREND); } 
         }
	
	      break;
	   }
   }

   return(Trend::State::INVALID_TREND);
}

Trend::State TrendManager::GetStateByLineDirection(const double p_PrevValue, const double p_CurrValue) {
   if(p_PrevValue < p_CurrValue) { return(Trend::State::VALID_UPTREND); }
   if(p_PrevValue > p_CurrValue) { return(Trend::State::VALID_DOWNTREND); }
   
   return(Trend::State::INVALID_TREND);
}