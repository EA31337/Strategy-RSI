/**
 * @file
 * Implements RSI strategy based on Relative Strength Index indicator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_RSI.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT float RSI_LotSize = 0;                // Lot size
INPUT int RSI_SignalOpenMethod = 0;         // Signal open method (-63-63)
INPUT float RSI_SignalOpenLevel = 36;       // Signal open level (-49-49)
INPUT int RSI_SignalOpenFilterMethod = 36;  // Signal open filter method (-49-49)
INPUT int RSI_SignalOpenBoostMethod = 36;   // Signal open boost method (-49-49)
INPUT int RSI_SignalCloseMethod = 0;        // Signal close method (-63-63)
INPUT float RSI_SignalCloseLevel = 36;      // Signal close level (-49-49)
INPUT int RSI_PriceLimitMethod = 0;         // Price limit method
INPUT float RSI_PriceLimitLevel = 15;       // Price limit level
INPUT int RSI_TickFilterMethod = 0;         // Tick filter method
INPUT float RSI_MaxSpread = 0;              // Max spread to trade (pips)
INPUT int RSI_Shift = 0;                    // Shift
INPUT string __RSI_Indi_RSI_Parameters__ =
    "-- RSI strategy: RSI indicator params --";       // >>> RSI strategy: RSI indicator <<<
INPUT int Indi_RSI_Period = 2;                        // Period
INPUT ENUM_APPLIED_PRICE Indi_RSI_Applied_Price = 3;  // Applied Price

// Structs.

// Defines struct with default user indicator values.
struct Indi_RSI_Params_Defaults : RSIParams {
  Indi_RSI_Params_Defaults() : RSIParams(::Indi_RSI_Period, ::Indi_RSI_Applied_Price) {}
} indi_rsi_defaults;

// Defines struct to store indicator parameter values.
struct Indi_RSI_Params : public RSIParams {
  // Struct constructors.
  void Indi_RSI_Params(RSIParams &_params, ENUM_TIMEFRAMES _tf) : RSIParams(_params, _tf) {}
};

// Defines struct with default user strategy values.
struct Stg_RSI_Params_Defaults : StgParams {
  Stg_RSI_Params_Defaults()
      : StgParams(::RSI_SignalOpenMethod, ::RSI_SignalOpenFilterMethod, ::RSI_SignalOpenLevel,
                  ::RSI_SignalOpenBoostMethod, ::RSI_SignalCloseMethod, ::RSI_SignalCloseLevel, ::RSI_PriceLimitMethod,
                  ::RSI_PriceLimitLevel, ::RSI_TickFilterMethod, ::RSI_MaxSpread, ::RSI_Shift) {}
} stg_rsi_defaults;

// Struct to define strategy parameters to override.
struct Stg_RSI_Params : StgParams {
  Indi_RSI_Params iparams;
  StgParams sparams;

  // Struct constructors.
  Stg_RSI_Params(Indi_RSI_Params &_iparams, StgParams &_sparams)
      : iparams(indi_rsi_defaults, _iparams.tf), sparams(stg_rsi_defaults) {
    iparams = _iparams;
    sparams = _sparams;
  }
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_H8.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_RSI : public Strategy {
 public:
  Stg_RSI(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_RSI *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Indi_RSI_Params _indi_params(indi_rsi_defaults, _tf);
    StgParams _stg_params(stg_rsi_defaults);
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Indi_RSI_Params>(_indi_params, _tf, indi_rsi_m1, indi_rsi_m5, indi_rsi_m15, indi_rsi_m30,
                                     indi_rsi_h1, indi_rsi_h4, indi_rsi_h8);
      SetParamsByTf<StgParams>(_stg_params, _tf, stg_rsi_m1, stg_rsi_m5, stg_rsi_m15, stg_rsi_m30, stg_rsi_h1,
                               stg_rsi_h4, stg_rsi_h8);
    }
    // Initialize indicator.
    RSIParams rsi_params(_indi_params);
    _stg_params.SetIndicator(new Indi_RSI(_indi_params));
    // Initialize strategy parameters.
    _stg_params.GetLog().SetLevel(_log_level);
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_RSI(_stg_params, "RSI");
    _stg_params.SetStops(_strat, _strat);
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0) {
    Indi_RSI *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    bool _result = _is_valid;
    if (_is_valid) {
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          _result = _indi[CURR].value[0] < (50 - _level);
          if (_method != 0) {
            if (METHOD(_method, 0)) _result &= _indi[CURR].value[0] < _indi[PREV].value[0];
            if (METHOD(_method, 1)) _result &= _indi[PREV].value[0] < _indi[PPREV].value[0];
            if (METHOD(_method, 2)) _result &= _indi[PREV].value[0] < (50 - _level);
            if (METHOD(_method, 3)) _result &= _indi[PPREV].value[0] < (50 - _level);
            if (METHOD(_method, 4))
              _result &= _indi[CURR].value[0] - _indi[PREV].value[0] > _indi[PREV].value[0] - _indi[PPREV].value[0];
            if (METHOD(_method, 5)) _result &= _indi[PPREV].value[0] > 50;
          }
          break;
        case ORDER_TYPE_SELL:
          _result = _indi[CURR].value[0] > (50 + _level);
          if (_method != 0) {
            if (METHOD(_method, 0)) _result &= _indi[CURR].value[0] > _indi[PREV].value[0];
            if (METHOD(_method, 1)) _result &= _indi[PREV].value[0] > _indi[PPREV].value[0];
            if (METHOD(_method, 2)) _result &= _indi[PREV].value[0] > (50 + _level);
            if (METHOD(_method, 3)) _result &= _indi[PPREV].value[0] > (50 + _level);
            if (METHOD(_method, 4))
              _result &= _indi[PREV].value[0] - _indi[CURR].value[0] > _indi[PPREV].value[0] - _indi[PREV].value[0];
            if (METHOD(_method, 5)) _result &= _indi[PPREV].value[0] < 50;
          }
          break;
      }
    }
    return _result;
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  float PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    Indi_RSI *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    if (_is_valid) {
      switch (_method) {
        case 0: {
          int _bar_count0 = (int)_level * (int)_indi.GetPeriod();
          _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count0))
                                   : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count0));
          break;
        }
        case 1: {
          int _bar_count1 = (int)_level * (int)_indi.GetPeriod() * 2;
          _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count1))
                                   : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count1));
          break;
        }
        case 2: {
          int _bar_count2 = (int)_level * (int)_indi.GetPeriod();
          _result = _direction > 0 ? _indi.GetPrice(_indi.GetAppliedPrice(), _indi.GetHighest(_bar_count2))
                                   : _indi.GetPrice(_indi.GetAppliedPrice(), _indi.GetLowest(_bar_count2));
          break;
        }
        case 3: {
          int _bar_count3 = (int)_level * (int)_indi.GetPeriod() * 2;
          _result = _direction > 0 ? _indi.GetPrice(_indi.GetAppliedPrice(), _indi.GetHighest(_bar_count3))
                                   : _indi.GetPrice(_indi.GetAppliedPrice(), _indi.GetLowest(_bar_count3));
          break;
        }
      }
      _result += _trail * _direction;
    }
    return (float)_result;
  }
};
