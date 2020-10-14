//+------------------------------------------------------------------+
//|                                                 TrendManager.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../_SignalManager.mqh"
#include "../_Indicators/MovingAverage.mqh"
#include "../_Indicators/Ichimoku.mqh"
#include "Trend.mqh"

class TrendManager : public SignalManager {
 private:  
   Trend m_Trends[];
   
 	Trend::State m_CurrentState;

   void UpdateTrend(const bool p_IsNewTrend, const datetime p_Time, const double p_Value);
   
   Trend::State GetStateByIMAOutCandles(const int p_MinNumOutCandles, MovingAverageSettings &p_MAFastSettings, MovingAverageSettings &p_MASlowSettings);
 public:
	TrendManager(const int p_MaxTrends = 10, const string p_ManagerID = "TrendManager");
	
	Trend::State AnalyzeByIMAOutCandles(const int p_MinOutCandles, MovingAverageSettings &p_MAFastSettings, MovingAverageSettings &p_MASlowSettings);
	Trend::State GetCurrentState() const { return(m_CurrentState); }
	
   Trend* GetSelectedTrend() { return(&m_Trends[GetSignalPointer()]); }
};

TrendManager::TrendManager(const int p_MaxTrends, const string p_ManagerID)
   : SignalManager(p_MaxTrends, p_ManagerID), m_CurrentState(Trend::State::INVALID_TREND) {
   if(ArrayResize(m_Trends, p_MaxTrends) != -1) {
      PrintFormat("Trend array initialized succesfully with size %d", GetMaxSignals());
   } else {
      Print("Trend array initialization failed with error %", GetLastError());
   }
};

void TrendManager::UpdateTrend(const bool p_IsNewTrend, const datetime p_Time, const double p_Value) {
	const int _SignalPointer = GetSignalPointer();

   if(p_IsNewTrend) {
      m_Trends[_SignalPointer] = Signal(StringFormat("%s_%d", GetManagerId(), _SignalPointer), p_Time, p_Value);
   } else {
      m_Trends[_SignalPointer].SetEnd(p_Time, p_Value);
   } 
}

Trend::State TrendManager::AnalyzeByIMAOutCandles(const int p_MinOutCandles, MovingAverageSettings &p_MAFastSettings, MovingAverageSettings &p_MASlowSettings) {
   const Trend::State _PreviousState = m_CurrentState;
   
   if((m_CurrentState = GetStateByIMAOutCandles(p_MinOutCandles, p_MAFastSettings, p_MASlowSettings)) != Trend::State::INVALID_TREND) {
      if(_PreviousState != m_CurrentState) { // Is new Trend?
         SelectNextSignal();
      } 
      
      UpdateTrend(_PreviousState != m_CurrentState, _Time, Bid);
   }
   
   return(m_CurrentState);
}

Trend::State TrendManager::GetStateByIMAOutCandles(const int p_MinNumOutCandles, MovingAverageSettings &p_MAFastSettings, MovingAverageSettings &p_MASlowSettings) {
   double _CurrentIMASlow; SetMovingAverage(&p_MASlowSettings, 0, _CurrentIMASlow);
   
   switch(m_CurrentState) {
      case Trend::State::VALID_UPTREND:
         if(Close[0] > _CurrentIMASlow) { return(Trend::State::VALID_UPTREND); }
   
         break;
      case Trend::State::VALID_DOWNTREND:
         if(Close[0] < _CurrentIMASlow) { return(Trend::State::VALID_DOWNTREND); }
   
         break;
      case Trend::State::INVALID_TREND: {
	      bool _IsUpTrend = true, _IsDownTrend = true;
	      
	      double _MAFast = DBL_EPSILON, _MASlow = DBL_EPSILON;
	      
	      for(int i = 0; i < p_MinNumOutCandles && _IsUpTrend && _IsDownTrend; ++i) {
	         SetMovingAverage(&p_MAFastSettings, i, _MAFast);
	         SetMovingAverage(&p_MASlowSettings, i, _MASlow);
            
	         if(!(Close[i] > _MAFast && _MAFast > _MASlow)) { _IsUpTrend = false; }
	         if(!(Close[i] < _MAFast && _MAFast < _MASlow)) { _IsDownTrend = false; }   
	      }
	
	      if(_IsUpTrend) { return(Trend::State::VALID_UPTREND); }
	      if(_IsDownTrend) { return(Trend::State::VALID_DOWNTREND); }
	
	      break;
	   }
   }

   return(Trend::State::INVALID_TREND);
}