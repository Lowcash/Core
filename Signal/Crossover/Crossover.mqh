//+------------------------------------------------------------------+
//|                                                    Crossover.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../_Signal.mqh"

class Crossover : public Signal {
 public:
   enum State { INVALID_CROSSOVER = -1, VALID_CROSSOVER };
 private:
   const State m_State;
 public:
   Crossover(const string p_CrossoverID, const datetime p_Time, const double p_Value)
      : Signal(p_CrossoverID, p_Time, p_Value) {}
   
   State GetState() const { return(m_State); }
};