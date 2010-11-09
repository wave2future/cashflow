// -*-  Mode:java; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-

package org.tmurakam.cashflow.ui;

import java.lang.Math;

import android.app.*;
import android.os.*;
import android.content.*;
import android.view.*;
import android.widget.*;

import org.tmurakam.cashflow.*;

public class CalculatorActivity extends Activity 
{
	public static final String TAG_VALUE = "value";

	// operation
	enum Operator {
		NONE,
		EQUAL,
		PLUS,
		MINUS,
		MULTIPLY,
		DIVIDE
	};

	// state
	enum State {
		DISPLAY,
		INPUT
	}

	private double value;

	private State state;
	private int decimalPlace; // 現在入力中の小数位

	private double storedValue;
	private Operator storedOperator;

	private TextView numLabel;

	public CalculatorActivity() {
		super();
		allClear();
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.calculator);

		numLabel = (TextView)findViewById(R.id.calcNumLabel);

		value = getIntent().getDoubleExtra(TAG_VALUE, 0);
		updateLabel();
	}

	private void allClear() {
		value = 0.0;
		state = State.DISPLAY;
		decimalPlace = 0;
		storedOperator = Operator.NONE;
		storedValue = 0.0;
	}

	///- Button event handlers

	public void onClickDone(View v) {
		onInputOperator(Operator.EQUAL);

		Intent i = new Intent();
		i.putExtra(TAG_VALUE, value);

		setResult(RESULT_OK, i);
		finish();
	}

	public void onClickClear(View v) {
		allClear();
		updateLabel();
	}

	public void onClickBS(View v) {
		// バックスペース
		if (state == State.INPUT) {
			if (decimalPlace > 0) {
				decimalPlace--;
				roundInputValue(); // TBD
			} else {
				value = Math.floor(value / 10);
			}

			updateLabel();
		}
	}

	public void onClickInv(View v) {
		value = -value;
		updateLabel();
	}

	// 演算子入力
	public void onClickPlus(View v)	    { onInputOperator(Operator.PLUS); }
	public void onClickMinus(View v)	{ onInputOperator(Operator.MINUS); }
	public void onClickMultiply(View v) { onInputOperator(Operator.MULTIPLY); }
	public void onClickDivide(View v)   { onInputOperator(Operator.DIVIDE); }
	public void onClickEqual(View v)	{ onInputOperator(Operator.EQUAL); }

	private void onInputOperator(Operator op) {
		if (state == State.INPUT || op == Operator.EQUAL) {
			// 数値入力中に演算ボタンが押された場合、
			// あるいは = が押された場合 (5x= など)
			// メモリしてある式を計算する
			switch (storedOperator) {
			case PLUS:
				value = storedValue + value;
				break;

			case MINUS:
				value = storedValue - value;
				break;

			case MULTIPLY:
				value = storedValue * value;
				break;

			case DIVIDE:
				if (value == 0.0) {
					// divided by zero error
					value = 0.0;
				} else {
					value = storedValue / value;
				}
				break;
			}

			// 表示中の値を記憶
			storedValue = value;

			// 表示状態に遷移
			state = State.DISPLAY;
			updateLabel();
		}

		// 表示中の場合は、operator を変えるだけ

		if (op == Operator.EQUAL) {
			// '=' を押したら演算終了
			storedOperator = Operator.NONE;
		} else {
			storedOperator = op;
		}
	}

	// 数値入力
	public void onClick0(View v) { onInputNumeric(0); }
	public void onClick1(View v) { onInputNumeric(1); }
	public void onClick2(View v) { onInputNumeric(2); }
	public void onClick3(View v) { onInputNumeric(3); }
	public void onClick4(View v) { onInputNumeric(4); }
	public void onClick5(View v) { onInputNumeric(5); }
	public void onClick6(View v) { onInputNumeric(6); }
	public void onClick7(View v) { onInputNumeric(7); }
	public void onClick8(View v) { onInputNumeric(8); }
	public void onClick9(View v) { onInputNumeric(9); }
	public void onClickPeriod(View v) { onInputNumeric(-1); }

	private void onInputNumeric(int num) {
		if (state == State.DISPLAY) {
			state = State.INPUT; // 入力状態に遷移

			storedValue = value;

			value = 0; // 表示中の値をリセット
			decimalPlace = 0;
		}

		if (num == -1) { // 小数点
			if (decimalPlace == 0) {
				decimalPlace = 1;
			}
		}
		else { // 数値
			if (decimalPlace == 0) {
				// 整数入力
				value = value * 10 + num;
			} else {
				// 小数入力
				double v = (double)num * Math.pow(10, -decimalPlace);
				value += v;

				decimalPlace++;
			}
		}
		 
		updateLabel();
	}

	private void roundInputValue() {
		double v;
		boolean isMinus = false;

		v = value;
		if (v < 0.0) {
			isMinus = true;
			v = -v;
		}

		value = Math.floor(v);
		v -= value; // 小数点以下

		if (decimalPlace >= 2) {
			// decimalPlace 桁以下を落とす
			double k = Math.pow(10, decimalPlace - 1);
			v = Math.floor(v * k) / (double)k;
			value += v;
		}

		if (isMinus) {
			value = -value;
		}
	}

	private void updateLabel() {
		StringBuffer numstr = new StringBuffer();

		// 表示すべき小数点以下の桁数を求める
		int dp = 0;
		double vtmp;

		switch (state) {
		case INPUT:
			dp = decimalPlace - 1;
			break;

		case DISPLAY:
			dp = -1;
			vtmp = value;
			if (vtmp < 0) vtmp = -vtmp;
			vtmp -= (int)vtmp;
			for (int i = 1; i <= 6; i++) {
				vtmp *= 10;
				if ((int)vtmp % 10 != 0) {
					dp = i;
				}
			}
			break;
		}

		if (dp <= 0) {
			numstr.append(String.format("%.0f", value));
		} else {
			String fmt = String.format("%%.%df", dp);
			numstr.append(String.format(fmt, value));
		}

		// カンマを３桁ごとに挿入
		int i = numstr.indexOf(".");
		if (i < 0) { // not found
			i = numstr.length();
		}

		for (i -= 3 ; i > 0; i -= 3) {
			if (value < 0 && i <= 1) break; // '-'記号
			numstr.insert(i, ',');
		}
	
		numLabel.setText(numstr.toString());
	}
}
