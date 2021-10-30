/**
 * @file
 * Implements RSI strategy based on Relative Strength Index indicator.
 */

// User input params.
INPUT_GROUP("RSI strategy: strategy params");
INPUT float RSI_LotSize = 0;                // Lot size
INPUT int RSI_SignalOpenMethod = 0;         // Signal open method (-127-127)
INPUT float RSI_SignalOpenLevel = 24.0;     // Signal open level (-49-49)
INPUT int RSI_SignalOpenFilterMethod = 32;  // Signal open filter method (0-31)
INPUT int RSI_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT int RSI_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int RSI_SignalCloseMethod = 0;        // Signal close method (-127-127)
INPUT int RSI_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT float RSI_SignalCloseLevel = 24.0;    // Signal close level (-49-49)
INPUT int RSI_PriceStopMethod = 1;          // Price stop method (0-127)
INPUT float RSI_PriceStopLevel = 2;         // Price stop level
INPUT int RSI_TickFilterMethod = 32;        // Tick filter method
INPUT float RSI_MaxSpread = 4.0;            // Max spread to trade (pips)
INPUT short RSI_Shift = 0;                  // Shift
INPUT float RSI_OrderCloseLoss = 80;        // Order close loss
INPUT float RSI_OrderCloseProfit = 80;      // Order close profit
INPUT int RSI_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("RSI strategy: RSI indicator params");
INPUT int RSI_Indi_RSI_Period = 16;                                    // Period
INPUT ENUM_APPLIED_PRICE RSI_Indi_RSI_Applied_Price = PRICE_WEIGHTED;  // Applied Price
INPUT int RSI_Indi_RSI_Shift = 0;                                      // Shift

// Structs.

// Defines struct with default user strategy values.
struct Stg_RSI_Params_Defaults : StgParams {
  Stg_RSI_Params_Defaults()
      : StgParams(::RSI_SignalOpenMethod, ::RSI_SignalOpenFilterMethod, ::RSI_SignalOpenLevel,
                  ::RSI_SignalOpenBoostMethod, ::RSI_SignalCloseMethod, ::RSI_SignalCloseFilter, ::RSI_SignalCloseLevel,
                  ::RSI_PriceStopMethod, ::RSI_PriceStopLevel, ::RSI_TickFilterMethod, ::RSI_MaxSpread, ::RSI_Shift) {
    Set(STRAT_PARAM_LS, RSI_LotSize);
    Set(STRAT_PARAM_OCL, RSI_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, RSI_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, RSI_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, RSI_SignalOpenFilterTime);
  }
};

#ifdef __config__
// Loads pair specific param values.
#include "config/H1.h"
#include "config/H4.h"
#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"
#endif

class Stg_RSI : public Strategy {
 public:
  Stg_RSI(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_RSI *Init(ENUM_TIMEFRAMES _tf = NULL) {
    // Initialize strategy initial values.
    Stg_RSI_Params_Defaults stg_rsi_defaults;
    StgParams _stg_params(stg_rsi_defaults);
#ifdef __config__
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_rsi_m1, stg_rsi_m5, stg_rsi_m15, stg_rsi_m30, stg_rsi_h1, stg_rsi_h4,
                             stg_rsi_h8);
#endif
    // Initialize indicator.
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_RSI(_stg_params, _tparams, _cparams, "RSI");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    IndiRSIParams _indi_params(::RSI_Indi_RSI_Period, ::RSI_Indi_RSI_Applied_Price, ::RSI_Indi_RSI_Shift);
    _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
    SetIndicator(new Indi_RSI(_indi_params));
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    Indi_RSI *_indi = GetIndicator();
    bool _result =
        _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift) && _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift + 1);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    IndicatorSignal _signals = _indi.GetSignals(4, _shift);
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result &= _indi[_shift][0] < (50 - _level);
        _result &= _indi.IsIncreasing(1, 0, _shift);
        _result &= _indi.IsIncByPct(_level / 10, 0, _shift, 2);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
      case ORDER_TYPE_SELL:
        _result &= _indi[_shift][0] > (50 + _level);
        _result &= _indi.IsDecreasing(1, 0, _shift);
        _result &= _indi.IsDecByPct(_level / 10, 0, _shift, 2);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
    }
    return _result;
  }
};
