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
   static void GetMovingAverageValues(MovingAverage &p_OutMovingAverage[], MovingAverageSettings &p_MASettings, const int p_From, const int p_To);
   static void GetIchimokuValues(Ichimoku &p_OutIchimoku[], IchimokuSettings &p_IchimokuSettings, const int p_From, const int p_To, const int p_ChikouSpanShift, const int p_SenkouSpanShift);
};

void IndicatorParser::GetMovingAverageValues(MovingAverage &p_OutMovingAverage[], MovingAverageSettings &p_MASettings, const int p_From, const int p_To) {
   if(ArrayResize(p_OutMovingAverage, MathAbs(p_From - p_To) + 1) != -1) {
      for(int i = p_From, MAIdx = 0; (p_From <= p_To) ? i <= p_To : i >= p_To ; p_From <= p_To ? ++i : --i, MAIdx++) {
         SetMovingAverage(&p_MASettings, i, p_OutMovingAverage[MAIdx].MovingAverageValue);
      }
   } else {
      Print("Moving Average array could not be initialized!");
   }
}

void IndicatorParser::GetIchimokuValues(Ichimoku &p_OutIchimoku[], IchimokuSettings &p_IchimokuSettings, const int p_From, const int p_To, const int p_ChikouSpanShift, const int p_SenkouSpanShift) {
   if(ArrayResize(p_OutIchimoku, MathAbs(p_From - p_To) + 1) != -1) {
      for(int i = p_From, MAIdx = 0; (p_From <= p_To) ? i <= p_To : i >= p_To ; p_From <= p_To ? ++i : --i, MAIdx++) {
         SetIchimoku(&p_IchimokuSettings, i, i + p_ChikouSpanShift, i + p_SenkouSpanShift, p_OutIchimoku[MAIdx].TenkanSen, p_OutIchimoku[MAIdx].KijunSen, p_OutIchimoku[MAIdx].ChinkouSpan, p_OutIchimoku[MAIdx].SenkouSpanA, p_OutIchimoku[MAIdx].SenkouSpanB);
      }
   } else {
      Print("Ichimoku array could not be initialized!");
   }
}