(* ::Package:: *)

BeginPackage["Thulium`Interface`Develop`", {
  "Thulium`System`",
  "Thulium`Assets`"
}];

ModifySong::usage = "ModifySong";
DeleteSong::usage = "DeleteSong";
AddSong::usage = "AddSong";

Begin["`Private`"];

ModifySong[song_] := Module[{textInfo},
  textInfo=SongIndex[[song,textInfoTags]];
  CreateDialog[Column[{Spacer[{20,20}],
    Caption[textInfo[["SongName"]],"Title"],
    Spacer[1],
    Grid[{Spacer[40],
      Caption[TagName[[#]],"Text"],
      Spacer[2],
      InputField[Dynamic @ textInfo[[#]],String],
    Spacer[40]}&/@textInfoTags,Alignment->Right],
    Spacer[1],
    Grid[{
      {Button[TextDict[["Save"]],putTextInfo[song,textInfo],ImageSize->150,Enabled->Dynamic[textInfo["SongName"]!=""]],
      Button[TextDict[["Undo"]],textInfo=SongIndex[[song,textInfoTags]],ImageSize->150]},
      {Button[TextDict[["DeleteSong"]],DialogReturn[DeleteSong[song]],ImageSize->150],
      Button[TextDict[["Return"]],DialogReturn[Thulium`Playlist["All"]],ImageSize->150]}
    }],Spacer[{20,20}]
  },Center,ItemSize->Full,Spacings->1],
  Background->WindowBackground,
  WindowTitle->TextDict["ModifySong"]];
];

putTextInfo[song_,textInfo_]:=With[
  {info=SongIndex[[song]]},
  Do[
    info[[tag]]=textInfo[[tag]],
  {tag,textInfoTags}];
  SongIndex[[song]]=info;
  Export[$LocalPath<>"Meta/"<>song<>".json",SongIndex[[song]]];
];

tagTemplate=<|"Image"->"","Uploader"->"","Tags"->{}|>;
addSong[songPath_,textInfo_]:=Module[{song,metaInfo,audio},
  song=StringDelete[songPath,RegularExpression["\\.\\w+$"]];
  AppendTo[SongIndex,song->Join[textInfo,tagTemplate]];
  putTextInfo[song,textInfo];
];

ignoreList={"test.qys"};
AddSong[]:=Module[{songPath,textInfo,candidates},
  textInfo=AssociationMap[""&,textInfoTags];
  SetDirectory[$LocalPath];
  candidates=Complement[StringDrop[StringReplace["\\"->"/"]/@FileNames["*.tm","Songs",Infinity],6],
    #<>".tm"&/@Keys@SongIndex,
    ignoreList
  ];
  CreateDialog[Column[{Spacer[{40,40}],
    Caption[TextDict["AddSong"],"Title"],
    Spacer[4],
    Row[{TextDict[["SongPath"]],Spacer[12],PopupMenu[Dynamic@songPath,candidates,ImageSize->200]}],
    Column[Row[{Spacer[40],
      Caption[TagName[[#]],"Text"],
      Spacer[16],
      InputField[Dynamic@textInfo[[#]],String],
    Spacer[40]}]&/@textInfoTags],
    Spacer[4],
    Row[{Button[TextDict[["Add"]],addSong[songPath,textInfo];DialogReturn[Thulium`Homepage[]],
    ImageSize->150,Enabled->Dynamic[textInfo[["SongName"]]!=""]],
    Spacer[20],
    Button[TextDict[["Return"]],DialogReturn[uiPlaylist["All"]],ImageSize->150]}],
  Spacer[{40,40}]},Center,ItemSize->Full,Spacings->1],
  Background->WindowBackground,WindowTitle->TextDict["AddSong"]]
];

DeleteSong[song_]:=CreateDialog[Column[{"",
  TextDict[["SureToRemove"]],"",
  Row[{
    Button[TextDict[["Confirm"]],
      SongIndex=Delete[SongIndex,song];
      DeleteFile[$LocalPath<>"Meta/"<>song<>".json"];
      DialogReturn[Thulium`Playlist["All"]],
    ImageSize->100],
    Spacer[20],
    Button[TextDict[["Return"]],DialogReturn[ModifySong[song]],ImageSize->100]      
  }],""
},Center,ItemSize->36],
Background->WindowBackground,WindowTitle->TextDict["DeleteSong"]];

End[];

EndPackage[];

Thulium`ModifySong = Thulium`Interface`Develop`ModifySong;
Thulium`AddSong = Thulium`Interface`Develop`AddSong;
Thulium`DeleteDong = Thulium`Interface`Develop`DeleteSong;


(* ::Input:: *)
(*ModifySong["Anima"];*)


(* ::Input:: *)
(*AddSong;*)
