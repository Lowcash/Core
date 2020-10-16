//+------------------------------------------------------------------+
//|                                                       Helper.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"

static datetime Time[];
static double Open[], Close[], Low[];

static datetime _Time;
static double Ask, Bid;

static MqlDateTime _TimeStruct;
static ENUM_DAY_OF_WEEK _DayOfWeek;

void UpdatePredefinedVars() {
   ArraySetAsSeries(Time, true);
   ArraySetAsSeries(Open, true);
   ArraySetAsSeries(Close, true);
   ArraySetAsSeries(Low, true);
   
   CopyTime(_Symbol, _Period, 0, 100, Time);
   CopyOpen(_Symbol, _Period, 0, 100, Open);
   CopyClose(_Symbol, _Period, 0, 100, Close);
   CopyLow(_Symbol, _Period, 0, 100, Low);
   
   MqlTick _LastTick;
   SymbolInfoTick(_Symbol, _LastTick);
   _Time = _LastTick.time;
   Ask = _LastTick.ask;
   Bid = _LastTick.bid;
   
   TimeCurrent(_TimeStruct);
   
   _DayOfWeek = (ENUM_DAY_OF_WEEK)_TimeStruct.day_of_week;
}

datetime iTimeMQL4(const string p_Symbol, const ENUM_TIMEFRAMES p_TimeFrame, const int p_Shift) {
   if(p_Shift < 0) return(-1);
   
   datetime _Arr[];
   if(CopyTime(p_Symbol, p_TimeFrame, p_Shift, 1, _Arr) > 0) { 
      return(_Arr[0]); 
   }
   
   return(-1);
}

double CopyBufferMQL4(const int p_Handle, const int p_Index, const int p_Shift) {
   double _Buffer[];
   
   switch(p_Index) {
      case 0: if(CopyBuffer(p_Handle, 0, p_Shift, 1, _Buffer) > 0) { return(_Buffer[0]); }
      case 1: if(CopyBuffer(p_Handle, 1, p_Shift, 1, _Buffer) > 0) { return(_Buffer[0]); }
      case 2: if(CopyBuffer(p_Handle, 2, p_Shift, 1, _Buffer) > 0) { return(_Buffer[0]); }
      case 3: if(CopyBuffer(p_Handle, 3, p_Shift, 1, _Buffer) > 0) { return(_Buffer[0]); }
      case 4: if(CopyBuffer(p_Handle, 4, p_Shift, 1, _Buffer) > 0) { return(_Buffer[0]); }
      
      default: break;
   }
   
   return(EMPTY_VALUE);
}
