//+------------------------------------------------------------------+
//|                                              RelationManager.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../../Include/Common.mqh"
#include "../_SignalManager.mqh"
#include "Relation.mqh"

class RelationManager : public SignalManager {
 private:  
   Relation m_Relations[];
   
 	Relation::State m_CurrState;

   void UpdateRelation(const bool p_IsNewRelation, const datetime p_Time, const double p_Value);
   
   Relation::State GetStateByValueComparer(double &p_ValuesA[], double &p_ValuesB[], Relation::Type p_RequiredType);
 public:
	RelationManager(const int p_MaxTrends = 1, const string p_ManagerID = "RelationManager");
	
	Relation::State AnalyzeByValueComparer(const datetime p_Time, double &p_ValuesA[], double &p_ValuesB[], Relation::Type p_RequiredType);
	
	Relation::State GetCurrentState() const { return(m_CurrState); }
	
   Relation* GetSelectedRelation() { return(&m_Relations[GetSignalPointer()]); }
};

RelationManager::RelationManager(const int p_MaxRelations, const string p_ManagerID)
   : SignalManager(p_MaxRelations, p_ManagerID), m_CurrState(Relation::State::INVALID_RELATION) {
   if(ArrayResize(m_Relations, p_MaxRelations) != -1) {
      PrintFormat("Relation array initialized succesfully with size %d", GetMaxSignals());
   } else {
      Print("Relation array initialization failed with error %", GetLastError());
   }
}

void RelationManager::UpdateRelation(const bool p_IsNewRelation, const datetime p_Time, const double p_Value) {
	const int _SignalPointer = GetSignalPointer();

   if(p_IsNewRelation) {
      m_Relations[_SignalPointer] = Signal(StringFormat("%s_%d", GetManagerId(), _SignalPointer), p_Time, p_Value);
   } else {
      m_Relations[_SignalPointer].SetEnd(p_Time, p_Value);
   } 
}

Relation::State RelationManager::AnalyzeByValueComparer(const datetime p_Time, double &p_ValuesA[], double &p_ValuesB[], Relation::Type p_RequiredABRelation) {
   const Relation::State _PreviousState = m_CurrState;
   
   if((m_CurrState = GetStateByValueComparer(p_ValuesA, p_ValuesB, p_RequiredABRelation)) != Relation::State::INVALID_RELATION) {
      //if(_PreviousState != m_CurrState) { // Is new Relation?
         SelectNextSignal();
      //} 
      
      UpdateRelation(/*_PreviousState != m_CurrState*/ true, p_Time, Bid);
   }
   
   return(m_CurrState);
}

Relation::State RelationManager::GetStateByValueComparer(double &p_ValuesA[], double &p_ValuesB[], Relation::Type p_RequiredType) {
   Relation::State _RelationState = Relation::State::VALID_RELATION;
   
   for(uint i = 0; i < (uint)ArraySize(p_ValuesA) && i < (uint)ArraySize(p_ValuesB) && _RelationState == Relation::State::VALID_RELATION; ++i) {
      switch(p_RequiredType) {
         case Relation::Type::IS_LOWER: {
            if(p_ValuesA[i] >= p_ValuesB[i]) { _RelationState = Relation::State::INVALID_RELATION; }
         
            break;
         }
         case Relation::Type::IS_HIGHER: {
            if(p_ValuesA[i] <= p_ValuesB[i]) { _RelationState = Relation::State::INVALID_RELATION; }
         
            break;
         }
         case Relation::Type::IS_EQUAL: {
            if(p_ValuesA[i] != p_ValuesB[i]) { _RelationState = Relation::State::INVALID_RELATION; }
         
            break;
         }
         case Relation::Type::IS_LOWER_OR_EQUAL: {
            if(p_ValuesA[i] > p_ValuesB[i]) { _RelationState = Relation::State::INVALID_RELATION; }
         
            break;
         }
         case Relation::Type::IS_HIGHER_OR_EQUAL: {
            if(p_ValuesA[i] < p_ValuesB[i]) { _RelationState = Relation::State::INVALID_RELATION; }
         
            break;
         }
      }
   }
   
   return(_RelationState);
}