//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

/**
 * @file
 * Implementation of RSI Strategy based on the Average True Range indicator (RSI).
 *
 * @docs
 * - https://docs.mql4.com/indicators/iRSI
 * - https://www.mql5.com/en/docs/indicators/iRSI
 */

// Includes.
#include <EA31337-classes\Strategy.mqh>
#include <EA31337-classes\Strategies.mqh>

// User inputs.
#ifdef __input__ input #endif string __RSI_Parameters__ = "-- Settings for the Relative Strength Index indicator --"; // >>> RSI <<<
#ifdef __input__ input #endif int RSI_Period = 21; // Period
#ifdef __input__ input #endif double RSI_Period_Ratio = 1.0; // Period ratio between timeframes (0.5-1.5)
#ifdef __input__ input #endif ENUM_APPLIED_PRICE RSI_Applied_Price = 4; // Applied Price
#ifdef __input__ input #endif int RSI_Shift = -2; // Shift
#ifdef __input__ input #endif int RSI_SignalLevel = 2; // Signal level
#ifdef __input__ input #endif int RSI_SignalMethod = 36; // Signal method for M1 (-63-63)

class RSI: public Strategy {
protected:

  double rsi[H1][3], rsi_stats[H1][3];
  int       open_method = EMPTY;    // Open method.
  double    open_level  = 0.0;     // Open level.

    public:

  /**
   * Update indicator values.
   */
  bool Update(int tf = EMPTY) {
    // Calculates the Relative Strength Index indicator.
    // int rsi_period = RSI_Period; // Not used at the moment.
    // sid = GetStrategyViaIndicator(RSI, tf); rsi_period = info[sid][CUSTOM_PERIOD]; // Not used at the moment.
    ratio = tf == 30 ? 1.0 : fmax(RSI_Period_Ratio, NEAR_ZERO) / tf * 30;
    for (i = 0; i < FINAL_ENUM_INDICATOR_INDEX; i++) {
      rsi[index][i] = iRSI(symbol, tf, (int) (RSI_Period * ratio), RSI_Applied_Price, i + RSI_Shift);
      if (rsi[index][i] > rsi_stats[index][UPPER]) rsi_stats[index][UPPER] = rsi[index][i]; // Calculate maximum value.
      if (rsi[index][i] < rsi_stats[index][LOWER] || rsi_stats[index][LOWER] == 0) rsi_stats[index][LOWER] = rsi[index][i]; // Calculate minimum value.
    }
    // Calculate average value.
    rsi_stats[index][0] = (rsi_stats[index][0] > 0 ? (rsi_stats[index][0] + rsi[index][0] + rsi[index][1] + rsi[index][2]) / 4 : (rsi[index][0] + rsi[index][1] + rsi[index][2]) / 3);
    if (VerboseDebug) PrintFormat("RSI M%d: %s", tf, Arrays::ArrToString2D(rsi, ",", Digits));
    success = (bool) rsi[index][CURR] + rsi[index][PREV] + rsi[index][FAR];
  }

  /**
   * Checks whether signal is on buy.
   *
   * @param
   *   cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   signal_method (int) - signal method to use by using bitwise AND operation
   *   signal_level - signal level to consider the signal
   */
  bool Signal(int cmd, ENUM_TIMEFRAMES tf = PERIOD_M1, int signal_method = EMPTY, double signal_level = EMPTY) {
    bool result = FALSE; int period = Timeframe::TfToIndex(tf);
    UpdateIndicator(S_RSI, tf);
    if (signal_method == EMPTY) signal_method = GetStrategySignalMethod(S_RSI, tf, 0);
    if (signal_level == EMPTY)  signal_level  = GetStrategySignalLevel(S_RSI, tf, 20);
    switch (cmd) {
      case OP_BUY:
        result = rsi[period][CURR] <= (50 - signal_level);
        if ((signal_method &   1) != 0) result &= rsi[period][CURR] < rsi[period][PREV];
        if ((signal_method &   2) != 0) result &= rsi[period][PREV] < rsi[period][FAR];
        if ((signal_method &   4) != 0) result &= rsi[period][PREV] < (50 - signal_level);
        if ((signal_method &   8) != 0) result &= rsi[period][FAR]  < (50 - signal_level);
        if ((signal_method &  16) != 0) result &= rsi[period][CURR] - rsi[period][PREV] > rsi[period][PREV] - rsi[period][FAR];
        if ((signal_method &  32) != 0) result &= rsi[period][FAR] > 50;
        //if ((signal_method &  32) != 0) result &= Open[CURR] > Close[PREV];
        //if ((signal_method & 128) != 0) result &= !RSI_On_Sell(M30);
        break;
      case OP_SELL:
        result = rsi[period][CURR] >= (50 + signal_level);
        if ((signal_method &   1) != 0) result &= rsi[period][CURR] > rsi[period][PREV];
        if ((signal_method &   2) != 0) result &= rsi[period][PREV] > rsi[period][FAR];
        if ((signal_method &   4) != 0) result &= rsi[period][PREV] > (50 + signal_level);
        if ((signal_method &   8) != 0) result &= rsi[period][FAR]  > (50 + signal_level);
        if ((signal_method &  16) != 0) result &= rsi[period][PREV] - rsi[period][CURR] > rsi[period][FAR] - rsi[period][PREV];
        if ((signal_method &  32) != 0) result &= rsi[period][FAR] < 50;
        //if ((signal_method &  32) != 0) result &= Open[CURR] < Close[PREV];
        //if ((signal_method & 128) != 0) result &= !RSI_On_Buy(M30);
        break;
    }
    result &= signal_method <= 0 || Convert::ValueToOp(curr_trend) == cmd;
    if (VerboseTrace && result) {
      PrintFormat("%s:%d: Signal: %d/%d/%d/%g", __FUNCTION__, __LINE__, cmd, tf, signal_method, signal_level);
    }
    return result;
  }
};
