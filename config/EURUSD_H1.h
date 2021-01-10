/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_RSI_Params_H1 : RSIParams {
  Indi_RSI_Params_H1() : RSIParams(indi_rsi_defaults, PERIOD_H1) {
    applied_price = (ENUM_APPLIED_PRICE)1;
    period = 12;
    shift = 0;
  }
} indi_rsi_h1;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_RSI_Params_H1 : StgParams {
  // Struct constructor.
  Stg_RSI_Params_H1() : StgParams(stg_rsi_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)30;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)30;
    price_stop_method = 0;
    price_stop_level = (float)15;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_rsi_h1;
