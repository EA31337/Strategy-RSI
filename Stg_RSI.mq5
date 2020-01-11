//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements RSI strategy based on Relative Strength Index indicator.
 */

// Includes.
#include <EA31337-classes/EA.mqh>
#include "Stg_RSI.mqh"

// Inputs.
input int Active_Tf = 127;                // Activated timeframes (1-255) [M1=1,M5=2,M15=4,M30=8,H1=16,H2=32,H4=64...]
input ENUM_LOG_LEVEL Log_Level = V_INFO;  // Log level.
input bool Info_On_Chart = true;          // Display info on chart.

// Defines.
#define ea_name "Stg_RSI"
#define ea_version "1.000"
#define ea_desc "Multi-strategy advanced trading robot"
#define ea_link "https://github.com/EA31337/Strategy-RSI"
#define ea_author "kenorb"

// Properties.
#property version ea_version
#ifdef __MQL4__
#property description ea_name
#property description ea_desc
#endif
#property link ea_link
#property copyright "Copyright 2016-2019, 31337 Investments Ltd"

// Class variables.
EA *ea;

/* EA event handler functions */

/**
 * Implements "Init" event handler function.
 */
int OnInit() {
  bool _result = true;
  // Initialize EA.
  EAParams ea_params(__FILE__, Log_Level);
  ea_params.SetChartInfoFreq(Info_On_Chart ? 2 : 0);
  ea = new EA(ea_params);
  // Initialize strategy.
  Collection *_strats = ea.Strategies();
  if ((Active_Tf & M1B) == M1B) _strats.Add(Stg_RSI::Init(PERIOD_M1));
  if ((Active_Tf & M5B) == M5B) _strats.Add(Stg_RSI::Init(PERIOD_M5));
  if ((Active_Tf & M15B) == M15B) _strats.Add(Stg_RSI::Init(PERIOD_M15));
  if ((Active_Tf & M30B) == M30B) _strats.Add(Stg_RSI::Init(PERIOD_M30));
  if ((Active_Tf & H1B) == H1B) _strats.Add(Stg_RSI::Init(PERIOD_H1));
  if ((Active_Tf & H4B) == H4B) _strats.Add(Stg_RSI::Init(PERIOD_H4));
  return (_result ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements "Tick" event handler function (EA only).
 *
 * Invoked when a new tick for a symbol is received, to the chart of which the Expert Advisor is attached.
 */
void OnTick() {
  ea.Process();
  if (!ea.Terminal().IsOptimization()) {
    ea.Log().Flush(2);
    ea.UpdateInfoOnChart();
  }
}

/**
 * Implements "Deinit" event handler function.
 */
void OnDeinit(const int reason) { Object::Delete(ea); }