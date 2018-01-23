(* ::Package:: *)

uiModifySong[song_]:=DynamicModule[{textInfo},
	textInfo=index[[song,textInfoTags]];
	CreateDialog[Column[{Spacer[{20,20}],
		caption[textInfo[["SongName"]],"Title"],
		Spacer[1],
		Grid[{Spacer[40],
			caption[tagName[[#]],"Text"],
			Spacer[2],
			InputField[Dynamic@textInfo[[#]],String],
		Spacer[40]}&/@textInfoTags,Alignment->Right],
		Spacer[1],
		Grid[{
			{Button[text[["Save"]],putTextInfo[song,textInfo],ImageSize->150,Enabled->Dynamic[textInfo[["SongName"]]!=""]],
			Button[text[["Undo"]],textInfo=index[[song,textInfoTags]],ImageSize->150]},
			{Button[text[["DeleteSong"]],DialogReturn[uiDeleteSong[song]],ImageSize->150],
			Button[text[["Return"]],DialogReturn[refresh;uiPlaylist["All"]],ImageSize->150]}
		}],Spacer[{20,20}]
	},Center,ItemSize->Full,Spacings->1],
	Background->styleColor[["Background"]],WindowTitle->text[["ModifySong"]]];
];


(* ::Input:: *)
(*uiModifySong["Anima"];*)


putTextInfo[song_,textInfo_]:=Module[
	{info=index[[song]]},
	Do[
		info[[tag]]=textInfo[[tag]],
	{tag,textInfoTags}];
	index[[song]]=info;
	Export[path<>"Meta\\"<>song<>".json",index[[song]]];
];


tagTemplate=<|"Image"->"","Uploader"->"","Tags"->{}|>;
addSong[songPath_,textInfo_]:=Module[{song,metaInfo,audio,format},
	song=StringDrop[songPath,-4];
	format=StringTake[songPath,-3];
	AppendTo[index,song->Join[textInfo,tagTemplate,<|"Format"->format|>]];
	putTextInfo[song,textInfo];
];


(* ::Input:: *)
(*uiAddSong;*)


ignoreList={"temp.qys","test.qys"};
uiAddSong:=DynamicModule[{songPath,textInfo,candidates},
	textInfo=AssociationMap[""&,textInfoTags];
	SetDirectory[path];
	candidates=Complement[StringDrop[FileNames["*.qys"|"*.qym","Songs",Infinity],6],
		#<>"."<>index[[#,"Format"]]&/@songs,
		ignoreList
	];
	CreateDialog[Column[{Spacer[{40,40}],
		caption["_AddSong","Title"],
		Spacer[4],
		Row[{text[["SongPath"]],Spacer[12],PopupMenu[Dynamic@songPath,candidates,ImageSize->200]}],
		Column[Row[{Spacer[40],
			caption[tagName[[#]],"Text"],
			Spacer[16],
			InputField[Dynamic@textInfo[[#]],String],
		Spacer[40]}]&/@textInfoTags],
		Spacer[4],
		Row[{Button[text[["Add"]],addSong[songPath,textInfo];DialogReturn[QYMP],
		ImageSize->150,Enabled->Dynamic[textInfo[["SongName"]]!=""]],
		Spacer[20],
		Button[text[["Return"]],DialogReturn[refresh;uiPlaylist["All"]],ImageSize->150]}],
	Spacer[{40,40}]},Center,ItemSize->Full,Spacings->1],
	Background->styleColor[["Background"]],WindowTitle->text[["AddSong"]]]
];


uiDeleteSong[song_]:=CreateDialog[Column[{"",
	text[["SureToRemove"]],"",
	Row[{
		Button[text[["Confirm"]],
			index=Delete[index,song];
			DeleteFile[path<>"Meta\\"<>song<>".json"];
			DialogReturn[refresh;uiPlaylist["All"]],
		ImageSize->100],
		Spacer[20],
		Button[text[["Return"]],DialogReturn[uiModifySong[song]],ImageSize->100]			
	}],""
},Center,ItemSize->36],
Background->styleColor[["Background"]],WindowTitle->text[["DeleteSong"]]];