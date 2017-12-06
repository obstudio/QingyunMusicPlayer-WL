(* ::Package:: *)

(* ::Text:: *)
(*Qingyun Music Player*)
(*Version 1.0.0*)


(* Initialization *)
$CharacterEncoding="UTF-8";
$Language="ChineseSimplified";
$favorite=NotebookDirectory[];
$TonalityDict=<|
	"C"->0,"G"->7,"D"->2,"A"->-3,"E"->4,
	"B"->-1,"#F"->6,"#C"->1,"F"->5,"bB"->-2,
	"bE"->3,"bA"->-4,"bD"->1,"bG"->6,"bC"->-1
|>;
index=Import[$favorite<>"Index.xml","CDATA"];
$songCount=Length@index/4;
$songTitle=Take[index,{1,Length@index,4}];
$songPath=Take[index,{4,Length@index,4}];
$songDict=Association[#->$songTitle[[#]]&/@Range[$songCount]];
$songLyricist=Take[index,{3,Length@index,4}];
$songComposer=Take[index,{2,Length@index,4}];
$playing="Null";


QingyunPlay[song_]:=Module[{filename},
	filename=$favorite<>"Songs\\"<>song;
	If[FileExistsQ[filename],
		qymPlay[filename],
		Print["Not Found!"];Return[];
	]
];
qymPlay[filename_]:=Module[
	{
		i,j,
		data,char,music={},
		tonality=0,beat=1,speed=88,instrument,
		pitch,sharp=0,time,space,tercet=0,tercetTime,
		comment,match,timeDot,note,duration
	},
	data=#[[1]]&/@Import[filename,"Table"];
	Do[
		j=1;
		While[j<=StringLength[data[[i]]],
			char=StringTake[data[[i]],{j}];
			Switch[char,
				"/",
					If[StringTake[data[[i]],{j+1}]=="/",Break[]],
				"#",
					sharp++;
					j++;
					Continue[],
				"b",
					sharp--;
					j++;
					Continue[],
				"<",
					match=Select[Transpose[StringPosition[data[[i]],">"]][[1]],#>j&][[1]];
					comment=StringTake[data[[i]],{j+1,match-1}];
					Switch[StringTake[comment,{2}],
						"=",
							tonality=$TonalityDict[[StringTake[comment,{3,StringLength@comment}]]],
						"/",
							beat=ToExpression[StringTake[comment,{3}]]/4,
						_,
							speed=ToExpression[comment];
					];
					j=match+1;
					Continue[],
				"(",
					match=Select[Transpose[StringPosition[data[[i]],")"]][[1]],#>j&][[1]];
					comment=StringTake[data[[i]],{j+1,match-1}];
					tercet=ToExpression[comment];
					tercetTime=(2^Floor[Log2[tercet]])/tercet;
					j=match+1;
					Continue[],
				"{",
					match=Select[Transpose[StringPosition[data[[i]],"}"]][[1]],#>j&][[1]];
					instrument=StringTake[data[[i]],{j+1,match-1}]
			];
			If[MemberQ[{"0","1","2","3","4","5","6","7"},char],
				note=ToExpression@char;
				time=1;
				space=True;
				pitch=If[note==0,None,$PitchDict[[note]]+tonality+sharp];
				sharp=0;
				j++;
				While[j<=StringLength[data[[i]]] && MemberQ[{"-","_","'",",",".","^"},StringTake[data[[i]],{j}]],
					char=StringTake[data[[i]],{j}];
					Switch[char,
						"-",time+=1,
						"_",time/=2,
						"'",pitch+=12,
						",",pitch-=12,
						".",
							timeDot=1/2;
							While[StringTake[data[[i]],{j+1}]==".",
								timeDot/=2;
								j++;
							];
							time*=(2-timeDot),
						"^",space=False
					];
					j++;
				];
				If[tercet>0,
					time*=tercetTime;
					tercet--;
				];
				duration=60/speed*time*beat;
				If[instrument=="",
					If[space,
						EmitSound[Play[Sin[440*2^((pitch-9)/12)*2*Pi*t],{t,0,duration*7/8}]];
						EmitSound[Play[0,{t,0,duration/8}]],
						EmitSound[Play[Sin[440*2^((pitch-9)/12)*2*Pi*t],{t,0,duration}]];
					],
					If[space,
						AppendTo[music,SoundNote[pitch,duration*7/8,instrument]];
						AppendTo[music,SoundNote[None,duration/8]],
						AppendTo[music,SoundNote[pitch,duration,instrument]];
					];
				],
			j++];
		],
	{i,Length[data]}];
	EmitSound@Sound@music
]


CreateDialog[Column[{
	Style["\:9752\:4e91\:64ad\:653e\:5668",Bold,20],
	SetterBar[Dynamic[choice],$songDict,Appearance->"Vertical"],
	Button["\:64ad\:653e",
		$playing=$songTitle[[choice]];
		QingyunPlay[$songPath[[choice]]];
		$playing="Null",
	ImageSize->150],
	If[$playing=="Null",
		"\:70b9\:51fb\[OpenCurlyDoubleQuote]\:64ad\:653e\[CloseCurlyDoubleQuote]\:6309\:94ae\:5f00\:59cb\:6f14\:594f\:3002",
		"\:6b63\:5728\:64ad\:653e\:ff1a"<>Dynamic[$playing]
	]
},Center],
WindowTitle->"\:9752\:4e91\:64ad\:653e\:5668"];
