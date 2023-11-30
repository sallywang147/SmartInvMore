type Ref;
type ContractName;
const unique null: Ref;
const unique IERC20: ContractName;
const unique VeriSol: ContractName;
const unique SafeMath: ContractName;
const unique visor2: ContractName;
function ConstantToRef(x: int) returns (ret: Ref);
function BoogieRefToInt(x: Ref) returns (ret: int);
function {:bvbuiltin "mod"} modBpl(x: int, y: int) returns (ret: int);
function keccak256(x: int) returns (ret: int);
function abiEncodePacked1(x: int) returns (ret: int);
function _SumMapping_VeriSol(x: [Ref]int) returns (ret: int);
function abiEncodePacked2(x: int, y: int) returns (ret: int);
function abiEncodePacked1R(x: Ref) returns (ret: int);
function abiEncodePacked2R(x: Ref, y: int) returns (ret: int);
var Balance: [Ref]int;
var DType: [Ref]ContractName;
var Alloc: [Ref]bool;
var balance_ADDR: [Ref]int;
var M_Ref_int: [Ref][Ref]int;
var M_int_Ref: [Ref][int]Ref;
var Length: [Ref]int;
var now: int;
procedure {:inline 1} FreshRefGenerator() returns (newRef: Ref);
implementation FreshRefGenerator() returns (newRef: Ref)
{
havoc newRef;
assume ((Alloc[newRef]) == (false));
Alloc[newRef] := true;
assume ((newRef) != (null));
}

procedure {:inline 1} HavocAllocMany();
implementation HavocAllocMany()
{
var oldAlloc: [Ref]bool;
oldAlloc := Alloc;
havoc Alloc;
assume (forall  __i__0_0:Ref ::  ((oldAlloc[__i__0_0]) ==> (Alloc[__i__0_0])));
}

procedure boogie_si_record_sol2Bpl_int(x: int);
procedure boogie_si_record_sol2Bpl_ref(x: Ref);
procedure boogie_si_record_sol2Bpl_bool(x: bool);

axiom(forall  __i__0_0:int, __i__0_1:int :: {ConstantToRef(__i__0_0), ConstantToRef(__i__0_1)} (((__i__0_0) == (__i__0_1)) || ((ConstantToRef(__i__0_0)) != (ConstantToRef(__i__0_1)))));

axiom(forall  __i__0_0:int, __i__0_1:int :: {keccak256(__i__0_0), keccak256(__i__0_1)} (((__i__0_0) == (__i__0_1)) || ((keccak256(__i__0_0)) != (keccak256(__i__0_1)))));

axiom(forall  __i__0_0:int, __i__0_1:int :: {abiEncodePacked1(__i__0_0), abiEncodePacked1(__i__0_1)} (((__i__0_0) == (__i__0_1)) || ((abiEncodePacked1(__i__0_0)) != (abiEncodePacked1(__i__0_1)))));

axiom(forall  __i__0_0:[Ref]int ::  ((exists __i__0_1:Ref ::  ((__i__0_0[__i__0_1]) != (0))) || ((_SumMapping_VeriSol(__i__0_0)) == (0))));

axiom(forall  __i__0_0:[Ref]int, __i__0_1:Ref, __i__0_2:int ::  ((_SumMapping_VeriSol(__i__0_0[__i__0_1 := __i__0_2])) == (((_SumMapping_VeriSol(__i__0_0)) - (__i__0_0[__i__0_1])) + (__i__0_2))));

axiom(forall  __i__0_0:int, __i__0_1:int, __i__1_0:int, __i__1_1:int :: {abiEncodePacked2(__i__0_0, __i__1_0), abiEncodePacked2(__i__0_1, __i__1_1)} ((((__i__0_0) == (__i__0_1)) && ((__i__1_0) == (__i__1_1))) || ((abiEncodePacked2(__i__0_0, __i__1_0)) != (abiEncodePacked2(__i__0_1, __i__1_1)))));

axiom(forall  __i__0_0:Ref, __i__0_1:Ref :: {abiEncodePacked1R(__i__0_0), abiEncodePacked1R(__i__0_1)} (((__i__0_0) == (__i__0_1)) || ((abiEncodePacked1R(__i__0_0)) != (abiEncodePacked1R(__i__0_1)))));

axiom(forall  __i__0_0:Ref, __i__0_1:Ref, __i__1_0:int, __i__1_1:int :: {abiEncodePacked2R(__i__0_0, __i__1_0), abiEncodePacked2R(__i__0_1, __i__1_1)} ((((__i__0_0) == (__i__0_1)) && ((__i__1_0) == (__i__1_1))) || ((abiEncodePacked2R(__i__0_0, __i__1_0)) != (abiEncodePacked2R(__i__0_1, __i__1_1)))));
procedure {:inline 1} IERC20_IERC20_NoBaseCtor(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int);
implementation IERC20_IERC20_NoBaseCtor(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int)
{
// start of initialization
assume ((msgsender_MSG) != (null));
Balance[this] := 0;
// end of initialization
}

procedure {:inline 1} IERC20_IERC20(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int);
implementation IERC20_IERC20(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int)
{
call  {:cexpr "_verisolFirstArg"} boogie_si_record_sol2Bpl_bool(false);
call  {:cexpr "this"} boogie_si_record_sol2Bpl_ref(this);
call  {:cexpr "msg.sender"} boogie_si_record_sol2Bpl_ref(msgsender_MSG);
call  {:cexpr "msg.value"} boogie_si_record_sol2Bpl_int(msgvalue_MSG);
call  {:cexpr "_verisolLastArg"} boogie_si_record_sol2Bpl_bool(true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\Libraries/IERC20.sol"} {:sourceLine 7} (true);
call IERC20_IERC20_NoBaseCtor(this, msgsender_MSG, msgvalue_MSG);
}

procedure {:public} {:inline 1} totalSupply_IERC20(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int) returns (__ret_0_: int);
procedure {:public} {:inline 1} balanceOf_IERC20(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, account_s81: Ref) returns (__ret_0_: int);
procedure {:public} {:inline 1} transfer_IERC20(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, recipient_s90: Ref, amount_s90: int) returns (__ret_0_: bool);
procedure {:public} {:inline 1} allowance_IERC20(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, owner_s99: Ref, spender_s99: Ref) returns (__ret_0_: int);
procedure {:public} {:inline 1} approve_IERC20(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, spender_s108: Ref, amount_s108: int) returns (__ret_0_: bool);
procedure {:public} {:inline 1} transferFrom_IERC20(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, sender_s119: Ref, recipient_s119: Ref, amount_s119: int) returns (__ret_0_: bool);
procedure {:inline 1} SafeMath_SafeMath_NoBaseCtor(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int);
implementation SafeMath_SafeMath_NoBaseCtor(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int)
{
// start of initialization
assume ((msgsender_MSG) != (null));
Balance[this] := 0;
// end of initialization
}

procedure {:inline 1} SafeMath_SafeMath(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int);
implementation SafeMath_SafeMath(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int)
{
call  {:cexpr "_verisolFirstArg"} boogie_si_record_sol2Bpl_bool(false);
call  {:cexpr "this"} boogie_si_record_sol2Bpl_ref(this);
call  {:cexpr "msg.sender"} boogie_si_record_sol2Bpl_ref(msgsender_MSG);
call  {:cexpr "msg.value"} boogie_si_record_sol2Bpl_int(msgvalue_MSG);
call  {:cexpr "_verisolLastArg"} boogie_si_record_sol2Bpl_bool(true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 16} (true);
call SafeMath_SafeMath_NoBaseCtor(this, msgsender_MSG, msgvalue_MSG);
}

procedure {:inline 1} add_SafeMath(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, a_s335: int, b_s335: int) returns (__ret_0_: int);
implementation add_SafeMath(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, a_s335: int, b_s335: int) returns (__ret_0_: int)
{
var c_s334: int;
call  {:cexpr "_verisolFirstArg"} boogie_si_record_sol2Bpl_bool(false);
call  {:cexpr "this"} boogie_si_record_sol2Bpl_ref(this);
call  {:cexpr "msg.sender"} boogie_si_record_sol2Bpl_ref(msgsender_MSG);
call  {:cexpr "msg.value"} boogie_si_record_sol2Bpl_int(msgvalue_MSG);
call  {:cexpr "a"} boogie_si_record_sol2Bpl_int(a_s335);
call  {:cexpr "b"} boogie_si_record_sol2Bpl_int(b_s335);
call  {:cexpr "_verisolLastArg"} boogie_si_record_sol2Bpl_bool(true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 26} (true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 27} (true);
assume ((c_s334) >= (0));
assume ((a_s335) >= (0));
assume ((b_s335) >= (0));
assume (((a_s335) + (b_s335)) >= (0));
c_s334 := (a_s335) + (b_s335);
call  {:cexpr "c"} boogie_si_record_sol2Bpl_int(c_s334);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 28} (true);
assume ((c_s334) >= (0));
assume ((a_s335) >= (0));
assume ((c_s334) >= (a_s335));
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 30} (true);
assume ((c_s334) >= (0));
__ret_0_ := c_s334;
return;
}

procedure {:inline 1} sub_SafeMath(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, a_s360: int, b_s360: int) returns (__ret_0_: int);
implementation sub_SafeMath(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, a_s360: int, b_s360: int) returns (__ret_0_: int)
{
var c_s359: int;
call  {:cexpr "_verisolFirstArg"} boogie_si_record_sol2Bpl_bool(false);
call  {:cexpr "this"} boogie_si_record_sol2Bpl_ref(this);
call  {:cexpr "msg.sender"} boogie_si_record_sol2Bpl_ref(msgsender_MSG);
call  {:cexpr "msg.value"} boogie_si_record_sol2Bpl_int(msgvalue_MSG);
call  {:cexpr "a"} boogie_si_record_sol2Bpl_int(a_s360);
call  {:cexpr "b"} boogie_si_record_sol2Bpl_int(b_s360);
call  {:cexpr "_verisolLastArg"} boogie_si_record_sol2Bpl_bool(true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 42} (true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 43} (true);
assume ((b_s360) >= (0));
assume ((a_s360) >= (0));
assume ((b_s360) <= (a_s360));
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 44} (true);
assume ((c_s359) >= (0));
assume ((a_s360) >= (0));
assume ((b_s360) >= (0));
assume (((a_s360) - (b_s360)) >= (0));
c_s359 := (a_s360) - (b_s360);
call  {:cexpr "c"} boogie_si_record_sol2Bpl_int(c_s359);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 46} (true);
assume ((c_s359) >= (0));
__ret_0_ := c_s359;
return;
}

procedure {:inline 1} mul_SafeMath(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, a_s394: int, b_s394: int) returns (__ret_0_: int);
implementation mul_SafeMath(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, a_s394: int, b_s394: int) returns (__ret_0_: int)
{
var c_s393: int;
call  {:cexpr "_verisolFirstArg"} boogie_si_record_sol2Bpl_bool(false);
call  {:cexpr "this"} boogie_si_record_sol2Bpl_ref(this);
call  {:cexpr "msg.sender"} boogie_si_record_sol2Bpl_ref(msgsender_MSG);
call  {:cexpr "msg.value"} boogie_si_record_sol2Bpl_int(msgvalue_MSG);
call  {:cexpr "a"} boogie_si_record_sol2Bpl_int(a_s394);
call  {:cexpr "b"} boogie_si_record_sol2Bpl_int(b_s394);
call  {:cexpr "_verisolLastArg"} boogie_si_record_sol2Bpl_bool(true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 58} (true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 62} (true);
assume ((a_s394) >= (0));
if ((a_s394) == (0)) {
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 62} (true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 63} (true);
__ret_0_ := 0;
return;
}
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 66} (true);
assume ((c_s393) >= (0));
assume ((a_s394) >= (0));
assume ((b_s394) >= (0));
assume (((a_s394) * (b_s394)) >= (0));
c_s393 := (a_s394) * (b_s394);
call  {:cexpr "c"} boogie_si_record_sol2Bpl_int(c_s393);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 67} (true);
assume ((c_s393) >= (0));
assume ((a_s394) >= (0));
assume (((c_s393) div (a_s394)) >= (0));
assume ((b_s394) >= (0));
assume (((c_s393) div (a_s394)) == (b_s394));
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 69} (true);
assume ((c_s393) >= (0));
__ret_0_ := c_s393;
return;
}

procedure {:inline 1} div_SafeMath(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, a_s419: int, b_s419: int) returns (__ret_0_: int);
implementation div_SafeMath(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, a_s419: int, b_s419: int) returns (__ret_0_: int)
{
var c_s418: int;
call  {:cexpr "_verisolFirstArg"} boogie_si_record_sol2Bpl_bool(false);
call  {:cexpr "this"} boogie_si_record_sol2Bpl_ref(this);
call  {:cexpr "msg.sender"} boogie_si_record_sol2Bpl_ref(msgsender_MSG);
call  {:cexpr "msg.value"} boogie_si_record_sol2Bpl_int(msgvalue_MSG);
call  {:cexpr "a"} boogie_si_record_sol2Bpl_int(a_s419);
call  {:cexpr "b"} boogie_si_record_sol2Bpl_int(b_s419);
call  {:cexpr "_verisolLastArg"} boogie_si_record_sol2Bpl_bool(true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 83} (true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 85} (true);
assume ((b_s419) >= (0));
assume ((b_s419) > (0));
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 86} (true);
assume ((c_s418) >= (0));
assume ((a_s419) >= (0));
assume ((b_s419) >= (0));
assume (((a_s419) div (b_s419)) >= (0));
c_s418 := (a_s419) div (b_s419);
call  {:cexpr "c"} boogie_si_record_sol2Bpl_int(c_s418);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 89} (true);
assume ((c_s418) >= (0));
__ret_0_ := c_s418;
return;
}

procedure {:inline 1} mod_SafeMath(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, a_s440: int, b_s440: int) returns (__ret_0_: int);
implementation mod_SafeMath(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, a_s440: int, b_s440: int) returns (__ret_0_: int)
{
call  {:cexpr "_verisolFirstArg"} boogie_si_record_sol2Bpl_bool(false);
call  {:cexpr "this"} boogie_si_record_sol2Bpl_ref(this);
call  {:cexpr "msg.sender"} boogie_si_record_sol2Bpl_ref(msgsender_MSG);
call  {:cexpr "msg.value"} boogie_si_record_sol2Bpl_int(msgvalue_MSG);
call  {:cexpr "a"} boogie_si_record_sol2Bpl_int(a_s440);
call  {:cexpr "b"} boogie_si_record_sol2Bpl_int(b_s440);
call  {:cexpr "_verisolLastArg"} boogie_si_record_sol2Bpl_bool(true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 103} (true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 104} (true);
assume ((b_s440) >= (0));
assume ((b_s440) != (0));
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\SafeMath.sol"} {:sourceLine 105} (true);
assume ((a_s440) >= (0));
assume ((b_s440) >= (0));
assume (((a_s440) mod (b_s440)) >= (0));
__ret_0_ := (a_s440) mod (b_s440);
return;
}

procedure {:inline 1} visor2_visor2_NoBaseCtor(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int);
implementation visor2_visor2_NoBaseCtor(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int)
{
// start of initialization
assume ((msgsender_MSG) != (null));
Balance[this] := 0;
// end of initialization
}

procedure {:inline 1} visor2_visor2(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int);
implementation visor2_visor2(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int)
{
call  {:cexpr "_verisolFirstArg"} boogie_si_record_sol2Bpl_bool(false);
call  {:cexpr "this"} boogie_si_record_sol2Bpl_ref(this);
call  {:cexpr "msg.sender"} boogie_si_record_sol2Bpl_ref(msgsender_MSG);
call  {:cexpr "msg.value"} boogie_si_record_sol2Bpl_int(msgvalue_MSG);
call  {:cexpr "_verisolLastArg"} boogie_si_record_sol2Bpl_bool(true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\visor2.sol"} {:sourceLine 8} (true);
call IERC20_IERC20(this, msgsender_MSG, msgvalue_MSG);
call visor2_visor2_NoBaseCtor(this, msgsender_MSG, msgvalue_MSG);
}

var token0_visor2: [Ref]Ref;
var token1_visor2: [Ref]Ref;
var myToken_visor2: [Ref]Ref;
procedure {:public} {:inline 1} exchange_visor2(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, amount_s46: int, to_s46: Ref);
implementation exchange_visor2(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int, amount_s46: int, to_s46: Ref)
{
var __var_1: int;
var __var_2: int;
var __var_3: int;
var __var_4: bool;
var __var_5: int;
call  {:cexpr "_verisolFirstArg"} boogie_si_record_sol2Bpl_bool(false);
call  {:cexpr "this"} boogie_si_record_sol2Bpl_ref(this);
call  {:cexpr "msg.sender"} boogie_si_record_sol2Bpl_ref(msgsender_MSG);
call  {:cexpr "msg.value"} boogie_si_record_sol2Bpl_int(msgvalue_MSG);
call  {:cexpr "amount"} boogie_si_record_sol2Bpl_int(amount_s46);
call  {:cexpr "to"} boogie_si_record_sol2Bpl_ref(to_s46);
call  {:cexpr "_verisolLastArg"} boogie_si_record_sol2Bpl_bool(true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\visor2.sol"} {:sourceLine 14} (true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\visor2.sol"} {:sourceLine 17} (true);
assume ((__var_1) >= (0));
call __var_1 := getPrice_visor2(this, msgsender_MSG, msgvalue_MSG);
assume ((__var_1) >= (0));
assume ((__var_2) >= (0));
call __var_2 := getPrice_visor2(this, msgsender_MSG, msgvalue_MSG);
assume ((__var_2) >= (0));
assume ((old(__var_2)) >= (0));
assume (((2) * (old(__var_2))) >= (0));
assert ((__var_1) <= ((2) * (old(__var_2))));
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\visor2.sol"} {:sourceLine 18} (true);
assume ((__var_3) >= (0));
call __var_3 := getPrice_visor2(this, msgsender_MSG, msgvalue_MSG);
assume ((__var_3) >= (0));
if ((__var_3) > (10000)) {
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\visor2.sol"} {:sourceLine 18} (true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\visor2.sol"} {:sourceLine 19} (true);
assume ((amount_s46) >= (0));
if ((DType[myToken_visor2[this]]) == (visor2)) {
call __var_4 := transfer_IERC20(myToken_visor2[this], this, __var_5, to_s46, amount_s46);
} else if ((DType[myToken_visor2[this]]) == (IERC20)) {
call __var_4 := transfer_IERC20(myToken_visor2[this], this, __var_5, to_s46, amount_s46);
} else {
assume (false);
}
}
}

procedure {:public} {:inline 1} getPrice_visor2(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int) returns (__ret_0_: int);
implementation getPrice_visor2(this: Ref, msgsender_MSG: Ref, msgvalue_MSG: int) returns (__ret_0_: int)
{
var __var_6: int;
var __var_7: int;
var __var_8: Ref;
var __var_9: int;
var __var_10: int;
var __var_11: Ref;
call  {:cexpr "_verisolFirstArg"} boogie_si_record_sol2Bpl_bool(false);
call  {:cexpr "this"} boogie_si_record_sol2Bpl_ref(this);
call  {:cexpr "msg.sender"} boogie_si_record_sol2Bpl_ref(msgsender_MSG);
call  {:cexpr "msg.value"} boogie_si_record_sol2Bpl_int(msgvalue_MSG);
call  {:cexpr "_verisolLastArg"} boogie_si_record_sol2Bpl_bool(true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\visor2.sol"} {:sourceLine 24} (true);
assert {:first} {:sourceFile "C:\Users\sally\verisol\Contracts\visor2.sol"} {:sourceLine 25} (true);
assume ((__var_6) >= (0));
__var_8 := this;
if ((DType[token0_visor2[this]]) == (visor2)) {
call __var_6 := balanceOf_IERC20(token0_visor2[this], this, __var_7, this);
} else if ((DType[token0_visor2[this]]) == (IERC20)) {
call __var_6 := balanceOf_IERC20(token0_visor2[this], this, __var_7, this);
} else {
assume (false);
}
assume ((__var_6) >= (0));
assume ((__var_9) >= (0));
__var_11 := this;
if ((DType[token1_visor2[this]]) == (visor2)) {
call __var_9 := balanceOf_IERC20(token1_visor2[this], this, __var_10, this);
} else if ((DType[token1_visor2[this]]) == (IERC20)) {
call __var_9 := balanceOf_IERC20(token1_visor2[this], this, __var_10, this);
} else {
assume (false);
}
assume ((__var_9) >= (0));
assume (((__var_6) div (__var_9)) >= (0));
__ret_0_ := (__var_6) div (__var_9);
return;
}

procedure {:inline 1} FallbackDispatch(from: Ref, to: Ref, amount: int);
implementation FallbackDispatch(from: Ref, to: Ref, amount: int)
{
if ((DType[to]) == (visor2)) {
assume ((amount) == (0));
} else if ((DType[to]) == (IERC20)) {
assume ((amount) == (0));
} else {
call Fallback_UnknownType(from, to, amount);
}
}

procedure {:inline 1} Fallback_UnknownType(from: Ref, to: Ref, amount: int);
implementation Fallback_UnknownType(from: Ref, to: Ref, amount: int)
{
// ---- Logic for payable function START 
assume ((Balance[from]) >= (amount));
Balance[from] := (Balance[from]) - (amount);
Balance[to] := (Balance[to]) + (amount);
// ---- Logic for payable function END 
}

procedure {:inline 1} send(from: Ref, to: Ref, amount: int) returns (success: bool);
implementation send(from: Ref, to: Ref, amount: int) returns (success: bool)
{
if ((Balance[from]) >= (amount)) {
call FallbackDispatch(from, to, amount);
success := true;
} else {
success := false;
}
}

procedure BoogieEntry_IERC20();
implementation BoogieEntry_IERC20()
{
var this: Ref;
var msgsender_MSG: Ref;
var msgvalue_MSG: int;
var choice: int;
var tmpNow: int;
assume ((now) >= (0));
assume (((DType[this]) == (IERC20)) || ((DType[this]) == (visor2)));
call IERC20_IERC20(this, msgsender_MSG, msgvalue_MSG);
while (true)
{
havoc msgsender_MSG;
havoc msgvalue_MSG;
havoc choice;
havoc tmpNow;
tmpNow := now;
havoc now;
assume ((now) > (tmpNow));
assume ((msgsender_MSG) != (null));
assume ((DType[msgsender_MSG]) != (IERC20));
assume ((DType[msgsender_MSG]) != (VeriSol));
assume ((DType[msgsender_MSG]) != (SafeMath));
assume ((DType[msgsender_MSG]) != (visor2));
Alloc[msgsender_MSG] := true;
}
}

procedure BoogieEntry_SafeMath();
implementation BoogieEntry_SafeMath()
{
var this: Ref;
var msgsender_MSG: Ref;
var msgvalue_MSG: int;
var choice: int;
var tmpNow: int;
assume ((now) >= (0));
assume ((DType[this]) == (SafeMath));
call SafeMath_SafeMath(this, msgsender_MSG, msgvalue_MSG);
while (true)
{
havoc msgsender_MSG;
havoc msgvalue_MSG;
havoc choice;
havoc tmpNow;
tmpNow := now;
havoc now;
assume ((now) > (tmpNow));
assume ((msgsender_MSG) != (null));
assume ((DType[msgsender_MSG]) != (IERC20));
assume ((DType[msgsender_MSG]) != (VeriSol));
assume ((DType[msgsender_MSG]) != (SafeMath));
assume ((DType[msgsender_MSG]) != (visor2));
Alloc[msgsender_MSG] := true;
}
}

procedure BoogieEntry_visor2();
implementation BoogieEntry_visor2()
{
var this: Ref;
var msgsender_MSG: Ref;
var msgvalue_MSG: int;
var choice: int;
var __ret_0_totalSupply: int;
var account_s81: Ref;
var __ret_0_balanceOf: int;
var recipient_s90: Ref;
var amount_s90: int;
var __ret_0_transfer: bool;
var owner_s99: Ref;
var spender_s99: Ref;
var __ret_0_allowance: int;
var spender_s108: Ref;
var amount_s108: int;
var __ret_0_approve: bool;
var sender_s119: Ref;
var recipient_s119: Ref;
var amount_s119: int;
var __ret_0_transferFrom: bool;
var amount_s46: int;
var to_s46: Ref;
var __ret_0_getPrice: int;
var tmpNow: int;
assume ((now) >= (0));
assume ((DType[this]) == (visor2));
call visor2_visor2(this, msgsender_MSG, msgvalue_MSG);
while (true)
{
havoc msgsender_MSG;
havoc msgvalue_MSG;
havoc choice;
havoc __ret_0_totalSupply;
havoc account_s81;
havoc __ret_0_balanceOf;
havoc recipient_s90;
havoc amount_s90;
havoc __ret_0_transfer;
havoc owner_s99;
havoc spender_s99;
havoc __ret_0_allowance;
havoc spender_s108;
havoc amount_s108;
havoc __ret_0_approve;
havoc sender_s119;
havoc recipient_s119;
havoc amount_s119;
havoc __ret_0_transferFrom;
havoc amount_s46;
havoc to_s46;
havoc __ret_0_getPrice;
havoc tmpNow;
tmpNow := now;
havoc now;
assume ((now) > (tmpNow));
assume ((msgsender_MSG) != (null));
assume ((DType[msgsender_MSG]) != (IERC20));
assume ((DType[msgsender_MSG]) != (VeriSol));
assume ((DType[msgsender_MSG]) != (SafeMath));
assume ((DType[msgsender_MSG]) != (visor2));
Alloc[msgsender_MSG] := true;
if ((choice) == (8)) {
call __ret_0_totalSupply := totalSupply_IERC20(this, msgsender_MSG, msgvalue_MSG);
} else if ((choice) == (7)) {
call __ret_0_balanceOf := balanceOf_IERC20(this, msgsender_MSG, msgvalue_MSG, account_s81);
} else if ((choice) == (6)) {
call __ret_0_transfer := transfer_IERC20(this, msgsender_MSG, msgvalue_MSG, recipient_s90, amount_s90);
} else if ((choice) == (5)) {
call __ret_0_allowance := allowance_IERC20(this, msgsender_MSG, msgvalue_MSG, owner_s99, spender_s99);
} else if ((choice) == (4)) {
call __ret_0_approve := approve_IERC20(this, msgsender_MSG, msgvalue_MSG, spender_s108, amount_s108);
} else if ((choice) == (3)) {
call __ret_0_transferFrom := transferFrom_IERC20(this, msgsender_MSG, msgvalue_MSG, sender_s119, recipient_s119, amount_s119);
} else if ((choice) == (2)) {
call exchange_visor2(this, msgsender_MSG, msgvalue_MSG, amount_s46, to_s46);
} else if ((choice) == (1)) {
call __ret_0_getPrice := getPrice_visor2(this, msgsender_MSG, msgvalue_MSG);
}
}
}

procedure CorralChoice_IERC20(this: Ref);
implementation CorralChoice_IERC20(this: Ref)
{
var msgsender_MSG: Ref;
var msgvalue_MSG: int;
var choice: int;
var tmpNow: int;
havoc msgsender_MSG;
havoc msgvalue_MSG;
havoc choice;
havoc tmpNow;
tmpNow := now;
havoc now;
assume ((now) > (tmpNow));
assume ((msgsender_MSG) != (null));
assume ((DType[msgsender_MSG]) != (IERC20));
assume ((DType[msgsender_MSG]) != (VeriSol));
assume ((DType[msgsender_MSG]) != (SafeMath));
assume ((DType[msgsender_MSG]) != (visor2));
Alloc[msgsender_MSG] := true;
}

procedure CorralEntry_IERC20();
implementation CorralEntry_IERC20()
{
var this: Ref;
var msgsender_MSG: Ref;
var msgvalue_MSG: int;
call this := FreshRefGenerator();
assume ((now) >= (0));
assume (((DType[this]) == (IERC20)) || ((DType[this]) == (visor2)));
call IERC20_IERC20(this, msgsender_MSG, msgvalue_MSG);
while (true)
{
call CorralChoice_IERC20(this);
}
}

procedure CorralChoice_SafeMath(this: Ref);
implementation CorralChoice_SafeMath(this: Ref)
{
var msgsender_MSG: Ref;
var msgvalue_MSG: int;
var choice: int;
var tmpNow: int;
havoc msgsender_MSG;
havoc msgvalue_MSG;
havoc choice;
havoc tmpNow;
tmpNow := now;
havoc now;
assume ((now) > (tmpNow));
assume ((msgsender_MSG) != (null));
assume ((DType[msgsender_MSG]) != (IERC20));
assume ((DType[msgsender_MSG]) != (VeriSol));
assume ((DType[msgsender_MSG]) != (SafeMath));
assume ((DType[msgsender_MSG]) != (visor2));
Alloc[msgsender_MSG] := true;
}

procedure CorralEntry_SafeMath();
implementation CorralEntry_SafeMath()
{
var this: Ref;
var msgsender_MSG: Ref;
var msgvalue_MSG: int;
call this := FreshRefGenerator();
assume ((now) >= (0));
assume ((DType[this]) == (SafeMath));
call SafeMath_SafeMath(this, msgsender_MSG, msgvalue_MSG);
while (true)
{
call CorralChoice_SafeMath(this);
}
}

procedure CorralChoice_visor2(this: Ref);
implementation CorralChoice_visor2(this: Ref)
{
var msgsender_MSG: Ref;
var msgvalue_MSG: int;
var choice: int;
var __ret_0_totalSupply: int;
var account_s81: Ref;
var __ret_0_balanceOf: int;
var recipient_s90: Ref;
var amount_s90: int;
var __ret_0_transfer: bool;
var owner_s99: Ref;
var spender_s99: Ref;
var __ret_0_allowance: int;
var spender_s108: Ref;
var amount_s108: int;
var __ret_0_approve: bool;
var sender_s119: Ref;
var recipient_s119: Ref;
var amount_s119: int;
var __ret_0_transferFrom: bool;
var amount_s46: int;
var to_s46: Ref;
var __ret_0_getPrice: int;
var tmpNow: int;
havoc msgsender_MSG;
havoc msgvalue_MSG;
havoc choice;
havoc __ret_0_totalSupply;
havoc account_s81;
havoc __ret_0_balanceOf;
havoc recipient_s90;
havoc amount_s90;
havoc __ret_0_transfer;
havoc owner_s99;
havoc spender_s99;
havoc __ret_0_allowance;
havoc spender_s108;
havoc amount_s108;
havoc __ret_0_approve;
havoc sender_s119;
havoc recipient_s119;
havoc amount_s119;
havoc __ret_0_transferFrom;
havoc amount_s46;
havoc to_s46;
havoc __ret_0_getPrice;
havoc tmpNow;
tmpNow := now;
havoc now;
assume ((now) > (tmpNow));
assume ((msgsender_MSG) != (null));
assume ((DType[msgsender_MSG]) != (IERC20));
assume ((DType[msgsender_MSG]) != (VeriSol));
assume ((DType[msgsender_MSG]) != (SafeMath));
assume ((DType[msgsender_MSG]) != (visor2));
Alloc[msgsender_MSG] := true;
if ((choice) == (8)) {
call __ret_0_totalSupply := totalSupply_IERC20(this, msgsender_MSG, msgvalue_MSG);
} else if ((choice) == (7)) {
call __ret_0_balanceOf := balanceOf_IERC20(this, msgsender_MSG, msgvalue_MSG, account_s81);
} else if ((choice) == (6)) {
call __ret_0_transfer := transfer_IERC20(this, msgsender_MSG, msgvalue_MSG, recipient_s90, amount_s90);
} else if ((choice) == (5)) {
call __ret_0_allowance := allowance_IERC20(this, msgsender_MSG, msgvalue_MSG, owner_s99, spender_s99);
} else if ((choice) == (4)) {
call __ret_0_approve := approve_IERC20(this, msgsender_MSG, msgvalue_MSG, spender_s108, amount_s108);
} else if ((choice) == (3)) {
call __ret_0_transferFrom := transferFrom_IERC20(this, msgsender_MSG, msgvalue_MSG, sender_s119, recipient_s119, amount_s119);
} else if ((choice) == (2)) {
call exchange_visor2(this, msgsender_MSG, msgvalue_MSG, amount_s46, to_s46);
} else if ((choice) == (1)) {
call __ret_0_getPrice := getPrice_visor2(this, msgsender_MSG, msgvalue_MSG);
}
}

procedure CorralEntry_visor2();
implementation CorralEntry_visor2()
{
var this: Ref;
var msgsender_MSG: Ref;
var msgvalue_MSG: int;
call this := FreshRefGenerator();
assume ((now) >= (0));
assume ((DType[this]) == (visor2));
call visor2_visor2(this, msgsender_MSG, msgvalue_MSG);
while (true)
{
call CorralChoice_visor2(this);
}
}


