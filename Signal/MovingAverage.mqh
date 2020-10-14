//+------------------------------------------------------------------+
//|                                                MovingAverage.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../Include/MQL4Helper.mqh"

class MovingAverageSettings {
 public:
   const string m_Symbol;
	const ENUM_TIMEFRAMES m_TimeFrame;
	const ENUM_MA_METHOD m_Method;
	const ENUM_APPLIED_PRICE m_AppliedTo;
	const int m_Period, m_Shift;
	
	MovingAverageSettings(const string p_Symbol, const ENUM_TIMEFRAMES p_TimeFrame, const ENUM_MA_METHOD p_Method, const ENUM_APPLIED_PRICE p_AppliedTo, const int p_Period, const int p_Shift)
		: m_Symbol(p_Symbol), m_TimeFrame(p_TimeFrame), m_Method(p_Method), m_AppliedTo(p_AppliedTo), m_Period(p_Period), m_Shift(p_Shift) {}
};

struct MovingAverage {
   MovingAverageSettings *ptr_MovingAverageSetting;
   
   double MovingAverageValue;
};

void SetMovingAverage(MovingAverageSettings *p_MovingAverageSetting, double &p_MovingAverageValue) {
   const int _Handle = iMA(p_MovingAverageSetting.m_Symbol, p_MovingAverageSetting.m_TimeFrame, p_MovingAverageSetting.m_Period, p_MovingAverageSetting.m_Shift, p_MovingAverageSetting.m_Method, p_MovingAverageSetting.m_AppliedTo);
   
   if(_Handle < 0) {
      Print("The iMA object is not created: Error", GetLastError());
      return;
   }
   
   p_MovingAverageValue = CopyBufferMQL4(_Handle, 0, p_MovingAverageSetting.m_Shift);
}