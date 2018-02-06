(* ::Package:: *)

BeginPackage["SMML`Tokenizer`"];

keyDict=<|
	"C"->0,"G"->7,"D"->2,"A"->9,"E"->4,
	"B"->-1,"#F"->6,"#C"->1,"F"->5,"bB"->-2,
	"bE"->3,"bA"->8,"bD"->1,"bG"->6,"bC"->-1,
	"F#"->6,"C#"->1,"Bb"->-2,"Gb"->6,
	"Eb"->3,"Ab"->8,"Db"->1,"Cb"->-1
|>;
key=Alternatives@@Keys@keyDict;
word=WordCharacter..;
jsCodePatt=Nest[(("{"~~#~~"}")|Except["{"|"}"])...&,Except["{"|"}"]...,8];
funcName=Alternatives@@Flatten[StringCases[StringExpression[
	name:word,
	Shortest["("~~__~~")"],
	Whitespace,
	Shortest["{"~~jsCodePatt~~"}"]
]:>name]/@StringCases[
	"module.exports = {"~~cont:Shortest[jsCodePatt]~~"}":>cont
]@Import[
	NotebookDirectory[]<>"Standard\\Function.js","String"
]];

rep[pat_]:=rep[pat,","];
rep[pat_,sep_]:=pat~~(sep~~pat)...;
unsigned=DigitCharacter..;
integer=""|"-"|"+"~~unsigned;
number=(integer~~""|("/"|"."~~unsigned))|("log2("~~unsigned~~")");
subtrack=Nest[(("{"~~#~~"}")|Except["{"|"}"])...&,Except["{"|"}"]...,8];
argument=rep[number|("{"~~subtrack~~"}")];
orderList=""|rep[unsigned~~""|("~"~~unsigned)];
orderTok[ord_]:=Union@@StringCases[ord,{
	n:integer~~"~"~~m:integer:>Range[ToExpression@n,ToExpression@m],
	n:integer:>{ToExpression@n}
}];

preOperator="$"|"";
postOperator="``"|"`"|"";
volOperator=(">"|":")...;
pitOperator=("#"|"b"|"'"|",")...;
durOperator=("."|"-"|"_"|"=")...;
scaleDegree="0"|"1"|"2"|"3"|"4"|"5"|"6"|"7"|"%"|"x";
chordNotation=""|Alternatives@@{"M","m","a","d","p"};
chordOperator=Alternatives@@{"o","u","i","j"}...;
pitch=scaleDegree~~pitOperator~~chordNotation~~chordOperator;
pitches="["~~pitch..~~"]"~~pitOperator;
note=preOperator~~pitch|pitches~~volOperator~~durOperator~~postOperator;
pitchTok[str_]:=StringCases[str,
	StringExpression[
		sd:scaleDegree,
		po:pitOperator,
		cn:chordNotation,
		co:chordOperator
	]:>{
		"ScaleDegree"->sd,
		"PitchOperators"->po,
		"ChordNotations"->cn,
		"ChordOperators"->co
	}
];

(* object *)
objectPatt=("{"~~""|(unsigned~~"*")~~subtrack~~"}")|note;
objectTok[str_]:=StringCases[str,{
	"{"~~n:unsigned~~"*"~~sub:subtrack~~"}":>
		{"Type"->"Subtrack","Contents"->trackTok[sub],"Repeat"->-ToExpression@n},
	"{"~~sub:subtrack~~"}":>
		{"Type"->"Subtrack","Contents"->trackTok[sub],"Repeat"->Max[-1,
			StringCases[sub,"/"~~i:orderList~~":":>orderTok[i]]
		]},
	StringExpression[
		pre:preOperator,
		""|"["~~pts:pitch..~~"]"|"",
		pit:pitOperator,
		vol:volOperator,
		dur:durOperator,
		pst:postOperator
	]:>{
		"Type"->"Note",
		"Pitches"->pitchTok[pts],
		"PitchOperators"->pit,
		"DurationOperators"->dur,
		"VolumeOperators"->vol,
		"Staccato"->StringCount[pst,"`"],
		"Arpeggio"->StringContainsQ[pre,"$"]
	}
}][[1]];

(* notation *)
notationPatt=("/"~~orderList~~":")|"|"|"/"|"^"|"&"|"*"|Whitespace;
notationTok[str_]:=StringCases[str,{
	bl:"/"~~ol:orderList~~":":>
		{"Type"->"BarLine","Newline"->(bl=="\\"),"Skip"->False,"Order"->orderTok[ol]},
	bl:"|"|"/":>
		{"Type"->"BarLine","Newline"->(bl=="\\"),"Skip"->(bl=="/"),"Order"->{0}},
	"^":>{"Type"->"Tie"},
	"&":>{"Type"->"PedalPress"},
	"*":>{"Type"->"PedalRelease"},
	space:Whitespace:>{"Type"->"Whitespace","Content"->space}
}][[1]];

(* function *)
objPaddedLeft=objectPatt~~notationPatt...;
objPaddedRight=notationPatt...~~objectPatt;
functionPatt=Alternatives[
	"("~~funcName~~":"~~rep[number]~~")",
	"("~~number~~"%)",
	"("~~unsigned~~"/"~~unsigned~~")",
	"("~~NumberString~~")",
	"(1="~~key~~("'"|",")...~~")",
	objPaddedLeft~~"~"~~objPaddedRight,
	objPaddedLeft~~"("~~unsigned~~"=)"~~objPaddedRight,
	"("~~unsigned~~"-)"~~objPaddedRight,
	"("~~note..~~"^)"~~objPaddedRight,
	objPaddedLeft~~"(^"~~note..~~")",
	"("~~unsigned~~"~)"~~objPaddedRight
];
functionTok[str_]:=StringCases[str,{
	"("~~var:funcName~~":"~~arg:rep[number]~~")":>{
		"Type"->"FUNCTION",
		"Name"->var,
		"Simplified"->True,
		"Argument"->({"Type"->"Expression","Content"->#}&)/@StringSplit[arg,","]
	},
	"("~~vol:number~~"%)":>{
		"Type"->"FUNCTION",
		"Name"->"Vol",
		"Simplified"->True,
		"Argument"->{{"Type"->"Expression","Content"->vol}}
	},
	"("~~bar:unsigned~~"/"~~beat:unsigned~~")":>{
		"Type"->"FUNCTION",
		"Name"->"BarBeat",
		"Simplified"->True,
		"Argument"->{
			{"Type"->"Expression","Content"->bar},
			{"Type"->"Expression","Content"->beat}
		}
	},
	"("~~spd:NumberString~~")":>{
		"Type"->"FUNCTION",
		"Name"->"Spd",
		"Simplified"->True,
		"Argument"->{{"Type"->"Expression","Content"->spd}}
	},
	"(1="~~key:key~~oct:("'"|",")...~~")":>{
		"Type"->"FUNCTION",
		"Name"->"KeyOct",
		"Simplified"->True,
		"Argument"->{
			{"Type"->"String","Content"->key},
			{"Type"->"Expression","Content"->ToString[StringCount[oct,"'"]-StringCount[oct,","]]}
		}
	},
	objL:objPaddedLeft~~"~"~~objR:objPaddedRight:>{
		"Type"->"FUNCTION",
		"Name"->"Portamento",
		"Simplified"->True,
		"Argument"->{
			{"Type"->"Subtrack","Content"->trackTok[objL],"Repeat"->-1},
			{"Type"->"Subtrack","Content"->trackTok[objR],"Repeat"->-1}
		}
	},
	objL:objPaddedLeft~~"("~~arg:unsigned~~"=)"~~objR:objPaddedRight:>{
		"Type"->"FUNCTION",
		"Name"->"Tremolo2",
		"Simplified"->True,
		"Argument"->{
			{"Type"->"Expression","Content"->arg},
			{"Type"->"Subtrack","Content"->trackTok[objL],"Repeat"->-1},
			{"Type"->"Subtrack","Content"->trackTok[objR],"Repeat"->-1}
		}
	},
	"("~~arg:unsigned~~"-)"~~objR:objPaddedRight:>{
		"Type"->"FUNCTION",
		"Name"->"Tremolo1",
		"Simplified"->True,
		"Argument"->{
			{"Type"->"Expression","Content"->arg},
			{"Type"->"Subtrack","Content"->trackTok[objR],"Repeat"->-1}
		}
	},
	"("~~nl:note..~~"^)"~~objR:objPaddedRight:>{
		"Type"->"FUNCTION",
		"Name"->"GraceNote",
		"Simplified"->True,
		"Argument"->{
			{"Type"->"Subtrack","Content"->trackTok[nl],"Repeat"->-1},
			{"Type"->"Subtrack","Content"->trackTok[objR],"Repeat"->-1}
		}
	},
	objL:objPaddedLeft~~"(^"~~nl:note..~~")":>{
		"Type"->"FUNCTION",
		"Name"->"Appoggiatura",
		"Simplified"->True,
		"Argument"->{
			{"Type"->"Subtrack","Content"->trackTok[objL],"Repeat"->-1},
			{"Type"->"Subtrack","Content"->trackTok[nl],"Repeat"->-1}
		}
	},
	"("~~arg:unsigned~~"~)"~~"{"~~trkR:subtrack~~"}":>{
		"Type"->"FUNCTION",
		"Name"->"Tuplet",
		"Simplified"->True,
		"Argument"->{
			{"Type"->"Expression","Content"->arg},
			{"Type"->"Subtrack","Content"->trackTok[trkR],"Repeat"->-1}
		}
	}
}][[1]];

trackTok[str_]:=StringCases[str,{
	func:functionPatt:>functionTok[func],
	objt:objectPatt:>objectTok[objt],
	nota:notationPatt:>notationTok[nota],
	und_:>{"Type"->"Undefined","Content"->und}
}];

include[SMLPath_]:=Module[
	{
		data={},context,command,
		messages={},
		tokenData=<|"ChordNotation"-><||>,"ChordInversion"-><||>|>
	},
	
	If[FileExistsQ[SMLPath],
		data=Import[SMLPath,"List"],
		AppendTo[messages,<|"Type"->"FileNotFound","Arguments"->SMLPath|>]
	];
	Do[
		Switch[line,
			_?(StringStartsQ["!"]),
				command=Cases[StringSplit[StringDrop[line,1]," "..],Except[""]];
				Switch[command[[1]],
					"SMML",
						Switch[command[[2]],
							"Version",,
							_,AppendTo[messages,<|"Type"->"InvalidCommand","Arguments"->line|>]
						],
					"Chord",
						Switch[command[[2]],
							"Notation",context="ChordNotation",
							"Inversion",context="ChordInversion"
						],
					_,
						AppendTo[messages,<|"Type"->"InvalidCommand","Arguments"->line|>]
				],
			_?(StringStartsQ[Except["#"]]),
				AppendTo[tokenData[[context]],Switch[context,
					"ChordNotation",
						#[[1]]->ToExpression/@StringSplit[#[[3]],","~~" "...]&,
					"ChordInversion",
						#[[1]]->ToExpression/@StringSplit[#[[3]],","~~" "...]&
				][StringSplit[line,"\t"..]]]
		],
	{line,data}];
	
	Return[<|
		"Data"->data,
		"Messages"->messages,
		"TokenData"->tokenData
	|>];
];

EndPackage[];


(* ::Input:: *)
(*trackTok["3(^12)3"]*)


(* ::Input:: *)
(*Contexts["SMML`*"]*)


(* ::Input:: *)
(*Export[NotebookDirectory[]<>"test.json",%];*)
