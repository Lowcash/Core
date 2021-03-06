//+------------------------------------------------------------------+
//|                                                     Ichimoku.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../../Include/MQL4Helper.mqh"

// Usually BULL is green and BEAR is red
enum CloudColor { BULL = 0, BEAR };

class IchimokuSettings {
 public:
   const string m_Symbol;
   const ENUM_TIMEFRAMES m_TimeFrame;
   const int m_TenkanSenPeriod, m_KijunSenPeriod, m_SenkouSpanBPeriod, m_Shift;
   
   IchimokuSettings(const string p_Symbol, const ENUM_TIMEFRAMES p_TimeFrame, const int p_TenkanSenPeriod, const int p_KijunSenPeriod, const int p_SenkouSpanBPeriod, const int p_Shift)
      : m_Symbol(p_Symbol), m_TimeFrame(p_TimeFrame), m_TenkanSenPeriod(p_TenkanSenPeriod), m_KijunSenPeriod(p_KijunSenPeriod), m_SenkouSpanBPeriod(p_SenkouSpanBPeriod),  m_Shift(p_Shift) {}
};

struct Ichimoku {
 public:
   double TenkanSen, KijunSen, ChinkouSpan, SenkouSpanA, SenkouSpanB;
};

void SetIchimoku(IchimokuSettings *p_IchimokuSettings, const int p_Shift, const int p_ChikouSpanShift, const int p_SenkouSpanShift, double &p_TenkanSen, double &p_KijunSen, double &p_ChinkouSpan, double &p_SenkouSpanA, double &p_SenkouSpanB) {
   const int _Handle = iIchimoku(p_IchimokuSettings.m_Symbol, p_IchimokuSettings.m_TimeFrame, p_IchimokuSettings.m_TenkanSenPeriod, p_IchimokuSettings.m_KijunSenPeriod, p_IchimokuSettings.m_SenkouSpanBPeriod);
   
   if(_Handle < 0) {
      Print("The iIchimoku object is not created: Error", GetLastError());
      return;
   }
   
   p_TenkanSen = NormalizeDouble(CopyBufferMQL4(_Handle, TENKANSEN_LINE, p_Shift), _Digits + 1);
   p_KijunSen = NormalizeDouble(CopyBufferMQL4(_Handle, KIJUNSEN_LINE, p_Shift), _Digits + 1);
   p_ChinkouSpan = NormalizeDouble(CopyBufferMQL4(_Handle, CHIKOUSPAN_LINE, p_ChikouSpanShift), _Digits + 1);
   p_SenkouSpanA = NormalizeDouble(CopyBufferMQL4(_Handle, SENKOUSPANA_LINE, p_SenkouSpanShift), _Digits + 1);
   p_SenkouSpanB = NormalizeDouble(CopyBufferMQL4(_Handle, SENKOUSPANB_LINE, p_SenkouSpanShift), _Digits + 1);
}

void GetTenkanSen(Ichimoku &p_InIchimoku[], double &p_OutTenkanSen[]) {
   if(ArrayResize(p_OutTenkanSen, ArraySize(p_InIchimoku))) {
      for (int i = 0; i < ArraySize(p_InIchimoku); ++i) {
         p_OutTenkanSen[i] = p_InIchimoku[i].TenkanSen;
      }
   } else {
      Print("TenkanSen array could not be initialized!");
   }
}

void GetKijunSen(Ichimoku &p_InIchimoku[], double &p_OutKijunSen[]) {
   if(ArrayResize(p_OutKijunSen, ArraySize(p_InIchimoku))) {
      for (int i = 0; i < ArraySize(p_InIchimoku); ++i) {
         p_OutKijunSen[i] = p_InIchimoku[i].KijunSen;
      }
   } else {
      Print("KijunSen array could not be initialized!");
   }
}

void GetChikouSpan(Ichimoku &p_InIchimoku[], double &p_OutChikouSpan[]) {
   if(ArrayResize(p_OutChikouSpan, ArraySize(p_InIchimoku))) {
      for (int i = 0; i < ArraySize(p_InIchimoku); ++i) {
         p_OutChikouSpan[i] = p_InIchimoku[i].ChinkouSpan;
      }
   } else {
      Print("ChikouSpan array could not be initialized!");
   }
}

void GetSenkouSpan(Ichimoku &p_InIchimoku[], double &p_OutSenkouSpanA[], double &p_OutSenkouSpanB[]) {
   if(ArrayResize(p_OutSenkouSpanA, ArraySize(p_InIchimoku)) != -1 && ArrayResize(p_OutSenkouSpanB, ArraySize(p_InIchimoku)) != -1) {
      for (int i = 0; i < ArraySize(p_InIchimoku); ++i) {
         p_OutSenkouSpanA[i] = p_InIchimoku[i].SenkouSpanA;
         p_OutSenkouSpanB[i] = p_InIchimoku[i].SenkouSpanB;
      }
   } else {
      Print("OutSenkouSpan arrays could not be initialized!");
   }
}