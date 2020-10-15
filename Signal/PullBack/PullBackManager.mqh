//+------------------------------------------------------------------+
//|                                              PullBackManager.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../_SignalManager.mqh"
#include "../_Indicators/MovingAverage.mqh"
#include "../Trend/Trend.mqh"
#include "PullBack.mqh"

class PullBackManager : public SignalManager {
 private:
   PullBack m_PullBacks[];
   
 	PullBack::State m_CurrState;
 	
   void UpdatePullBack(const bool p_IsNewPullBack, const datetime p_Time, const double p_Value);
   
   PullBack::State GetStateInclTrend(Trend::State p_TrendState, MovingAverageSettings &p_MAFastSettings, MovingAverageSettings &p_MAMediSettings, MovingAverageSettings &p_MASlowSettings, const double p_PipValue, const double p_TrigPipsTolerance, const double p_PrevMinPipsToIMA);
 public:
   PullBackManager(const int p_MaxPullBacks = 1, const string p_ManagerID = "TrendManager");
	
	PullBack::State AnalyzeInclTrend(Trend::State p_TrendState, MovingAverageSettings &p_MAFastSettings, MovingAverageSettings &p_MAMediSettings, MovingAverageSettings &p_MASlowSettings, const double p_PipValue, const double p_TrigPipsTolerance, const double p_PrevMinPipsToIMA);
	PullBack::State GetCurrState() const { return(m_CurrState); }
	
   PullBack* GetSelectedPullBack() { return(&m_PullBacks[GetSignalPointer()]); }
};

PullBackManager::PullBackManager(const int p_MaxPullBacks, const string p_ManagerID)
   : SignalManager(p_MaxPullBacks, p_ManagerID), m_CurrState(PullBack::State::INVALID_PULLBACK) {
   if(ArrayResize(m_PullBacks, p_MaxPullBacks) != -1) {
      PrintFormat("PullBack array initialized succesfully with size %d", GetMaxSignals());
   } else {
      Print("PullBack array initialization failed with error %", GetLastError());
   }
}

void PullBackManager::UpdatePullBack(const bool p_IsNewPullBack, const datetime p_Time, const double p_Value) {
	const int _SignalPointer = GetSignalPointer();

   if(p_IsNewPullBack) {
      m_PullBacks[_SignalPointer] = Signal(StringFormat("%s_%d", GetManagerId(), _SignalPointer), p_Time, p_Value);
   } else {
      m_PullBacks[_SignalPointer].SetEnd(p_Time, p_Value);
   }
}

PullBack::State PullBackManager::AnalyzeInclTrend(Trend::State p_TrendState, MovingAverageSettings &p_MAFastSettings, MovingAverageSettings &p_MAMediSettings, MovingAverageSettings &p_MASlowSettings, const double p_PipValue, const double p_TrigPipsTolerance, const double p_PrevMinPipsToIMA) {
	const PullBack::State _PrevState = m_CurrState;
	
	if((m_CurrState = GetStateInclTrend(p_TrendState, p_MAFastSettings, p_MAMediSettings, p_MASlowSettings, p_PipValue, p_TrigPipsTolerance, p_PrevMinPipsToIMA)) != PullBack::State::INVALID_PULLBACK) {
		if((p_TrendState == Trend::State::VALID_UPTREND && m_CurrState == PullBack::State::VALID_UPPULLBACK) ||
		(p_TrendState == Trend::State::VALID_DOWNTREND && m_CurrState == PullBack::State::VALID_DOWNPULLBACK)) {
			if(_PrevState != m_CurrState) { // Is new PullBack?
			   SelectNextSignal();
			}	

			UpdatePullBack(_PrevState != m_CurrState, _Time, Bid);
		}
	}
	
	return(m_CurrState);
}

PullBack::State PullBackManager::GetStateInclTrend(Trend::State p_TrendState, MovingAverageSettings &p_MAFastSettings, MovingAverageSettings &p_MAMediSettings, MovingAverageSettings &p_MASlowSettings, const double p_PipValue, const double p_TrigPipsTolerance, const double p_PrevMinPipsToIMA) {
   double _PrevIMAFast; SetMovingAverage(&p_MAFastSettings, 2, _PrevIMAFast);
   
	double _CurrIMASlow; SetMovingAverage(&p_MASlowSettings, 1, _CurrIMASlow);
	double _CurrIMAMedi; SetMovingAverage(&p_MAMediSettings, 1, _CurrIMAMedi);
	double _CurrIMAFast; SetMovingAverage(&p_MAFastSettings, 1, _CurrIMAFast);
	
	const double _PrevLength = MathAbs((Open[2] / p_PipValue) - (Close[2] / p_PipValue));
	const double _TrigLength = MathAbs((Open[1] / p_PipValue) - (Close[1] / p_PipValue));
		      	   
	switch(p_TrendState) {
		case Trend::State::VALID_UPTREND: {
			if(_CurrIMASlow < _CurrIMAMedi && _CurrIMAMedi < _CurrIMAFast) {
			   const double _TriggerLow = iLow(_Symbol, p_MAFastSettings.m_TimeFrame, 1);
			   
			   // Is the trigger wick above the fast iMA and the whole candle below the slow iMA?
				if((_TriggerLow < _CurrIMAFast || GetNumPipsBetweenPrices(_TriggerLow, _CurrIMAFast, p_PipValue) <= p_TrigPipsTolerance) && Close[1] > _CurrIMASlow) {
				   const double _PrevLow = iLow(_Symbol, p_MAFastSettings.m_TimeFrame, 2);
				   
				   // Is the previous candle above the fast iMA?
				   if(_PrevLow > _PrevIMAFast) {
				      const double _NumPips = GetNumPipsBetweenPrices(_PrevLow, _PrevIMAFast, p_PipValue);
				      
				      // Is valid wick - iMA distance?
		      		if(_NumPips >= p_PrevMinPipsToIMA) {
		      		
		      		   // Is there a good shape of previous and trigger candle?
		      		   if((Close[2] > Close[1] || _PrevLength > _TrigLength) && !(IsBullCandle(2) && IsBullCandle(1))) {
		      		      PrintFormat("Valid pullback! Previous candle close: %lf; Trigger candle close: %lf; Previous candle length: %lf; Trigger candle close: %lf", Close[2], Close[1], _PrevLength, _TrigLength);
		      		   
		      		      return(PullBack::State::VALID_UPPULLBACK);
		      		   } else {
		      		      Print("Invalid pullback! Wrong previous/trigger candle shape.");
		      		   }
		      		} else {
		      		   PrintFormat("Invalid previous candle! Candle wick is too close to iMA! Wick: %lf; Fast iMA: %lf; Num pips: %lf < Min num pips: %lf", _PrevLow, _PrevIMAFast, _NumPips, p_PrevMinPipsToIMA);
		      		}
				   } else {
				      PrintFormat("Invalid previous candle! Candle is not above the fast iMA! Wick: %lf; Candle: %lf; Fast iMA: %lf", _PrevLow, Close[2], _CurrIMAFast);
				   }
				} else {
				   PrintFormat("Invalid trigger candle! Wick: %lf; Candle: %lf; Fast iMA: %lf; Slow iMA: %lf", _TriggerLow, Close[1], _CurrIMAFast, _CurrIMASlow);
				}
		   }
   
			break;
		}
		case Trend::State::VALID_DOWNTREND: {
		   if(_CurrIMASlow > _CurrIMAMedi && _CurrIMAMedi > _CurrIMAFast) {
			   const double _TriggerHigh = iHigh(_Symbol, p_MAFastSettings.m_TimeFrame, 1);
			   
			   // Is the trigger wick below the fast iMA and the whole candle above the slow iMA?
				if((_TriggerHigh > _CurrIMAFast || GetNumPipsBetweenPrices(_TriggerHigh, _CurrIMAFast, p_PipValue) <= p_TrigPipsTolerance) && Close[1] < _CurrIMASlow) {
				   const double _PrevHigh = iHigh(_Symbol, p_MAFastSettings.m_TimeFrame, 2);
				   
				   // Is the previous candle below the fast iMA?
				   if(_PrevHigh < _PrevIMAFast) {
				      const double _NumPips = GetNumPipsBetweenPrices(_PrevHigh, _PrevIMAFast, p_PipValue);
				      
				      // Is valid wick - iMA distance?
		      		if(_NumPips >= p_PrevMinPipsToIMA) {
		      		
		      		   // Is there a good shape of previous and trigger candle?
		      		   if((Close[2] < Close[1] || _PrevLength > _TrigLength) && !(IsBearCandle(2) && IsBearCandle(1))) {
		      		      PrintFormat("Valid pullback! Previous candle close: %lf; Trigger candle close: %lf; Previous candle length: %lf; Trigger candle close: %lf", Close[2], Close[1], _PrevLength, _TrigLength);
		      		   
		      		      return(PullBack::State::VALID_DOWNPULLBACK);
		      		   } else {
		      		      Print("Invalid pullback! Wrong previous/trigger candle shape.");
		      		   }
		      		} else {
		      		   PrintFormat("Invalid previous candle! Candle wick is too close to iMA! Wick: %lf; Fast iMA: %lf; Num pips: %lf < Min num pips: %lf", _PrevHigh, _PrevIMAFast, _NumPips, p_PrevMinPipsToIMA);
		      		}
				   } else {
				      PrintFormat("Invalid previous candle! Candle is not below the fast iMA! Wick: %lf; Candle: %lf; Fast iMA: %lf", _PrevHigh, Close[2], _CurrIMAFast);
				   }
				} else {
				   PrintFormat("Invalid trigger candle! Wick: %lf; Candle: %lf; Fast iMA: %lf; Slow iMA: %lf", _TriggerHigh, Close[1], _CurrIMAFast, _CurrIMASlow);
				}
		   }
   
			break;
		}
	}

   return(PullBack::State::INVALID_PULLBACK);
}