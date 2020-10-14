//+------------------------------------------------------------------+
//|                                                     Ichimoku.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

class IchimokuSettings {
   const ENUM_TIMEFRAMES m_TimeFrame;
   const int m_TenkanSenPeriod, m_KijunSenPeriod, m_SenkouSpanBPeriod;
   
   IchimokuSettings(const ENUM_TIMEFRAMES p_TimeFrame, const int p_TenkanSenPeriod, const int p_KijunSenPeriod, const int p_SenkouSpanBPeriod)
      : m_TimeFrame(p_TimeFrame), m_TenkanSenPeriod(p_TenkanSenPeriod), m_KijunSenPeriod(p_KijunSenPeriod), m_SenkouSpanBPeriod(p_SenkouSpanBPeriod) {}
};

struct Ichimoku {
   IchimokuSettings *ptr_IchimokuSettings;   
};