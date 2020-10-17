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

   void UpdateTrend(const bool p_IsNewTrend, const datetime p_Time, const double p_Value);
   
   Trend::State GetTrendByCandlePosition(const double p_CandleValue, double &p_Values[], const int p_CritValueIdx, const bool p_CheckOrderedValues, const bool p_CheckCritValueFarthest);
   Trend::State GetStateByIchimokuTracing(IchimokuSettings &p_IchimokuSetting, const int p_TraceLine, const bool p_IsTraceUntilNotInvalid = false);
 public:
	TrendManager(const int p_MaxTrends = 1, const string p_ManagerID = "TrendManager");
	
	Trend::State AnalyzeByTrendByCandlePosition(const double p_CandleValue, double &p_Values[], const int p_CritValueIdx, const bool p_CheckOrderedValues, const bool p_CheckCritValueFarthest);
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
}

void TrendManager::UpdateTrend(const bool p_IsNewTrend, const datetime p_Time, const double p_Value) {
	const int _SignalPointer = GetSignalPointer();

   if(p_IsNewTrend) {
      m_Trends[_SignalPointer] = Signal(StringFormat("%s_%d", GetManagerId(), _SignalPointer), p_Time, p_Value);
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

Trend::State TrendManager::GetStateByIchimokuTracing(IchimokuSettings &p_IchimokuSetting, const int p_TraceLine, const bool p_IsTraceUntilNotInvalid) {
   Ichimoku _PrevIchimoku, _CurrIchimoku;

   for(int i = 1; (p_IsTraceUntilNotInvalid && i < Bars(p_IchimokuSetting.m_Symbol, p_IchimokuSetting.m_TimeFrame)) || i == 1; ++i) {
      SetIchimoku(&p_IchimokuSetting, i + 0, _CurrIchimoku.TenkanSen, _CurrIchimoku.KijunSen, _CurrIchimoku.ChinkouSpan, _CurrIchimoku.SenkouSpanA, _CurrIchimoku.SenkouSpanB);
      SetIchimoku(&p_IchimokuSetting, i + 1, _PrevIchimoku.TenkanSen, _PrevIchimoku.KijunSen, _PrevIchimoku.ChinkouSpan, _PrevIchimoku.SenkouSpanA, _PrevIchimoku.SenkouSpanB);
      
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