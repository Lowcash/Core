//+------------------------------------------------------------------+
//|                                             _IndicatorParser.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../_Indicators/MovingAverage.mqh"
#include "../_Indicators/Ichimoku.mqh"

class IndicatorParser {
 public:
   static void GetMovingAverageValues(double &p_OutValues[], MovingAverageSettings &p_MASettings, const int p_From, const int p_To);
};

void IndicatorParser::GetMovingAverageValues(double &p_OutValues[], MovingAverageSettings &p_MASettings, const int p_From, const int p_To) {
   if(ArrayResize(p_OutValues, MathAbs(p_From - p_To) + 1) != -1) {
      for(int i = p_From, MAIdx = 0; (p_From <= p_To) ? i <= p_To : i >= p_To ; p_From <= p_To ? ++i : --i, MAIdx++) {
         SetMovingAverage(&p_MASettings, i, p_OutValues[MAIdx]);
      }
   } else {
      Print("Moving Average array could not be initialized!");
   }
}