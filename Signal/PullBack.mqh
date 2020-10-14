//+------------------------------------------------------------------+
//|                                                     PullBack.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "_Signal.mqh"

class PullBack : public Signal {
 public:
 	enum State { INVALID_PULLBACK = -1, VALID_UPPULLBACK = 1, VALID_DOWNPULLBACK = 2 };
 private:
 	const State m_State;
 public:
	PullBack(const string p_PullbackID, const datetime p_Time, const double p_Value) 
 		: Signal(p_PullbackID, p_Time, p_Value) {}
 		
 	State GetState() const { return(m_State); }
};