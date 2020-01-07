//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_RSI_EURUSD_H1_Params : Stg_RSI_Params {
  void Stg_RSI_EURUSD_H1_Params() {
    symbol = "EURUSD";
    tf = PERIOD_H1;
    RSI_Period = 2;
    RSI_Applied_Price = 3;
    RSI_Shift = 0;
    RSI_TrailingStopMethod = 6;
    RSI_TrailingProfitMethod = 11;
    RSI_SignalLevel1 = 36;
    RSI_SignalLevel2 = 36;
    RSI_SignalBaseMethod = 0;
    RSI_SignalOpenMethod1 = 195;
    RSI_SignalOpenMethod2 = 0;
    RSI_SignalCloseMethod1 = 1;
    RSI_SignalCloseMethod2 = 0;
    RSI_MaxSpread = 6;
  }
};