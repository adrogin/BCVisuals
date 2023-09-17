table 50105 "Style CS"
{
    Caption = 'Style';
    DataClassification = CustomerContent;
    LookupPageId = "Styles List CS";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Selector Code"; Code[20])
        {
            Caption = 'Selector';
            TableRelation = "Selector CS";

            trigger OnValidate()
            var
                Selector: Record "Selector CS";
            begin
                Selector.Get("Selector Code");
                "Selector Text" := Selector."Selector Text";
            end;
        }
        field(4; "Selector Text"; Text[1024])
        {
            Caption = 'Selector Text';

            trigger OnValidate()
            begin
                "Selector Code" := '';
            end;
        }
        field(5; StyleSheet; Blob)
        {
            Caption = 'StyleSheet';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    procedure ReadStyleSheetText(): Text
    var
        InStr: InStream;
        StyleText: Text;
    begin
        Rec.CalcFields(StyleSheet);
        if Rec.StyleSheet.HasValue then begin
            Rec.StyleSheet.CreateInStream(InStr);
            InStr.ReadText(StyleText);
        end;

        exit(StyleText);
    end;

    procedure WriteStyleSheetText(StyleText: Text)
    var
        OutStr: OutStream;
    begin
        Rec.StyleSheet.CreateOutStream(OutStr);
        OutStr.WriteText(StyleText);
    end;
}
