//+------------------------------------------------------------------+
//|                                                 TrendManager.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../_SignalManager.mqh"
#include "../MovingAverage.mqh"
#include "Trend.mqh"

class TrendManager : public SignalManager {
 private:
   const ENUM_INDICATOR m_IndicatorType;
   
   MovingAverage m_FastMA, m_MediumMA, m_SlowMA;

 	Trend::State m_CurrState;
 	
   Trend m_Trends[];
   
   void InitTrendArray(const int p_MaxTrends);
   void UpdateTrendInfo(const bool p_IsNewTrend, const datetime p_Time, const double p_Value);
   
   //Trend::State GetState(const int p_MinCandles);
 public:
   TrendManager(MovingAverageSettings *p_FastMASettings, MovingAverageSettings *p_SlowMASettings, const int p_MaxTrends = 10, const string p_ManagerID = "TrendManager");
	
	void UpdateTrendValues();
	
	//Trend::State AnalyzeTrend(const int p_MinCandles);
	Trend::State GetCurrState() const { return(m_CurrState); }
	
   Trend* GetSelectedTrend() { return(&m_Trends[GetSignalPointer()]); }
};

TrendManager::TrendManager(MovingAverageSettings *p_FastMASettings, MovingAverageSettings *p_SlowMASettings, const int p_MaxTrends, const string p_ManagerID)
   : SignalManager(p_MaxTrends, p_ManagerID), m_IndicatorType(IND_MA), m_CurrState(Trend::State::INVALID_TREND) {
   m_FastMA.ptr_MovingAverageSetting = p_FastMASettings;
   m_SlowMA.ptr_MovingAverageSetting = p_SlowMASettings;
   
   InitTrendArray(p_MaxTrends);
};

void TrendManager::InitTrendArray(const int p_MaxTrends) {
   if(ArrayResize(m_Trends, p_MaxTrends) != -1) {
      PrintFormat("Trend array initialized succesfully with size %d", GetMaxSignals());
   } else {
      Print("Trend array initialization failed with error %", GetLastError());
   }
}