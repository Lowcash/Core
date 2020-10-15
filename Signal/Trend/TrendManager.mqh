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
   
 	Trend::State m_CurrState;

   void UpdateTrend(const bool p_IsNewTrend, const datetime p_Time, const double p_Value);
   
   Trend::State GetStateByIMAOutCandles(MovingAverageSettings &p_MAFastSettings, MovingAverageSettings &p_MASlowSettings, const int p_MinNumOutCandles);
   Trend::State GetStateByIchimokuTracing(IchimokuSettings &p_IchimokuSetting, const int p_TraceLine, const bool p_IsTraceUntilNotInvalid = false);
 public:
	TrendManager(const int p_MaxTrends = 1, const string p_ManagerID = "TrendManager");
	
	Trend::State AnalyzeByIMAOutCandles(MovingAverageSettings &p_MAFastSettings, MovingAverageSettings &p_MASlowSettings, const int p_MinOutCandles);
	Trend::State AnalyzeByIchimokuTracing(IchimokuSettings &p_IchimokuSetting, const int p_TraceLine, const bool p_IsTraceUntilNotInvalid = false);
	
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
};

void TrendManager::UpdateTrend(const bool p_IsNewTrend, const datetime p_Time, const double p_Value) {
	const int _SignalPointer = GetSignalPointer();

   if(p_IsNewTrend) {
      m_Trends[_SignalPointer] = Signal(StringFormat("%s_%d", GetManagerId(), _SignalPointer), p_Time, p_Value);
   } else {
      m_Trends[_SignalPointer].SetEnd(p_Time, p_Value);
   } 
}

Trend::State TrendManager::AnalyzeByIMAOutCandles(MovingAverageSettings &p_MAFastSettings, MovingAverageSettings &p_MASlowSettings, const int p_MinOutCandles) {
   const Trend::State _PreviousState = m_CurrState;
   
   if((m_CurrState = GetStateByIMAOutCandles(p_MAFastSettings, p_MASlowSettings, p_MinOutCandles)) != Trend::State::INVALID_TREND) {
      if(_PreviousState != m_CurrState) { // Is new Trend?
         SelectNextSignal();
      } 
      
      UpdateTrend(_PreviousState != m_CurrState, _Time, Bid);
   }
   
   return(m_CurrState);
}

Trend::State TrendManager::AnalyzeByIchimokuTracing(IchimokuSettings &p_IchimokuSetting, const int p_TraceLine, const bool p_IsTraceUntilNotInvalid) {
   const Trend::State _PreviousState = m_CurrState;
   
   if((m_CurrState = GetStateByIchimokuTracing(p_IchimokuSetting, p_TraceLine, p_IsTraceUntilNotInvalid)) != Trend::State::INVALID_TREND) {
      if(_PreviousState != m_CurrState) { // Is new Trend?
         SelectNextSignal();
      } 
      
      UpdateTrend(_PreviousState != m_CurrState, _Time, Bid);
   }
   
   return(m_CurrState);
}

Trend::State TrendManager::GetStateByIMAOutCandles(MovingAverageSettings &p_MAFastSettings, MovingAverageSettings &p_MASlowSettings, const int p_MinNumOutCandles) {
   double _CurrIMASlow; SetMovingAverage(&p_MASlowSettings, 1, _CurrIMASlow);
   
   switch(m_CurrState) {
      case Trend::State::VALID_UPTREND:
         if(Close[1] > _CurrIMASlow) { return(Trend::State::VALID_UPTREND); }
   
         break;
      case Trend::State::VALID_DOWNTREND:
         if(Close[1] < _CurrIMASlow) { return(Trend::State::VALID_DOWNTREND); }
   
         break;
      case Trend::State::INVALID_TREND: {
	      bool _IsUpTrend = true, _IsDownTrend = true;
	      
	      double _MAFast = DBL_EPSILON, _MASlow = DBL_EPSILON;
	      
	      for(int i = 1; i <= p_MinNumOutCandles && _IsUpTrend && _IsDownTrend; ++i) {
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

Trend::State TrendManager::GetStateByIchimokuTracing(IchimokuSettings &p_IchimokuSetting, const int p_TraceLine, const bool p_IsTraceUntilNotInvalid) {
   Ichimoku _CurrIchimoku(&p_IchimokuSetting);
   Ichimoku _PrevIchimoku(&p_IchimokuSetting);

   for(int i = 1; (p_IsTraceUntilNotInvalid && i < Bars(p_IchimokuSetting.m_Symbol, p_IchimokuSetting.m_TimeFrame)) || i == 1; ++i) {
      SetIchimoku(_CurrIchimoku.ptr_IchimokuSettings, i + 0, _CurrIchimoku.TenkanSen, _CurrIchimoku.KijunSen, _CurrIchimoku.ChinkouSpan, _CurrIchimoku.SenkouSpanA, _CurrIchimoku.SenkouSpanB);
      SetIchimoku(_PrevIchimoku.ptr_IchimokuSettings, i + 1, _PrevIchimoku.TenkanSen, _PrevIchimoku.KijunSen, _PrevIchimoku.ChinkouSpan, _PrevIchimoku.SenkouSpanA, _PrevIchimoku.SenkouSpanB);
      
      switch(p_TraceLine) {
         case TENKANSEN_LINE: {
            if(_PrevIchimoku.TenkanSen < _CurrIchimoku.TenkanSen) { return(Trend::State::VALID_UPTREND); }
            if(_PrevIchimoku.TenkanSen > _CurrIchimoku.TenkanSen) { return(Trend::State::VALID_DOWNTREND); }
      
            break;
         }
         case KIJUNSEN_LINE: {
            if(_PrevIchimoku.KijunSen < _CurrIchimoku.KijunSen) { return(Trend::State::VALID_UPTREND); }
            if(_PrevIchimoku.KijunSen > _CurrIchimoku.KijunSen) { return(Trend::State::VALID_DOWNTREND); }
      
            break;
         }
         case CHIKOUSPAN_LINE: {
            if(_PrevIchimoku.ChinkouSpan < _CurrIchimoku.ChinkouSpan) { return(Trend::State::VALID_UPTREND); }
            if(_PrevIchimoku.ChinkouSpan > _CurrIchimoku.ChinkouSpan) { return(Trend::State::VALID_DOWNTREND); }
      
            break;
         }
         case SENKOUSPANA_LINE: {
            if(_PrevIchimoku.SenkouSpanA < _CurrIchimoku.SenkouSpanA) { return(Trend::State::VALID_UPTREND); }
            if(_PrevIchimoku.SenkouSpanA > _CurrIchimoku.SenkouSpanA) { return(Trend::State::VALID_DOWNTREND); }
      
            break;
         }
         case SENKOUSPANB_LINE: {
            if(_PrevIchimoku.SenkouSpanB < _CurrIchimoku.SenkouSpanB) { return(Trend::State::VALID_UPTREND); }
            if(_PrevIchimoku.SenkouSpanB > _CurrIchimoku.SenkouSpanB) { return(Trend::State::VALID_DOWNTREND); }
      
            break;
         }
      }
   }
   
   return(Trend::State::INVALID_TREND);
}