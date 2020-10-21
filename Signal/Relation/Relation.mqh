//+------------------------------------------------------------------+
//|                                                     Relation.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../_Signal.mqh"

class Relation : public Signal {
 public:
	enum State { INVALID_RELATION = -1, VALID_RELATION = 1 };
   enum Type { IS_LOWER = 0, IS_HIGHER, IS_EQUAL, IS_LOWER_OR_EQUAL, IS_HIGHER_OR_EQUAL }; 
 private: 
 	const State m_State;
 	const Type m_Type;
 public:
 	Relation(const string p_RelationID, const State p_State, const Type p_Type, const datetime p_Time, const double p_Value) 
 		: Signal(p_RelationID, p_Time, p_Value), m_State(p_State), m_Type(p_Type) {}
 
 	State GetState() const { return(m_State); }
 	
 	Type GetType() const { return(m_Type); }
};