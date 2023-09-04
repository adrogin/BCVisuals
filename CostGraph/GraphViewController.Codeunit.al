codeunit 50101 "Graph View Controller"
{
    procedure GraphLayoutEnumToText(GraphLayout: Enum "Graph Layout Name"): Text
    begin
        case GraphLayout of
            GraphLayout::Grid:
                exit('grid');
            GraphLayout::Circle:
                exit('circle');
            GraphLayout::Concentric:
                exit('concentric');
            GraphLayout::Breadthfirst:
                exit('breadthfirst');
        end;
    end;
}