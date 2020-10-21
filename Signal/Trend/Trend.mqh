//+------------------------------------------------------------------+
//|                                                        Trend.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../_Signal.mqh"

class Trend : public Signal {
 public:
	enum State { INVALID_TREND = -1, VALID_UPTREND = 1, VALID_DOWNTREND = 2 };
 private: 
 	State m_State;
 public:
 	Trend(const string p_TrendID, const State p_State, const datetime p_Time, const double p_Value) 
 		: Signal(p_TrendID, p_Time, p_Value), m_State(p_State) {}
   
   void SetState(const State p_State) { m_State = p_State; }
   
 	State GetState() const { return(m_State); }
};