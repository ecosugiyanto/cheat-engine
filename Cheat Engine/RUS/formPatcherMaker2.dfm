�
 TFRMPATCHERMAKER2 0�  TPF0TfrmPatcherMaker2frmPatcherMaker2Left�Top� WidthHeightXBorderIcons Caption   Создатель патчейColor	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style OldCreateOrderPositionpoScreenCenterOnCreate
FormCreateOnShowFormShow
DesignSize6 PixelsPerInch`
TextHeight TLabelLabel1Left Top� Width$HeightAnchorsakLeftakBottom CaptionLegend  TLabelLabel2Left Top� Width� HeightHintr   Рекомендуется (я почти уверен, что это - то, в чем Вы нуждаетесь)AnchorsakLeftakBottom CaptionN   1=байты вокруг этого адреса как и ожидалосьFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameMS Sans Serif
Font.Style 
ParentFontParentShowHintShowHint	  TLabelLabel3Left Top
Width� HeightHint\   Рекомендуется (Если тебе нужен nop opcod(a) рядом с этимAnchorsakLeftakBottom Caption^   2 = Некоторые байты вокруг этого адреса получили noppedFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style 
ParentFontParentShowHintShowHint	  TLabelLabel4Left TopWidth� HeightHint�   Не рекомендуется. (Байты перед этим opcode, или байтами после этого opcode различны, и я не думаю, ЧТО CE делал это (а твая мама делал эта?:)AnchorsakLeftakBottom CaptionM   3=Только байты до или после как и ожидалосьFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style 
ParentFontParentShowHintShowHint	  TLabelLabel5Left�Top*Width� HeightHint�   Не РекомендуеЦЦа!! (Байты вокруг этого opcode даже не смотрят на тот  же самый, как когда Вы добавляли opcode к списку)AnchorsakLeftakBottom CaptionD   4 = байты вокруг этого opcode - не такие жеFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style 
ParentFontParentShowHintShowHint	  TLabelLabel6Left Top WidthHeightCaptiona   Выбери адрес(а) которые хочешь пачкануть и жми Хорошо  TListBox	FoundListLeft TopWidth� Height� AnchorsakLeftakTopakRightakBottom 
ItemHeightMultiSelect	ParentShowHintShowHintSorted	TabOrder OnClickFoundListClick  TButtonButton1Left� TopWidthKHeightAnchorsakTopakRight Caption   %>@>H>Default	EnabledTabOrderOnClickButton1Click  TButtonButton2Left� Top8WidthKHeightAnchorsakTopakRight Cancel	Caption   !1@>AModalResultTabOrder   