//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_RSI_EURUSD_M15_Params : Stg_RSI_Params {
  void Stg_RSI_EURUSD_M15_Params() {
    symbol = "EURUSD";
    tf = PERIOD_M15;
    RSI_Period = 2;
    RSI_Applied_Price = 3;
    RSI_Shift = 0;
    RSI_TrailingStopMethod = 6;
    RSI_TrailingProfitMethod = 11;
    RSI_SignalOpenLevel = 36;
    RSI_SignalBaseMethod = -63;
    RSI_SignalOpenMethod1 = 389;
    RSI_SignalOpenMethod2 = 0;
    RSI_SignalCloseLevel = 36;
    RSI_SignalCloseMethod1 = 1;
    RSI_SignalCloseMethod2 = 0;
    RSI_MaxSpread = 4;
  }
};