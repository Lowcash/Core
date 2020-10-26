//+------------------------------------------------------------------+
//|                                                       _Trade.mqh |
//|                                         Copyright 2020, Lowcash. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lowcash."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <../../../Include/Object.mqh>

class Trade : public CObject {
 public:
 	enum State { ABORTED = -1, PENDING = 0, ORDER = 1, POSITION = 2 };
 private:
 	State m_State;
 	ulong m_Ticket;
 public:
 	Trade(){}
 
 	Trade(const ulong p_Ticket)
 	   : m_State(PENDING) {
 		SetTrade(p_Ticket);
 	}
 	
 	void SetTrade(const ulong p_Ticket) {
 		m_Ticket = p_Ticket;
 	}
 	
 	void SetTrade(const State p_State) {
 		m_State = p_State;
 	}
 	
 	ulong GetTicket() const { return(m_Ticket); }
 	State GetState() const { return(m_State); }
 	
 	void SetState(const State p_State) { m_State = p_State; }
};