/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_RSI_Params_M5 : RSIParams {
  Indi_RSI_Params_M5() : RSIParams(indi_rsi_defaults, PERIOD_M5) {
    applied_price = (ENUM_APPLIED_PRICE)0;
    period = 12;
    shift = 0;
  }
} indi_rsi_m5;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_RSI_Params_M5 : StgParams {
  // Struct constructor.
  Stg_RSI_Params_M5() : StgParams(stg_rsi_defaults) {
    lot_size = 0;
    signal_open_method = 1;
    signal_open_filter = 4;
    signal_open_level = (float)20;
    signal_open_boost = 0;
    signal_close_method = 4;
    signal_close_level = (float)20;
    price_stop_method = 1;
    price_stop_level = (float)25;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_rsi_m5;
