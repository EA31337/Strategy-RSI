/**
 * @file
 * Implements RSI strategy based on Relative Strength Index indicator.
 */

// User input params.
INPUT string __RSI_Parameters__ = "-- RSI strategy params --";  // >>> RSI <<<
INPUT float RSI_LotSize = 0;                                    // Lot size
INPUT int RSI_SignalOpenMethod = 2;                             // Signal open method (-127-127)
INPUT float RSI_SignalOpenLevel = 20.0;                         // Signal open level (-49-49)
INPUT int RSI_SignalOpenFilterMethod = 32;                      // Signal open filter method (0-31)
INPUT int RSI_SignalOpenBoostMethod = 0;                        // Signal open boost method
INPUT int RSI_SignalCloseMethod = 2;                            // Signal close method (-127-127)
INPUT float RSI_SignalCloseLevel = 20.0;                        // Signal close level (-49-49)
INPUT int RSI_PriceStopMethod = 1;                              // Price stop method
INPUT float RSI_PriceStopLevel = 15;                            // Price stop level
INPUT int RSI_TickFilterMethod = 1;                             // Tick filter method
INPUT float RSI_MaxSpread = 4.0;                                // Max spread to trade (pips)
INPUT short RSI_Shift = 0;                                      // Shift
INPUT int RSI_OrderCloseTime = -20;                             // Order close time in mins (>0) or bars (<0)
INPUT string __RSI_Indi_RSI_Parameters__ =
    "-- RSI strategy: RSI indicator params --";                               // >>> RSI strategy: RSI indicator <<<
INPUT int RSI_Indi_RSI_Period = 12;                                           // Period
INPUT ENUM_APPLIED_PRICE RSI_Indi_RSI_Applied_Price = (ENUM_APPLIED_PRICE)0;  // Applied Price
INPUT int RSI_Indi_RSI_Shift = 0;                                             // Shift

// Structs.

// Defines struct with default user indicator values.
struct Indi_RSI_Params_Defaults : RSIParams {
  Indi_RSI_Params_Defaults() : RSIParams(::RSI_Indi_RSI_Period, ::RSI_Indi_RSI_Applied_Price, ::RSI_Indi_RSI_Shift) {}
} indi_rsi_defaults;

// Defines struct with default user strategy values.
struct Stg_RSI_Params_Defaults : StgParams {
  Stg_RSI_Params_Defaults()
      : StgParams(::RSI_SignalOpenMethod, ::RSI_SignalOpenFilterMethod, ::RSI_SignalOpenLevel,
                  ::RSI_SignalOpenBoostMethod, ::RSI_SignalCloseMethod, ::RSI_SignalCloseLevel, ::RSI_PriceStopMethod,
                  ::RSI_PriceStopLevel, ::RSI_TickFilterMethod, ::RSI_MaxSpread, ::RSI_Shift, ::RSI_OrderCloseTime) {}
} stg_rsi_defaults;

// Struct to define strategy parameters to override.
struct Stg_RSI_Params : StgParams {
  RSIParams iparams;
  StgParams sparams;

  // Struct constructors.
  Stg_RSI_Params(RSIParams &_iparams, StgParams &_sparams)
      : iparams(indi_rsi_defaults, _iparams.tf.GetTf()), sparams(stg_rsi_defaults) {
    iparams = _iparams;
    sparams = _sparams;
  }
};

// Loads pair specific param values.
#include "config/EURUSD_H1.h"
#include "config/EURUSD_H4.h"
#include "config/EURUSD_H8.h"
#include "config/EURUSD_M1.h"
#include "config/EURUSD_M15.h"
#include "config/EURUSD_M30.h"
#include "config/EURUSD_M5.h"

class Stg_RSI : public Strategy {
 public:
  Stg_RSI(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_RSI *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    RSIParams _indi_params(indi_rsi_defaults, _tf);
    StgParams _stg_params(stg_rsi_defaults);
#ifdef __config__
    SetParamsByTf<RSIParams>(_indi_params, _tf, indi_rsi_m1, indi_rsi_m5, indi_rsi_m15, indi_rsi_m30, indi_rsi_h1,
                             indi_rsi_h4, indi_rsi_h8);
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_rsi_m1, stg_rsi_m5, stg_rsi_m15, stg_rsi_m30, stg_rsi_h1, stg_rsi_h4,
                             stg_rsi_h8);
#endif
    // Initialize indicator.
    RSIParams rsi_params(_indi_params);
    _stg_params.SetIndicator(new Indi_RSI(_indi_params));
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams(_magic_no, _log_level);
    Strategy *_strat = new Stg_RSI(_stg_params, _tparams, _cparams, "RSI");
    return _strat;
  }

  /**
   * Executes on new time periods.
   */
  void OnPeriod(unsigned int _periods = DATETIME_NONE) {
    if ((_periods & DATETIME_MINUTE) != 0) {
      // New minute started.
    }
    if ((_periods & DATETIME_HOUR) != 0) {
      // New hour started.
    }
    if ((_periods & DATETIME_DAY) != 0) {
      // New day started.
      // Clear indicator cached values older than a day.
      long _prev_day_time = trade.GetChart().GetBarTime(PERIOD_D1, 1);
      GetIndicator().ExecuteAction(INDI_ACTION_CLEAR_CACHE, _prev_day_time);
    }
    if ((_periods & DATETIME_WEEK) != 0) {
      // New week started.
    }
    if ((_periods & DATETIME_MONTH) != 0) {
      // New month started.
    }
    if ((_periods & DATETIME_YEAR) != 0) {
      // New year started.
    }
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    Indi_RSI *_indi = GetIndicator();
    bool _result = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    IndicatorSignal _signals = _indi.GetSignals(4, _shift);
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result &= _indi[_shift][0] > (50 - _level) && _indi[_shift + 1][0] < (50 - _level);
        _result &= _indi.IsIncreasing(2, 0, _shift);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
      case ORDER_TYPE_SELL:
        _result &= _indi[_shift][0] < (50 + _level) && _indi[_shift + 1][0] > (50 + _level);
        _result &= _indi.IsDecreasing(2, 0, _shift);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
    }
    return _result;
  }
};
