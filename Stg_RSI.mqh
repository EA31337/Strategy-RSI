//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 *   Implements RSI strategy based on Relative Strength Index indicator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_RSI.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __RSI_Parameters__ = "-- RSI strategy params --";  // >>> RSI <<<
INPUT int RSI_Active_Tf = 127;  // Activated timeframes (1-255) [M1=1,M5=2,M15=4,M30=8,H1=16,H2=32,H4=64...]
INPUT int RSI_Period = 2;       // Period
INPUT ENUM_APPLIED_PRICE RSI_Applied_Price = 3;       // Applied Price
INPUT int RSI_Shift = 0;                              // Shift
INPUT ENUM_TRAIL_TYPE RSI_TrailingStopMethod = 6;     // Trail stop method
INPUT ENUM_TRAIL_TYPE RSI_TrailingProfitMethod = 11;  // Trail profit method
INPUT double RSI_SignalOpenLevel = 36;                // Signal open level (-49-49)
INPUT long RSI_SignalBaseMethod = 0;                  // Signal base method (-63-63)
INPUT long RSI_SignalOpenMethod1 = 0;                 // Signal open method 1 (0-1023)
INPUT long RSI_SignalOpenMethod2 = 0;                 // Signal open method 2 (0-1023)
INPUT double RSI_SignalCloseLevel = 36;               // Signal close level (-49-49)
INPUT ENUM_MARKET_EVENT RSI_SignalCloseMethod1 = 0;   // Signal close method 1
INPUT ENUM_MARKET_EVENT RSI_SignalCloseMethod2 = 0;   // Signal close method 2
INPUT double RSI_MaxSpread = 0;                       // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_RSI_Params : Stg_Params {
  unsigned int RSI_Period;
  ENUM_APPLIED_PRICE RSI_Applied_Price;
  int RSI_Shift;
  ENUM_TRAIL_TYPE RSI_TrailingStopMethod;
  ENUM_TRAIL_TYPE RSI_TrailingProfitMethod;
  double RSI_SignalOpenLevel;
  long RSI_SignalBaseMethod;
  long RSI_SignalOpenMethod1;
  long RSI_SignalOpenMethod2;
  double RSI_SignalCloseLevel;
  ENUM_MARKET_EVENT RSI_SignalCloseMethod1;
  ENUM_MARKET_EVENT RSI_SignalCloseMethod2;
  double RSI_MaxSpread;

  // Constructor: Set default param values.
  Stg_RSI_Params()
      : RSI_Period(::RSI_Period),
        RSI_Applied_Price(::RSI_Applied_Price),
        RSI_Shift(::RSI_Shift),
        RSI_TrailingStopMethod(::RSI_TrailingStopMethod),
        RSI_TrailingProfitMethod(::RSI_TrailingProfitMethod),
        RSI_SignalOpenLevel(::RSI_SignalOpenLevel),
        RSI_SignalBaseMethod(::RSI_SignalBaseMethod),
        RSI_SignalOpenMethod1(::RSI_SignalOpenMethod1),
        RSI_SignalOpenMethod2(::RSI_SignalOpenMethod2),
        RSI_SignalCloseLevel(::RSI_SignalCloseLevel),
        RSI_SignalCloseMethod1(::RSI_SignalCloseMethod1),
        RSI_SignalCloseMethod2(::RSI_SignalCloseMethod2),
        RSI_MaxSpread(::RSI_MaxSpread) {}
  void Init() {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_RSI : public Strategy {
 public:
  Stg_RSI(StgParams &_params, string _name) : Strategy(_params, _name) {}

  /**
   * Initialize strategy's instance.
   */
  static Stg_RSI *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_RSI_Params _params;
    switch (_tf) {
      case PERIOD_M1: {
        Stg_RSI_EURUSD_M1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M5: {
        Stg_RSI_EURUSD_M5_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M15: {
        Stg_RSI_EURUSD_M15_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M30: {
        Stg_RSI_EURUSD_M30_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H1: {
        Stg_RSI_EURUSD_H1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H4: {
        Stg_RSI_EURUSD_H4_Params _new_params;
        _params = _new_params;
      }
    }
    // Initialize strategy parameters.
    ChartParams cparams(_tf);
    RSI_Params rsi_params(_params.RSI_Period, _params.RSI_Applied_Price);
    IndicatorParams rsi_iparams(10, INDI_RSI);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_RSI(rsi_params, rsi_iparams, cparams), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.RSI_SignalBaseMethod, _params.RSI_SignalOpenMethod1, _params.RSI_SignalOpenMethod2,
                       _params.RSI_SignalCloseMethod1, _params.RSI_SignalCloseMethod2, _params.RSI_SignalOpenLevel,
                       _params.RSI_SignalCloseLevel);
    sparams.SetStops(_params.RSI_TrailingProfitMethod, _params.RSI_TrailingStopMethod);
    sparams.SetMaxSpread(_params.RSI_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_RSI(sparams, "RSI");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, long _method, double _level) {
    bool _result = false;
    double rsi_0 = ((Indi_RSI *)this.Data()).GetValue(0);
    double rsi_1 = ((Indi_RSI *)this.Data()).GetValue(1);
    double rsi_2 = ((Indi_RSI *)this.Data()).GetValue(2);
    bool is_valid = fmin(fmin(rsi_0, rsi_1), rsi_2) > 0;
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result = rsi_0 > 0 && rsi_0 < (50 - _level);
        if (_method != 0) {
          _result &= is_valid;
          if (METHOD(_method, 0)) _result &= rsi_0 < rsi_1;
          if (METHOD(_method, 1)) _result &= rsi_1 < rsi_2;
          if (METHOD(_method, 2)) _result &= rsi_1 < (50 - _level);
          if (METHOD(_method, 3)) _result &= rsi_2 < (50 - _level);
          if (METHOD(_method, 4)) _result &= rsi_0 - rsi_1 > rsi_1 - rsi_2;
          if (METHOD(_method, 5)) _result &= rsi_2 > 50;
        }
        break;
      case ORDER_TYPE_SELL:
        _result = rsi_0 > 0 && rsi_0 > (50 + _level);
        if (_method != 0) {
          _result &= is_valid;
          if (METHOD(_method, 0)) _result &= rsi_0 > rsi_1;
          if (METHOD(_method, 1)) _result &= rsi_1 > rsi_2;
          if (METHOD(_method, 2)) _result &= rsi_1 > (50 + _level);
          if (METHOD(_method, 3)) _result &= rsi_2 > (50 + _level);
          if (METHOD(_method, 4)) _result &= rsi_1 - rsi_0 > rsi_2 - rsi_1;
          if (METHOD(_method, 5)) _result &= rsi_2 < 50;
        }
        break;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, long _method, double _level) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level);
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  double PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_STG_PRICE_LIMIT_MODE _mode, long _method = 0, double _level = 0.0) {
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd) * (_mode == LIMIT_VALUE_STOP ? -1 : 1);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch ((int) _method) {
      case 0: {
        // @todo
      }
    }
    return _result;
  }
};