/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_RSI_Params_H4 : IndiRSIParams {
  Indi_RSI_Params_H4() : IndiRSIParams(indi_rsi_defaults, PERIOD_H4) {
    applied_price = (ENUM_APPLIED_PRICE)1;
    period = 12;
    shift = 0;
  }
} indi_rsi_h4;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_RSI_Params_H4 : StgParams {
  // Struct constructor.
  Stg_RSI_Params_H4() : StgParams(stg_rsi_defaults) {
    lot_size = 0;
    signal_open_method = 2;
    signal_open_level = (float)1;
    signal_open_boost = 0;
    signal_close_method = 2;
    signal_close_level = (float)0;
    price_profit_method = 60;
    price_profit_level = (float)1;
    price_stop_method = 60;
    price_stop_level = (float)16;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_rsi_h4;
