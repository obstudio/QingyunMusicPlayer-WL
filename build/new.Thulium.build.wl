(* ::Package:: *)

With[
  {
    LogoCloud = FilledCurveBox[{BezierCurve[{
      {836.15, -454.53}, {926.4, -472.85}, {994.36, -552.64}, {994.36, -648.321},
      {994.36, -757.541}, {905.82, -846.05}, {796.61, -846.05}, {228.11, -846.05}, 
      {228.11, -846.05}, {228.11, -846.05}, {105.24, -846.05}, {5.65, -746.45}, 
      {5.65, -623.59}, {5.65, -526.62}, {67.72, -444.15}, {154.27, -413.69}, 
      {154.05, -409.54}, {153.95, -405.35}, {153.95, -401.12}, {153.95, -264.62}, 
      {264.62, -153.95}, {401.13, -153.95}, {492.72, -153.95}, {572.67, -203.77}, 
      {615.37, -277.79}, {638.92, -262.02}, {667.25, -252.82}, {697.74, -252.82}, 
      {779.65, -252.82}, {846.03, -319.23}, {846.03, -401.12}, 
      {846.03, -419.96}, {842.519, -437.96}, {836.13, -454.53}
    }]}],
    
    LogoNote = FilledCurveBox[{BezierCurve[{
      {569.07, -330.54}, {569.07, -330.54}, {565.67, -326.59}, {556.54, -320.44}, 
      {527.76, -301.04}, {492.09, -291.33}, {458.21, -288.52}, {447.88, -287.66}, 
      {434.85, -287.06}, {424.48, -286.9}, {399.31, -286.52}, {370.87, -289.95}, 
      {347.76, -301.3}, {492.81, -615.11}, {492.81, -615.11}, {492.81, -615.11}, 
      {470.14, -602.809}, {440.61, -596.78}, {409.06, -599.809}, {343.37, -606.12}, 
      {293.77, -649.33}, {298.28, -696.339}, {302.79, -743.339}, {359.71, -776.329}, 
      {425.41, -770.029}, {491.1, -763.718}, {540.7, -720.499}, {536.19, -673.499}, 
      {535.66, -668.019}, {534.419, -662.729}, {532.54, -657.669}, {532.53, -657.669}, 
      {532.53, -657.669}, {532.53, -657.669}, {424.34, -315.88}, {424.34, -315.88}, 
      {424.34, -315.88}, {430.44, -313.16}, {459.85, -311.49}, {476.72, -311.78}, 
      {499.7, -312.17}, {536.04, -319.6}, {546.2, -322.56}, 
      {555.89, -325.38}, {569.07, -330.54}, {569.07, -330.54}, 
      {569.07, -330.54}, {569.07, -330.54}, {569.07, -330.54}
    }]}],
    
    InitializeThulium = Hold[
      (* FIXME: optimized paclet tests *)
      If[Length[PacletCheckUpdate["QuantityUnits"]] != 0,
        PacletUpdate["QuantityUnits"];
        Quit[];
      ];
      localPath = StringReplace[NotebookDirectory[], "\\"->"/"];
      Get[localPath <> "library/initialization.wl"];
      Cells[CellTags -> "$title"];
      NotebookDelete[Cells[CellTags -> "$init"]];
      SelectionMove[First @ Cells[CellTags -> "$monitor"], Before, Cell, AutoScroll -> False];
      NotebookWrite[EvaluationNotebook[], Cell[BoxData @ RowBox[{
        TemplateBox[{4}, "Spacer1"],
        TemplateBox[{
          "Initialize Thulium",
          "Click to initialize the kernel.",
          Unevaluated @ InitializePackage
        }, "TextButtonMonitored"],
        TemplateBox[{4}, "Spacer1"],
        TemplateBox[{
          "Initialize Parser",
          "Click to initialize the parser.",
          Unevaluated @ InitializeParser
        }, "TextButtonMonitored"],
        TemplateBox[{4}, "Spacer1"],
        TemplateBox[{
          "Initialize Songs",
          "Click to initialize the songs.",
          Unevaluated @ update
        }, "TextButtonMonitored"],
        TemplateBox[{4}, "Spacer1"],
        TemplateBox[{
          "Start Front End",
          "Click to run the front end.",
          Hold @ homepage
        }, "TextButton"],
        TemplateBox[{4}, "Spacer1"]
      }], "Controls", CellTags -> "$controls"]];
    ]
  },
  
  build`TemporaryNotebook = CreateDialog[
    {
      Cell[
        BoxData @ RowBox[{
          StyleBox["Thulium Music Player",
            FontFamily -> "Source Sans Pro",
            FontSize -> 32,
            FontColor -> RGBColor[0.1, 0.4, 0.7]
          ],
          TemplateBox[{1}, "Spacer1"],
          StyleBox[FormBox["\"v2.3\"", InputForm],
            FontFamily -> "Source Sans Pro",
            FontSize -> 24,
            FontColor -> RGBColor[0.3, 0.5, 0.8]
          ]
        }],
        "Title", CellTags -> "$title"
      ],
          
      Cell[BoxData @ RowBox[{
        TemplateBox[{4}, "Spacer1"],
        TemplateBox[{
          "Start Thulium",
          "Click to initialize the kernel.",
          InitializeThulium
        }, "LogoButton"],
        TemplateBox[{4}, "Spacer1"]
      }], "Init", CellTags -> "$init"],
      
      Cell[BoxData @ Null, "Hidden", CellTags -> "$monitor"]
    },
    
    StyleDefinitions -> Notebook[{
      Cell[StyleData[StyleDefinitions -> "Default.nb"]],
      
      Cell[StyleData["Title"],
        TextAlignment -> Center,
        ShowStringCharacters -> False,
        CellMargins -> {{40, 40}, {16, 32}},
        ShowCellBracket -> False,
        Evaluatable -> False,
        Deletable -> False,
        Deployed -> True
      ],
      
      Cell[StyleData["Init"],
        CellMargins -> {{24, 24}, {60, 60}},
        TextAlignment -> Center,
        ShowCellBracket -> False,
        Deployed -> True
      ],
      
      Cell[StyleData["Controls"],
        CellMargins -> {{24, 24}, {8, 8}},
        TextAlignment -> Center,
        ShowCellBracket -> False,
        Deletable -> False,
        Deployed -> True
      ],
      
      Cell[StyleData["Tip"],
        CellMargins -> {{60, 60}, {8, 4}},
        Deployed -> True,
        Copyable -> False,
        ShowCellBracket -> False,
        TextAlignment -> Center,
        ShowCellLabel -> False,
        TemplateBoxOptions -> {DisplayFunction -> Function[
          FrameBox[
            AdjustmentBox[
              RowBox[{
                StyleBox["\[LightBulb]", FontSize -> 18],
                TemplateBox[{4}, "Spacer1"],
                StyleBox[#1, FontFamily -> "Calibri", FontSize -> 16]
              }],
              BoxBaselineShift -> 0,
              BoxMargins -> {{2, 2}, {2, 2}}
            ],
            Background -> RGBColor[1, 0.96, 0.98],
            RoundingRadius -> {8, 8},
            ContentPadding -> True,
            FrameStyle -> None
          ]
        ]}
      ],
      
      Cell[StyleData["Hidden"],
        FontSize -> 1,
        FontColor -> RGBColor[0, 0, 0, 0],
        CellSize -> {Inherited, 1},
        CellMargins -> {{24, 24}, {0, 0}},
        CellElementSpacings -> {"CellMinHeight" -> 1},
        Background -> Inherited,
        Evaluatable -> True,
        CellGroupingRules -> "InputGrouping"
      ],
      
      Cell[StyleData["ButtonTooltip"],
        TemplateBoxOptions -> {DisplayFunction -> Function[
          RowBox[{
            TemplateBox[{1}, "Spacer1"],
            StyleBox[#1,
              FontFamily -> "Calibri",
              FontSize -> 24
            ],
            TemplateBox[{1}, "Spacer1"]
          }]
        ]}
      ],
      
      Cell[StyleData["LogoButtonDisplay"],
        TemplateBoxOptions -> {DisplayFunction -> Function[
          GraphicsBox[{#3, LogoCloud, RGBColor[1, 1, 1], LogoNote}, ImageSize -> 240]
        ]}
      ],
      
      Cell[StyleData["TextButtonDisplay"],
        TemplateBoxOptions -> {DisplayFunction -> Function[
          FrameBox[
            RowBox[{
              TemplateBox[{4}, "Spacer1"],
              AdjustmentBox[
                StyleBox[#1,
                  FontFamily -> "Sitka Text",
                  FontSize -> 15,
                  FontColor -> #2
                ],
                BoxBaselineShift -> 0.2
              ],
              TemplateBox[{4}, "Spacer1"]
            }],
            Background -> #3,
            ImageMargins -> {{1, 1}, {0, 0}},
            ImageSize -> {Automatic, 32},
            BoxFrame -> {{0, 0}, {0, 0}},
            RoundingRadius -> {8, 8},
            ContentPadding -> True,
            BaselinePosition -> 1
          ]
        ]}
      ],
      
      Cell[StyleData["ButtonTemplate"],
        (*|    1    |    2    |    3    |    4   |    5    |*)
        (*| Default | Clicked | Hovered | Action | Tooltip |*)
        TemplateBoxOptions -> {DisplayFunction -> Function[
          PaneSelectorBox[{
            True -> TooltipBox[
              TagBox[
                TagBox[
                  PaneSelectorBox[{
                    True -> #2,
                    False -> #3
                  }, Dynamic @ CurrentValue["MouseButtonTest"]],
                EventHandlerTag @ {"MouseClicked" :> ReleaseHold @ #4}],
              MouseAppearanceTag @ "LinkHand"],
              TemplateBox[{#5}, "ButtonTooltip"],
              TooltipDelay -> 0.2,
              TooltipStyle -> {
                CellFrameMargins -> {{4, 4}, {4, 4}},
                CellFrameColor -> RGBColor[0.7, 0.7, 0.6, 0.5],
                Background -> RGBColor[1, 1, 0.9, 0.7]
              }
            ],
            False -> #1
          }, Dynamic @ CurrentValue["MouseOver"]]
        ]}
      ],
      
      Cell[StyleData["TextButton"],
        TemplateBoxOptions -> {DisplayFunction -> Function[
          TemplateBox[{
            TemplateBox[{#1,
              RGBColor[0.2, 0.1, 0],
              RGBColor[0.92, 0.96, 1]
            }, "TextButtonDisplay"],
            TemplateBox[{#1,
              RGBColor[0, 0, 0],
              RGBColor[0.5, 0.8, 1]
            }, "TextButtonDisplay"],
            TemplateBox[{#1,
              RGBColor[0.08, 0.04, 0],
              RGBColor[0.8, 0.9, 1]
            }, "TextButtonDisplay"],
            #3, #2
          }, "ButtonTemplate"]
        ]}
      ],
      
      Cell[StyleData["LogoButton"],
        TemplateBoxOptions -> {DisplayFunction -> Function[
          TemplateBox[{
            TemplateBox[{#1,
              RGBColor[0.2, 0.1, 0],
              RGBColor[0.8, 0.96, 1]
            }, "LogoButtonDisplay"],
            TemplateBox[{#1,
              RGBColor[0, 0, 0],
              RGBColor[0.5, 0.8, 1]
            }, "LogoButtonDisplay"],
            TemplateBox[{#1,
              RGBColor[0.08, 0.04, 0],
              RGBColor[0.72, 0.9, 1]
            }, "LogoButtonDisplay"],
            #3, #2
          }, "ButtonTemplate"]
        ]}
      ],
      
      Cell[StyleData["TextButtonMonitored"],
        TemplateBoxOptions -> {DisplayFunction -> Function[
          TemplateBox[{#1, #2, Hold[
            NotebookLocate["$monitor"];
            NotebookWrite[EvaluationNotebook[], Cell[
              BoxData @ MakeBoxes @ Evaluate @ #3,
              "Hidden",
              CellTags -> "$monitor"
            ], All];
            SelectionEvaluate[EvaluationNotebook[]];
            NotebookLocate["$title"];
          ]}, "TextButton"]
        ]}
      ],
      
      (* Enhancement for cell style - PrintTemporary *)
      Cell[StyleData["PrintTemporary", StyleDefinitions -> "PrintTemporary"],
        FontFamily -> "Calibri",
        FontSize -> 16,
        CellMargins -> {{60, 60}, {8, 4}},
        Deployed -> True,
        Copyable -> False,
        ShowCellBracket -> False,
        TextAlignment -> Center
      ],
      
      (* Enhancement for cell style - Input *)
      Cell[StyleData["Input", StyleDefinitions -> "Input"],
        NumberMarks -> False,
        Editable -> True,
        Evaluatable -> True,
        StyleKeyMapping -> {">" -> "Music"},
        ContextMenu -> {
          MenuItem["Cut", "Cut"],
          MenuItem["Copy", "Copy"],
          MenuItem["Paste", FrontEnd`Paste[After]],
          Delimiter,
          MenuItem["Evaluate Cell", "EvaluateCells"]
        }
      ]
    }],
    
    ShowCellLabel -> False,
    ShowCellTags -> False,
    ShowCellBracket -> False,
    CellGrouping -> Manual,
    Background -> RGBColor["#FFFFFF"],
    WindowTitle -> " Thulium Music Player 2.3",
    WindowElements -> {},
    WindowFrameElements -> {"CloseBox", "MinimizeBox", "ZoomBox"},
    WindowSize -> {1440, 900},
    WindowFrame -> "ModelessDialog",
    Magnification -> 2,
    Saveable -> False,
    Evaluatable -> False,
    Editable -> False
  ];
  
  NotebookSave[build`TemporaryNotebook, localPath <> "Thulium.new.nb"];
  NotebookClose[build`TemporaryNotebook];
  NotebookOpen[localPath <> "Thulium.new.nb"];
]

