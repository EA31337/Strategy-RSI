//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements RSI strategy.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_RSI.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __RSI_Parameters__ = "-- Settings for the Relative Strength Index indicator --"; // >>> RSI <<<
INPUT uint RSI_Active_Tf = 12; // Activate timeframes (1-255, e.g. M1=1,M5=2,M15=4,M30=8,H1=16,H2=32...)
INPUT int RSI_Period = 2; // Period
INPUT ENUM_APPLIED_PRICE RSI_Applied_Price = 3; // Applied Price
INPUT uint RSI_Shift = 0; // Shift
INPUT ENUM_TRAIL_TYPE RSI_TrailingStopMethod = 6; // Trail stop method
INPUT ENUM_TRAIL_TYPE RSI_TrailingProfitMethod = 11; // Trail profit method
INPUT int RSI_SignalLevel1 = 36; // Signal level 1 (-49-49)
int RSI_SignalLevel2 = 0; // Signal level 2 (-49-49)
INPUT int RSI_SignalBaseMethod = 0; // Signal base method (-63-63)
INPUT int RSI_SignalOpenMethod1 = 0; // Signal open method 1 (0-1023)
int RSI_SignalOpenMethod2 = 0; // Signal open method 2 (0-1023)
INPUT ENUM_MARKET_EVENT RSI_SignalCloseMethod1 = 0; // Signal close method 1
INPUT ENUM_MARKET_EVENT RSI_SignalCloseMethod2 = 0; // Signal close method 2
double RSI_MaxSpread = 0; // Max spread to trade (pips)

// Loads SET files.
#resource "sets/EURUSD_M1.set" as string Stg_RSI_EURUSD_M1
#resource "sets/EURUSD_M5.set" as string Stg_RSI_EURUSD_M5
#resource "sets/EURUSD_M15.set" as string Stg_RSI_EURUSD_M15
#resource "sets/EURUSD_M30.set" as string Stg_RSI_EURUSD_M30
#resource "sets/EURUSD_H1.set" as string Stg_RSI_EURUSD_H1
#resource "sets/EURUSD_H4.set" as string Stg_RSI_EURUSD_H4

class Stg_RSI : public Strategy {

  public:

  void Stg_RSI(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_RSI *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    ChartParams cparams(_tf);
    RSI_Params rsi_params(RSI_Period, RSI_Applied_Price);
    IndicatorParams rsi_iparams(10, INDI_RSI);
    StgParams rsi_sparams(new Trade(_tf, _Symbol), new Indi_RSI(rsi_params, rsi_iparams, cparams), NULL, NULL);
    rsi_sparams.logger.SetLevel(_log_level);
    rsi_sparams.SetMagicNo(_magic_no);
    rsi_sparams.SetSignals(RSI_SignalBaseMethod, RSI_SignalOpenMethod1, RSI_SignalOpenMethod2, RSI_SignalCloseMethod1, RSI_SignalCloseMethod2, RSI_SignalLevel1, RSI_SignalLevel2);
    rsi_sparams.SetStops(RSI_TrailingProfitMethod, RSI_TrailingStopMethod);
    rsi_sparams.SetMaxSpread(RSI_MaxSpread);
    return (new Stg_RSI(rsi_sparams, "RSI"));
  }

  /**
   * Check if RSI indicator is on buy/sell.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   _signal_method (int) - signal method to use by using bitwise AND operation
   *   _signal_level1 - 1st signal level to consider the signal
   *   _signal_level2 - 2nd signal level to consider the signal
   * @result bool
   * Returns true on signal for the given _cmd, otherwise false.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level1 = EMPTY, double _signal_level2 = EMPTY) {
    bool _result = false;
    double rsi_0 = ((Indi_RSI *) this.Data()).GetValue(0);
    double rsi_1 = ((Indi_RSI *) this.Data()).GetValue(1);
    double rsi_2 = ((Indi_RSI *) this.Data()).GetValue(2);
    if (_signal_method == EMPTY) _signal_method = GetSignalBaseMethod();
    if (_signal_level1 == EMPTY) _signal_level1 = GetSignalLevel1();
    if (_signal_level2 == EMPTY) _signal_level2 = GetSignalLevel2();
    bool is_valid = fmin(fmin(rsi_0, rsi_1), rsi_2) > 0;
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result = rsi_0 > 0 && rsi_0 < (50 - _signal_level1);
        if (_signal_method != 0) {
          _result &= is_valid;
          if (METHOD(_signal_method, 0)) _result &= rsi_0 < rsi_1;
          if (METHOD(_signal_method, 1)) _result &= rsi_1 < rsi_2;
          if (METHOD(_signal_method, 2)) _result &= rsi_1 < (50 - _signal_level1);
          if (METHOD(_signal_method, 3)) _result &= rsi_2  < (50 - _signal_level1);
          if (METHOD(_signal_method, 4)) _result &= rsi_0 - rsi_1 > rsi_1 - rsi_2;
          if (METHOD(_signal_method, 5)) _result &= rsi_2 > 50;
        }
        break;
      case ORDER_TYPE_SELL:
        _result = rsi_0 > 0 && rsi_0 > (50 + _signal_level1);
        if (_signal_method != 0) {
          _result &= is_valid;
          if (METHOD(_signal_method, 0)) _result &= rsi_0 > rsi_1;
          if (METHOD(_signal_method, 1)) _result &= rsi_1 > rsi_2;
          if (METHOD(_signal_method, 2)) _result &= rsi_1 > (50 + _signal_level1);
          if (METHOD(_signal_method, 3)) _result &= rsi_2  > (50 + _signal_level1);
          if (METHOD(_signal_method, 4)) _result &= rsi_1 - rsi_0 > rsi_2 - rsi_1;
          if (METHOD(_signal_method, 5)) _result &= rsi_2 < 50;
        }
        break;
    }
    return _result;
  }

};