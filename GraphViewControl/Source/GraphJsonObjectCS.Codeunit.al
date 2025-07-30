codeunit 50103 "Graph Json Object CS"
{
    procedure GetValueFromObject(JObj: JsonToken; KeyName: Text): Text
    var
        Token: JsonToken;
    begin
        JObj.AsObject().Get(KeyName, Token);
        exit(Token.AsValue().AsText());
    end;
}