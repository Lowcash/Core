//+------------------------------------------------------------------+
//|                                                     Ichimoku.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../Include/MQL4Helper.mqh"

class IchimokuSettings {
 public:
   const string m_Symbol;
   const ENUM_TIMEFRAMES m_TimeFrame;
   const int m_TenkanSenPeriod, m_KijunSenPeriod, m_SenkouSpanBPeriod, m_Shift;
   
   IchimokuSettings(const string p_Symbol, const ENUM_TIMEFRAMES p_TimeFrame, const int p_TenkanSenPeriod, const int p_KijunSenPeriod, const int p_SenkouSpanBPeriod, const int p_Shift)
      : m_Symbol(p_Symbol), m_TimeFrame(p_TimeFrame), m_TenkanSenPeriod(p_TenkanSenPeriod), m_KijunSenPeriod(p_KijunSenPeriod), m_SenkouSpanBPeriod(p_SenkouSpanBPeriod),  m_Shift(p_Shift) {}
};

struct Ichimoku {
   IchimokuSettings *ptr_IchimokuSettings;
   
   double TenkanSen, KijunSen, ChinkouSpan, SenkouSpanA, SenkouSpanB;
};

void SetIchimoku(IchimokuSettings *p_IchimokuSettings, double &p_TenkanSen, double &p_KijunSen, double &p_ChinkouSpan, double &p_SenkouSpanA, double &p_SenkouSpanB) {
   const int _Handle = iIchimoku(p_IchimokuSettings.m_Symbol, p_IchimokuSettings.m_TimeFrame, p_IchimokuSettings.m_TenkanSenPeriod, p_IchimokuSettings.m_KijunSenPeriod, p_IchimokuSettings.m_SenkouSpanBPeriod);
   
   if(_Handle < 0) {
      Print("The iIchimoku object is not created: Error", GetLastError());
      return;
   }
   
   p_TenkanSen = CopyBufferMQL4(_Handle, 0, p_IchimokuSettings.m_Shift);
   p_KijunSen = CopyBufferMQL4(_Handle, 1, p_IchimokuSettings.m_Shift);
   p_ChinkouSpan = CopyBufferMQL4(_Handle, 2, -p_IchimokuSettings.m_KijunSenPeriod);
   p_SenkouSpanA = CopyBufferMQL4(_Handle, 3, -p_IchimokuSettings.m_KijunSenPeriod);
   p_SenkouSpanB = CopyBufferMQL4(_Handle, 4, p_IchimokuSettings.m_Shift);
}