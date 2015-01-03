{ <- Illegal Characters? Simply remove! It is the UTF-8 Byte Order Mark.
     Open with UTF-8 enabled Editor if you want to read the Cyrillic Text
 ************************************************************
 SimpleXML - Библиотека для синтаксического разбора текстов XML
   и преобразования в иерархию XML-объектов.
   И наоборот: можно сформировать иерархию XML-объектов, и
   уже из нее получить текст XML.
   Достойная замена для MSXML. При использовании Ansi-строк
   работает быстрее и кушает меньше памяти.

 (с) Авторские права 2002,2003 Михаил Власов.
   Библиотека бесплатная и может быть использована по любому назначению.
   Разрешается внесение любых изменений и использование измененных
   библиотек без ограничений.
   Единственное требование: Данный текст должен присутствовать
   без изменений во всех модификациях библиотеки.

   Все пожелания приветствую по адресу misha@integro.ru
   Так же рекомендую посетить мою страничку: http://mv.rb.ru
   Там Вы всегда найдете самую последнюю версию библиотеки.
   Желаю приятного программирования, Михаил Власов.

   Translations: Yahoo Babel Fish / Samuel Soldat

   2015 Version by Kroligoff: Google code - https://code.google.com/p/simplexml-delphi/

SimpleXML - By Michael Vlasov. Library for XML parsing and convertion to
   XML objects hierarchy and vise versa. Worthy replacement for MSXML.
   While using ANSI strings works much faster.

 (c) Copyrights 2002, 2003 Michail Vlasov.
   This Library is free and can be used for any needs. The introduction of
   any changes and the use of those changed library is permitted without
   limitations. Only requirement:
   This text must be present without changes in all modifications of library.

   All wishes I greet to misha@integro.ru. So I recommend to visit my page: http://mv.rb.ru
   There you will always find the quite last version of library. I desire pleasant programming,
   Michail Vlasov. It must be present without changes in all modifications of library.

   -----------------------------------------------------------------------------------------------

   What's new:
   03-Jan-2015 - Add Method FindNodes (Kroligoff) -
                 Find Nodes and SubNodes by name
   02-Jan-2015 - Fix for Delphi XE
   03-Dec-2009 so - Support for Delphi 2007/2009
                  - Character set conversions included (only some few)
                  - Make library thread safe by removing some global vars
                  - SelectSingleNode and SelectNodes understand XML Pathes
                  - FullPath return XML Path of current Node
                  - License change to Mozilla Public License Version 1.1
   23-Dec-2009 so - CloneNode copy data
   24-Dec-2009 so - Improved performance for parsing
   27-Dec-2009 so - Improved performance for hash and save
   03-Jan-2010 so - Minor bugs in russian error messages fixed
   14-Apr-2010 so - ExchangeChilds added                        
   06-Dec-2010 so - Minor Changes in error messages 
   16-Apr-2012 so - BOM support added
   16-Jul-2012 so - Error message in the case of 4-Byte-Unicode (not supported)
   12-Nov-2012 vz - Reformed logic saved long attributes - thanks to Vadim Zharkov
   23-Nov-2012 so - Bug: It is not possible to copy aNode from one Doc to another 
   23-Feb-2013 so - Bug in Get_Text
   24-Mar-2013 lg - Some new features - thanks to Lukas Gebauer
                  - Ansi-version can use UTF8-Strings (see XMLDefaultcodepage)
                  - Error messages with line and columne numbers
                  - OnTagBegin/OnTagEnd-Events
                  - 4 Byte-UTF8-Decoding
   31-Mar-2013 so - All internal data are UTF8 encoded strings. TXMLElements do
                    not save data anymore, instead of this, data is saved by
                    text or cdata child nodes
   03-Apr-2013 vb - DateTime strings are now somewhat more W3C compliant
                  - thanks to Vladimir Belyaev
   16-Apr-2013 so - More speed for TXMLSaver and MyXMLString converter

   -----------------------------------------------------------------------------------------------

 (c) Copyrights 2009 - 2013 Samuel Soldat.

                     Latest releases of SimpleXml.pas are made available through the
                      distribution site at: http://www.audio-data.de/simplexml.html

                        See readme.txt for an introduction and documentation.

              *********************************************************************
              * The contents of this file are used with permission, subject to    *
              * the Mozilla Public License Version 1.1 (the "License"); you may   *
              * not use this file except in compliance with the License. You may  *
              * obtain a copy of the License at                                   *
              * http:  www.mozilla.org/MPL/MPL-1.1.html                           *
              *                                                                   *
              * Software distributed under the License is distributed on an       *
              * "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or    *
              * implied. See the License for the specific language governing      *
              * rights and limitations under the License.                         *
              *                                                                   *
              *  Contributor(s)                                                   *
              *  (mv)  Michail Vlasov    <misha@integro.ru>                       *
              *  (so)  Samuel Soldat     <samuel.soldat@audio-data.de>            *
              *                                                                   *
              *********************************************************************

   -----------------------------------------------------------------------------------------------
}
unit SimpleXML;

interface

{ How to customize your simplexml.pas
  ===================================
  1) If you use Delphi prior Version 2009 (Unicode-Delphi), you can chose the
     codepage for TXmlString (the strings used to comunicate with your application).
     This is done by setting of XMLDefaultcodepage or XMLCodepage. By Default the
     system codepage is used. If you want to use widestring instead of ansistring,
     you can enable the compiler directive XML_WIDE_CHARS.

     If you use Delphi Version 2009 or newer (Unicode-Delphi), simplexml.pas use
     Unicodestrings for TXmlString.

  2) You can chose the language of the errormessages. Currently only English and
     Russian is supported. Disable the compiler directive "English" to enable
     Russian error messages.
}
uses
  SysUtils, Types, Windows, Classes;
{$IF CompilerVersion>=18}{$DEFINE Regions}{$IFEND}
{$IFDEF Regions}{$REGION 'Constantes Declaration'}{$ENDIF}
const
  BinXmlSignature: UTF8String = '< binary-xml >';

  DefaultHashSize = 499;

  {$ifndef Unicode}
  // For Delphi prior Delphi 2009 you can chose the codepage used for TXmlString.
  // Set CP_UTF8, if you want to use UTF8 encoded AnsiStrings. At runtime you
  // can change the variable XMLCodepage
  XMLDefaultcodepage = CP_ACP;

  {$endif}
  XSTR_NULL = '{{null}}';

  SourceBufferSize=$4000;

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Interfaces'}{$ENDIF}
type
 { TXmlString - тип строковых переменных, используемых в SimpleXML.
   Может быть String или WideString.
   TXmlString - The type of the string variables, used by the user interface
   of SimpleXML. There can be AnsiString or WideString. Until Delphi 2009 you 
   can chose the codepage used for TXmlString. If your Delphi is version 2009
   or newer, TXmlString is always string (Unicode).
   Internal used strings are always UTF8.}

  {$DEFINE English} //language of error messages

  {$IFNDEF Unicode}
    {.$DEFINE XML_WIDE_CHARS <---remove the "." character if you want to use WideString}
    {$IFDEF XML_WIDE_CHARS}
    PXmlChar = PWideChar;
    TXmlChar = WideChar;
    TXmlString = WideString;
    {$ELSE}
    PXmlChar = PChar;
    TXmlChar = Char;
    TXmlString = String;
    {$ENDIF}
  {$ELSE}
  PXmlChar = PChar;
  TXmlChar = Char;
  TXmlString = String;
  {$ENDIF}

  {$IF not Declared(RawByteString)}
  RawByteString = AnsiString;
  {$IFEND}
  {$IF not Declared(TBytes)}
  TBytes = TByteDynArray;
  {$IFEND}
  {$IF (CompilerVersion<20.00)}
  NativeInt = type Integer;     //Override NativeInt because in Delphi2007 SizeOf(NativeInt)<>SizeOf(Pointer)
  {$IFEND}

  {$define myXMLString_is_UTF8String}
  {.$define myXMLString_is_TBytes}
  {$ifdef myXMLString_is_UTF8String}
  TmyXMLString = UTF8String;
  TmyXMLChar = AnsiChar;
  {$endif}
  {$ifdef myXMLString_is_TBytes}
  TMyXMLString = TBytes;
  TMyXMLChar = Byte;
  {$endif}
  PMyXMLChar = ^TmyXMLChar;

  TXmlNodeType = (NODE_INVALID, NODE_ELEMENT, NODE_TEXT, NODE_CDATA_SECTION,
                  NODE_PROCESSING_INSTRUCTION, NODE_COMMENT, NODE_DOCUMENT);

  IXmlDocument = interface;
  IXmlElement = interface;
  IXmlText = interface;
  IXmlCDATASection = interface;
  IXmlComment = interface;
  IXmlProcessingInstruction = interface;

  // IXmlBase - базовый интерфейс для всех интерфейсов SimpleXML.
  // Base of all interfaces uses in SimpleXML
  IXmlBase = interface
    // GetObject - возвращает ссылку на объект, реализующий интерфейс.
    function GetObject: TObject;
  end;

  // IXmlNameTable - таблица имен. Каждому имени сопоставляется некий
  // уникальный числовой идентификатор. Используется для хранения
  // азваний тэгов и атрибутов.
  // IXmlNameTable - Table for names. Each name maps to a unique numeric identifier.
  // Used to store Names of tags and attributes.
  IXmlNameTable = interface(IXmlBase)
    // GetID - возвращает числовой идентификатор указанной строки.
    function GetID(const aName: TXmlString): NativeInt;
    // GetID - возвращает строку, соответствующую указанному числовому
    // идентификатору.
    function GetName(anID: NativeInt): TXmlString;
  end;

  IXmlNode = interface;

  // IXmlNodeList - список узлов. Список организован в виде массива.
  // Доступ к элементам списка по индексу
  IXmlNodeList = interface(IXmlBase)
    // Get_Count - количество узлов в списке
    function Get_Count: Integer;
    // Get_Item - получить узел по индексу
    function Get_Item(anIndex: Integer): IXmlNode;
    procedure Exchange(Index1, Index2: Integer);
    // Get_XML - возвращает представление элементов списка в формате XML
    function Get_XML: TXmlString;

    property Count: Integer read Get_Count;
    property Item[anIndex: Integer]: IXmlNode read Get_Item; default;
    property XML: TXmlString read Get_XML;
  end;

  // IXmlNode - узел XML-дерева
  IXmlNode = interface(IXmlBase)
    // Get_NameTable - таблица имен, используемая данным узлом
    function Get_NameTable: IXmlNameTable;
    // Get_NodeName - возвращает название узла. Интерпретация названия узла
    // зависит от его типа
    function Get_NodeName: TXmlString;
    // Get_NodeNameID - возвращает код названия узла
    function Get_NodeNameID: NativeInt;
    // Get_NodeType - возвращает тип узла
    function Get_NodeType: TXmlNodeType;
    // Get_Text - возвращает текст узла
    function Get_Text: TXmlString;
    // Set_Text - изменяет текст узла
    procedure Set_Text(const aValue: TXmlString);
    // Get_DataType - возаращает тип данных узла в терминах вариантов
    function Get_DataType: TVarType;
    // Set_DataType - This specifies the data type of value saved as text or cdata
    procedure Set_DataType(const aValue: TVarType);
    // Get_TypedValue - Return the saved value as variant with the type specifies in DataType
    function Get_TypedValue: Variant;
    // Set_TypedValue - Change the value and the data type of text/cdata child
    procedure Set_TypedValue(const aValue: Variant);
    // Get_XML - возвращает представление узла и всех вложенных узлов
    // в формате XML.
    function Get_XML: TXmlString;

    // CloneNode - создает точную копию данного узла
    //  Если задан признак aDeep, то создастся копия
    //  всей ветви иерархии от данного узла.
    function CloneNode(aDeep: Boolean = True): IXmlNode;

    // Get_ParentNode - возвращает родительский узел
    function Get_ParentNode: IXmlNode;
    // Get_OwnerDocument - возвращает XML-документ,
    //  в котором расположен данный узел
    function Get_OwnerDocument: IXmlDocument;

    // Get_ChildNodes - возвращает список дочерних узлов
    function Get_ChildNodes: IXmlNodeList;
    // AppendChild - добавляет указанный узел в конец списка дочерних узлов
    procedure AppendChild(const aChild: IXmlNode);
    // InsertBefore - добавляет указанный узел в указанное место списка дочерних узлов
    procedure InsertBefore(const aChild, aBefore: IXmlNode);
    // ReplaceChild - заменяет указанный узел другим узлом
    procedure ReplaceChild(const aNewChild, anOldChild: IXmlNode);
    // RemoveChild - удаляет указанный узел из списка дочерних узлов
    procedure RemoveChild(const aChild: IXmlNode);
    // ExchangeChild - Change node order
    procedure ExchangeChilds(const aChild1, aChild2: IXmlNode);

    // AppendElement - создает элемент и добавляет его в конец списка
    //  в конец списка дочерних объектов
    // created an element and add it to the end of the list as child node
    function AppendElement(aNameID: NativeInt): IXmlElement; overload;
    function AppendElement(const aName: TxmlString): IXmlElement; overload;

    // AppendText - создает текстовый узел и добавляет его
    //  в конец списка дочерних объектов
    function AppendText(const aData: TXmlString): IXmlText;

    // AppendCDATA - создает секцию CDATA и добавляет ее
    //  в конец списка дочерних объектов
    function AppendCDATA(const aData: TXmlString): IXmlCDATASection;

    // AppendComment - создает комментарий и добавляет его
    //  в конец списка дочерних объектов
    function AppendComment(const aData: TXmlString): IXmlComment;

    // AppendProcessingInstruction - создает инструкцию и добавляет её
    //  в конец списка дочерних объектов
    function AppendProcessingInstruction(aTargetID: NativeInt;
      const aData: TXmlString): IXmlProcessingInstruction; overload;
    function AppendProcessingInstruction(const aTarget: TXmlString;
      const aData: TXmlString): IXmlProcessingInstruction; overload;

    // GetChildText - возвращает значение дочернего узла
    // SetChildText - добавляет или изменяет значение дочернего узла
    function GetChildText(const aName: TXmlString; const aDefault: TXmlString = ''): TXmlString; overload;
    function GetChildText(aNameID: NativeInt; const aDefault: TXmlString = ''): TXmlString; overload;
    procedure SetChildText(const aName, aValue: TXmlString); overload;
    procedure SetChildText(aNameID: NativeInt; const aValue: TXmlString); overload;

    // NeedChild - возвращает дочерний узел с указанным именем.
    //  Если узел не найден, то генерируется исключение
    function NeedChild(aNameID: NativeInt): IXmlNode; overload;
    function NeedChild(const aName: TXmlString): IXmlNode; overload;

    // EnsureChild - возвращает дочерний узел с указанным именем.
    //  Если узел не найден, то он будет создан
    function EnsureChild(aNameID: NativeInt): IXmlNode; overload;
    function EnsureChild(const aName: TXmlString): IXmlNode; overload;

    // RemoveAllChilds - удаляет все дочерние узлы
    procedure RemoveAllChilds;

    //FindNodes - находит все узлы и вложенные узлы по названию
    function FindNodes(const anExpression: TXmlString): IXmlNodeList;
    // SelectNodes - производит выборку узлов, удовлетворяющих
    //  указанным критериям
    function SelectNodes(const anExpression: TXmlString): IXmlNodeList;
    // SelectSingleNode - производит поиск первого узла, удовлетворяющего
    //  указанным критериям
    // SelectSingleNode - Get specified Node. You can indicate a complete path
    function SelectSingleNode(const anExpression: TXmlString): IXmlNode;
    // FullPath - Return full XML path to the XML Node - can used as anExpression
    function FullPath: TXmlString;
    // FindElement - производит поиск первого узла, удовлетворяющего
    //  указанным критериям
    function FindElement(const anElementName, anAttrName: String; const anAttrValue: Variant): IXmlElement;

    // Get_AttrCount - возвращает количество атрибутов
    function Get_AttrCount: Integer;
    // Get_AttrNameID - возвращает код названия атрибута
    function Get_AttrNameID(anIndex: Integer): NativeInt;
    // Get_AttrName - возвращает название атрибута
    function Get_AttrName(anIndex: Integer): TXmlString;
    // RemoveAttr - удаляет атрибут
    procedure RemoveAttr(const aName: TXmlString); overload;
    procedure RemoveAttr(aNameID: NativeInt); overload;
    // RemoveAllAttrs - удаляет все атрибуты
    procedure RemoveAllAttrs;

    // AttrExists - проверяет, задан ли указанный атрибут.
    function AttrExists(aNameID: NativeInt): Boolean; overload;
    function AttrExists(const aName: TXmlString): Boolean; overload;

    // GetAttrType - возаращает тип данных атрибута в терминах вариантов
    function GetAttrType(aNameID: NativeInt): Integer; overload;
    function GetAttrType(const aName: TXmlString): Integer; overload;

    // GetAttrType - возвращает тип атрибута
    //  Result
    // GetVarAttr - возвращает типизированное значение указанного атрибута.
    //  Если атрибут не задан, то возвращается значение по умолчанию
    // SetAttr - изменяет или добавляет указанный атрибут
    function GetVarAttr(aNameID: NativeInt; const aDefault: Variant): Variant; overload;
    function GetVarAttr(const aName: TXmlString; const aDefault: Variant): Variant; overload;
    procedure SetVarAttr(aNameID: NativeInt; const aValue: Variant); overload;
    procedure SetVarAttr(const aName: TXmlString; const aValue: Variant); overload;

    // NeedAttr - возвращает строковое значение указанного атрибута.
    //  Если атрибут не задан, то генерируется исключение
    function NeedAttr(aNameID: NativeInt): TXmlString; overload;
    function NeedAttr(const aName: TXmlString): TXmlString; overload;

    // GetAttr - возвращает строковое значение указанного атрибута.
    //  Если атрибут не задан, то возвращается значение по умолчанию
    // SetAttr - изменяет или добавляет указанный атрибут
    function GetAttr(aNameID: NativeInt; const aDefault: TXmlString = ''): TXmlString; overload;
    function GetAttr(const aName: TXmlString; const aDefault: TXmlString = ''): TXmlString; overload;
    procedure SetAttr(aNameID: NativeInt; const aValue: TXmlString); overload;
    procedure SetAttr(const aName, aValue: TXmlString); overload;

    // GetBytesAttr - return attribut as raw data
    function GetBytesAttr(aNameID: NativeInt; const aDefault: TBytes): TBytes; overload;
    function GetBytesAttr(const aName: TXmlString; const aDefault: TBytes): TBytes; overload;

    // GetBoolAttr - возвращает целочисленное значение указанного атрибута
    // SetBoolAttr - изменяет или добавляет указанный атрибут целочисленным
    //  значением
    function GetBoolAttr(aNameID: NativeInt; aDefault: Boolean = False): Boolean; overload;
    function GetBoolAttr(const aName: TXmlString; aDefault: Boolean = False): Boolean; overload;
    procedure SetBoolAttr(aNameID: NativeInt; aValue: Boolean = False); overload;
    procedure SetBoolAttr(const aName: TXmlString; aValue: Boolean); overload;

    // GetIntAttr - возвращает целочисленное значение указанного атрибута
    // SetIntAttr - изменяет или добавляет указанный атрибут целочисленным
    //  значением
    function GetIntAttr(aNameID: NativeInt; aDefault: Integer = 0): Integer; overload;
    function GetIntAttr(const aName: TXmlString; aDefault: Integer = 0): Integer; overload;
    procedure SetIntAttr(aNameID: NativeInt; aValue: Integer); overload;
    procedure SetIntAttr(const aName: TXmlString; aValue: Integer); overload;

    // GetDateTimeAttr - возвращает целочисленное значение указанного атрибута
    // SetDateTimeAttr - изменяет или добавляет указанный атрибут целочисленным
    //  значением
    function GetDateTimeAttr(aNameID: NativeInt; aDefault: TDateTime = 0): TDateTime; overload;
    function GetDateTimeAttr(const aName: TXmlString; aDefault: TDateTime = 0): TDateTime; overload;
    procedure SetDateTimeAttr(aNameID: NativeInt; aValue: TDateTime); overload;
    procedure SetDateTimeAttr(const aName: TXmlString; aValue: TDateTime); overload;

    // GetFloatAttr - возвращает значение указанного атрибута в виде
    //  вещественного числа
    // SetFloatAttr - изменяет или добавляет указанный атрибут вещественным
    //  значением
    function GetFloatAttr(aNameID: NativeInt; aDefault: Double = 0): Double; overload;
    function GetFloatAttr(const aName: TXmlString; aDefault: Double = 0): Double; overload;
    procedure SetFloatAttr(aNameID: NativeInt; aValue: Double); overload;
    procedure SetFloatAttr(const aName: TXmlString; aValue: Double); overload;

    // GetHexAttr - получение значения указанного атрибута в целочисленном виде.
    //  Строковое значение атрибута преобразуется в целое число. Исходная
    //  строка должна быть задана в шестнадцатиричном виде без префиксов
    //  ("$", "0x" и пр.) Если преобразование не может быть выполнено,
    //  генерируется исключение.
    //  Если атрибут не задан, возвращается значение параметра aDefault.
    // GetHexAttr - getting the value of the specified attribute in integer form.    
    // A string attribute value is converted to an cardinal. Initial    
    // String must be specified in hexadecimal notation with no prefix    
    // ("$", "0x", etc.) If the conversion can not be performed,    
    // Exception is thrown.
    function GetHexAttr(const aName: TXmlString; aDefault: Cardinal = 0): Cardinal; overload;
    function GetHexAttr(aNameID: NativeInt; aDefault: Cardinal = 0): Cardinal; overload;
    // SetHexAttr - изменение значения указанного атрибута на строковое
    //  представление целого числа в шестнадцатиричном виде без префиксов
    //    ("$", "0x" и пр.) Если преобразование не может быть выполнено,
    //    генерируется исключение.
    //    Если атрибут не был задан, до он будет добавлен.
    //    Если был задан, то будет изменен.
    procedure SetHexAttr(const aName: TXmlString; aValue: Cardinal; aDigits: Integer = 8); overload;
    procedure SetHexAttr(aNameID: NativeInt; aValue: Cardinal; aDigits: Integer = 8); overload;

    //  GetEnumAttr - ищет значение атрибута в указанном списке строк и
    //    возвращает индекс  найденной строки. Если атрибут задан но не найден
    //    в списке, то генерируется исключение.
    //    Если атрибут не задан, возвращается значение параметра aDefault.
    function GetEnumAttr(const aName: TXmlString;
      const aValues: array of TXmlString; aDefault: Integer = 0): Integer; overload;
    function GetEnumAttr(aNameID: NativeInt;
      const aValues: array of TXmlString; aDefault: Integer = 0): Integer; overload;

    function NeedEnumAttr(const aName: TXmlString;
      const aValues: array of TXmlString): Integer; overload;
    function NeedEnumAttr(aNameID: NativeInt;
      const aValues: array of TXmlString): Integer; overload;

    function Get_Values(const aName: TXmlString): Variant;
    procedure Set_Values(const aName: TXmlString; const aValue: Variant);

    function AsElement: IXmlElement;
    function AsText: IXmlText;
    function AsCDATASection: IXmlCDATASection;
    function AsComment: IXmlComment;
    function AsProcessingInstruction: IXmlProcessingInstruction;

    property NodeName: TXmlString read Get_NodeName;
    property NodeNameID: NativeInt read Get_NodeNameID;
    property NodeType: TXmlNodeType read Get_NodeType;
    property ParentNode: IXmlNode read Get_ParentNode;
    property OwnerDocument: IXmlDocument read Get_OwnerDocument;
    property NameTable: IXmlNameTable read Get_NameTable;
    property ChildNodes: IXmlNodeList read Get_ChildNodes;
    property AttrCount: Integer read Get_AttrCount;
    property AttrNames[anIndex: Integer]: TXmlString read Get_AttrName;
    property AttrNameIDs[anIndex: Integer]: NativeInt read Get_AttrNameID;
    // Read Text: Get the combined values ​​of the node and all its children.
    // Write Text: Set the value of the node, the values of the children are not affected!
    property Text: TXmlString read Get_Text write Set_Text;
    // Gets/Sets the data type of the value
    property DataType: TVarType read Get_DataType write Set_DataType;
    // Gets/Sets the value of the node.
    property TypedValue: Variant read Get_TypedValue write Set_TypedValue;
    // Returns a XML text representation of the node and all sub nodes in XML.
    property XML: TXmlString read Get_XML;
    // aName = '': Same as TypedValue
    // aName = <Name of child>: Gets/Sets the TypedValue of a child
    // aName = @<Name of attribute>: Gets/sets the TypedValue of a attribute
    property Values[const aName: TXmlString]: Variant read Get_Values write Set_Values; default;
  end;

  IXmlElement = interface(IXmlNode)
    //  ReplaceTextByCDATASection -
    procedure ReplaceTextByCDATASection(const aText: TXmlString);

    // ReplaceTextByBinaryData - Remove all text and cdata subnodes. Insert a
    // a new text subnode and copy aData into. The encoding of the "Data" is
    // always UTF8
    procedure ReplaceTextByBinaryData(const aData; aSize: Integer);

    //  GetTextAsBinaryData - Get text as UTF8 encoded byte array.
    function GetTextAsBinaryData: TBytes;

  end;

  IXmlCharacterData = interface(IXmlNode)
  end;

  // XML-node, which is a text block.
  IXmlText = interface(IXmlCharacterData)
  end;

  IXmlCDATASection = interface(IXmlCharacterData)
  end;

  IXmlComment = interface(IXmlCharacterData)
  end;

  IXmlProcessingInstruction = interface(IXmlNode)
  end;

  THookTag = procedure(Sender: TObject; const aNode: IXmlNode) of object;

  IXmlDocument = interface(IXmlNode)
    function Get_DocumentElement: IXmlElement;
    function Get_BinaryXML: TBytes;
    function Get_OnTagBegin: THookTag;
    procedure Set_OnTagBegin(aValue: THookTag);
    function Get_OnTagEnd: THookTag;
    procedure Set_OnTagEnd(aValue: THookTag);
    function Get_PreserveWhiteSpace: Boolean;
    procedure Set_PreserveWhiteSpace(aValue: Boolean);

    function NewDocument(const aVersion, anEncoding: TXmlString;
      aRootElementNameID: NativeInt): IXmlElement; overload;
    function NewDocument(const aVersion, anEncoding,
      aRootElementName: TXmlString): IXmlElement; overload;

    function CreateElement(aNameID: NativeInt): IXmlElement; overload;
    function CreateElement(const aName: TXmlString): IXmlElement; overload;
    function CreateText(const aData: TXmlString): IXmlText;
    function CreateCDATASection(const aData: TXmlString): IXmlCDATASection;
    function CreateComment(const aData: TXmlString): IXmlComment;
    function CreateProcessingInstruction(const aTarget: TXmlString;
      const aData: TXmlString = ''): IXmlProcessingInstruction; overload;
    function CreateProcessingInstruction(aTargetID: NativeInt;
      const aData: TXmlString = ''): IXmlProcessingInstruction; overload;

    procedure LoadXML(const aXML: RawByteString; const Encoding: String = '');
    procedure LoadBinaryXML(const data; const Count: Integer);

    procedure Load(aStream: TStream; const Encoding: String = ''); overload;
    procedure Load(const aFileName: String; const Encoding: String = ''); overload;

    procedure LoadResource(aType, aName: PChar);

    procedure Save(aStream: TStream); overload;
    procedure Save(const aFileName: String); overload;

    procedure SaveBinary(aStream: TStream); overload;
    procedure SaveBinary(const aFileName: String); overload;

    function GetEncoding: TXmlString;
    procedure SetEncoding(const Endcoding: TXmlString);

    property PreserveWhiteSpace: Boolean read Get_PreserveWhiteSpace write Set_PreserveWhiteSpace;
    property DocumentElement: IXmlElement read Get_DocumentElement;
    property BinaryXML: TBytes read Get_BinaryXML;
    property OnTagBegin: THookTag read Get_OnTagBegin write Set_OnTagBegin;
    property OnTagEnd: THookTag read Get_OnTagEnd write Set_OnTagEnd;
  end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Document Creation Functions'}{$ENDIF}
function CreateNameTable(aHashTableSize: Integer = DefaultHashSize): IXmlNameTable;
function CreateXmlDocument(const aRootElementName: String = '';
                           const aVersion: String = '';    // '1.0'
                           const anEncoding: String = '';  // 'UTF-8'
                           const aNameTable: IXmlNameTable = nil): IXmlDocument;

function CreateXmlElement(const aName: TXmlString; const aNameTable: IXmlNameTable = nil): IXmlElement;
function LoadXmlDocumentFromXML(const aXML: RawByteString; const anEncoding: String = ''): IXmlDocument;
function LoadXmlDocumentFromBinaryXML(const aXML: RawByteString): IXmlDocument;

function LoadXmlDocument(aStream: TStream): IXmlDocument; overload;
function LoadXmlDocument(const aFileName: String): IXmlDocument; overload;
function LoadXmlDocument(aResType, aResName: PChar): IXmlDocument; overload;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Globle Variables'}{$ENDIF}
var
  DefaultPreserveWhiteSpace: Boolean = False;
  DefaultIndentText: TmyXmlString = #9;
  XMLPathDelimiter: TXmlString = '\';

  {$if not defined(XML_WIDE_CHARS) and not defined(Unicode)}

  // Codepage for TXmlString if it is AnsiString
  // !!! do not change if you have one or more open XMLDocuments !!!
  XMLCodepage: Word = XMLDefaultcodepage;

  {$ifend}

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Helper Functions'}{$ENDIF}
// replaces some XML control characters by XML entity
function TextToXML(const aText: TmyXmlString): TmyXmlString;

// Base64 Encoding
function BinToBase64(const aBin; aSize: Cardinal; aMaxLineLength: Cardinal=76): RawByteString;

// Base64 Decoding
function Base64ToBin(const aBase64: RawByteString): TBytes;
// Decode aSize Bytes
//function Base64Decode(var Buffer; Size: Cardinal; const Base64: TMyXMLString): Cardinal;

// Start aData with '<?xml ' or binary signature?
function IsXmlDataString(const aData: RawByteString): Boolean;

function XmlIsInBinaryFormat(const aData: RawByteString): Boolean;

procedure PrepareToSaveXml(var anElem: IXmlElement; const aChildName: String);

function PrepareToLoadXml(var anElem: IXmlElement; const aChildName: String): Boolean;

procedure GetCodingNameList(List: TStrings);
{$IFDEF Regions}{$ENDREGION}{$ENDIF}

implementation

{$ifdef Unicode}
uses
  SysConst, AnsiStrings, Variants, DateUtils;
{$else}
uses
  SysConst, Variants, DateUtils, StrUtils;
{$endif}
{$IFDEF Regions}{$REGION 'Error Messages'}{$ENDIF}
resourcestring
  {$IFDEF English}
  SSimpleXmlError1 = 'Failed to get list item: Index %d out of range';
  SSimpleXmlError2 = 'Incomplete definition of the element';
  SSimpleXmlError3 = 'Invalid symbol in the name of the element';
  SSimpleXmlError4 = 'Error reading binary XML: incorrect node-type';
  SSimpleXmlError5 = 'Error writing binary XML: incorrect node-type';
  SSimpleXmlError6 = 'Incorrect value of the attribute "%0:s" at element "%1:s".'#13#10 +
                     'Allowed values are: '#13#10 + '%2:s';
  SSimpleXmlError7 = 'Attribute "%s" not found';
  SSimpleXmlError8 = 'Attribute "%s" not assigned';
  SSimpleXmlError9 = 'This feature is not supported by SimpleXML';
  SSimpleXmlError10 = 'Error: Child node "%s" not found';
  SSimpleXmlError11 = 'Name must start with letter or "_" at [%d:%d]';
  SSimpleXmlError12 = 'Number expected at [%d:%d]';
  SSimpleXmlError13 = 'Hexadecimal number expected at [%d:%d]';
  SSimpleXmlError14 = '"#" or XML entity symbol name expected at [%d:%d]';
  SSimpleXmlError15 = 'Unknown XML entity symbol name "%s" found at [%d:%d]';
  SSimpleXmlError16 = 'Character "%s" expected at [%d:%d]';
  SSimpleXmlError17 = 'Text "%s" expected at [%d:%d]';
  SSimpleXmlError18 = 'Character "<" cannot be used in the values of attributes at [%d:%d]';
  SSimpleXmlError19 = '"%s" expected at [%d:%d]';
  SSimpleXmlError20 = 'The value of the attribute is expected at [%d:%d]';
  SSimpleXmlError21 = 'Line constant expected at [%d:%d]';
  SSimpleXmlError22 = '"%s" expected at [%d:%d]';
  SSimpleXmlError23 = 'Error reading data';
  SSimpleXmlError24 = 'Error reading value: incorrect type';
  SSimpleXmlError25 = 'Unknown data type in variant';
  SSimpleXmlError26 = 'Encoding "%s" is not supported by SimpleXML';
  SSimpleXmlError27 = 'Unicode Encoding is not supported by SimpleXML';
  SSimpleXmlError28 = 'Child "%s" has multiple data nodes';
  {$ELSE}
  {$IF CompilerVersion>=18}
  SSimpleXmlError1 = 'Ошибка получения элемента списка: индекс %d выходит за пределы';
  SSimpleXmlError2 = 'Не завершено определение элемента';
  SSimpleXmlError3 = 'Некорретный символ в имени элемента';
  SSimpleXmlError4 = 'Ошибка чтения двоичного XML: некорректный тип узла';
  SSimpleXmlError5 = 'Ошибка записи двоичного XML: некорректный тип узла';
  SSimpleXmlError6 = 'Неверное значение атрибута "%0:s" элемента "%1:s".'#13#10 +
                     'Допустимые значения:'#13#10 + '%2:s';
  SSimpleXmlError7 = 'Не найден атрибут "%s"';
  SSimpleXmlError8 = 'Не задан атрибут "%s"';
  SSimpleXmlError9 = 'Данная возможность не поддерживается SimpleXML';
  SSimpleXmlError10 = 'Ошибка: не найден дочерний элемент "%s".';
  SSimpleXmlError11 = 'Имя должно начинаться с буквы или "_" в [%d:%d]';
  SSimpleXmlError12 = 'Ожидается число в [%d:%d]';
  SSimpleXmlError13 = 'Ожидается шестнадцатеричное число в [%d:%d]';
  SSimpleXmlError14 = 'Ожидается "#" или имя управляющего символа в [%d:%d]';
  SSimpleXmlError15 = 'Некорректное имя управляющего символа "%s" в [%d:%d]';
  SSimpleXmlError16 = 'Ожидается "%s" в [%d:%d]';
  SSimpleXmlError17 = 'Ожидается "%s" в [%d:%d]';
  SSimpleXmlError18 = 'Символ "<" не может использоваться в значениях атрибутов в [%d:%d]';
  SSimpleXmlError19 = 'Ожидается "%s" в [%d:%d]';
  SSimpleXmlError20 = 'Ожидается значение атрибута в [%d:%d]';
  SSimpleXmlError21 = 'Ожидается строковая константа в [%d:%d]';
  SSimpleXmlError22 = 'Ожидается "%s" в [%d:%d]';
  SSimpleXmlError23 = 'Ошибка чтения данных.';
  SSimpleXmlError24 = 'Ошибка чтения значения: некорректный тип.';
  SSimpleXmlError25 = 'Ошибка записи значения: некорректный тип.';
  SSimpleXmlError26 = 'Кодировка "%s" не поддерживается SimpleXML';
  SSimpleXmlError27 = 'Unicode кодировка не поддерживается SimpleXML';
  SSimpleXmlError28 = 'Дочерний элемент "%s" имеет несколько узлов данных';
  {$ELSE}
  {$INCLUDE *_Cyrillic.inc}
  {$IFEND}
  {$ENDIF}
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Constantes Declaration'}{$ENDIF}

const
  MyXMLEmptyString = '';
  {$ifdef Unicode}
  NativeVarType = varUString;
  {$else}
    {$ifdef XML_WIDE_CHARS}
    NativeVarType = varOleStr;
    {$else}
    NativeVarType = varString;
    {$endif}
  {$endif}
  DefaultEncoding = 'UTF-8';

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Codepage Support'}{$ENDIF}

function Big5CheckAlignment(P: PByte; Size: Integer): Integer;
begin
  Result := 0;
  if (P^>=$A1) and (P^<=$FE) and (Size>1)
  then begin //realy trailing Byte?
    dec(P);
    if P^<$80
    then //no leadbyte found!
      Inc(Result); //misaligned by one byte
  end;
end;

function GB2312CheckAlignment(P: PByte; Size: Integer): Integer;
begin
  Result := 0;
  // Misaligned if the number of Bytes between first ASCII character
  // an last character is not even
  while (Size>0) and (P^>=$A1) do
  begin
    Result := Result xor 1; // toggle result
    dec(P); dec(Size);
  end;
end;

function Shift_JISCheckAlignment(P: PByte; Size: Integer): Integer;
var
  AsciiCount: Integer;
  CharCount: Integer;
begin
  CharCount := 0;
  AsciiCount := 0;
  // Misalgned if the number of Bytes between first ASCII character
  // an last character is not even
  while (Size>0) do
  begin
    if P^<$81
    then begin
      if AsciiCount>0
      then begin
        Inc(CharCount);
        break;
      end;
      inc(AsciiCount);
    end
    else
      AsciiCount := 0;
    dec(P); dec(Size);
    Inc(CharCount);
  end;
  Result := CharCount and 1;
end;

function GB18030CheckAlignment(P: PByte; Size: Integer): Integer;
begin
  // 00..$7F => Ascii
  // $81.. $FE and next byte $40..$FE => 2 byte codepoint
  // $81.. $FE and next byte $30..$39 => 4 byte codepoint
  Result := Size;
  dec(P, Size-1);
  while Result>0 do
  begin
    if (P^<$81)
    then begin //ASCII or illegal codepoint
      inc(P); Dec(Result);
    end
    else //Now, I should still have at least 1 byte
    if Result=1
    then
      break
    else begin
      inc(P);
      if (P^>=$30) and (P^<=$39)
      then begin //4 byte codepoint
        if (Result<4) then
          break;
        dec(Result, 4);
        inc(P, 3);
      end
      else
      if (P^>=$40) and (P^<=$FE)
      then begin //2 byte codepoint
        if (Result<2) then
          break;
        dec(Result, 2);
        inc(P);
      end
      else begin
        inc(P); Dec(Result); //Illegal codepoint
      end;
    end;
  end;
end;

type
  TAlignmentCheck =  function (P: PByte; Size: Integer): Integer;
{
 http://www.iana.org/assignments/character-sets/character-sets.xml
 http://msdn.microsoft.com/en-us/library/windows/desktop/dd317756(v=vs.85).aspx
 character-sets according ISO-2022 not supported (seems only relevant for mail)
 character-set UTF-7 not supported (only relevant for mail)
}

const
  XMLEncodingData: array [0..78] of
      record
        Name: RawByteString;
        AlignCheck: TAlignmentCheck;
        Codepage: Word;
      end =
   ((Name: 'ASMO-708';                Codepage:   708),
    (Name: 'Big5';
     AlignCheck: Big5CheckAlignment;
                                      Codepage:   950),
    (Name: 'cp866';                   Codepage:   866),
    (Name: 'GB18030';
     AlignCheck: GB18030CheckAlignment;
                                      Codepage: 54936),
    (Name: 'GB2312';
     AlignCheck: GB2312CheckAlignment;
                                      Codepage:   936),
    (Name: 'IBM-Thai';                Codepage: 20838),
    (Name: 'IBM00858';                Codepage:   858),
    (Name: 'IBM00924';                Codepage: 20924),
    (Name: 'IBM01140';                Codepage:  1140),
    (Name: 'IBM01141';                Codepage:  1141),
    (Name: 'IBM01142';                Codepage:  1142),
    (Name: 'IBM01143';                Codepage:  1143),
    (Name: 'IBM01144';                Codepage:  1144),
    (Name: 'IBM01145';                Codepage:  1145),
    (Name: 'IBM01146';                Codepage:  1146),
    (Name: 'IBM01147';                Codepage:  1147),
    (Name: 'IBM01148';                Codepage:  1148),
    (Name: 'IBM01149';                Codepage:  1149),
    (Name: 'IBM037';                  Codepage:    37),
    (Name: 'IBM1026';                 Codepage:  1026),
    (Name: 'IBM1047';                 Codepage:  1047),
    (Name: 'IBM273';                  Codepage: 20273),
    (Name: 'IBM277';                  Codepage: 20277),
    (Name: 'IBM278';                  Codepage: 20278),
    (Name: 'IBM280';                  Codepage: 20280),
    (Name: 'IBM284';                  Codepage: 20284),
    (Name: 'IBM285';                  Codepage: 20285),
    (Name: 'IBM290';                  Codepage: 20290),
    (Name: 'IBM297';                  Codepage: 20297),
    (Name: 'IBM420';                  Codepage: 20420),
    (Name: 'IBM423';                  Codepage: 20423),
    (Name: 'IBM424';                  Codepage: 20424),
    (Name: 'IBM437';                  Codepage:   437),
    (Name: 'IBM500';                  Codepage:   500),
    (Name: 'IBM737';                  Codepage:   737),
    (Name: 'IBM775';                  Codepage:   775),
    (Name: 'IBM850';                  Codepage:   850),
    (Name: 'IBM852';                  Codepage:   852),
    (Name: 'IBM855';                  Codepage:   855),
    (Name: 'IBM857';                  Codepage:   857),
    (Name: 'IBM860';                  Codepage:   860),
    (Name: 'IBM861';                  Codepage:   861),
    (Name: 'IBM863';                  Codepage:   863),
    (Name: 'IBM864';                  Codepage:   864),
    (Name: 'IBM865';                  Codepage:   865),
    (Name: 'IBM869';                  Codepage:   869),
    (Name: 'IBM870';                  Codepage:   870),
    (Name: 'IBM871';                  Codepage: 20871),
    (Name: 'IBM880';                  Codepage: 20880),
    (Name: 'IBM905';                  Codepage: 20905),
    (Name: 'ISO-8859-1';              Codepage: 28591),
    (Name: 'ISO-8859-13';             Codepage: 28603),
    (Name: 'ISO-8859-15';             Codepage: 28605),
    (Name: 'ISO-8859-2';              Codepage: 28592),
    (Name: 'ISO-8859-3';              Codepage: 28593),
    (Name: 'ISO-8859-4';              Codepage: 28594),
    (Name: 'ISO-8859-5';              Codepage: 28595),
    (Name: 'ISO-8859-6';              Codepage: 28596),
    (Name: 'ISO-8859-7';              Codepage: 28597),
    (Name: 'ISO-8859-8';              Codepage: 28598),
    (Name: 'ISO-8859-8-I';            Codepage: 38598),
    (Name: 'ISO-8859-9';              Codepage: 28599),
    (Name: 'KOI8-R';                  Codepage: 20866),
    (Name: 'KOI8-U';                  Codepage: 21866),
    (Name: 'macintosh';               Codepage: 10000),
    (Name: 'Shift_JIS';
     AlignCheck: Shift_JISCheckAlignment;
                                      Codepage:   932),
    (Name: 'TIS-620';                 Codepage:   874),
    (Name: 'US-ASCII';                Codepage: 20127),
    (Name: 'UTF-8';                   Codepage: CP_UTF8),
    (Name: 'windows-1250';            Codepage:  1250),
    (Name: 'windows-1251';            Codepage:  1251),
    (Name: 'windows-1252';            Codepage:  1252),
    (Name: 'windows-1253';            Codepage:  1253),
    (Name: 'windows-1254';            Codepage:  1254),
    (Name: 'windows-1255';            Codepage:  1255),
    (Name: 'windows-1256';            Codepage:  1256),
    (Name: 'windows-1257';            Codepage:  1257),
    (Name: 'windows-1258';            Codepage:  1258),
    (Name: 'windows-874';             Codepage:   874));

function FindCodepage(const s: RawByteString): Word;
var
  L, H, I, C: Integer;
begin
  Result := 0;
  L := 0;
  H := High(XMLEncodingData);
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := CompareText(XMLEncodingData[I].Name, s);
    if C < 0
    then
      L := I + 1
    else begin
      H := I - 1;
      if C = 0
      then begin
        Result := XMLEncodingData[I].CodePage;
        break;
      end;
    end;
  end;
end;

function ReadUTF16Char(var c: UCS4Char; w: Word): Integer;
begin
  Result := 0;
  if (w<$D800)
  then
    c := w
  else
  if (w<$DC00)
  then begin
    c := w and $3FF;
    Inc(Result); //Additional codepoint needed
  end
  else
  if (w<$E000)
  then
    c := (c shl 10) or (w and $3FF) + $10000
  else
    c := UCS4Char('?');
end;

function ReadUTF8Char(var c: UCS4Char; b: Byte): Integer;
// Decode one byte and return the number of readings needed to complete the codepoint
begin
  Result := 0;
  if b<$80
  then //b = [$0..$7F]; 1 Byte Source -> 7 Bit Unicode Char
    c := b
  else
  if b<=$BF
  then begin //b = [$80..$BF]; trailing byte
    c := (c shl 6) or (b and $3F);
  end
  else
  if b<=$C1
  then begin //b = [$C0..$C1]; illegal byte
    c := UCS4Char('?');
  end
  else
  if b<$E0
  then begin //b = [$C2..$DF]; 2 Byte Source -> 11 Bit Unicode Char
    c := (b and $1F);
    Inc(Result);
  end
  else
  if b<$F0
  then begin //b = [$E0..$EF]; 3 Byte Source -> 16 Bit Unicode Char
    c := (b and $F);
    Result := 2;
  end
  else
  if b<=$F4
  then begin //b = [$F0..$F4]; 4 Byte Source -> 21 Bit Unicode Char
    c := (b and $7);
    Result := 3;
  end
  else
    c := UCS4Char('?');
end;

function WriteUTF8Char(p: PByte; c: UCS4Char): Integer;
//UCS4 -> UTF8 conversion
begin
  if c<$80
  then begin //7 Bit UCS4Char
    p^ := c;
    Result := 1;
  end
  else
  if c<=$7FF
  then begin //11 Bit UCS4Char
    p^ := Byte(c shr 6) or $C0; inc(p);
    p^ := (Byte(c) and $3F) or $80;
    Result := 2;
  end
  else
  if c<=$FFFF
  then begin //16 Bit UCS4Char
    p^ := Byte(c shr 12) or $E0; inc(p);
    p^ := (Byte(c shr 6) and $3F) or $80; inc(p);
    p^ := (Byte(c) and $3F) or $80;
    Result := 3;
  end
  else
  if c<=$1FFFFF  //RFC 3629 violation
  then begin //21 Bit UCS4Char
    p^ := Byte(c shr 18) or $F0; inc(p);
    p^ := (Byte(c shr 12) and $3F) or $80; inc(p);
    p^ := (Byte(c shr 6) and $3F) or $80; inc(p);
    p^ := (Byte(c) and $3F) or $80;
    Result := 4;
  end
  else
    Result := 0;
end;

function XMLStringToMyXMLString(const src: TXMLString): TmyXMLString;
{$IF not Defined(XML_WIDE_CHARS) and not Defined(Unicode)}
var
  TempSize: Integer;
  temp: array of WideChar;
  TempWideBuffer: array [0..2047] of WideChar;
  WideBuffer: Pointer;
  ResultSize: Integer;
{$ifend}
var
  SrcCount: Integer;
begin
  SrcCount := Length(src);
  if (SrcCount<>0)
  then begin
    {$IF Defined(XML_WIDE_CHARS) or Defined(Unicode)}
    // UTF16 -> UTF8
    Result := UTF8Encode(src);
    {$else}
    if XMLCodepage<>CP_UTF8
    then begin
      // Ansi -> UTF16
      WideBuffer := @TempWideBuffer;
      TempSize := MultiByteToWideChar(XMLCodepage, 0,
                                      Pointer(src), SrcCount,
                                      WideBuffer, Length(TempWideBuffer));
      if (TempSize=0)
      then begin
        if (GetLastError=ERROR_INSUFFICIENT_BUFFER)
        then begin
          //Calc needed buffersize
          TempSize := MultiByteToWideChar(XMLCodepage, 0, Pointer(src), SrcCount, nil, 0);
          SetLength(temp, TempSize);
          WideBuffer := Pointer(temp);
          if MultiByteToWideChar(XMLCodepage, 0, Pointer(src), SrcCount, WideBuffer, TempSize)<>TempSize
          then
            exit;
        end
        else
          exit;
      end;
      // UTF16 -> UTF8
      ResultSize := TempSize * 3;
      SetLength(Result, ResultSize);
      ResultSize := UnicodeToUtf8(Pointer(Result), ResultSize, WideBuffer, TempSize);
      if ResultSize>0
      then
        SetLength(Result, ResultSize-1)
      else
        Result := '';;
    end
    else begin
      Result := src;
    end;
    {$ifend}
  end;
end;

function MyXMLStringToXMLString(const src: TMyXMLString): TXMLString;
{$IF not Defined(XML_WIDE_CHARS) and not Defined(Unicode)}
var
  TempSize: Integer;
  temp: array of WideChar;
  ResultSize: Integer;
  TempWideBuffer: array [0..2047] of WideChar;
  WideBuffer: Pointer;
{$ifend}
var
  SrcCount: Integer;
begin
  SrcCount := Length(src);
  if (SrcCount<>0)
  then begin
    {$ifdef Unicode}
    // UTF8 -> UTF16
    Result := UTF8ToString(src);
    {$endif}
    {$ifdef XML_WIDE_CHARS}
    // UTF8 -> UTF16
    Result := UTF8Decode(src);
    {$endif}
    {$IF not Defined(XML_WIDE_CHARS) and not Defined(Unicode)}
    if XMLCodepage<>CP_UTF8
    then begin
      // UTF8 -> UTF16
      if SrcCount>Length(TempWideBuffer)
      then begin
        SetLength(temp, SrcCount);
        TempSize := SrcCount;
        WideBuffer := Pointer(temp);
      end
      else begin
        TempSize := Length(TempWideBuffer);
        WideBuffer := @TempWideBuffer;
      end;
      TempSize := Utf8ToUnicode(WideBuffer, TempSize+1, Pointer(src), SrcCount);
      if TempSize=0
      then
        exit;
      // UTF16 -> Ansi
      ResultSize := TempSize * 2;
      SetLength(Result, ResultSize);
      ResultSize := WideCharToMultiByte(XMLCodepage, 0, WideBuffer, TempSize-1, Pointer(Result), ResultSize, nil, nil);
      if ResultSize>0
      then
        SetLength(Result, ResultSize)
      else
        Result := '';
    end
    else begin
      Result := src;
    end;
    {$ifend}
  end;
end;

function myXMLTrim(const src: TMyXmlString): TMyXmlString;
var
  L: Integer;
  s, p: PByte;
begin
  L := Length(src);
  if L>0
  then begin
    s := Pointer(src);
    p := s;
    inc(p, L-1);
    while (L > 0) and (s^ <= Byte(' ')) do
    begin
      Inc(s);
      dec(L);
    end;
    if L>0
    then begin
      while p^ <= Byte(' ') do
      begin
        Dec(L);
        dec(p);
      end;
      SetLength(Result, L);
      move(s^, Pointer(Result)^, L);
    end;
  end;
end;

function StrToIntA(const s: TMyXMLString): Integer;
var
  i, Count: Integer;
  P: PByte;
  c: Integer;
  neg: Boolean;
begin
  Result := 0;
  P := Pointer(s);
  Count := Length(s);
  neg := P^=Byte('-');
  if neg
  then begin
    inc(P); dec(Count);
  end;
  for i := 0 to Count - 1 do
  begin
    c := Integer(P^) - ord('0');
    if (c>=0) and (c<=9)
    then
      Result := Result * 10 + c
    else
      raise Exception.CreateFmt(SInvalidInteger, [UTF8ToAnsi(s)]);
    inc(P);
  end;
  if neg
  then
    Result := -Result;
end;

function StrToCardA(const s: TMyXMLString): Cardinal;
var
  i, Count: Integer;
  P: PByte;
  c: Integer;
begin
  Result := 0;
  P := Pointer(s);
  Count := Length(s);
  for i := 0 to Count - 1 do
  begin
    c := Integer(P^) - ord('0');
    if (c>=0) and (c<=9)
    then
      Result := Result * 10 + Cardinal(c)
    else
      raise Exception.CreateFmt(SInvalidInteger, [UTF8ToAnsi(s)]);
    inc(P);
  end;
end;

function HexToCardA(const s: TMyXMLString): Cardinal;
var
  i, Count: Integer;
  P: PByte;
  c: SmallInt;
begin
  Result := 0;
  P := Pointer(s);
  Count := Length(s);
  for i := 0 to Count - 1 do
  begin
    if (P^>=ord('0')) and (P^<=ord('9'))
    then
      c := SmallInt(P^) - ord('0')
    else
    if (P^>=ord('A')) and (P^<=ord('F'))
    then
      c := SmallInt(P^) - ord('A') + 10
    else
    if (P^>=ord('a')) and (P^<=ord('f'))
    then
      c := SmallInt(P^) - ord('a') + 10
    else
      raise Exception.CreateFmt(SInvalidInteger, [UTF8ToAnsi(s)]);
    Result := Result * 16 + Cardinal(c);
    inc(P);
  end;
end;

function StrToInt64A(const s: TMyXMLString): Int64;
var
  i, Count: Integer;
  P: PByte;
  c: Integer;
  neg: Boolean;
begin
  Result := 0;
  P := Pointer(s);
  Count := Length(s);
  neg := P^=Byte('-');
  if neg
  then begin
    inc(P); dec(Count);
  end;
  for i := 0 to Count - 1 do
  begin
    c := Integer(P^) - ord('0');
    if (c>=0) and (c<=9)
    then
      Result := Result * 10 + c
    else
      raise Exception.CreateFmt(SInvalidInteger, [UTF8ToAnsi(s)]);
    inc(P);
  end;
  if neg
  then
    Result := -Result;
end;

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Helper functions'}{$ENDIF}
function TextToXML(const aText: TmyXmlString): TmyXmlString;
const
  cLowerThan: TmyXmlString = '&lt;';
  cGreaterThan: TmyXmlString = '&gt;';
  cAmpersand: TmyXmlString = '&amp;';
  cQuote: TmyXmlString = '&quot;';
var
  i, j: Integer;
begin
  j := 0;
  for i := 1 to Length(aText) do
    case aText[i] of
      '<', '>': Inc(j, 4);
      '&': Inc(j, 5);
      '"': Inc(j, 6);
      else
        Inc(j);
    end;
  if j = Length(aText) then
    Result := aText
  else begin
    SetLength(Result, j);
    j := 1;
    for i := 1 to Length(aText) do
      case aText[i] of
        '<': begin Move(PMyXMLChar(cLowerThan)^, Result[j], 4*SizeOf(TmyXMLChar)); Inc(j, 4) end;
        '>': begin Move(PMyXMLChar(cGreaterThan)^, Result[j], 4*SizeOf(TmyXMLChar)); Inc(j, 4) end;
        '&': begin Move(PMyXMLChar(cAmpersand)^, Result[j], 5*SizeOf(TmyXMLChar)); Inc(j, 5) end;
        '"': begin Move(PMyXMLChar(cQuote)^, Result[j], 6*SizeOf(TmyXMLChar)); Inc(j, 6) end;
        else begin Result[j] := aText[i]; Inc(j) end;
      end;
  end;
end;

function ReplaceControlChars(const aText: TMyXMLString): TMyXMLString;
const
  cLowerThan: PAnsiChar = '&lt;';
  cGreaterThan: PAnsiChar = '&gt;';
  cAmpersand: PAnsiChar = '&amp;';
  cQuote: PAnsiChar = '&quot;';
var
  i, j: Integer;
  pSrc: PByte;
  pDst: PByte;
  Count: Integer;
begin
  j := 0;
  pSrc := Pointer(aText);
  Count := Length(aText);
  for i := 0 to Count-1 do
  begin
    case pSrc^ of
      Ord('<'), Ord('>'): Inc(j, 4);
      Ord('&'): Inc(j, 5);
      Ord('"'): Inc(j, 6);
      else
        Inc(j);
    end;
    Inc(pSrc);
  end;
  if j = Count then
    Result := aText
  else begin
    SetLength(Result, j);
    pSrc := Pointer(aText);
    pDst := Pointer(Result);
    for i := 0 to Count-1 do
    begin
      case pSrc^ of
        Ord('<'): begin Move(Pointer(cLowerThan)^, pDst^, 4);   Inc(pDst, 4) end;
        Ord('>'): begin Move(Pointer(cGreaterThan)^, pDst^, 4); Inc(pDst, 4) end;
        Ord('&'): begin Move(Pointer(cAmpersand)^, pDst^, 5);   Inc(pDst, 5) end;
        Ord('"'): begin Move(Pointer(cQuote)^, pDst^, 6);       Inc(pDst, 6) end;
        else begin
          pDst^ := pSrc^; Inc(pDst);
        end;
      end;
      inc(pSrc);
    end;
  end;
end;

function XSTRToFloat(const s: String): Extended;
var
  code: Integer;
begin
  Val(s,  result, code);
  if (code>0) and (code<=2)
  then begin
    code := 0;
    if SameText(s, 'INF') or SameText(s, '+INF')
    then
      result :=  (1.0 / 0.0)
    else
    if SameText(s, '-INF')
    then
      result :=  (-1.0 / 0.0)
    else
    if SameText(s, 'NAN')
    then
      result :=  (0.0 / 0.0)
    else
      code := 1;
  end;
  if (code>0)
  then
    raise Exception.CreateFmt(SInvalidFloat, [s]);
end;

procedure TrimFloat(var s: RawByteString);
var
  i: Integer;
begin
  i := 1;
  while (s[i]<=' ') do //Str(NaN, s) => s = '                    Nan'
    inc(i);
  if s[i]<>'+' then dec(i);
  if i>0
  then
    Delete(s, 1, i);
end;

function FloatToStrA(v: Extended): RawByteString; overload;
begin
  Str(v, Result);
  {$ifdef Unicode}
  SetCodePage(Result, CP_UTF8, False);
  {$endif}
  TrimFloat(Result);
end;

function FloatToStrA(v: Double): RawByteString; overload;
begin
  Str(v, Result);
  {$ifdef Unicode}
  SetCodePage(Result, CP_UTF8, False);
  {$endif}
  TrimFloat(Result);
end;

function FloatToStrA(v: Single): RawByteString; overload;
begin
  Str(v, Result);
  {$ifdef Unicode}
  SetCodePage(Result, CP_UTF8, False);
  {$endif}
  TrimFloat(Result);
end;

function MyXMLStringToDateTime(const s: TMyXMLString): TDateTime;
var
  pSrc: PByte;
  Count: Integer;
  function FetchTo(aStop: AnsiChar): Integer;
  begin
    Result := 0;
    while (Count>0) and (pSrc^>=Ord('0')) and (pSrc^<=Ord('9')) do
    begin
      Result := Result * 10 + Integer(pSrc^) - Ord('0');
      Inc(pSrc);
      Dec(Count);
    end;
    if (Count>0) and (pSrc^=Ord(aStop))
    then begin
      inc(pSrc);
      Dec(Count);
    end
    else
      Count := 0;
  end;

var
  y, m, d, h, n, ss: Integer;
begin
  pSrc := Pointer(s);
  Count := Length(s);
  y := FetchTo('-'); m := FetchTo('-'); d := FetchTo('T');
  h := FetchTo(':'); n := FetchTo(':'); ss := FetchTo(#0);
  Result := EncodeDateTime(y, m, d, h, n, ss, 0);
end;


function DateTimeToXSTR(v: TDateTime): TXmlString;
var
  y, m, d, h, n, s, ms: Word;
begin
  DecodeDateTime(v, y, m, d, h, n, s, ms);
  Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d', [y, m, d, h, n, s]);
end;

function DateTimeToStrA(v: TDateTime): RawByteString;
var
  y, m, d, h, n, s, ms: Word;
begin
  DecodeDateTime(v, y, m, d, h, n, s, ms);
  {$ifdef Unicode}
  Result := AnsiStrings.Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d', [y, m, d, h, n, s]);
  SetCodePage(Result, CP_UTF8, False);
  {$else}
  Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d', [y, m, d, h, n, s]);
  {$endif}
end;

function IntToStrA(X: Integer; Width: Integer = 0): RawByteString;
begin
  Str(X: Width, Result);
  {$ifdef Unicode}
  SetCodePage(Result, CP_UTF8, False);
  {$endif}
end;

function IntToStr64A(X: Int64; Width: Integer = 0): RawByteString;
begin
  Str(X: Width, Result);
  {$ifdef Unicode}
  SetCodePage(Result, CP_UTF8, False);
  {$endif}
end;

function CardToStrA(X: Cardinal; Width: Integer = 0): RawByteString;
begin
  Str(X: Width, Result);
  {$ifdef Unicode}
  SetCodePage(Result, CP_UTF8, False);
  {$endif}
end;

function DataTypeIsStr(DataType: TVarType): Boolean;
begin
  {$ifdef Unicode}
  Result := (DataType = varOleStr) or (DataType = varString) or (DataType = varUString);
  {$else}
  Result := (DataType = varOleStr) or (DataType = varString);
  {$endif}
end;

function VarToMyXMLString(const v: Variant): TMyXMLString;
const
  BoolStr: array[Boolean] of TMyXMLString = ('0', '1');
var
  p: Pointer;
  L: Integer;
begin
  case TVarData(v).VType of
    varEmpty,
    varNull:     Result := MyXMLEmptyString;
    varSmallint: Result := IntToStrA(TVarData(v).VSmallInt);
    varInteger:  Result := IntToStrA(TVarData(v).VInteger);
    varSingle:   Result := FloatToStrA(TVarData(v).VSingle);
    varDouble:   Result := FloatToStrA(TVarData(v).VDouble);
    varCurrency: Result := FloatToStrA(TVarData(v).VCurrency);
    varDate:     Result := DateTimeToStrA(TVarData(v).VDate);
    varOleStr:   Result := Utf8Encode(TVarData(v).VOleStr);
    varBoolean:  Result := BoolStr[TVarData(v).VBoolean<>False];
    varShortInt: Result := IntToStrA(TVarData(v).VShortInt);
    varByte:     Result := CardToStrA(TVarData(v).VByte);
    varWord:     Result := CardToStrA(TVarData(v).VWord);
    varLongWord: Result := CardToStrA(TVarData(v).VLongWord);
    varInt64:    Result := IntToStr64A(TVarData(v).VInt64);
    {$if defined(Unicode)}
    varString:   Result := UTF8Encode(AnsiString(TVarData(v).VString));
    varUString:  Result := AnsiToUtf8(String(TVarData(v).VUString));
    {$elseif defined(XML_WIDE_CHARS)}
    varString:   Result := AnsiToUtf8(AnsiString(TVarData(v).VString));
    {$else}
    varString:   Result := XMLStringToMyXMLString(AnsiString(TVarData(v).VString));
    {$ifend}
    varArray + varByte:
      begin
        p := VarArrayLock(v);
        try
          L := VarArrayHighBound(v, 1) - VarArrayLowBound(v, 1) + 1;
          SetLength(Result, L);
          move(p^, Pointer(Result)^, L);
        finally
          VarArrayUnlock(v)
        end
      end;
    else
      Result := AnsiToUtf8(v);
  end;
end;

function MyXMLStringToVar(DataType: TVarType; const Data: TMyXMLString): Variant;
var
  p: Pointer;
begin
  case DataType of
    varNull:     Result := NULL;
    varSmallint: Result := SmallInt(StrToIntA(Data));
    varInteger:  Result := StrToIntA(Data);
    varSingle:
      begin
        TVarData(Result).VType := varSingle;
        TVarData(Result).VSingle := XSTRToFloat(UTF8ToAnsi(Data));
      end;
    varDouble:
      begin
        TVarData(Result).VType := varDouble;
        TVarData(Result).VDouble := XSTRToFloat(UTF8ToAnsi(Data));
      end;
    varCurrency:
      begin
        TVarData(Result).VType := varCurrency;
        TVarData(Result).VCurrency := XSTRToFloat(UTF8ToAnsi(Data));
      end;
    varDate:     Result := MyXMLStringToDateTime(Data);
    varShortInt: Result := ShortInt(StrToIntA(Data));
    varByte:     Result := Byte(StrToCardA(Data));
    varWord:     Result := Word(StrToCardA(Data));
    varLongWord: Result := StrToCardA(Data);
    varInt64:    Result := StrToInt64A(Data);
    {$if defined(Unicode)}
    varOleStr:   Result := UTF8ToWideString(Data);
    varString:   Result := AnsiString(UTF8ToAnsi(Data));
    varUString:  Result := UTF8ToAnsi(Data);
    {$elseif defined(XML_WIDE_CHARS)}
    varOleStr:   Result := UTF8Decode(Data);
    varString:   Result := UTF8ToAnsi(Data);
    {$else}
    varString:   Result := MyXMLStringToXMLString(Data);
    {$ifend}
    varArray + varByte:
      begin
        Variant(Result) := VarArrayCreate([0, Length(Data) - 1], varByte);
        p := VarArrayLock(Result);
        try
          move(Pointer(Data)^, p^, Length(Data));
        finally
          VarArrayUnlock(Result)
        end
      end;
  else
    VarCast(Result, UTF8ToAnsi(Data), DataType);
  end;
end;

procedure PrepareToSaveXml(var anElem: IXmlElement; const aChildName: String);
begin
  if aChildName <> '' then
    anElem := anElem.AppendElement(aChildName);
end;

function PrepareToLoadXml(var anElem: IXmlElement; const aChildName: String): Boolean;
begin
  if (aChildName <> '') and Assigned(anElem) then
    anElem := anElem.selectSingleNode(aChildName).AsElement;
  Result := Assigned(anElem);
end;

procedure GetCodingNameList(List: TStrings);
var
  i: Integer;
begin
  List.BeginUpdate;
  try
    List.Clear;
    for i:=0 to High(XMLEncodingData) do
      List.Add(String(XMLEncodingData[i].Name));
  finally
    List.EndUpdate;
  end;
end;

function LoadXMLResource(aModule: HMODULE; aName, aType: PChar; const aXMLDoc: IXmlDocument): boolean;
var
  aRSRC: HRSRC;
  aGlobal: HGLOBAL;
  aSize: DWORD;
  aPointer: Pointer;
  AStr: RawByteString;
begin
  Result := false;

  aRSRC := FindResource(aModule, aName, aType);
  if aRSRC <> 0 then begin
    aGlobal := LoadResource(aModule, aRSRC);
    aSize := SizeofResource(aModule, aRSRC);
    if (aGlobal <> 0) and (aSize <> 0) then begin
      aPointer := LockResource(aGlobal);
      if Assigned(aPointer) then begin
        SetLength(AStr, aSize);
        move(aPointer^, Pointer(AStr), aSize);
        aXMLDoc.LoadXML(AStr);
        Result := true;
      end;
    end;
  end;
end;

function IsXmlDataString(const aData: RawByteString): Boolean;
var
  i: Integer;
begin
  Result := Copy(aData, 1, Length(BinXmlSignature)) = BinXmlSignature;
  if not Result then begin
    i := 1;
    while (i <= Length(aData)) and (aData[i] in [#10, #13, #9, ' ']) do
      Inc(i);
    Result := Copy(aData, i, Length('<?xml ')) = '<?xml ';
  end;
end;

function XmlIsInBinaryFormat(const aData: RawByteString): Boolean;
begin
  if Length(AData)>Length(BinXmlSignature)
  then
    Result := CompareMem(Pointer(aData), Pointer(BinXmlSignature), Length(BinXmlSignature))
  else
    Result := False;
end;

type
  PBase64Sample = ^TBase64Sample;
  TBase64Sample = packed record a, b, c, d: TmyXMLChar end;
  PBinSample = ^TBinSample;
  TBinSample = packed record a, b, c: Byte; end;

const
  Base64Map: array [0..63] of TmyXMLChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

{$IFDEF ADDebug}
var
  DebugId: Integer;
{$ENDIF}

function SimpleBinToBase64(const aBin; aSize: Cardinal): TMyXMLString;
var
  o: PBinSample;
  Base64Sample: Cardinal;
  procedure GetBase64SrcBytes;
  begin
    with o^ do
      Base64Sample := c or b shl 8 or a shl 16;
    inc(o);
  end;
var
  c: PMyXMLChar;
  procedure Base64Coding;
  begin
    c^ := Base64Map[(Base64Sample shr 18) and $3F]; inc(c);
    Base64Sample := Base64Sample shl 6;
  end;
var
  r: Cardinal;
  procedure Flush;
  begin
  end;
var
  aCount: Integer;
begin
  o := @aBin;
  r := aSize mod 3;
  aCount := aSize - r;
  SetLength(Result, ((aSize + 2) div 3) * 4);
  c := Pointer(Result);
  while aCount > 0 do
  begin
    GetBase64SrcBytes;
    Base64Coding;
    Base64Coding;
    Base64Coding;
    Base64Coding;
    dec(aCount, 3);
  end;
  Flush;
end;

function BinToBase64(const aBin; aSize, aMaxLineLength: Cardinal): RawByteString;
var
  c: PAnsiChar;
  LineCharCount: Integer;
  function OutputLineBreak: Boolean; //True if NO Linebreak needed
  var
    L: Integer;
    p: PAnsiChar;
  begin
    Result := (LineCharCount>0);
    if Result
    then
      Dec(LineCharCount)
    else begin
      L := Length(sLineBreak);
      p := sLineBreak;
      while L>0 do
      begin
        c^ := p^; inc(c); inc(p); dec (L);
      end;
      LineCharCount := aMaxLineLength - 1;
    end;
  end;
var
  o: PBinSample;
  Base64Sample: Cardinal;
  procedure GetBase64SrcBytes;
  begin
    with o^ do
      Base64Sample := c or b shl 8 or a shl 16;
    inc(o);
  end;
  procedure Base64Coding;
  begin
    c^ := Base64Map[(Base64Sample shr 18) and $3F]; inc(c);
    Base64Sample := Base64Sample shl 6;
  end;
var
  aCount: Integer;
  SourceBytesPerLine: Integer;
  ResultBytesPerLine: Integer;
  procedure OutputLine;
  var
    n: Integer;
  begin
    if aCount > SourceBytesPerLine
    then begin
      n := SourceBytesPerLine;
      dec(LineCharCount, ResultBytesPerLine);
    end
    else begin
      n := aCount;
      dec(LineCharCount, (n div 3) * 4);
    end;
    dec(aCount, n);
    while n > 0 do
    begin
      GetBase64SrcBytes;
      Base64Coding;
      Base64Coding;
      Base64Coding;
      Base64Coding;
      dec(n, 3);
    end;
  end;
  procedure OutputChars;
  begin
    if OutputLineBreak and (aCount > 0)
    then begin
      GetBase64SrcBytes;
      Base64Coding;
      OutputLineBreak;
      Base64Coding;
      OutputLineBreak;
      Base64Coding;
      OutputLineBreak;
      Base64Coding;
      dec(aCount, 3);
    end;
  end;
var
  r: Cardinal;
  procedure Flush;
  begin
    if r=2
    then begin
      OutputLineBreak;
      Base64Sample := o^.a shl 16 or o^.b shl 8;
      Base64Coding;
      OutputLineBreak;
      Base64Coding;
      OutputLineBreak;
      Base64Coding;
      OutputLineBreak;
      c^ := '=';
    end
    else
    if r=1
    then begin
      OutputLineBreak;
      Base64Sample := o^.a shl 16;
      Base64Coding;
      OutputLineBreak;
      Base64Coding;
      OutputLineBreak;
      c^ := '='; inc(c);
      OutputLineBreak;
      c^ := '=';
    end;
  end;
begin
  o := @aBin;
  r := ((aSize + 2) div 3) * 4; //Resulting length without linebreaks
  if aMaxLineLength>0
  then
    Inc(r, (r div aMaxLineLength) * Cardinal(Length(sLineBreak))); //calc linebreaks
  SetLength(Result, r);
  c := Pointer(Result);
  r := aSize mod 3;
  aCount := aSize - r;
  if aMaxLineLength=0
  then begin
    while aCount > 0 do
    begin
      GetBase64SrcBytes;
      Base64Coding;
      Base64Coding;
      Base64Coding;
      Base64Coding;
      dec(aCount, 3);
    end;
    LineCharCount := MaxInt;
    Flush;
  end
  else begin
    SourceBytesPerLine := (aMaxLineLength div 4) * 3;
    ResultBytesPerLine := (SourceBytesPerLine div 3) * 4;
    LineCharCount := aMaxLineLength;
    while aCount > 0 do
    begin
      OutputLine;  // output most chars of the line
      OutputChars; // output chars surrounding Linebreak
    end;
    Flush;
  end;
end;

function CharTo6Bit(c: AnsiChar): Byte;
begin
  if (c >= 'A') and (c <= 'Z') then
    Result := Ord(c) - Ord('A')
  else if (c >= 'a') and (c <= 'z') then
    Result := Ord(c) - Ord('a') + 26
  else if (c >= '0') and (c <= '9') then
    Result := Ord(c) - Ord('0') + 52
  else if c = '+' then
    Result := 62
  else if c = '/' then
    Result := 63
  else
    Result := 0
end;

function Base64ToBin(const aBase64: RawByteString): TBytes;
var
  p2, p1: PAnsiChar;
  procedure DecodeBase64;
  var
    i: Integer;
  begin
    i := CharTo6Bit(p1^); inc(p1);
    i := CharTo6Bit(p1^) or (i shl 6); inc(p1);
    if p1^ = '='
    then begin // 1 byte
      inc(p1, 2);
      p2^ := AnsiChar((i shr 4)); inc(p2);
      exit;
    end;
    i := CharTo6Bit(p1^) or (i shl 6); inc(p1);
    if p1^ = '='
    then begin // 2 byte
      inc(p1);
      p2^ := AnsiChar((i shr 10)); inc(p2);
      p2^ := AnsiChar((i shr 2)); inc(p2);
      exit;
    end;
    // 3 bytes
    i := CharTo6Bit(p1^) or (i shl 6); inc(p1);
    p2^ := AnsiChar((i shr 16)); inc(p2);
    p2^ := AnsiChar((i shr 8)); inc(p2);
    p2^ := AnsiChar(i); inc(p2);
  end;
var
  aCount: Cardinal;
  TempBase64: array of AnsiChar;
  N: Cardinal;
  r: Cardinal;
begin
  N := Length(aBase64);
  SetLength(TempBase64, N);
  p1 := Pointer(aBase64);
  p2 := Pointer(TempBase64);
  while N > 0  do
  begin
    if p1^>' '
    then begin
      p2^ := p1^;
      inc(p2);
    end;
    inc(p1);
    dec(N);
  end;
  N := Cardinal(NativeInt(p2) - NativeInt(TempBase64));
  if N < 4 then
    SetLength(Result, 0)
  else begin
    // append trailing '=', if length not divisible by 4 
    r := N mod 4;
    if r>0
    then begin
      r := 4 - r;
      Inc(N, r);
    end;
    SetLength(TempBase64, N);
    aCount := (N div 4) * 3;
    while r>0 do
    begin
      p2^ := '=';
      inc(p2);
      dec(r);
    end;
    SetLength(Result, aCount);
    p1 := Pointer(TempBase64);
    p2 := Pointer(Result);
    while aCount > 0 do
    begin
      DecodeBase64;
      Dec(aCount, 3);
    end;
    N := Cardinal(NativeInt(p2) - NativeInt(Result));
    SetLength(Result, N);
  end;
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Reader Declaration'}{$ENDIF}
type
  TBinXmlReader = class
  private
  public
    procedure Read(var aBuf; aSize: Integer); virtual; abstract;

    function ReadLongint: Longint;
    function ReadBinData: TmyXMLString;
    procedure ReadVariant(var aDataType: TVarType; var aData: TmyXMLString);
  end;

  TStreamXmlReader = class(TBinXmlReader)
  private
    FStream: TStream;
    FBufStart: PmyXMLChar;
    FBufPtr: PmyXMLChar;
    FBufSize: Integer;
    FBufRemain: Integer;
    FRemainSize: Int64;
  public
    constructor Create(aStream: TStream; aBufSize: Integer);
    destructor Destroy; override;

    procedure Read(var aBuf; aSize: Integer); override;
  end;

  TMemoryXmlReader = class(TBinXmlReader)
  private
    FData: Pointer;
    FPtr: PByte;
    FRemain: Integer;
  public
    constructor Create(const aData; const aCount: Integer);

    procedure Read(var aBuf; aSize: Integer); override;
  end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Writer Declaration'}{$ENDIF}
  TBinXmlWriter = class
  private
  public
    procedure Write(const aBuf; aSize: Integer); virtual; abstract;

    procedure WriteLongint(aValue: Longint);
    procedure WriteUTF8String(const aValue: TmyXmlString);
    procedure WriteVariant(aDataType: TVarType; const aData: TMyXMLString);
  end;

  TStreamXmlWriter = class(TBinXmlWriter)
  private
    FStream: TStream;
    FBuffer: PByte;       // Doublebuffering needed?
    FBufPtr: PByte;
    FBufSize: Integer;
    FRemain: Integer;     // current free size in Buffer
  public
    constructor Create(aStream: TStream; aBufSize: Integer);
    destructor Destroy; override;

    procedure Write(const aBuf; aSize: Integer); override;
  end;

  TMemoryXmlWriter = class(TBinXmlWriter)
  private
    FData: TBytes;
    FBufPtr: PByte;
    FBufSize: Integer;
    FRemain: Integer;
    procedure FlushBuf;
  public
    constructor Create(aBufSize: Integer);

    procedure Write(const aBuf; aSize: Integer); override;
  end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Base Classes'}{$ENDIF}
  TXmlBase = class(TInterfacedObject, IXmlBase)
  protected
    // реализация интерфейса IXmlBase
    function GetObject: TObject;
  public
  end;

  TXMLStringDynArray = array of TmyXMLString;
  TXmlNameTable = class(TXmlBase, IXmlNameTable)
  private
    FNames: array of TXMLStringDynArray;
    FHashTable: array of TCardinalDynArray;

    FXmlTextNameID: NativeInt;
    FXmlCDATASectionNameID: NativeInt;
    FXmlCommentNameID: NativeInt;
    FXmlDocumentNameID: NativeInt;
    FXmlNameID: NativeInt;
    FEncodingNameId: NativeInt;
    {$IFDEF ADDebug}
    FDebugId: Integer;
    {$ENDIF}
  protected
    function GetKeyID(NameID: NativeInt): Integer;
    function GetNameID(aHashKey: Cardinal): NativeInt;
    function GetmyXMLID(aName: TmyXMLString): NativeInt;
    function GetmyXMLName(anID: NativeInt): TmyXMLString;
    function GetName(anID: NativeInt): TXMLString;
    function GetID(const aName: TXMLString): NativeInt;
  public
    constructor Create(aHashTableSize: Integer);
    {$IFDEF ADDebug}
    destructor Destroy; override;
    {$ENDIF}

    procedure LoadBinXml(aReader: TBinXmlReader);
    procedure SaveBinXml(aWriter: TBinXmlWriter);
  end;

{ TXmlBase }

function TXmlBase.GetObject: TObject;
begin
  Result := Self;
end;

{ TXmlNameTable }

constructor TXmlNameTable.Create(aHashTableSize: Integer);
begin
  inherited Create;
  {$IFDEF ADDebug}
  FDebugId := InterlockedIncrement(DebugId);
  outputdebugstring(PChar(Format('Create %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  SetLength(FNames, aHashTableSize);
  SetLength(FHashTable, aHashTableSize);
  FXmlTextNameID := GetID('#text');
  FXmlCDATASectionNameID := GetID('#cdata-section');
  FXmlCommentNameID := GetID('#comment');
  FXmlDocumentNameID := GetID('#document');
  FXmlNameID := GetID('xml');
  FEncodingNameId := GetID('encoding');
end;

procedure TXmlNameTable.LoadBinXml(aReader: TBinXmlReader);
var
  aCount: LongInt;
  i: Integer;
begin
  for i := 0 to High(FNames) do
  begin
    SetLength(FNames[i], 0);
    SetLength(FHashTable[i], 0);
  end;
  aCount := aReader.ReadLongint;
  for i := 0 to aCount - 1 do
  begin
    GetmyXMLID(aReader.ReadBinData);
  end;
end;

procedure TXmlNameTable.SaveBinXml(aWriter: TBinXmlWriter);
var
  aCount: LongInt;
  i, j: Integer;
begin
  aCount := 0;
  for i := 0 to High(FNames) do
  begin
    inc(aCount, Length(FNames[i]));
  end;
  aWriter.WriteLongint(aCount);
  for i := 0 to High(FNames) do
  begin
    for j := 0 to High(FNames[i]) do
    begin
      aWriter.WriteUTF8String(FNames[i][j]);
    end;
  end;
end;

function NameHashKey(aName: PByte; Count: Integer): Cardinal;{$IF CompilerVersion>=18}inline;{$IFEND}
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count-1 do
  begin
    Inc(Result, Result shl 6 xor aName^);
    inc(aName);
  end;
end;

function TXmlNameTable.GetID(const aName: TXMLString): NativeInt;
var
  temp: TmyXMLString;
begin
  temp := XMLStringToMyXMLString(aName);
  Result := GetmyXMLID(temp);
end;

function TXmlNameTable.GetKeyID(NameID: NativeInt): Integer;
var
  temp: TmyXMLString;
begin
  temp := GetmyXMLName(NameID);
  Result := NameHashKey(Pointer(temp), Length(temp));
end;

{$IFDEF ADDebug}
destructor TXmlNameTable.Destroy;
begin
  outputdebugstring(PChar(Format('Destroy %s (%d)', [Classname, FDebugId])));
  inherited;
end;
{$ENDIF}

function TXmlNameTable.GetmyXMLID(aName: TmyXMLString): NativeInt;
var
  i, L: Integer;
  aHashKey: Cardinal;
  aHashIndex: Integer;
  aHashKeyList: ^TCardinalDynArray;
  NameList: ^TXMLStringDynArray;
begin
  Result := 0;
  if Length(aName) <> 0
  then begin
    aHashKey := NameHashKey(Pointer(aName), Length(aName));
    aHashIndex := aHashKey mod Cardinal(Length(FHashTable));
    NameList := @FNames[aHashIndex];
    aHashKeyList := @FHashTable[aHashIndex];
    L := Length(aHashKeyList^);
    for i:=0 to L-1 do
    begin
      if (aHashKeyList^[i] = aHashKey) and (NameList^[i] = aName)
      then begin
        Result := NativeInt(Pointer(NameList^[i]));
        exit;
      end;
    end;
    SetLength(aHashKeyList^, L+1);
    aHashKeyList^[L] := aHashKey;
    SetLength(NameList^, L+1);
    NameList^[L] := aName;
    Result := NativeInt(Pointer(NameList^[L]));
  end;
end;

function TXmlNameTable.GetmyXMLName(anID: NativeInt): TmyXMLString;
begin
  if anID = 0
  then
    SetLength(Result, 0)
  else
    Result := TmyXMLString(Pointer(anID));
end;

function TXmlNameTable.GetName(anID: NativeInt): TXMLString;
begin
  Result := MyXMLStringToXMLString(GetmyXMLName(anID));
end;

function TXmlNameTable.GetNameID(aHashKey: Cardinal): NativeInt;
var
  i: Integer;
  aHashIndex: Integer;
  aHashKeyList: ^TCardinalDynArray;
  NameList: ^TXMLStringDynArray;
begin
  Result := 0;
  aHashIndex := aHashKey mod Cardinal(Length(FHashTable));
  NameList := @FNames[aHashIndex];
  aHashKeyList := @FHashTable[aHashIndex];
  for i := 0 to High(aHashKeyList^) do
  begin
    if aHashKeyList^[i] = aHashKey
    then begin
      Result := NativeInt(Pointer(NameList^[i]));
      exit;
    end;
  end;
end;

function CreateNameTable(aHashTableSize: Integer): IXmlNameTable;
begin
  Result := TXmlNameTable.Create(aHashTableSize)
end;

type
  TXmlNode = class;
  TXmlToken = class
  private
    FValueBuf: TmyXMLString;
    FLength: Integer;
  public
    constructor Create;
    procedure Clear;
    procedure AppendChar(const aChar: UCS4Char);
    procedure AppendText(const aText: PmyXMLChar; const aCount: Integer);
    function Text: TmyXMLString;
//    property Length: Integer read FLength;
  end;

  TXmlSource = class
  private
    FTokenStack: array of TXmlToken;
    FTokenStackTop: Integer;
    FToken: TXmlToken;
    FStream: TStream;
    FBuffer: PByte;      // UTF8 or UTF16
    FBufPtr: PByte;
    FBufSize: Integer;   // Number of byte/words in buffer
    FSourceLine: Int64;
    FSourceCol: Int64;
    FCodepage: Word;
    fAlignCheck: TAlignmentCheck;
    f8BitBufferCoding: Boolean;
    FStreamOwner: Boolean;
    fEof: Boolean;
    function ExpectQuotedText(aQuote: Char): TmyXMLString;
    procedure SetCodepage(Codepage: Word);
  protected
  public
    CurChar: UCS4Char;
    AutoCodepage: Boolean;
    constructor Create(aStream: TStream); overload;
    constructor Create(const aString: RawByteString); overload;
    destructor Destroy; override;

    property EOF: Boolean read fEof;
    function Next: Boolean;

    procedure SkipBlanks;
    function ExpectAlpha: TmyXMLString;
    function ExpectXmlName: TmyXMLString;
    function ExpectXmlEntity: UCS4Char;
    procedure ExpectChar(aChar: Char);
    procedure ExpectText(const aText: TMyXMLString);
    function ExpectDecimalInteger: Integer;
    function ExpectHexInteger: Integer;
    function ParseTo(const aText: TMyXMLString): TmyXmlString;
    procedure ParseAttrs(aNode: TXmlNode);

    procedure NewToken;
    procedure AppendTokenChar(aChar: UCS4Char);
    procedure AppendTokenText(aText: PmyXMLChar; aCount: Integer);
    function AcceptToken: TmyXMLString;
    procedure DropToken;
    property Codepage: Word read FCodepage write SetCodepage;
  end;

  TXmlSaver = class
  private
    FCodepage: Word;
    fUnicodeBuffer: Pointer;
    fUnicodeSize: Cardinal;
    fAnsiPtr: PAnsiChar;
    fMaxCharSize: Cardinal;
    fBuffer: Pointer;
    fRemain: Cardinal;
    fBuffersize: Cardinal;
    procedure SaveToBuffer(UTF8Data: Pointer; UTF8Size: Cardinal);
    procedure FlushBuffer; virtual;
    procedure Save(const XmlStr: TmyXmlString); virtual; abstract;
    procedure SetCodepage(const Value: Word);
  public
    constructor Create;
    destructor Destroy; override;
    property Codepage: Word read FCodepage write SetCodepage;
  end;

  TXmlStmSaver = class(TXmlSaver)
  private
    FStream: TStream;
    procedure Save(const XmlStr: TmyXmlString); override;
    procedure FlushBuffer; override;
  public
    constructor Create(aStream: TStream);
  end;
  
  TXmlNodeList = class(TXmlBase, IXmlNodeList)
  private
    FOwnerNode: TXmlNode;

    FItems: array of TXmlNode;
    FCount: Integer;
    {$IFDEF ADDebug}
    FDebugId: Integer;
    {$ENDIF}
    procedure Grow;
  protected
    function Get_Count: Integer;
    function Get_Item(anIndex: Integer): IXmlNode;
    function Get_myXML: TmyXmlString;
    function Get_XML: TXmlString;
  public
    constructor Create(anOwnerNode: TXmlNode);
    destructor Destroy; override;

    function IndexOf(aNode: TXmlNode): Integer;
    procedure ParseXML(aXML: TXmlSource; aNames: TXmlNameTable;
                       HookTagBegin, HookTagEnd: THookTag;
                       aPreserveWhiteSpace: Boolean);
    procedure SaveXML(aXML: TXmlSaver);

    procedure LoadBinXml(aReader: TBinXmlReader; aCount: Integer; aNames: TXmlNameTable);
    procedure SaveBinXml(aWriter: TBinXmlWriter);

    procedure Insert(aNode: TXmlNode; anIndex: Integer);
    function Remove(aNode: TXmlNode): Integer;
    procedure Delete(anIndex: Integer);
    procedure Replace(anIndex: Integer; aNode: TXmlNode);
    procedure Exchange(Index1, Index2: Integer);
    procedure Clear;
  end;

  PXmlAttrData = ^TXmlAttrData;
  TXmlAttrData = record
    NameID: NativeInt;   // Hash Id of name for attribut
    DataType: TVarType;  // Type of data saved in value
    Value: TmyXMLString; // UTF8 encoded data
  end;

  TXmlDocument = class;
  TXmlNode = class(TXmlBase, IXmlNode)
  private
    FParentNode: TXmlNode;
    // FNames - таблица имен. Задается извне
    FNames: TXmlNameTable;
    // Количество атрибутов в массиве FAttrs
    FAttrCount: Integer;
    // Массив атрибутов
    FAttrs: array of TXmlAttrData;
    // Список дочерних узлов
    FChilds: TXmlNodeList;
    {$IFDEF ADDebug}
    FDebugId: Integer;
    {$ENDIF}
    function GetChilds: TXmlNodeList; virtual;
    function FindFirstChild(aNameID: NativeInt): TXmlNode;
    function GetAttrsXML: TmyXmlString;
    function FindAttrData(aNameID: NativeInt): PXmlAttrData;
    function GetOwnerDocument: TXmlDocument;
    function GetXMLIndent: Integer;
    procedure SetNameTable(aValue: TXmlNameTable);
    procedure SetNodeNameID(aValue: Integer); virtual;
    function DoCloneNode(aDeep: Boolean): IXmlNode; virtual; abstract; // need
    function Get_MyXMLText: TmyXmlString; virtual; abstract;
    procedure Set_MyXMLText(const aValue: TmyXmlString); virtual; abstract;
    procedure Set_MyXMLAttr(aNameID: NativeInt; aDataType: TVarType; const aValue: TmyXmlString);
    function Get_myXML: TmyXmlString; virtual; abstract;
  protected
    // IXmlNode
    function Get_NameTable: IXmlNameTable;
    function Get_NodeName: TXmlString;

    function Get_NodeNameID: NativeInt; virtual; abstract;
    function Get_NodeType: TXmlNodeType;
    function Get_Text: TXmlString;
    procedure Set_Text(const aValue: TXmlString);
    function CloneNode(aDeep: Boolean): IXmlNode;

    procedure LoadBinXml(aReader: TBinXmlReader);
    procedure SaveBinXml(aWriter: TBinXmlWriter);
    procedure SaveXML(aXMLSaver: TXmlSaver); virtual; abstract;

    function Get_DataType: TVarType; virtual;
    procedure Set_DataType(const aValue: TVarType); virtual;
    function Get_TypedValue: Variant; virtual;
    procedure Set_TypedValue(const aValue: Variant); virtual;

    function Get_XML: TXmlString;

    function Get_OwnerDocument: IXmlDocument; virtual;
    function Get_ParentNode: IXmlNode;

    function Get_ChildNodes: IXmlNodeList; virtual;
    procedure AppendChild(const aChild: IXmlNode);

    function AppendElement(aNameID: NativeInt): IXmlElement; overload;
    function AppendElement(const aName: TxmlString): IXmlElement; overload;
    function AppendText(const aData: TXmlString): IXmlText;
    function AppendCDATA(const aData: TXmlString): IXmlCDATASection;
    function AppendComment(const aData: TXmlString): IXmlComment;
    function AppendProcessingInstruction(aTargetID: NativeInt;
      const aData: TXmlString): IXmlProcessingInstruction; overload;
    function AppendProcessingInstruction(const aTarget: TXmlString;
      const aData: TXmlString): IXmlProcessingInstruction; overload;

    procedure InsertBefore(const aChild, aBefore: IXmlNode);
    procedure ReplaceChild(const aNewChild, anOldChild: IXmlNode);
    procedure ExchangeChilds(const aChild1, aChild2: IXmlNode);
    procedure RemoveChild(const aChild: IXmlNode);
    function GetChildText(const aName: TXmlString; const aDefault: TXmlString = ''): TXmlString; overload;
    function GetChildText(aNameID: NativeInt; const aDefault: TXmlString = ''): TXmlString; overload;
    procedure SetChildText(const aName, aValue: TXmlString); overload;
    procedure SetChildText(aNameID: NativeInt; const aValue: TXmlString); overload;

    function NeedChild(aNameID: NativeInt): IXmlNode; overload;
    function NeedChild(const aName: TXmlString): IXmlNode; overload;
    function EnsureChild(aNameID: NativeInt): IXmlNode; overload;
    function EnsureChild(const aName: TXmlString): IXmlNode; overload;

    procedure RemoveAllChilds;

    function FindNodes(const anExpression: TXmlString): IXmlNodeList;

    function SelectNodes(const anExpression: TXmlString): IXmlNodeList;
    function SelectSingleNode(const anExpression: TXmlString): IXmlNode;
    function FullPath: TXmlString;
    function FindElement(const anElementName, anAttrName: String; const anAttrValue: Variant): IXmlElement;

    function Get_AttrCount: Integer;
    function Get_AttrNameID(anIndex: Integer): NativeInt;
    function Get_AttrName(anIndex: Integer): TXmlString;
    procedure RemoveAttr(const aName: TXmlString); overload;
    procedure RemoveAttr(aNameID: NativeInt); overload;
    procedure RemoveAllAttrs;

    function AttrExists(aNameID: NativeInt): Boolean; overload;
    function AttrExists(const aName: TXmlString): Boolean; overload;

    function GetAttrType(aNameID: NativeInt): Integer; overload;
    function GetAttrType(const aName: TXmlString): Integer; overload;

    function GetVarAttr(aNameID: NativeInt; const aDefault: Variant): Variant; overload;
    function GetVarAttr(const aName: TXmlString; const aDefault: Variant): Variant; overload;
    procedure SetVarAttr(aNameID: NativeInt; const aValue: Variant); overload;
    procedure SetVarAttr(const aName: TXmlString; const aValue: Variant); overload;

    function NeedAttr(aNameID: NativeInt): TXmlString; overload;
    function NeedAttr(const aName: TXmlString): TXmlString; overload;

    function GetAttr(aNameID: NativeInt; const aDefault: TXmlString = ''): TXmlString; overload;
    function GetAttr(const aName: TXmlString; const aDefault: TXmlString = ''): TXmlString; overload;
    procedure SetAttr(aNameID: NativeInt; const aValue: TXmlString); overload;
    procedure SetAttr(const aName, aValue: TXmlString); overload;

    function GetBytesAttr(aNameID: NativeInt; const aDefault: TBytes): TBytes; overload;
    function GetBytesAttr(const aName: TXmlString; const aDefault: TBytes): TBytes; overload;

    function GetBoolAttr(aNameID: NativeInt; aDefault: Boolean = False): Boolean; overload;
    function GetBoolAttr(const aName: TXmlString; aDefault: Boolean = False): Boolean; overload;
    procedure SetBoolAttr(aNameID: NativeInt; aValue: Boolean = False); overload;
    procedure SetBoolAttr(const aName: TXmlString; aValue: Boolean); overload;

    function GetIntAttr(aNameID: NativeInt; aDefault: Integer = 0): Integer; overload;
    function GetIntAttr(const aName: TXmlString; aDefault: Integer = 0): Integer; overload;
    procedure SetIntAttr(aNameID: NativeInt; aValue: Integer); overload;
    procedure SetIntAttr(const aName: TXmlString; aValue: Integer); overload;

    function GetDateTimeAttr(aNameID: NativeInt; aDefault: TDateTime = 0): TDateTime; overload;
    function GetDateTimeAttr(const aName: TXmlString; aDefault: TDateTime = 0): TDateTime; overload;
    procedure SetDateTimeAttr(aNameID: NativeInt; aValue: TDateTime); overload;
    procedure SetDateTimeAttr(const aName: TXmlString; aValue: TDateTime); overload;

    function GetFloatAttr(aNameID: NativeInt; aDefault: Double = 0): Double; overload;
    function GetFloatAttr(const aName: TXmlString; aDefault: Double = 0): Double; overload;
    procedure SetFloatAttr(aNameID: NativeInt; aValue: Double); overload;
    procedure SetFloatAttr(const aName: TXmlString; aValue: Double); overload;

    function GetHexAttr(const aName: TXmlString; aDefault: Cardinal = 0): Cardinal; overload;
    function GetHexAttr(aNameID: NativeInt; aDefault: Cardinal = 0): Cardinal; overload;
    procedure SetHexAttr(const aName: TXmlString; aValue: Cardinal; aDigits: Integer = 8); overload;
    procedure SetHexAttr(aNameID: NativeInt; aValue: Cardinal; aDigits: Integer = 8); overload;

    function GetEnumAttr(const aName: TXmlString;
      const aValues: array of TXmlString; aDefault: Integer = 0): Integer; overload;
    function GetEnumAttr(aNameID: NativeInt;
      const aValues: array of TXmlString; aDefault: Integer = 0): Integer; overload;
    function NeedEnumAttr(const aName: TXmlString;
      const aValues: array of TXmlString): Integer; overload;
    function NeedEnumAttr(aNameID: NativeInt;
      const aValues: array of TXmlString): Integer; overload;


    function Get_Values(const aName: TXmlString): Variant;
    procedure Set_Values(const aName: TXmlString; const aValue: Variant);

    function AsElement: IXmlElement; virtual;
    function AsText: IXmlText; virtual;
    function AsCDATASection: IXmlCDATASection; virtual;
    function AsComment: IXmlComment; virtual;
    function AsProcessingInstruction: IXmlProcessingInstruction; virtual;

  public
    constructor Create(aNames: TXmlNameTable);
    destructor Destroy; override;
  end;

  TXmlDataNode = class;

  // TXmlElement is a named node - it is not able to save any data by itself.
  // For data it need a child node like TXmlText or TXmlCDATASection
  TXmlElement = class(TXmlNode, IXmlElement)
  private
    FNameID: NativeInt;
    procedure RemoveTextNodes;
    procedure SetNodeNameID(aValue: Integer); override;
    function DoCloneNode(aDeep: Boolean): IXmlNode; override;
    function Get_DataNode(Clean: Boolean=False): TXMLDataNode;
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_MyXMLText: TMyXmlString; override;
    procedure Set_MyXMLText(const aValue: TMyXmlString); override;
    function Get_DataType: TVarType; override;
    procedure Set_DataType(const aValue: TVarType); override;
    function Get_TypedValue: Variant; override;
    procedure Set_TypedValue(const aValue: Variant); override;
    function Get_myXML: TmyXmlString; override;
    function AsElement: IXmlElement; override;
    procedure SaveXML(aXMLSaver: TXmlSaver); override;

    // IXmlElement
    procedure ReplaceTextByCDATASection(const aText: TXmlString);
    procedure ReplaceTextByBinaryData(const aData; aSize: Integer);
    function GetTextAsBinaryData: TBytes;
  public
    constructor Create(aNames: TXmlNameTable; aNameID: NativeInt);
  end;

  TXmlCharacterData = class(TXmlNode, IXmlCharacterData)
  private
    FData: TmyXmlString;
  protected
    function Get_MyXMLText: TMyXmlString; override;
    procedure Set_MyXMLText(const aValue: TmyXmlString); override;
  public
    constructor Create(aNames: TXmlNameTable; const aData: TmyXmlString);
  end;

  TXmlDataNode = class(TXmlNode)
  private
    FDataType: TVarType;
    FData: TmyXmlString;
  protected
    function Get_DataType: TVarType; override;
    procedure Set_DataType(const aValue: TVarType); override;
    function Get_TypedValue: Variant; override;
    function Get_MyXMLText: TMyXmlString; override;
    procedure Set_MyXMLText(const aValue: TMyXmlString); override;
    procedure Set_TypedValue(const aValue: Variant); override;
    procedure SaveXML(aXMLSaver: TXmlSaver); override;
  public
    constructor Create(aNames: TXmlNameTable; const aData: TmyXmlString);
  end;

  TXmlText = class(TXmlDataNode, IXmlText)
  private
    function DoCloneNode(aDeep: Boolean): IXmlNode; override;
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_myXML: TmyXmlString; override;
    function AsText: IXmlText; override;
  public
  end;

  TXmlCDATASection = class(TXmlDataNode, IXmlCDATASection)
  private
    function DoCloneNode(aDeep: Boolean): IXmlNode; override;
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_myXML: TmyXmlString; override;
    function AsCDATASection: IXmlCDATASection; override;
  public
  end;

  TXmlComment = class(TXmlCharacterData, IXmlComment)
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_myXML: TmyXmlString; override;
    procedure SaveXML(aXMLSaver: TXmlSaver); override;
    function AsComment: IXmlComment; override;
    function DoCloneNode(aDeep: Boolean): IXmlNode; override;
  public
  end;

  TXmlProcessingInstruction = class(TXmlNode, IXmlProcessingInstruction)
  private
    FTargetNameID: NativeInt;
    FData: TmyXmlString;
    procedure SetNodeNameID(aValue: Integer); override;
    function DoCloneNode(aDeep: Boolean): IXmlNode; override;
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_MyXMLText: TMyXmlString; override;
    procedure Set_MyXMLText(const aText: TmyXmlString); override;
    function Get_myXML: TmyXmlString; override;
    procedure SaveXML(aXMLSaver: TXmlSaver); override;
    function AsProcessingInstruction: IXmlProcessingInstruction; override;

  public
    constructor Create(aNames: TXmlNameTable; aTargetID: NativeInt;
      const aData: TmyXmlString = '');
  end;

  TXmlDocument = class(TXmlNode, IXmlDocument)
  private
    FOnTagEnd: THookTag;
    FOnTagBegin: THookTag;
    FPreserveWhiteSpace: Boolean;

    function DoCloneNode(aDeep: Boolean): IXmlNode; override;
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_MyXMLText: TMyXmlString; override;
    procedure Set_MyXMLText(const aText: TmyXmlString); override;
    function Get_myXML: TmyXmlString; override;
    procedure SaveXML(aXMLSaver: TXmlSaver); override;
    function Get_OnTagBegin: THookTag;
    procedure Set_OnTagBegin(aValue: THookTag);
    function Get_OnTagEnd: THookTag;
    procedure Set_OnTagEnd(aValue: THookTag);
    function Get_PreserveWhiteSpace: Boolean;
    procedure Set_PreserveWhiteSpace(aValue: Boolean);

    function NewDocument(const aVersion, anEncoding: TXmlString;
      aRootElementNameID: NativeInt): IXmlElement; overload;
    function NewDocument(const aVersion, anEncoding,
      aRootElementName: TXmlString): IXmlElement; overload;

    function CreateElement(aNameID: NativeInt): IXmlElement; overload;
    function CreateElement(const aName: TXmlString): IXmlElement; overload;
    function CreateText(const aData: TXmlString): IXmlText;
    function CreateCDATASection(const aData: TXmlString): IXmlCDATASection;
    function CreateComment(const aData: TXmlString): IXmlComment;
    function Get_DocumentElement: IXmlElement;
    function CreateProcessingInstruction(const aTarget: TXmlString;
      const aData: TXmlString = ''): IXmlProcessingInstruction; overload;
    function CreateProcessingInstruction(aTargetID: NativeInt;
      const aData: TXmlString = ''): IXmlProcessingInstruction; overload;
    procedure LoadXML(const aXML: RawByteString; const Encoding: String  = ''); overload;
    {$IF Defined(XML_WIDE_CHARS) or Defined(Unicode)}
    procedure LoadXML(const aXML: TXmlString; const Encoding: String = ''); overload;
    {$IFEND}

    procedure Load(aStream: TStream; const Encoding: String); overload;
    procedure Load(const aFileName, Encoding: String); overload;

    procedure LoadResource(aType, aName: PChar);

    procedure Save(aStream: TStream); overload;
    procedure Save(const aFileName: String); overload;

    procedure SaveBinary(aStream: TStream); overload;
    procedure SaveBinary(const aFileName: String); overload;

    function GetEncoding: TXmlString;
    procedure SetEncoding(const Encoding: TXmlString);

    function Get_BinaryXML: TBytes;
    procedure LoadBinaryXML(const Data; const Count: Integer);
  public
    constructor Create(aNames: TXmlNameTable=nil);
  end;

const
  NodeClasses: array [TXmlNodeType] of TClass=
    (TObject, TXmlElement, TXmlText, TXmlCDATASection, 
     TXmlProcessingInstruction, TXmlComment, TXmlDocument);
  
{ TXmlNodeList }

procedure TXmlNodeList.Clear;
var
  i: Integer;
  aNode: TXmlNode;
begin
  for i := 0 to FCount - 1 do begin
    aNode := FItems[i];
    if Assigned(FOwnerNode) then
      aNode.FParentNode := nil;
    aNode._Release;
  end;
  FCount := 0;
end;

procedure TXmlNodeList.Delete(anIndex: Integer);
var
  aNode: TXmlNode;
begin
  aNode := FItems[anIndex];
  Dec(FCount);
  if anIndex < FCount then
    Move(FItems[anIndex + 1], FItems[anIndex],
      (FCount - anIndex)*SizeOf(TXmlNode));
  if Assigned(aNode) then begin
    if Assigned(FOwnerNode) then
      aNode.FParentNode := nil;
    aNode._Release;
  end;
end;

constructor TXmlNodeList.Create(anOwnerNode: TXmlNode);
begin
  inherited Create;
  {$IFDEF ADDebug}
  FDebugId := InterlockedIncrement(DebugId);
  outputdebugstring(PChar(Format('Create %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  FOwnerNode := anOwnerNode;
end;

destructor TXmlNodeList.Destroy;
begin
  {$IFDEF ADDebug}
  outputdebugstring(PChar(Format('Destroy %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  Clear;
  inherited;
end;

procedure TXmlNodeList.Exchange(Index1, Index2: Integer);
var
  Temp: TXmlNode;
begin
  if (Index1>=0) and (Index2>=0)
  then begin
    Temp := FItems[Index1];
    FItems[Index1] := FItems[Index2];
    FItems[Index2] := Temp;
  end;
end;

function TXmlNodeList.Get_Item(anIndex: Integer): IXmlNode;
begin
  if (anIndex < 0) or (anIndex >= FCount) then
    raise Exception.CreateFmt(SSimpleXmlError1, [anIndex]);
  Result := FItems[anIndex]
end;

function TXmlNodeList.Get_myXML: TmyXmlString;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to FCount - 1 do
    Result := Result + FItems[i].Get_myXML;
end;

function TXmlNodeList.Get_Count: Integer;
begin
  if Self<>nil
  then
    Result := FCount
  else
    Result := 0;
end;

function TXmlNodeList.IndexOf(aNode: TXmlNode): Integer;
var
  i: Integer;
begin
  for i := 0 to FCount - 1 do
    if FItems[i] = aNode then begin
      Result := i;
      Exit
    end;
  Result := -1;
end;

procedure TXmlNodeList.Grow;
var
  aDelta: Integer;
begin
  if Length(FItems) > 64 then
    aDelta := Length(FItems) div 4
  else
    if Length(FItems) > 8 then
      aDelta := 16
    else
      aDelta := 4;
  SetLength(FItems, Length(FItems) + aDelta);
end;

procedure TXmlNodeList.Insert(aNode: TXmlNode; anIndex: Integer);
begin
  if aNode <> nil
  then begin
    if ((aNode.FParentNode<>nil) and (aNode.FParentNode <> FOwnerNode)) or
       ((FOwnerNode<>nil) and (FOwnerNode.FNames<>aNode.FNames))
    then begin
      aNode := aNode.DoCloneNode(True).GetObject as TXmlNode;
      if FOwnerNode<>nil
      then
        aNode.SetNameTable(FOwnerNode.FNames);
    end;
    aNode._AddRef;
    aNode.FParentNode := FOwnerNode;
  end;
  if anIndex = -1 then
    anIndex := FCount;
  if FCount = Length(FItems) then
    Grow;
  if anIndex < FCount then
    Move(FItems[anIndex], FItems[anIndex + 1],
         (FCount - anIndex)*SizeOf(TXmlNode));
  FItems[anIndex] := aNode;
  Inc(FCount);
end;

function TXmlNodeList.Remove(aNode: TXmlNode): Integer;
begin
  Result := IndexOf(aNode);
  if Result <> -1 then
    Delete(Result);
end;

procedure TXmlNodeList.Replace(anIndex: Integer; aNode: TXmlNode);
var
  anOldNode: TXmlNode;
begin
  anOldNode := FItems[anIndex];
  if aNode <> anOldNode
  then begin
    if Assigned(anOldNode)
    then begin
      if Assigned(FOwnerNode)
      then
        anOldNode.FParentNode := nil;
      anOldNode._Release;
    end;
    FItems[anIndex] := aNode;
    if (aNode<>nil)
    then begin
      if ((aNode.FParentNode<>nil) and (aNode.FParentNode <> FOwnerNode)) or
         ((FOwnerNode<>nil) and (FOwnerNode.FNames<>aNode.FNames))
      then begin
        aNode := aNode.DoCloneNode(True).GetObject as TXmlNode;
        aNode.FParentNode := FOwnerNode;
        aNode.SetNameTable(FOwnerNode.FNames);
      end
      else
        aNode._AddRef;
    end;
  end;
end;

function TXmlNodeList.Get_XML: TXmlString;
begin
  Result := MyXMLStringToXMLString(Get_myXML);
end;

procedure TXmlNodeList.ParseXML(aXML: TXmlSource; aNames: TXmlNameTable;
                                HookTagBegin, HookTagEnd: THookTag;
                                aPreserveWhiteSpace: Boolean);

  // на входе: символ текста
  // на выходе: символ разметки '<'
  procedure ParseText;
  var
    aText: TmyXmlString;
  begin
    aXml.NewToken;
    while not aXML.EOF and (aXML.CurChar <> UCS4Char('<')) do
      if aXML.CurChar = UCS4Char('&') then
        aXml.AppendTokenChar(aXml.ExpectXmlEntity)
      else begin
        aXml.AppendTokenChar(aXML.CurChar);
        aXML.Next;
      end;
    if aPreserveWhiteSpace
    then
      aText := aXml.AcceptToken
    else
      aText := myXMLTrim(aXml.AcceptToken);
    if Length(aText)<>0
    then
      Insert(TXmlText.Create(aNames, aText), -1);
  end;

  // CurChar - '?'
  procedure ParseProcessingInstruction;
  var
    aTarget: TmyXMLString;
    aNode: TXmlProcessingInstruction;
    EncodingData: PXMLAttrData;
  begin
    aXML.Next;
    aTarget := aXML.ExpectXmlName;
    aNode := TXmlProcessingInstruction.Create(aNames, aNames.GetmyXMLID(aTarget));
    Insert(aNode, -1);
    if aNode.FTargetNameID = aNames.FXmlNameID
    then begin
      aXml.ParseAttrs(aNode);
      aXml.ExpectText('?>');
      if aXML.AutoCodepage
      then begin
        EncodingData := aNode.FindAttrData(aNames.FEncodingNameId);
        if (EncodingData<>nil)
        then begin
          aXML.Codepage := FindCodepage(EncodingData.Value);
          if aXML.Codepage=0
          then
            raise Exception.CreateFmt(SSimpleXmlError26, [UTF8ToAnsi(EncodingData.Value)]);
        end
        else
          aXML.SetCodepage(CP_UTF8);
      end;
    end
    else
      aNode.FData := aXml.ParseTo('?>');
  end;

  // на входе: первый '--'
  // на выходе: символ после '-->'
  procedure ParseComment;
  begin
    aXml.ExpectText('--');
    Insert(TXmlComment.Create(aNames, aXml.ParseTo('-->')), -1);
  end;

  // на входе: '[CDATA['
  // на выходе: символ после ']]>'
  procedure ParseCDATA;
  begin
    aXml.ExpectText('[CDATA[');
    Insert(TXmlCDATASection.Create(aNames, aXml.ParseTo(']]>')), -1);
  end;

  // на входе: 'DOCTYPE'
  // на выходе: символ после '>'
  procedure ParseDOCTYPE;
  begin
    aXml.ExpectText('DOCTYPE');
    aXml.ParseTo('>');
  end;

  // на входе: 'имя-элемента'
  // на выходе: символ после '>'
  procedure ParseElement;
  var
    aNameID: NativeInt;
    aNode: TXmlElement;
  begin
    if (aXML.Codepage=0) and aXML.AutoCodepage and
       (FCount=0) and (FOwnerNode.ClassType = TXmlDocument)
    then
      aXML.Codepage := CP_UTF8;
    aNameID := aNames.GetmyXMLID(aXml.ExpectXmlName);
    if aXml.EOF then
      raise Exception.Create(SSimpleXMLError2);
    if not ((aXml.CurChar <= UCS4Char(' ')) or
            (aXml.CurChar = UCS4Char('/')) or
            (aXml.CurChar = UCS4Char('>')))
    then
      raise Exception.Create(SSimpleXMLError3);
    aNode := TXmlElement.Create(aNames, aNameID);
    Insert(aNode, -1);
    aXml.ParseAttrs(aNode);
    if assigned(HookTagBegin) then
      HookTagBegin(Self, aNode);
    if aXml.CurChar = UCS4Char('/') then
      aXml.ExpectText('/>')
    else begin
      aXml.ExpectChar('>');
      aNode.GetChilds.ParseXML(aXml, aNames, HookTagBegin, HookTagEnd, aPreserveWhiteSpace);
      aXml.ExpectChar('/');
      aXml.ExpectText(aNames.GetmyXMLName(aNameID));
      aXml.SkipBlanks;
      aXml.ExpectChar('>');
    end;
    if assigned(HookTagEnd) then
      HookTagEnd(Self, aNode);
  end;
  
begin
  while not aXML.EOF do
  begin
    ParseText;
    if aXML.CurChar = UCS4Char('<')
    then begin// символ разметки
      if aXML.Next
      then begin
        if aXML.CurChar = UCS4Char('/')
        then // закрывающий тэг элемента
          Exit
        else
        if aXML.CurChar = UCS4Char('?')
        then begin// инструкция
          ParseProcessingInstruction;
        end
        else
        if aXML.CurChar = UCS4Char('!')
        then begin
          if aXML.Next
          then begin
            if aXML.CurChar = UCS4Char('-')
            then // коментарий
              ParseComment
            else
            if aXML.CurChar = UCS4Char('[')
            then // секция CDATA
              ParseCDATA
            else
              ParseDOCTYPE;
          end;
        end
        else // открывающий тэг элемента
          ParseElement;
      end;
    end;
  end;
end;

procedure TXmlNodeList.LoadBinXml(aReader: TBinXmlReader; aCount: Integer; aNames: TXmlNameTable);
var
  i: Integer;
  aNodeType: TXmlNodeType;
  aNode: TXmlNode;
  aNameID: LongInt;
begin
  Clear;
  SetLength(FItems, aCount);
  for i := 0 to aCount - 1 do begin
    aReader.Read(aNodeType, sizeof(aNodeType));
    case aNodeType of
      NODE_ELEMENT:
        begin
          aNameID := aNames.GetNameID(aReader.ReadLongint);
          aNode := TXmlElement.Create(aNames, aNameID);
          Insert(aNode, -1);
          aNode.LoadBinXml(aReader);
        end;
      NODE_TEXT:
        begin
          aNode := TXmlText.Create(aNames, MyXMLEmptyString);
          Insert(aNode, -1);
          aReader.ReadVariant(TXmlText(aNode).FDataType, TXmlText(aNode).FData);
        end;
      NODE_CDATA_SECTION:
        begin
          aNode := TXmlCDATASection.Create(aNames, MyXMLEmptyString);
          Insert(aNode, -1);
          aReader.ReadVariant(TXmlText(aNode).FDataType, TXmlText(aNode).FData);
        end;
      NODE_PROCESSING_INSTRUCTION:
        begin
          aNameID := aNames.GetNameID(aReader.ReadLongint);
          aNode := TXmlProcessingInstruction.Create(aNames, aNameID,
                     aReader.ReadBinData);
          Insert(aNode, -1);
          aNode.LoadBinXml(aReader);
        end;
      NODE_COMMENT:
        Insert(TXmlComment.Create(aNames, aReader.ReadBinData), -1);
      else
        raise Exception.Create(SSimpleXMLError4);
    end
  end;
end;

procedure TXmlNodeList.SaveBinXml(aWriter: TBinXmlWriter);
const
  EmptyVar: TVarData = (VType:varEmpty);
var
  aCount: LongInt;
  i: Integer;
  aNodeType: TXmlNodeType;
  aNode: TXmlNode;
begin
  aCount := FCount;
  for i := 0 to aCount - 1 do begin
    aNode := FItems[i];
    aNodeType := aNode.Get_NodeType;
    aWriter.Write(aNodeType, sizeof(aNodeType));
    case aNodeType of
      NODE_ELEMENT:
        with TXmlElement(aNode) do begin
          aWriter.WriteLongint(FNames.GetKeyID(FNameID));
          SaveBinXml(aWriter);
        end;
      NODE_TEXT, NODE_CDATA_SECTION:
        aWriter.WriteVariant(TXmlDataNode(aNode).FDataType, TXmlDataNode(aNode).FData);
      NODE_PROCESSING_INSTRUCTION:
        begin
          with TXmlProcessingInstruction(aNode) do
          begin
            aWriter.WriteLongint(FNames.GetKeyID(FTargetNameID));
            aWriter.WriteUTF8String(FData);
          end;
          aNode.SaveBinXml(aWriter);
        end;
      NODE_COMMENT:
        aWriter.WriteUTF8String(TXmlComment(aNode).FData);
      else
        raise Exception.Create(SSimpleXmlError5);
    end
  end;
end;

procedure TXmlNodeList.SaveXML(aXML: TXmlSaver);
var
  i: Integer;
begin
  for i := 0 to FCount - 1 do
    FItems[i].SaveXML(aXML);
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'XML Node Implementation'}{$ENDIF}
{ TXmlNode }

constructor TXmlNode.Create(aNames: TXmlNameTable);
begin
  inherited Create;
  {$IFDEF ADDebug}
  FDebugId := InterlockedIncrement(DebugId);
  outputdebugstring(PChar(Format('Create %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  if aNames<>nil
  then
    FNames := aNames
  else
    FNames := TXmlNameTable.Create(DefaultHashSize);
  FNames._AddRef;
end;

destructor TXmlNode.Destroy;
begin
  {$IFDEF ADDebug}
  outputdebugstring(PChar(Format('Destroy %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  if Assigned(FChilds) then
    FChilds._Release;
  FNames._Release;
  inherited;
end;

function TXmlNode.GetChilds: TXmlNodeList;
begin
  if not Assigned(FChilds) then begin
    FChilds := TXmlNodeList.Create(Self);
    FChilds._AddRef;
  end;
  Result := FChilds;
end;

procedure TXmlNode.AppendChild(const aChild: IXmlNode);
begin
  GetChilds.Insert(aChild.GetObject as TXmlNode, -1);
end;

function TXmlNode.Get_AttrCount: Integer;
begin
  Result := FAttrCount;
end;

function TXmlNode.Get_AttrName(anIndex: Integer): TXmlString;
begin
  Result := FNames.GetName(FAttrs[anIndex].NameID);
end;

function TXmlNode.Get_AttrNameID(anIndex: Integer): NativeInt;
begin
  Result := FAttrs[anIndex].NameID;
end;

function TXmlNode.Get_ChildNodes: IXmlNodeList;
begin
  Result := GetChilds
end;

function TXmlNode.Get_DataType: TVarType;
begin
  Result := NativeVarType;
end;

function TXmlNode.Get_NameTable: IXmlNameTable;
begin
  Result := FNames
end;

function TXmlNode.GetAttr(const aName, aDefault: TXmlString): TXmlString;
begin
  Result := GetAttr(FNames.GetID(aName), aDefault)
end;

function TXmlNode.GetAttr(aNameID: NativeInt; const aDefault: TXmlString): TXmlString;
var
  aData: PXmlAttrData;
begin
  aData := FindAttrData(aNameID);
  if Assigned(aData) then
    Result := MyXMLStringToXMLString(aData.Value)
  else
    Result := aDefault;
end;

function TXmlNode.GetBoolAttr(aNameID: NativeInt; aDefault: Boolean): Boolean;
begin
  Result := GetVarAttr(aNameID, aDefault);
end;

function TXmlNode.GetBoolAttr(const aName: TXmlString; aDefault: Boolean): Boolean;
begin
  Result := GetVarAttr(aName, aDefault);
end;

procedure CopyWordToByteArray(s: PWord; d: PByte; Size: Integer);
begin
  while Size>0 do
  begin
    d^ := PByte(s)^;
    inc(s); inc(d); dec(Size);
  end;
end;

function TXmlNode.GetBytesAttr(aNameID: NativeInt; const aDefault: TBytes): TBytes;
var
  temp: TXmlString;
begin
  temp := GetVarAttr(aNameID, aDefault);
  if temp<>''
  then begin
    SetLength(Result, Length(temp));
    {$IF Defined(XML_WIDE_CHARS) or Defined(Unicode)}
    CopyWordToByteArray(Pointer(temp), Pointer(Result), Length(Result));
    {$ELSE}
    move(Pointer(temp)^, Pointer(Result)^, Length(Result));
    {$IFEND}
  end
  else
    Result := aDefault
end;

function TXmlNode.GetBytesAttr(const aName: TXmlString; const aDefault: TBytes): TBytes;
begin
  Result := GetBytesAttr(FNames.GetID(aName), aDefault);
end;

function TXmlNode.FindFirstChild(aNameID: NativeInt): TXmlNode;
var
  i: Integer;
begin
  if Assigned(FChilds) then
    for i := 0 to FChilds.FCount - 1 do begin
      Result := FChilds.FItems[i];
      if Result.Get_NodeNameID = aNameID then
        Exit
    end;
  Result := nil
end;

function TXmlNode.FullPath: TXmlString;
var
  aParent: TXmlNode;
begin
  aParent := FParentNode;
  if (aParent<>nil)
  then begin
    Result := Get_NodeName;
    while (aParent<>nil) and (aParent.ClassType<>TXmlDocument) do
    begin
      Result := aParent.Get_NodeName + XMLPathDelimiter + Result;
      aParent := aParent.FParentNode;
    end;
  end;
end;

function TXmlNode.GetChildText(aNameID: NativeInt;
                               const aDefault: TXmlString): TXmlString;
var
  aChild: TXmlNode;
begin
  aChild := FindFirstChild(aNameID);
  if Assigned(aChild) then
    Result := aChild.Get_Text
  else
    Result := aDefault
end;

function TXmlNode.GetChildText(const aName: TXmlString;
                               const aDefault: TXmlString): TXmlString;
begin
  Result := GetChildText(FNames.GetID(aName), aDefault);
end;

function TXmlNode.GetEnumAttr(const aName: TXmlString;
                              const aValues: array of TXmlString;
                              aDefault: Integer): Integer;
begin
  Result := GetEnumAttr(FNames.GetID(aName), aValues, aDefault);
end;

function EnumAttrValue(aNode: TXmlNode; anAttrData: PXmlAttrData;
                       const aValues: array of TXmlString): Integer;
var
  anAttrValue: TXmlString;
  s: TXmlString;
  i: Integer;
begin
  anAttrValue := MyXMLStringToXMLString(anAttrData.Value);
  for Result := 0 to High(aValues) do
  begin
    {$ifdef XML_WIDE_CHARS}
    if WideCompareText(anAttrValue, aValues[Result]) = 0 then
      Exit;
    {$else}
    if AnsiCompareText(anAttrValue, aValues[Result]) = 0 then
      Exit;
    {$endif}
  end;
  if Length(aValues) = 0 then
    s := ''
  else begin
    s := aValues[0];
    for i := 1 to Length(aValues) - 1 do
      s := s + #13#10 + aValues[i];
  end;
  raise Exception.CreateFmt(SSimpleXmlError6,
    [aNode.FNames.GetName(anAttrData.NameID), aNode.Get_NodeName, s]);
end;

function TXmlNode.GetEnumAttr(aNameID: NativeInt;
                              const aValues: array of TXmlString; 
                              aDefault: Integer): Integer;
var
  anAttrData: PXmlAttrData;
begin
  anAttrData := FindAttrData(aNameID);
  if Assigned(anAttrData) then
    Result := EnumAttrValue(Self, anAttrData, aValues)
  else
    Result := aDefault;
end;

function TXmlNode.NeedEnumAttr(const aName: TXmlString;
                               const aValues: array of TXmlString): Integer;
begin
  Result := NeedEnumAttr(FNames.GetID(aName), aValues)
end;

function TXmlNode.NeedEnumAttr(aNameID: NativeInt;
                               const aValues: array of TXmlString): Integer;
var
  anAttrData: PXmlAttrData;
begin
  anAttrData := FindAttrData(aNameID);
  if Assigned(anAttrData) then
    Result := EnumAttrValue(Self, anAttrData, aValues)
  else
    raise Exception.CreateFmt(SSimpleXMLError7, [FNames.GetName(aNameID)]);
end;

function TXmlNode.GetFloatAttr(const aName: TXmlString; aDefault: Double): Double;
begin
  Result := GetFloatAttr(FNames.GetID(aName), aDefault);
end;

function TXmlNode.GetFloatAttr(aNameID: NativeInt; aDefault: Double): Double;
var
  aData: PXmlAttrData;
begin
  aData := FindAttrData(aNameID);
  if Assigned(aData) then
    Result := XSTRToFloat(UTF8ToAnsi(aData.Value))
  else
    Result := aDefault
end;

function TXmlNode.GetHexAttr(aNameID: NativeInt; aDefault: Cardinal): Cardinal;
var
  aData: PXmlAttrData;
begin
  aData := FindAttrData(aNameID);
  if Assigned(aData) then
    Result := HexToCardA(aData.Value)
  else
    Result := aDefault;
end;

function TXmlNode.GetHexAttr(const aName: TXmlString; aDefault: Cardinal): Cardinal;
begin
  Result := GetHexAttr(FNames.GetID(aName), aDefault)
end;

function TXmlNode.GetIntAttr(aNameID: NativeInt; aDefault: Integer): Integer;
var
  anAttr: PXmlAttrData;
begin
  anAttr := FindAttrData(aNameID);
  if Assigned(anAttr)
  then begin
    if DataTypeIsStr(anAttr.DataType) or (anAttr.DataType in [varSmallint, varInteger, varShortInt])
    then
      Result := StrToIntA(anAttr.Value)
    else
      Result := MyXMLStringToVar(anAttr.DataType, anAttr.Value);
  end
  else
    Result := aDefault;
end;

function TXmlNode.GetIntAttr(const aName: TXmlString; aDefault: Integer): Integer;
begin
  Result := GetIntAttr(FNames.GetID(aName), aDefault)
end;

function TXmlNode.NeedAttr(aNameID: NativeInt): TXmlString;
var
  anAttr: PXmlAttrData;
begin
  anAttr := FindAttrData(aNameID);
  if not Assigned(anAttr) then
    raise Exception.CreateFmt(SSimpleXmlError8, [FNames.GetName(aNameID)]);
  Result := MyXMLStringToXMLString(anAttr.Value);
end;

function TXmlNode.NeedAttr(const aName: TXmlString): TXmlString;
begin
  Result := NeedAttr(FNames.GetID(aName))
end;

function TXmlNode.GetVarAttr(aNameID: NativeInt; const aDefault: Variant): Variant;
var
  anAttr: PXmlAttrData;
begin
  anAttr := FindAttrData(aNameID);
  if (anAttr<>nil)
  then begin
    Result := MyXMLStringToVar(anAttr.DataType, anAttr.Value);
  end
  else
    Result := aDefault;
end;

function TXmlNode.GetVarAttr(const aName: TXmlString; 
                             const aDefault: Variant): Variant;
begin
  Result := GetVarAttr(FNames.GetID(aName), aDefault)
end;

function TXmlNode.GetXMLIndent: Integer;
var
  aParentNode: TXmlNode;
begin
  Result := 0;
  aParentNode := FParentNode;
  while (aParentNode<>nil) and not (aParentNode is TXmlDocument) do
  begin
    aParentNode := aParentNode.FParentNode;
    inc(Result);
  end;
end;

function TXmlNode.Get_NodeName: TXmlString;
begin
  Result := FNames.GetName(Get_NodeNameID);
end;

function TXmlNode.Get_NodeType: TXmlNodeType;
begin
  Result := High(TXmlNodeType);
  while (Result>Low(TXmlNodeType)) and (NodeClasses[Result]<>ClassType) do
    dec(Result);
end;

function TXmlNode.GetOwnerDocument: TXmlDocument;
var
  aResult: TXmlNode;
begin
  aResult := Self;
  while (aResult<>nil) and not (aResult is TXmlDocument) do
    aResult := aResult.FParentNode;
  Result := TXmlDocument(aResult);
end;

function TXmlNode.Get_OwnerDocument: IXmlDocument;
var
  aDoc: TXmlDocument;
begin
  aDoc := GetOwnerDocument;
  if Assigned(aDoc) then
    Result := aDoc
  else
    Result := nil;
end;

function TXmlNode.Get_ParentNode: IXmlNode;
begin
  Result := FParentNode
end;

function TXmlNode.Get_Text: TXmlString;
begin
  Result := MyXMLStringToXMLString(Get_MyXMLText)
end;

function TXmlNode.Get_TypedValue: Variant;
begin
  Result := Get_Text
end;

procedure TXmlNode.InsertBefore(const aChild, aBefore: IXmlNode);
var
  i: Integer;
  aChilds: TXmlNodeList;
begin
  aChilds := GetChilds;
  if Assigned(aBefore) then
    i := aChilds.IndexOf(aBefore.GetObject as TXmlNode)
  else
    i := aChilds.FCount;
  GetChilds.Insert(aChild.GetObject as TXmlNode, i)
end;

procedure TXmlNode.RemoveAllAttrs;
begin
  FAttrCount := 0; 
end;

procedure TXmlNode.RemoveAllChilds;
begin
  if Assigned(FChilds) then
    FChilds.Clear
end;

procedure TXmlNode.RemoveAttr(const aName: TXmlString);
begin
  RemoveAttr(FNames.GetID(aName));
end;

procedure TXmlNode.RemoveAttr(aNameID: NativeInt);
var
  a1, a2: PXmlAttrData;
  i: Integer;
begin
  a1 := @FAttrs[0];
  i := 0;
  while (i < FAttrCount) and (a1.NameID <> aNameID) do begin
    Inc(a1);
    Inc(i)
  end;
  if i < FAttrCount then begin
    a2 := a1;
    Inc(a2);
    while i < FAttrCount - 1 do begin
      a1^ := a2^;
      Inc(a1);
      Inc(a2);
      Inc(i)
    end;
    SetLength(a1.Value, 0);
    Dec(FAttrCount);
  end;
end;

procedure TXmlNode.RemoveChild(const aChild: IXmlNode);
begin
  GetChilds.Remove(aChild.GetObject as TXmlNode)
end;

procedure TXmlNode.ReplaceChild(const aNewChild, anOldChild: IXmlNode);
var
  i: Integer;
  aChilds: TXmlNodeList;
begin
  aChilds := GetChilds;
  i := aChilds.IndexOf(anOldChild.GetObject as TXmlNode);
  if i <> -1 then
    aChilds.Replace(i, aNewChild.GetObject as TXmlNode)
end;

function NameCanBeginWith(aChar: TXmlChar): Boolean;
begin
  {$IFDEF XML_WIDE_CHARS}
  Result := (aChar = '_') or IsCharAlphaW(aChar)
  {$ELSE}
  Result := (aChar = '_') or IsCharAlpha(aChar)
  {$ENDIF}
end;

function NameCanContain(aChar: TXmlChar): Boolean;
begin
  {$IFDEF XML_WIDE_CHARS}
  Result := (aChar = '_') or (aChar = '-') or (aChar = ':') or (aChar = '.') or
    IsCharAlphaNumericW(aChar)
  {$ELSE}
    {$IFDEF Unicode}
    Result := CharInSet(aChar, ['_', '-', ':', '.']) or IsCharAlphaNumeric(aChar)
    {$ELSE}
    Result := (aChar in ['_', '-', ':', '.']) or IsCharAlphaNumeric(aChar)
    {$ENDIF}
  {$ENDIF}
end;

function IsName(const s: TXmlString): Boolean;
var
  i: Integer;
begin
  if s = ''
  then
    Result := False
  else
  if not NameCanBeginWith(s[1])
  then
    Result := False
  else begin
    for i := 2 to Length(s) do
      if not NameCanContain(s[i])
      then begin
        Result := False;
        Exit;
      end;
    Result := True;
  end;
end;

function NameCanBeginWith4(aChar: UCS4Char): Boolean;
begin
  Result := (aChar = UCS4Char('_')) or
            ((aChar<=$FFFF) and IsCharAlphaW(WideChar(aChar)));
end;

function NameCanContain4(aChar: UCS4Char): Boolean;
begin
  Result := (aChar = UCS4Char('_')) or (aChar = UCS4Char('-')) or
            (aChar = UCS4Char(':')) or (aChar = UCS4Char('.')) or
            ((aChar<=$FFFF) and IsCharAlphaNumericW(WideChar(aChar)));
end;

const
  ntComment = -2;
  ntNode = -3;
  ntProcessingInstruction = -4;
  ntText = -5;
    
type
  TAxis = (axAncestor, axAncestorOrSelf, axAttribute, axChild,
    axDescendant, axDescendantOrSelf, axFollowing, axFollowingSibling,
    axParent, axPreceding, axPrecedingSibling, axSelf);

  TPredicate = class
    function Check(aNode: TXmlNode): Boolean; virtual; abstract;
  end;

  TLocationStep = class
    Next: TLocationStep;
    Axis: TAxis;
    NodeTest: Integer;
    Predicates: TList;
  end;


function TXmlNode.FindNodes(const anExpression: TXmlString): IXmlNodeList;
var
  aNodes: TXmlNodeList;
  aChilds: TXmlNodeList;
  aChild: TXmlNode;
  i:integer;
               procedure FindSubNode(aNode: TXmlNode);
               var
               x: Integer;
               aSubChilds: TXmlNodeList;
               begin
                   if aNode.Get_NodeName=anExpression then
                   begin
                     aNodes.Insert(aNode, aNodes.FCount);
                   end;

                  aSubChilds := aNode.GetChilds;

                  for x:=0 to aSubChilds.FCount-1 do
                  begin
                    FindSubNode(aSubChilds.FItems[x]);
                  end;
               end;
begin
    aNodes := TXmlNodeList.Create(Self);
    Result := aNodes;
    aChilds := GetChilds;

    for i := 0 to aChilds.FCount - 1 do begin
      aChild := aChilds.FItems[i];
      FindSubNode(aChild);
    end;
end;



function TXmlNode.SelectNodes(const anExpression: TXmlString): IXmlNodeList;
var
  aNodes: TXmlNodeList;
  aChilds: TXmlNodeList;
  aChild: TXmlNode;
  iChild: IXmlNode;
  aNameID: NativeInt;
  i, p: Integer;
begin
  if IsName(anExpression)
  then begin
    aNodes := TXmlNodeList.Create(Self);
    Result := aNodes;
    aChilds := GetChilds;
    aNameID := FNames.GetID(anExpression);
    for i := 0 to aChilds.FCount - 1 do begin
      aChild := aChilds.FItems[i];
      if (aChild.ClassType = TXmlElement) and (aChild.Get_NodeNameID = aNameID) then
        aNodes.Insert(aChild, aNodes.FCount);
    end;
  end
  else begin
    p := Pos(XMLPathDelimiter, anExpression);
    if p>0
    then begin
      iChild := SelectSingleNode(copy(anExpression, 1, p-1));
      if iChild<>nil
      then
        Result := iChild.SelectNodes(copy(anExpression, p+1, MaxInt));
    end
    else
      raise Exception.Create(SSimpleXmlError9)
  end;
end;

function TXmlNode.SelectSingleNode(const anExpression: TXmlString): IXmlNode;
var
  aChilds: TXmlNodeList;
  aChild: TXmlNode;
  aNameID: NativeInt;
  i, p: Integer;
begin
  Result := nil;
  if IsName(anExpression)
  then begin
    aChilds := GetChilds;
    aNameID := FNames.GetID(anExpression);
    for i := 0 to aChilds.FCount - 1 do 
    begin
      aChild := aChilds.FItems[i];
      if (aChild.ClassType = TXmlElement) and (aChild.Get_NodeNameID = aNameID) 
      then begin
        Result := aChild;
        Exit;
      end
    end;
  end
  else begin
    p := Pos(XMLPathDelimiter, anExpression);
    if p>0
    then begin
      Result := SelectSingleNode(copy(anExpression, 1, p-1));
      if Result<>nil 
      then
        Result := Result.SelectSingleNode(copy(anExpression, p+1, MaxInt));
    end
    else
      raise Exception.Create(SSimpleXmlError9)
  end
end;

function TXmlNode.FindElement(const anElementName, anAttrName: String;
                              const anAttrValue: Variant): IXmlElement;
var
  aChild: TXmlNode;
  aNameID, anAttrNameID: NativeInt;
  i: Integer;
  pa: PXmlAttrData;
begin
  if Assigned(FChilds) then begin
    aNameID := FNames.GetID(anElementName);
    anAttrNameID := FNames.GetID(anAttrName);

    for i := 0 to FChilds.FCount - 1 do begin
      aChild := FChilds.FItems[i];
      if (aChild.ClassType = TXmlElement) and (aChild.Get_NodeNameID = aNameID) then begin
        pa := aChild.FindAttrData(anAttrNameID);
        try
          if Assigned(pa) and VarSameValue(pa.Value, anAttrValue) then begin
            Result := aChild.AsElement;
            Exit
          end
        except
          // Исключительная ситуация может возникнуть в том случае,
          // если произойдет сбой в функции VarSameValue.
          // Иными словами - если значения нельзя сравнивать.
        end;
      end
    end;
  end;
  Result := nil;
end;

procedure TXmlNode.Set_DataType(const aValue: TVarType);
begin
  //nothing to - Node has fixed data type 
end;

procedure TXmlNode.Set_MyXMLAttr(aNameID: NativeInt; aDataType: TVarType; const aValue: TmyXmlString);
var
  aData: PXmlAttrData;
  aDelta: Integer;
begin
  aData := FindAttrData(aNameID);
  if (aData=nil)
  then begin
    if FAttrCount = Length(FAttrs)
    then begin
      if FAttrCount > 64 then
        aDelta := FAttrCount div 4
      else if FAttrCount > 8 then
        aDelta := 16
      else
        aDelta := 4;
      SetLength(FAttrs, FAttrCount + aDelta);
    end;
    aData := @FAttrs[FAttrCount];
    aData.NameID := aNameID;
    Inc(FAttrCount);
  end;
  if (aDataType=varEmpty) and (Length(aValue)>0)
  then
    aData.DataType := NativeVarType
  else
    aData.DataType := aDataType;
  aData.Value := aValue;
end;

procedure TXmlNode.Set_Text(const aValue: TXmlString);
begin
  Set_MyXMLText(XMLStringToMyXMLString(aValue));
end;

procedure TXmlNode.Set_TypedValue(const aValue: Variant);
begin
  Set_Text(aValue)
end;

procedure TXmlNode.SetAttr(const aName, aValue: TXmlString);
begin
  SetAttr(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetAttr(aNameID: NativeInt; const aValue: TXmlString);
begin
  if VarIsNull(aValue) or VarIsEmpty(aValue)
  then
    Set_MyXMLAttr(aNameID, varEmpty, MyXMLEmptyString)
  else begin
    Set_MyXMLAttr(aNameID,
                  NativeVarType,
                  XMLStringToMyXMLString(aValue));
  end;
end;

procedure TXmlNode.SetBoolAttr(aNameID: NativeInt; aValue: Boolean);
begin
  SetVarAttr(aNameID, aValue)
end;

procedure TXmlNode.SetBoolAttr(const aName: TXmlString; aValue: Boolean);
begin
  SetBoolAttr(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetChildText(const aName: TXmlString;
                                const aValue: TXmlString);
begin
  SetChildText(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetChildText(aNameID: NativeInt; const aValue: TXmlString);
var
  aChild: TXmlNode;
begin
  aChild := FindFirstChild(aNameID);
  if not Assigned(aChild) then begin
    aChild := TXmlElement.Create(FNames, aNameID);
    with GetChilds do
      Insert(aChild, FCount);
  end;
  aChild.Set_Text(aValue)
end;

procedure TXmlNode.SetFloatAttr(aNameID: NativeInt; aValue: Double);
begin
  Set_MyXMLAttr(aNameID,
                varDouble,
                FloatToStrA(aValue));
end;

procedure TXmlNode.SetFloatAttr(const aName: TXmlString; aValue: Double);
begin
  SetFloatAttr(FNames.GetID(aName), aValue);
end;

procedure TXmlNode.SetHexAttr(const aName: TXmlString;
                              aValue: Cardinal; aDigits: Integer);
begin
  SetHexAttr(FNames.GetID(aName), aValue, aDigits)
end;

procedure TXmlNode.SetHexAttr(aNameID: NativeInt; aValue: Cardinal; aDigits: Integer);
begin
  SetVarAttr(aNameID, IntToHex(aValue, aDigits))
end;

procedure TXmlNode.SetIntAttr(aNameID: NativeInt; aValue: Integer);
begin
  Set_MyXMLAttr(aNameID,
                varInteger,
                IntToStrA(aValue));
end;

procedure TXmlNode.SetIntAttr(const aName: TXmlString; aValue: Integer);
begin
  SetIntAttr(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetVarAttr(const aName: TXmlString; const aValue: Variant);
begin
  SetVarAttr(FNames.GetID(aName), aValue)
end;

procedure TXmlNode.SetVarAttr(aNameID: NativeInt; const aValue: Variant);
begin
  if VarIsNull(aValue) or VarIsEmpty(aValue)
  then
    Set_MyXMLAttr(aNameID, varEmpty, MyXMLEmptyString)
  else begin
    Set_MyXMLAttr(aNameID,
                  TVarData(aValue).VType,
                  VarToMyXMLString(aValue));
  end;
end;

function TXmlNode.FindAttrData(aNameID: NativeInt): PXmlAttrData;
var
  i: Integer;
begin
  if Length(FAttrs)>0
  then begin
    Result := @FAttrs[0];
    for i := 0 to FAttrCount - 1 do
      if Result.NameID = aNameID then
        Exit
      else
        Inc(Result);
  end;
  Result := nil;
end;

function TXmlNode.AsElement: IXmlElement;
begin
  Result := nil
end;

function TXmlNode.AsCDATASection: IXmlCDATASection;
begin
  Result := nil
end;

function TXmlNode.AsComment: IXmlComment;
begin
  Result := nil
end;

function TXmlNode.AsText: IXmlText;
begin
  Result := nil
end;

function TXmlNode.AsProcessingInstruction: IXmlProcessingInstruction;
begin
  Result := nil
end;

function TXmlNode.AppendCDATA(const aData: TXmlString): IXmlCDATASection;
var
  aChild: TXmlCDATASection;
begin
  aChild := TXmlCDATASection.Create(FNames, XMLStringToMyXMLString(aData));
  GetChilds.Insert(aChild, -1);
  Result := aChild
end;

function TXmlNode.AppendComment(const aData: TXmlString): IXmlComment;
var
  aChild: TXmlComment;
begin
  aChild := TXmlComment.Create(FNames, XMLStringToMyXMLString(aData));
  GetChilds.Insert(aChild, -1);
  Result := aChild
end;

function TXmlNode.AppendElement(const aName: TxmlString): IXmlElement;
var
  aChild: TXmlElement;
begin
  aChild := TXmlElement.Create(FNames, FNames.GetID(aName));
  GetChilds.Insert(aChild, -1);
  Result := aChild
end;

function TXmlNode.AppendElement(aNameID: NativeInt): IXmlElement;
var
  aChild: TXmlElement;
begin
  aChild := TXmlElement.Create(FNames, aNameID);
  GetChilds.Insert(aChild, -1);
  Result := aChild
end;

function TXmlNode.AppendProcessingInstruction(const aTarget,
  aData: TXmlString): IXmlProcessingInstruction;
var
  aChild: TXmlProcessingInstruction;
begin
  aChild := TXmlProcessingInstruction.Create(
    FNames,
    FNames.GetID(aTarget),
    XMLStringToMyXMLString(aData));
  GetChilds.Insert(aChild, -1);
  Result := aChild
end;

function TXmlNode.AppendProcessingInstruction(aTargetID: NativeInt;
  const aData: TXmlString): IXmlProcessingInstruction;
var
  aChild: TXmlProcessingInstruction;
begin
  aChild := TXmlProcessingInstruction.Create(
    FNames,
    aTargetID,
    XMLStringToMyXMLString(aData));
  GetChilds.Insert(aChild, -1);
  Result := aChild
end;

function TXmlNode.AppendText(const aData: TXmlString): IXmlText;
var
  aChild: TXmlText;
begin
  aChild := TXmlText.Create(FNames, XMLStringToMyXMLString(aData));
  GetChilds.Insert(aChild, -1);
  Result := aChild
end;

function TXmlNode.GetAttrsXML: TmyXmlString;
var
  a: PXmlAttrData;
  i: Integer;
begin
  Result := '';
  if FAttrCount > 0 then begin
    a := @FAttrs[0];
    for i := 0 to FAttrCount - 1 do begin
      Result := Result + ' ' +
                FNames.GetmyXMLName(a.NameID) + '="' +
                TextToXML(a.Value) + '"';
      Inc(a);
    end;
  end;
end;

procedure TXmlNode.LoadBinXml(aReader: TBinXmlReader);
var
  aCount: LongInt;
  a: PXmlAttrData;
  i: Integer;
begin
  // Считать атрибуты //Load attributes
  RemoveAllAttrs;
  aCount := aReader.ReadLongint;
  SetLength(FAttrs, aCount);
  FAttrCount := aCount;
  a := @FAttrs[0];
  for i := 0 to aCount - 1 do begin
    a.NameID := FNames.GetNameID(aReader.ReadLongint);
    aReader.ReadVariant(a.DataType, a.Value);
    Inc(a);
  end;

  // Считать дочерние узлы //Load childs
  aCount := aReader.ReadLongint;
  if aCount > 0 then
    GetChilds.LoadBinXml(aReader, aCount, FNames);
end;

procedure TXmlNode.SaveBinXml(aWriter: TBinXmlWriter);
var
  aCount: LongInt;
  a: PXmlAttrData;
  i: Integer;
begin
  // Считать атрибуты  //Save attributes
  aCount := FAttrCount;
  aWriter.WriteLongint(aCount);
  a := @FAttrs[0];
  for i := 0 to aCount - 1 do begin
    aWriter.WriteLongint(FNames.GetKeyID(a.NameID));
    aWriter.WriteVariant(a.DataType, a.Value);
    Inc(a);
  end;

  // Записать дочерние узлы //Save Childs
  if Assigned(FChilds) then begin
    aWriter.WriteLongint(FChilds.FCount);
    FChilds.SaveBinXml(aWriter);
  end
  else
    aWriter.WriteLongint(0);
end;

function TXmlNode.AttrExists(aNameID: NativeInt): Boolean;
begin
  Result := FindAttrData(aNameID) <> nil
end;

function TXmlNode.AttrExists(const aName: TXmlString): Boolean;
begin
  Result := FindAttrData(FNames.GetID(aName)) <> nil
end;

function TXmlNode.GetAttrType(aNameID: NativeInt): Integer;
var
  a: PXmlAttrData;
begin
  a := FindAttrData(aNameID);
  if Assigned(a) then
    Result := a.DataType
  else
    Result := NativeVarType;
end;

function TXmlNode.GetAttrType(const aName: TXmlString): Integer;
begin
  Result := GetAttrType(FNames.GetID(aName));
end;

function TXmlNode.Get_Values(const aName: TXmlString): Variant;
var
  aChild: IXmlNode;
begin
  if aName = '' then
    Result := Get_TypedValue
  else if aName[1] = '@' then
    Result := GetVarAttr(Copy(aName, 2, Length(aName) - 1), '')
  else begin
    aChild := SelectSingleNode(aName);
    if Assigned(aChild) then
      Result := aChild.TypedValue
    else
      Result := ''
  end
end;

function TXmlNode.Get_XML: TXmlString;
begin
  Result := myXMLStringToXMLString(Get_myXML);
end;

procedure TXmlNode.Set_Values(const aName: TXmlString; const aValue: Variant);
var
  aChild: IXmlNode;
begin
  if aName = '' then
    Set_TypedValue(aValue)
  else if aName[1] = '@' then
    SetVarAttr(Copy(aName, 2, Length(aName) - 1), aValue)
  else begin
    aChild := SelectSingleNode(aName);
    if not Assigned(aChild) then
      aChild := AppendElement(aName);
    aChild.TypedValue := aValue;
  end
end;

function TXmlNode.GetDateTimeAttr(aNameID: NativeInt; aDefault: TDateTime): TDateTime;
var
  anAttr: PXmlAttrData;
  aVarType: Word;
begin
  anAttr := FindAttrData(aNameID);
  if (anAttr<>nil) then begin
    aVarType := anAttr.DataType;
    {$IFDEF Unicode}
    if (aVarType=varUString) or (aVarType=varString) or (aVarType=varOleStr) then
    {$ELSE}
    if (aVarType=varString) or (aVarType=varOleStr) then
    {$ENDIF}
      Result := MyXMLStringToDateTime(anAttr.Value)
    else
      Result := VarAsType(anAttr.Value, varDate)  //String->DateTime
  end
  else
    Result := aDefault;
end;

function TXmlNode.GetDateTimeAttr(const aName: TXmlString;
  aDefault: TDateTime): TDateTime;
begin
  Result := GetDateTimeAttr(FNames.GetID(aName), aDefault)
end;

procedure TXmlNode.SetDateTimeAttr(aNameID: NativeInt; aValue: TDateTime);
begin
  SetVarAttr(aNameID, VarAsType(aValue, varDate))
end;

procedure TXmlNode.SetDateTimeAttr(const aName: TXmlString;
                                         aValue: TDateTime);
begin
  SetDateTimeAttr(FNames.GetID(aName), aValue)
end;

function TXmlNode.EnsureChild(aNameID: NativeInt): IXmlNode;
var
  aChild: TXmlNode;
begin
  aChild := FindFirstChild(aNameID);
  if Assigned(aChild) then
    Result := aChild
  else
    Result := AppendElement(aNameID)
end;

function TXmlNode.EnsureChild(const aName: TXmlString): IXmlNode;
begin
  Result := EnsureChild(FNames.GetID(aName))
end;

procedure TXmlNode.ExchangeChilds(const aChild1, aChild2: IXmlNode);
var
  i1, i2: Integer;
  aChilds: TXmlNodeList;
begin
  aChilds := GetChilds;
  i1 := aChilds.IndexOf(aChild1.GetObject as TXmlNode);
  i2 := aChilds.IndexOf(aChild2.GetObject as TXmlNode);
  if (i1 <> -1) and (i2 <> -1) then
    aChilds.Exchange(i1, i2);
end;

function TXmlNode.NeedChild(aNameID: NativeInt): IXmlNode;
var
  aChild: TXmlNode;
begin
  aChild := FindFirstChild(aNameID);
  if not Assigned(aChild) then
    raise Exception.CreateFmt(SSimpleXmlError10, [FNames.GetName(aNameID)]);
  Result := aChild
end;

function TXmlNode.NeedChild(const aName: TXmlString): IXmlNode;
begin
  Result := NeedChild(FNames.GetID(aName));
end;

procedure TXmlNode.SetNameTable(aValue: TXmlNameTable);
var
  i: Integer;
begin
  if aValue <> FNames
  then begin
    //Merge different Nametables
    SetNodeNameID(aValue.GetID(Get_NodeName));
    for i := 0 to High(FAttrs) do
      with FAttrs[i] do
        NameID := aValue.GetID(FNames.GetName(NameID));
    if Assigned(FChilds) then
      for i := 0 to FChilds.FCount - 1 do
        FChilds.FItems[i].SetNameTable(aValue);
    FNames._Release;
    FNames := aValue;
    FNames._AddRef;
  end;
end;

procedure TXmlNode.SetNodeNameID(aValue: Integer);
begin
//Do nothing here for Classes with read only name - like '#text'
end;

function TXmlNode.CloneNode(aDeep: Boolean): IXmlNode;
begin
  Result := DoCloneNode(aDeep)
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'XML Element Implementation'}{$ENDIF}
{ TXmlElement }

constructor TXmlElement.Create(aNames: TXmlNameTable; aNameID: NativeInt);
begin
  {$IFDEF ADDebug}
  outputdebugstring(PChar(Format('Create %s (%s)', [Classname, aNames.GetName(aNameID)])));
  {$ENDIF}
  inherited Create(aNames);
  FNameID := aNameID;
end;

function TXmlElement.Get_NodeNameID: NativeInt;
begin
  Result := FNameID
end;

function TXmlElement.Get_MyXMLText: TMyXmlString;
var
  aChilds: TXmlNodeList;
  aChild: TXmlNode;
  aChildText: TMyXmlString;
  i: Integer;
begin
  SetLength(Result, 0);
  aChilds := FChilds;
  if Assigned(aChilds) and (aChilds.FCount>0)
  then begin
    for i := 0 to aChilds.FCount - 1 do begin
      aChild := aChilds.FItems[i];
      if (aChild is TXmlDataNode) // (aChild.ClassType=TXmlText) or (aChild.ClassType=TXmlCDATASection)//or (aChild.ClassType=TXmlElement)
      then begin
        aChildText := aChild.Get_MyXMLText;
        if Length(aChildText) <> 0
        then begin
          if Length(Result) = 0
          then
            Result := aChildText
          else begin
            Result := Result + ' ' + aChildText;
          end;
        end;
      end
    end;
  end;
end;

function TXmlElement.GetTextAsBinaryData: TBytes;
var
  aChildText: TMyXmlString;
  L: Integer;
begin
  aChildText := Get_MyXMLText;
  L := Length(aChildText);
  SetLength(Result, L);
  move(Pointer(aChildText)^, Pointer(Result)^, L);
end;

procedure TXmlElement.ReplaceTextByBinaryData(const aData; aSize: Integer);
var
  aChildText: TMyXmlString;
begin
  RemoveTextNodes;
  SetLength(aChildText, aSize);
  move(aData, Pointer(aChildText)^, aSize);
  GetChilds.Insert(TXmlText.Create(FNames, aChildText), -1);
end;

procedure TXmlElement.RemoveTextNodes;
var
  i: Integer;
  aNode: TXmlNode;
begin
  if Assigned(FChilds) then
    for i := FChilds.FCount - 1 downto 0 do begin
      aNode := FChilds.FItems[i];
      if aNode is TXmlDataNode //(aNode.ClassType=TXmlText) or (aNode.ClassType=TXmlCDATASection)
      then
        FChilds.Delete(i);
    end;
end;

procedure TXmlElement.ReplaceTextByCDATASection(const aText: TXmlString);

  procedure AddCDATASection(const aText: TXmlString);
  var
    i: Integer;
    aChilds: TXmlNodeList;
  begin
    i := Pos(']]>', aText);
    aChilds := GetChilds;
    if i = 0 then
      aChilds.Insert(TXmlCDATASection.Create(
                       FNames,
                       XMLStringToMyXMLString(aText)),
                     aChilds.FCount)
    else begin
      aChilds.Insert(TXmlCDATASection.Create(
                       FNames,
                       XMLStringToMyXMLString(Copy(aText, 1, i))),
                     aChilds.FCount);
      AddCDATASection(Copy(aText, i + 1, Length(aText) - i - 1));
    end;
  end;

begin
  RemoveTextNodes;
  AddCDATASection(aText);
end;

procedure TXmlElement.Set_DataType(const aValue: TVarType);
var
  DataNode: TXMLDataNode;
begin
  DataNode := Get_DataNode(True);
  if DataNode=nil
  then begin
    DataNode := TXmlText.Create(FNames, MyXMLEmptyString);
    GetChilds.Insert(DataNode, 0);
  end;
  DataNode.FDataType := aValue;
end;

procedure TXmlElement.Set_MyXMLText(const aValue: TMyXmlString);
var
  DataNode: TXMLDataNode;
begin
  DataNode := Get_DataNode;
  if DataNode=nil
  then begin
    DataNode := TXmlText.Create(FNames, aValue);
    GetChilds.Insert(DataNode, 0);
  end
  else begin
    DataNode.FData := aValue;
  end;
end;

function TXmlElement.AsElement: IXmlElement;
begin
  Result := Self
end;

function GetIndentStr(XMLIndent: Integer): TmyXmlString;
var
  i: Integer;
begin
  SetLength(Result, XMLIndent*Length(DefaultIndentText));
  for i := 0 to XMLIndent - 1 do
    Move(DefaultIndentText[1], Result[i*Length(DefaultIndentText) + 1], Length(DefaultIndentText)*SizeOf(TmyXmlChar));
end;

function HasCRLF(const s: TmyXmlString): Boolean;
var
  i: Integer;
begin
  for i := 1 to Length(s) do
    if (s[i] = #13) or (s[i] = #10) then begin
      Result := True;
      Exit
    end;
  Result := False;
end;

function EndWithCRLF(const s: TmyXmlString): Boolean;
begin
  Result :=
    (Length(s) > 1) and
    (s[Length(s) - 1] = #13) and
    (s[Length(s)] = #10);
end;

function TXmlElement.Get_myXML: TmyXmlString;
var
  aChildsXML: TmyXmlString;
  aTag: TmyXmlString;
  aXMLIndent: Integer;
begin
  if GetOwnerDocument.Get_PreserveWhiteSpace 
  then begin
    if Assigned(FChilds) and (FChilds.FCount > 0) then
      aChildsXML := FChilds.Get_myXML
    else
      aChildsXML := '';

    aTag := FNames.GetmyXMLName(FNameID);
    Result := '<' + aTag + GetAttrsXML;
    if aChildsXML = '' then
      Result := Result + '/>'
    else
      Result := Result + '>' + aChildsXML + '</' + aTag + '>'
  end
  else begin
    aXMLIndent := GetXMLIndent;
    if Assigned(FChilds) and (FChilds.FCount > 0)
    then
      aChildsXML := FChilds.Get_myXML
    else
      aChildsXML := '';
    aTag := FNames.GetmyXMLName(FNameID);
    Result := #13#10 + GetIndentStr(aXMLIndent) + '<' + aTag + GetAttrsXML;
    if aChildsXML = '' then
      Result := Result + '/>'
    else if HasCRLF(aChildsXML) then
      if EndWithCRLF(aChildsXML) then
        Result := Result + '>' + aChildsXML + GetIndentStr(aXMLIndent) + '</' + aTag + '>'
      else
        Result := Result + '>' + aChildsXML + #13#10 + GetIndentStr(aXMLIndent) + '</' + aTag + '>'
    else
      Result := Result + '>' + aChildsXML + '</' + aTag + '>';
  end;
end;

function TXmlElement.Get_TypedValue: Variant;
var
  DataNode: TXMLDataNode;
begin
  DataNode := Get_DataNode;
  if DataNode<>nil
  then
    Result := MyXMLStringToVar(DataNode.FDataType, DataNode.FData)
  else
    VarClear(Result);
end;

procedure TXmlElement.Set_TypedValue(const aValue: Variant);
var
  DataNode: TXMLDataNode;
begin
  DataNode := Get_DataNode(True);
  if DataNode=nil
  then begin
    DataNode := TXmlText.Create(FNames, MyXMLEmptyString);
    GetChilds.Insert(DataNode, 0);
  end;
  DataNode.FDataType := TVarData(aValue).VType;
  DataNode.FData := VarToMyXMLString(aValue);
end;

function TXmlElement.Get_DataNode(Clean: Boolean): TXMLDataNode;
// Find first child '#text' or child '#cdata-section' and save Value.
// If Clean is true all further text or cdata childs will removed.
// If Clean is false and more than one text or cdata section exists,
// a exception is raised.
var
  i, ItemIndex: Integer;
begin
  Result := nil;
  if Assigned(FChilds)
  then begin
    ItemIndex := -1;
    for i := 0 to FChilds.FCount - 1 do
    begin
      if FChilds.FItems[i] is TXMLDataNode
      then begin
        if Result=nil
        then begin
          Result := TXMLDataNode(FChilds.FItems[i]);
          ItemIndex := i;
          if Clean then
            break;
        end
        else
          raise Exception.CreateFmt(SSimpleXmlError28, [Get_NodeName]);
      end;
    end;
    if Clean and (Result<>nil)
    then begin
      for i := FChilds.FCount - 1 downto ItemIndex + 1 do
      begin
        if FChilds.FItems[i] is TXMLDataNode
        then begin
          FChilds.Delete(i);
        end;
      end;
    end;
  end;
end;

function TXmlElement.Get_DataType: TVarType;
var
  DataNode: TXMLDataNode;
begin
  DataNode := Get_DataNode;
  if DataNode<>nil
  then
    Result := DataNode.FDataType
  else
    Result := varNULL;
end;

procedure TXmlElement.SaveXML(aXMLSaver: TXmlSaver);
var
  aTag: TmyXmlString;
  aXMLIndent: TmyXmlString;
begin
  aTag := FNames.GetmyXMLName(FNameID);
  if GetOwnerDocument.Get_PreserveWhiteSpace
  then begin
    if Assigned(FChilds) and (FChilds.FCount > 0)
    then begin
      aXMLSaver.Save('<' + aTag + GetAttrsXML + '>');
      FChilds.SaveXML(aXMLSaver);
      aXMLSaver.Save('</' + aTag + '>');
    end
    else
      aXMLSaver.Save('<' + aTag + GetAttrsXML + '/>');
  end
  else begin
    aXMLIndent := #13#10 + GetIndentStr(GetXMLIndent);
    if Assigned(FChilds) and (FChilds.FCount > 0)
    then begin
      aXMLSaver.Save(aXMLIndent + '<' + aTag + GetAttrsXML + '>');
      FChilds.SaveXML(aXMLSaver);
      if (FChilds.FCount > 1) or (FChilds.FItems[0] is TXmlElement)
      then
        aXMLSaver.Save(aXMLIndent + '</' + aTag + '>')
      else
        aXMLSaver.Save('</' + aTag + '>');
    end
    else
      aXMLSaver.Save(aXMLIndent + '<' + aTag + GetAttrsXML + '/>');
  end;
end;

procedure TXmlElement.SetNodeNameID(aValue: Integer);
begin
  FNameID := aValue
end;

function TXmlElement.DoCloneNode(aDeep: Boolean): IXmlNode;
var
  aClone: TXmlElement;
  i: Integer;
begin
  aClone := TXmlElement.Create(FNames, FNameID);
  Result := aClone;
  SetLength(aClone.FAttrs, FAttrCount);
  aClone.FAttrCount := FAttrCount;
  for i := 0 to FAttrCount - 1 do
    aClone.FAttrs[i] := FAttrs[i];
  if aDeep and Assigned(FChilds) and (FChilds.FCount > 0)
  then begin
    for i := 0 to FChilds.FCount - 1 do
      aClone.AppendChild(FChilds.FItems[i].CloneNode(True));
  end;
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlCharacterData Implementation'}{$ENDIF}

constructor TXmlCharacterData.Create(aNames: TXmlNameTable;
  const aData: TmyXmlString);
begin
  inherited Create(aNames);
  FData := aData;
end;

function TXmlCharacterData.Get_MyXMLText: TMyXmlString;
begin
  if GetOwnerDocument.Get_PreserveWhiteSpace
  then
    Result := FData
  else
    Result := myXMLTrim(FData);
end;

procedure TXmlCharacterData.Set_MyXMLText(const aValue: TMyXmlString);
begin
  FData := aValue
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlDataNode Implementation'}{$ENDIF}

{ TXmlDataNode }

function TXmlDataNode.Get_DataType: TVarType;
begin
  Result := FDataType;
end;

function TXmlDataNode.Get_MyXMLText: TMyXmlString;
begin
  if GetOwnerDocument.Get_PreserveWhiteSpace
  then
    Result := FData
  else
    Result := myXMLTrim(FData);
end;

function TXmlDataNode.Get_TypedValue: Variant;
begin
  Result := FData
end;

constructor TXmlDataNode.Create(aNames: TXmlNameTable; const aData: TmyXmlString);
begin
  inherited Create(aNames);
  FDataType := varString;
  FData := aData;
end;

procedure TXmlDataNode.SaveXML(aXMLSaver: TXmlSaver);
begin
  aXMLSaver.Save(Get_myXML);
end;

procedure TXmlDataNode.Set_DataType(const aValue: TVarType);
begin
  FDataType := aValue;
end;

procedure TXmlDataNode.Set_MyXMLText(const aValue: TMyXmlString);
begin
  FData := aValue;
end;

procedure TXmlDataNode.Set_TypedValue(const aValue: Variant);
begin
  FDataType := TVardata(aValue).VType;
  fData := VarToMyXMLString(aValue);
end;

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlText Implementation'}{$ENDIF}

function TXmlText.AsText: IXmlText;
begin
  Result := Self;
end;

function TXmlText.DoCloneNode(aDeep: Boolean): IXmlNode;
begin
  Result := TXmlText.Create(FNames, FData);
end;

function TXmlText.Get_NodeNameID: NativeInt;
begin
  Result := FNames.FXmlTextNameID
end;

function TXmlText.Get_myXML: TmyXmlString;
begin
  Result := TextToXML(FData);
end;

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlCDATASection Implementation'}{$ENDIF}
function TXmlCDATASection.AsCDATASection: IXmlCDATASection;
begin
  Result := Self
end;

function TXmlCDATASection.DoCloneNode(aDeep: Boolean): IXmlNode;
begin
  Result := TXmlCDATASection.Create(FNames, FData);
end;

function TXmlCDATASection.Get_NodeNameID: NativeInt;
begin
  Result := FNames.FXmlCDATASectionNameID
end;

function GenCDATAXML(const aValue: RawByteString): TmyXmlString;
var
  i: Integer;
begin
  {$IF CompilerVersion<18}
  i := Pos(']]>', aValue);
  {$else}
  i := PosEx(']]>', aValue);
  {$ifend}
  if i = 0 then
    Result := '<![CDATA[' + aValue + ']]>'
  else //Split aValue into several consecutive CDATA sections
    Result := '<![CDATA[' + Copy(aValue, 1, i) + ']]>' + GenCDATAXML(Copy(aValue, i + 1, Length(aValue) - i - 1));
end;

function TXmlCDATASection.Get_myXML: TmyXmlString;
begin
  Result := GenCDATAXML(FData);
end;

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlComment Implementation'}{$ENDIF}

function TXmlComment.AsComment: IXmlComment;
begin
  Result := Self
end;

function TXmlComment.DoCloneNode(aDeep: Boolean): IXmlNode;
begin
  Result := TXmlComment.Create(FNames, FData);
end;

function TXmlComment.Get_NodeNameID: NativeInt;
begin
  Result := FNames.FXmlCommentNameID
end;

function TXmlComment.Get_myXML: TmyXmlString;
begin
  Result := '<!--' + FData + '-->'
end;

procedure TXmlComment.SaveXML(aXMLSaver: TXmlSaver);
begin
  aXMLSaver.Save(Get_myXML);
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlDocument Implementation'}{$ENDIF}

constructor TXmlDocument.Create(aNames: TXmlNameTable);
begin
  inherited Create(aNames);
  FPreserveWhiteSpace := DefaultPreserveWhiteSpace;
end;

function TXmlDocument.CreateCDATASection(
  const aData: TXmlString): IXmlCDATASection;
begin
  Result := TXmlCDATASection.Create(FNames, XMLStringToMyXMLString(aData))
end;

function TXmlDocument.CreateComment(const aData: TXmlString): IXmlComment;
begin
  Result := TXmlComment.Create(FNames, XMLStringToMyXMLString(aData))
end;

function TXmlDocument.CreateElement(aNameID: NativeInt): IXmlElement;
begin
  Result := TXmlElement.Create(FNames, aNameID)
end;

function TXmlDocument.CreateElement(const aName: TXmlString): IXmlElement;
begin
  Result := TXmlElement.Create(FNames, FNames.GetID(aName));
end;

function TXmlDocument.CreateProcessingInstruction(const aTarget,
  aData: TXmlString): IXmlProcessingInstruction;
begin
  Result := CreateProcessingInstruction(FNames.GetID(aTarget), aData);
end;

function TXmlDocument.CreateProcessingInstruction(aTargetID: NativeInt;
  const aData: TXmlString): IXmlProcessingInstruction;
begin
  Result := TXmlProcessingInstruction.Create(FNames, aTargetID,
              XMLStringToMyXMLString(aData))
end;

function TXmlDocument.CreateText(const aData: TXmlString): IXmlText;
begin
  Result := TXmlText.Create(FNames, XMLStringToMyXMLString(aData))
end;

function TXmlDocument.DoCloneNode(aDeep: Boolean): IXmlNode;
var
  aClone: TXmlDocument;
  i: Integer;
begin
  aClone := TXmlDocument.Create(FNames);
  Result := aClone;
  if aDeep and Assigned(FChilds) and (FChilds.FCount > 0) then
    for i := 0 to FChilds.FCount - 1 do
      aClone.AppendChild(FChilds.FItems[i].CloneNode(True));
end;

function TXmlDocument.GetEncoding: TXmlString;
var
  i: Integer;
  aChilds: TXmlNodeList;
  aNode: TXmlNode;
begin
  Result := DefaultEncoding;
  aChilds := GetChilds;
  for i := 0 to aChilds.FCount - 1 do
  begin
    aNode := aChilds.FItems[i];
    if (aNode.ClassType = TXMLProcessingInstruction) and
       (aNode.Get_NodeNameID = fNames.FXmlNameID)
    then begin
      Result := aNode.GetAttr(FNames.FEncodingNameId, Result);
      exit;
    end;
  end;
end;

function TXmlDocument.Get_BinaryXML: TBytes;
var
  aWriter: TMemoryXmlWriter;
begin
  aWriter := TMemoryXmlWriter.Create($10000);
  try
    FNames.SaveBinXml(aWriter);
    SaveBinXml(aWriter);
    aWriter.FlushBuf;
    Result := aWriter.FData;
  finally
    aWriter.Free
  end
end;

function TXmlDocument.Get_DocumentElement: IXmlElement;
var
  aChilds: TXmlNodeList;
  aChild: TXmlNode;
  i: Integer;
begin
  aChilds := GetChilds;
  for i := 0 to aChilds.FCount - 1 do begin
    aChild := aChilds.FItems[i];
    if aChild.ClassType = TXmlElement then begin
      Result := TXmlElement(aChild);
      Exit
    end
  end;
  Result := nil;
end;

function TXmlDocument.Get_NodeNameID: NativeInt;
begin
  Result := FNames.FXmlDocumentNameID
end;

function TXmlDocument.Get_OnTagBegin: THookTag;
begin
  if Self<>nil
  then
    Result := FOnTagBegin
  else
    Result := nil;
end;

function TXmlDocument.Get_OnTagEnd: THookTag;
begin
  if Self<>nil
  then
    Result := FOnTagEnd
  else
    Result := nil;
end;

function TXmlDocument.Get_PreserveWhiteSpace: Boolean;
begin
  if Self<>nil 
  then
    Result := FPreserveWhiteSpace
  else
    Result := DefaultPreserveWhiteSpace;
end;

function TXmlDocument.Get_MyXMLText: TMyXmlString;
var
  aChilds: TXmlNodeList;
  aChild: TXmlNode;
  aChildText: TMyXmlString;
  i: Integer;
begin
  SetLength(Result, 0);
  aChilds := GetChilds;
  for i := 0 to aChilds.FCount - 1 do begin
    aChild := aChilds.FItems[i];
    if aChild is TXmlDataNode //(aChild.ClassType=TXmlText) or (aChild.ClassType=TXmlCDATASection) //or (aChild.ClassType=TXmlElement)
    then begin
      aChildText := aChild.Get_MyXMLText;
      if Length(aChildText) <> 0
      then begin
        if Length(Result) = 0
        then
          Result := aChildText
        else begin
          Result := Result + ' ' + aChildText;
        end;
      end;
    end
  end;
end;

function TXmlDocument.Get_myXML: TmyXmlString;
begin
  Result := GetChilds.Get_myXML
end;

procedure TXmlDocument.Load(aStream: TStream; const Encoding: String);
var
  aXml: TXmlSource;
  aBinarySign: TMyXMLString;
  aReader: TBinXmlReader;
  Bom: array [0..3] of Byte;
  BomLen: Integer;
  BomType: (btNone, btUTF16BE, btUTF16LE, btUTF32BE, btUTF32LE, btUTF8);
begin
  RemoveAllChilds;
  RemoveAllAttrs;
  if aStream.Size > Length(BinXmlSignature)
  then begin
    SetLength(aBinarySign, Length(BinXmlSignature));
    aStream.ReadBuffer(Pointer(aBinarySign)^, Length(BinXmlSignature));
    if aBinarySign = BinXmlSignature
    then begin
      aReader := TStreamXmlReader.Create(aStream, $10000);
      try
        FNames.LoadBinXml(aReader);
        LoadBinXml(aReader);
      finally
        aReader.Free
      end;
      Exit;
    end;
    aStream.Position := aStream.Position - Length(BinXmlSignature);
  end;
  if aStream.Size > Length(Bom)
  then begin
    aStream.ReadBuffer(Bom, Length(Bom));
    aStream.Seek(-Length(Bom), soFromCurrent);
    if PDWord(@Bom)^=$FFFE0000
    then begin
      BomType := btUTF32BE;
      BomLen := 4;
    end
    else
    if PDWord(@Bom)^=$0000FEFF
    then begin
      BomType := btUTF32LE;
      BomLen := 4;
    end
    else
    if PWord(@Bom)^=$FEFF
    then begin
      BomType := btUTF16LE;
      BomLen := 2;
    end
    else
    if PWord(@Bom)^=$FFFE
    then begin
      BomType := btUTF16BE;
      BomLen := 2;
    end
    else
    if (Bom[0]=$EF) and (Bom[1]=$BB) and (Bom[2]=$BF)
    then begin
      BomType := btUTF8;
      BomLen := 3;
    end
    else begin
      BomType := btNone;
      BomLen := 0;
    end;
    if not (BomType in [btNone, btUTF8])
    then
      raise Exception.Create(SSimpleXmlError27);
    aStream.Seek(BomLen, soCurrent);
  end
  else
    BomType := btNone;
  aXml := TXmlSource.Create(aStream);
  try
    if BomType=btUTF8
    then
      aXml.Codepage := CP_UTF8
    else
    if Encoding<>''
    then
      aXml.Codepage := FindCodepage(AnsiString(Encoding));
    GetChilds.ParseXML(aXml, FNames, FOnTagBegin, FOnTagEnd, FPreserveWhiteSpace);
  finally
    aXml.Free
  end
end;

procedure TXmlDocument.Load(const aFileName, Encoding: String);
var
  aFile: TFileStream;
begin
  aFile := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyWrite);
  try
    Load(aFile, Encoding);
  finally
    aFile.Free
  end
end;

procedure TXmlDocument.LoadBinaryXML(const Data; const Count: Integer);
var
  aReader: TMemoryXmlReader;
begin
  RemoveAllChilds;
  RemoveAllAttrs;
  aReader := TMemoryXmlReader.Create(Data, Count);
  try
    FNames.LoadBinXml(aReader);
    LoadBinXml(aReader);
  finally
    aReader.Free;
  end
end;

procedure TXmlDocument.LoadResource(aType, aName: PChar);
var
  aRSRC: HRSRC;
  aGlobal: HGLOBAL;
  aSize: DWORD;
  aPointer: Pointer;
  AStr: RawByteString;
begin
  aRSRC := FindResource(HInstance, aName, aType);
  if aRSRC <> 0 then begin
    aGlobal := Windows.LoadResource(HInstance, aRSRC);
    aSize := SizeofResource(HInstance, aRSRC);
    if (aGlobal <> 0) and (aSize <> 0) then begin
      aPointer := LockResource(aGlobal);
      if Assigned(aPointer) then begin
        SetLength(AStr, aSize);
        move(aPointer^, Pointer(AStr)^, aSize);
        LoadXML(AStr);
      end;
    end;
  end;
end;

procedure TXmlDocument.LoadXML(const aXML: RawByteString; const Encoding: String);
var
  aSource: TXmlSource;
begin
  if XmlIsInBinaryFormat(aXML)
  then begin
    LoadBinaryXML(Pointer(aXML)^, Length(aXML))
  end
  else begin
    RemoveAllChilds;
    RemoveAllAttrs;
    aSource := TXmlSource.Create(aXML);
    try
      if Encoding<>''
      then
        aSource.Codepage := FindCodepage(AnsiString(Encoding));
      GetChilds.ParseXML(aSource, FNames, FOnTagBegin, FOnTagEnd, FPreserveWhiteSpace);
    finally
      aSource.Free
    end
  end
end;

{$IF Defined(XML_WIDE_CHARS) or Defined(Unicode)}
procedure TXmlDocument.LoadXML(const aXML: TXmlString; const Encoding: String);
var
  aSource: TXmlSource;
  Temp: RawByteString;
begin
  if XmlIsInBinaryFormat(AnsiString(copy(aXml, 1, Length(BinXmlSignature))))
  then begin
    SetLength(Temp, Length(aXML));
    CopyWordToByteArray(Pointer(aXML), Pointer(Temp), Length(aXML));
    LoadBinaryXML(Pointer(Temp)^, Length(Temp));
  end
  else begin
    RemoveAllChilds;
    RemoveAllAttrs;
    aSource := TXmlSource.Create(AnsiToUTF8(aXML));
    try
      if Encoding<>''
      then
        aSource.Codepage := FindCodepage(AnsiString(Encoding));
      aSource.AutoCodepage := False;
      GetChilds.ParseXML(aSource, FNames, FOnTagBegin, FOnTagEnd, FPreserveWhiteSpace);
    finally
      aSource.Free
    end
  end
end;
{$IFEND}


function TXmlDocument.NewDocument(const aVersion, anEncoding,
                                  aRootElementName: TXmlString): IXmlElement;
begin
  Result := NewDocument(aVersion, anEncoding, FNames.GetID(aRootElementName));
end;

function TXmlDocument.NewDocument(const aVersion, anEncoding: TXmlString;
                                  aRootElementNameID: NativeInt): IXmlElement;
var
  aChilds: TXmlNodeList;
  aNode: TXmlNode;
  aValue: TXmlString;
begin
  aChilds := GetChilds;
  aChilds.Clear;
  aNode := TXmlProcessingInstruction.Create(FNames, FNames.FXmlNameID);
  if aVersion = '' then
    aValue := '1.0'
  else
    aValue := aVersion;
  aNode.SetAttr('version', aValue);
  if anEncoding = '' then
    aValue := DefaultEncoding
  else
    aValue := anEncoding;
  aNode.SetAttr(FNames.FEncodingNameId, aValue);
  aChilds.Insert(aNode, 0);
  aNode := TXmlElement.Create(FNames, aRootElementNameID);
  aChilds.Insert(aNode, 1);
  Result := TXmlElement(aNode);
end;

procedure TXmlDocument.Save(aStream: TStream);
var
  EncodingData: PXMLAttrData;
  aNode: TXmlNode;
  XMLSaver: TXMLSaver;
begin
  XMLSaver := TXMLStmSaver.Create(aStream);
  try
    aNode := FindFirstChild(FNames.FXmlNameID);
    if aNode<>nil
    then begin
      EncodingData := aNode.FindAttrData(FNames.FEncodingNameId);
      if (EncodingData<>nil)
      then begin
        XMLSaver.Codepage := FindCodepage(EncodingData.Value);
        if XMLSaver.Codepage=0
        then
          raise Exception.CreateFmt(SSimpleXmlError26, [UTF8ToAnsi(EncodingData.Value)]);
      end;
    end;
    SaveXML(XMLSaver);
  finally
    XMLSaver.Free;
  end;
end;

procedure TXmlDocument.Save(const aFileName: String);
var
  aFile: TFileStream;
begin
  aFile := TFileStream.Create(aFileName, fmCreate or fmShareDenyWrite);
  try
    Save(aFile);
  finally
    aFile.Free
  end
end;

procedure TXmlDocument.SaveBinary(aStream: TStream);
var
  aWriter: TBinXmlWriter;
begin
  aWriter := TStreamXmlWriter.Create(aStream, $10000);
  try
    FNames.SaveBinXml(aWriter);
    SaveBinXml(aWriter);
  finally
    aWriter.Free
  end
end;

procedure TXmlDocument.SaveBinary(const aFileName: String);
var
  aFile: TFileStream;
begin
  aFile := TFileStream.Create(aFileName, fmCreate or fmShareDenyWrite);
  try
    SaveBinary(aFile);
  finally
    aFile.Free
  end
end;

procedure TXmlDocument.SaveXML(aXMLSaver: TXmlSaver);
begin
  GetChilds.SaveXML(aXMLSaver);
end;

procedure TXmlDocument.Set_PreserveWhiteSpace(aValue: Boolean);
begin
  FPreserveWhiteSpace := aValue;
end;

procedure TXmlDocument.SetEncoding(const Encoding: TXmlString);
var
  i: Integer;
  aChilds: TXmlNodeList;
  aNode: TXmlNode;
begin
  aChilds := GetChilds;
  for i := 0 to aChilds.FCount - 1 do
  begin
    aNode := aChilds.FItems[i];
    if (aNode.ClassType = TXMLProcessingInstruction) and
       (aNode.Get_NodeNameID = fNames.FXmlNameID)
    then begin
      aNode.SetAttr(FNames.FEncodingNameId, Encoding);
      exit;
    end;
  end;
  aNode := TXmlProcessingInstruction.Create(FNames, fNames.FXmlNameID);
  aNode.SetAttr('version', '1.0');
  aNode.SetAttr(fNames.FEncodingNameId, Encoding);
  aChilds.Insert(aNode, 0);
end;

procedure TXmlDocument.Set_MyXMLText(const aText: TmyXmlString);
var
  aChilds: TXmlNodeList;
begin
  aChilds := GetChilds;
  aChilds.Clear;
  aChilds.Insert(TXmlText.Create(FNames, aText), 0);
end;

procedure TXmlDocument.Set_OnTagBegin(aValue: THookTag);
begin
  FOnTagBegin := aValue;
end;

procedure TXmlDocument.Set_OnTagEnd(aValue: THookTag);
begin
  FOnTagEnd := aValue;
end;

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlProcessingInstruction Implementation'}{$ENDIF}

function TXmlProcessingInstruction.AsProcessingInstruction: IXmlProcessingInstruction;
begin
  Result := Self
end;

constructor TXmlProcessingInstruction.Create(aNames: TXmlNameTable;
  aTargetID: NativeInt; const aData: TmyXmlString);
begin
  inherited Create(aNames);
  FTargetNameID := aTargetID;
  FData := aData;
end;

function TXmlProcessingInstruction.DoCloneNode(aDeep: Boolean): IXmlNode;
begin
  Result := TXmlProcessingInstruction.Create(FNames, FTargetNameID, FData);
end;

function TXmlProcessingInstruction.Get_NodeNameID: NativeInt;
begin
  Result := FTargetNameID
end;

function TXmlProcessingInstruction.Get_MyXMLText: TMyXmlString;
begin
  Result := FData;
end;

function TXmlProcessingInstruction.Get_myXML: TmyXmlString;
begin
  if Length(FData) = 0 then
    Result := '<?' + FNames.GetmyXMLName(FTargetNameID) + GetAttrsXML + '?>'
  else
    Result := '<?' + FNames.GetmyXMLName(FTargetNameID) + ' ' + FData + '?>'
end;

procedure TXmlProcessingInstruction.SaveXML(aXMLSaver: TXmlSaver);
begin
  aXMLSaver.Save(Get_myXML);
end;

procedure TXmlProcessingInstruction.SetNodeNameID(aValue: Integer);
begin
  FTargetNameID := aValue
end;

procedure TXmlProcessingInstruction.Set_MyXMLText(const aText: TmyXmlString);
begin
  FData := aText
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlSource Implementation'}{$ENDIF}

procedure TXmlSource.NewToken;
begin
  Inc(FTokenStackTop);
  if FTokenStackTop < Length(FTokenStack) then begin
    FToken := FTokenStack[FTokenStackTop];
    FToken.Clear
  end
  else begin
    SetLength(FTokenStack, FTokenStackTop + 1);
    FToken := TXmlToken.Create;
    FTokenStack[FTokenStackTop] := FToken;
  end
end;

function TXmlSource.Next: Boolean;
  function FillBuffer: Boolean;
  const
    AnsiBuffSize = SourceBufferSize div 4;
  var
    TempSrc: array [0..AnsiBuffSize-1] of AnsiChar;
    Size: Integer;
    NMisAligned: Integer;
  begin
    if FBufSize=0
    then begin
      if CodePage=0
      then begin
        // Read only 1 AnsiChar from source until character coding discovered
        FBufSize := FStream.Read(FBuffer^, 1);
      end
      else
      if f8BitBufferCoding
      then begin
        FBufSize := FStream.Read(FBuffer^, SourceBufferSize);
      end
      else begin
        Size := FStream.Read(TempSrc, AnsiBuffSize);
        if (Size>0) and Assigned(fAlignCheck)
        then begin
          NMisAligned := fAlignCheck(@TempSrc[Size-1], Size);
          if NMisAligned>0
          then begin
            FStream.Seek(-NMisAligned, soFromCurrent);
            dec(Size, NMisAligned);
          end;
        end;
        // Ansi -> UTF16
        FBufSize := MultiByteToWideChar(Codepage, 0, @TempSrc, Size, Pointer(FBuffer), SourceBufferSize div 2);
      end;
      FBufPtr := FBuffer;
      Result := FBufSize>0;
    end
    else
      Result := True;
  end;
  procedure MoveBufferPointerA;
  begin
    dec(FBufSize);
    Inc(FBufPtr);
  end;
  procedure MoveBufferPointerW;
  begin
    dec(FBufSize);
    Inc(FBufPtr, 2);
  end;
var
  N: Integer; // Number of additional codepoints needed for current character
begin
(*  if FStream.Position  - FBufSize >= 43401270//19530397//19546167 19546748 //19562551 //
  then                           //43401273
    Outputdebugstring('Position erreicht');*)
  if FillBuffer
  then begin
    if f8BitBufferCoding
    then begin
      N := ReadUTF8Char(CurChar, FBufPtr^);
      MoveBufferPointerA;
      while (N>0) and FillBuffer do
      begin
        ReadUTF8Char(CurChar, FBufPtr^);
        MoveBufferPointerA;
        Dec(N);
      end;
    end
    else begin
      N := ReadUTF16Char(CurChar, PWord(FBufPtr)^);
      MoveBufferPointerW;
      if (N>0) and FillBuffer
      then begin
        N := ReadUTF16Char(CurChar, PWord(FBufPtr)^);
        MoveBufferPointerW;
      end;
    end;
    Inc(FSourceCol);
    if CurChar = UCS4Char(#10)
    then begin
      Inc(FSourceLine);
      FSourceCol := 0;
    end;
    Result := (N=0);
  end
  else begin
    CurChar := 0;
    Result := False;
    fEof := True;
  end;
end;

function TXmlSource.AcceptToken: TmyXMLString;
begin
  Result := FToken.Text;
  DropToken;
end;

procedure TXmlSource.SetCodepage(Codepage: Word);
var
  i: Integer;
begin
  FCodepage := Codepage;
  f8BitBufferCoding := Codepage=CP_UTF8;
  for i := 0 to High(XMLEncodingData) do
  begin
    if XMLEncodingData[i].Codepage = Codepage
    then begin
      fAlignCheck := XMLEncodingData[i].AlignCheck;
      break;
    end;
  end;
end;

procedure TXmlSource.SkipBlanks;
begin
  while not EOF and (CurChar <= UCS4Char(' ')) do
    Next;
end;

// на входе - первый символ имени
// на выходе - первый символ, который не является допустимым для имен
function TXmlSource.ExpectXmlName: TmyXMLString;
begin
  if not NameCanBeginWith4(CurChar) then
    raise Exception.CreateFmt(SSimpleXmlError11, [FSourceLine, FSourceCol]);
  NewToken;
  AppendTokenChar(CurChar);
  while Next and NameCanContain4(CurChar) do
    AppendTokenChar(CurChar);
  Result := AcceptToken;
end;

// на входе - первый символ числа
// на выходе - первый символ, который не является допустимым для чисел
// read decimal characters until it find the first nondecimal character and
// return the value
function TXmlSource.ExpectDecimalInteger: Integer;
var
  DigitFound: Boolean;
begin
  Result := 0;
  DigitFound := False;
  while (CurChar >= UCS4Char('0')) and (CurChar <= UCS4Char('9')) do
  begin
    Result := Result * 10 + Integer(CurChar) - Ord('0');
    DigitFound := True;
    Next;
  end;
  if not DigitFound then
    raise Exception.CreateFmt(SSimpleXmlError12, [FSourceLine, FSourceCol]);
end;

// на входе - первый символ числа
// на выходе - первый символ, который не является допустимым для
// щестнадцатиричных чисел
function TXmlSource.ExpectHexInteger: Integer;
var
  DigitFound: Boolean;
  Digit: Integer;
begin
  Result := 0;
  Digit := 0;
  DigitFound := False;
  while True do
  begin
    if (CurChar >= UCS4Char('0')) and (CurChar <= UCS4Char('9'))
    then
      Digit := Ord(CurChar) - Ord('0')
    else
    if (CurChar >= UCS4Char('A')) and (CurChar <= UCS4Char('F'))
    then
      Digit := Ord(CurChar) - Ord('A')
    else
    if (CurChar >= UCS4Char('a')) and (CurChar <= UCS4Char('f'))
    then
      Digit := Ord(CurChar) - Ord('a')
    else
      break;
    Result := Result * 16 + Digit; 
    DigitFound := True;
    Next;
  end;
  if not DigitFound then
    raise Exception.CreateFmt(SSimpleXmlError13, [FSourceLine, FSourceCol]);
end;

// на входе: "&"
// на выходе: следующий за ";"
function TXmlSource.ExpectXmlEntity: UCS4Char;
var
  s: UTF8String;
begin
  if not Next then
    raise Exception.CreateFmt(SSimpleXmlError14, [FSourceLine, FSourceCol]);
  if CurChar = UCS4Char('#') then begin
    if not Next then
      raise Exception.CreateFmt(SSimpleXmlError12, [FSourceLine, FSourceCol]);
    if CurChar = UCS4Char('x') then begin
      Next;
      Result := UCS4Char(ExpectHexInteger);
    end
    else
      Result := UCS4Char(ExpectDecimalInteger);
    ExpectChar(';');
  end
  else begin
    s := ExpectAlpha;
    ExpectChar(';');
    if s = 'amp' then
      Result := UCS4Char('&')
    else if s = 'quot' then
      Result := UCS4Char('"')
    else if s = 'lt' then
      Result := UCS4Char('<')
    else if s = 'gt' then
      Result := UCS4Char('>')
    else if s = 'apos' then
      Result := UCS4Char('''')
    else
      raise Exception.CreateFmt(SSimpleXmlError15 , [String(s), FSourceLine, FSourceCol]);
  end
end;

function TXmlSource.ExpectAlpha: TmyXMLString;
  function IsAlphaAscii(Char: UCS4Char): Boolean;
  begin
    Result := ((Char>=UCS4Char('A')) and (Char<=UCS4Char('Z'))) or
              ((Char>=UCS4Char('a')) and (Char<=UCS4Char('z')));
  end;
begin
  if not IsAlphaAscii(CurChar) then
    raise Exception.CreateFmt(SSimpleXmlError11, [FSourceLine, FSourceCol]);
  NewToken;
  AppendTokenChar(CurChar);
  while Next and IsAlphaAscii(CurChar) do
    AppendTokenChar(CurChar);
  Result := AcceptToken;
end;

procedure TXmlSource.ExpectChar(aChar: Char);
begin
  if EOF or (CurChar <> UCS4Char(aChar)) then
    raise Exception.CreateFmt(SSimpleXmlError16, [String(aChar), FSourceLine, FSourceCol]);
  Next;
end;

procedure TXmlSource.ExpectText(const aText: TMyXMLString);
// aText is UTF8 coded
var
  TextChar: UCS4Char;
  p: PByte;
  N: Integer;
begin
  p := PByte(aText);
  while p^<>0 do
  begin
    N := ReadUTF8Char(TextChar, p^);
    Inc(p);
    while (N>0) and (p^<>0) do
    begin
      ReadUTF8Char(TextChar, p^);
      Inc(p);
    end;
    if (CurChar <> TextChar) or EOF
    then
      raise Exception.CreateFmt(SSimpleXmlError17, [UTF8toAnsi(aText), FSourceLine, FSourceCol]);
    Next;
  end;
end;

// на входе: открывающая кавычка
// на выходе: символ, следующий за закрывающей кавычкой
function TXmlSource.ExpectQuotedText(aQuote: Char): TmyXMLString;
begin
  NewToken;
  Next;
  while not EOF and (CurChar <> UCS4Char(aQuote)) do begin
    if CurChar = UCS4Char('&') then
      AppendTokenChar(ExpectXmlEntity)
    else if CurChar = UCS4Char('<') then
      raise Exception.CreateFmt(SSimpleXmlError18, [FSourceLine, FSourceCol])
    else begin
      AppendTokenChar(CurChar);
      Next;
    end
  end;
  if EOF then
    raise Exception.CreateFmt(SSimpleXmlError19, [aQuote, FSourceLine, FSourceCol]);
  Next;
  Result := AcceptToken;
end;

procedure TXmlSource.ParseAttrs(aNode: TXmlNode);
var
  aName: TmyXMLString;
  aValue: TmyXMLString;
begin
  SkipBlanks;
  while not EOF and NameCanBeginWith4(CurChar) do begin
    aName := ExpectXmlName;
    SkipBlanks;
    ExpectChar('=');
    SkipBlanks;
    if EOF then
      raise Exception.CreateFmt(SSimpleXmlError20, [FSourceLine, FSourceCol]);
    if (CurChar = UCS4Char('''')) or (CurChar = UCS4Char('"'))
    then
      aValue := ExpectQuotedText(Char(CurChar))
    else
      raise Exception.CreateFmt(SSimpleXmlError21, [FSourceLine, FSourceCol]);
    with aNode do
      Set_MyXMLAttr(FNames.GetmyXMLID(aName), varEmpty, aValue);
    SkipBlanks;
  end;
end;

function StrEquals(p1, p2: PmyXMLChar; aLen: Integer): Boolean;
// return true if string p1 and p2 are equal until aLen chars
begin
  while aLen > 0 do
  begin
    if p1^ <> p2^
    then begin
      Result := False;
      Exit;
    end
    else
    if (Byte(p1^) = 0) or (Byte(p2^) = 0)
    then begin
      Result := p1^ = p2^;
      Exit;
    end
    else begin
      Inc(p1);
      Inc(p2);
      Dec(aLen);
    end;
  end;
  Result := True;
end;

// на входе: первый символ текста
// на выходе: символ, следующий за последним символом ограничителя
function TXmlSource.ParseTo(const aText: TMyXMLString): TmyXmlString;
// aText is ASCII
var
  aCheck: PmyXMLChar;
  p: PmyXMLChar;
begin
  NewToken;
  aCheck := Pointer(aText);
  while not EOF do
  begin
    if CurChar = UCS4Char(aCheck^)
    then begin
      // compare XmlSource and aText
      Inc(aCheck);
      Next;
      if Byte(aCheck^) = 0
      then begin
        Result := AcceptToken;
        Exit; //aText is found
      end;
    end
    else
    if aCheck = Pointer(aText)
    then begin // scan for aText
      AppendTokenChar(CurChar);
      Next;
    end
    else begin
      p := Pointer(aText); inc(p);
      while (NativeInt(p) < NativeInt(aCheck)) and
            not StrEquals(p, Pointer(aText), NativeInt(aCheck) - NativeInt(p)) do
      begin
        Inc(p);
      end;
      AppendTokenText(Pointer(aText), NativeInt(p) - NativeInt(aText));
      if (NativeInt(p) < NativeInt(aCheck))
      then
        aCheck := p
      else
        aCheck := Pointer(aText);
    end;
  end;
  raise Exception.CreateFmt(SSimpleXmlError22, [UTF8toAnsi(aText), FSourceLine, FSourceCol]);
end;

function CalcUTF8Len(c: AnsiChar): Integer;
begin
  if Byte(c) and $80=0
  then
    Result := 1
  else
  if Byte(c) and $E0=$C0
  then
    Result := 2
  else
  if Byte(c) and $F0=$E0
  then
    Result := 3
  else
  if Byte(c) and $F8=$F0
  then
    Result := 4
  else
    Result := 0;
end;

procedure TXmlSource.AppendTokenChar(aChar: UCS4Char);
begin
  FToken.AppendChar(aChar);
end;

procedure TXmlSource.AppendTokenText(aText: PmyXMLChar; aCount: Integer);
begin
  FToken.AppendText(aText, aCount)
end;

constructor TXmlSource.Create(aStream: TStream);
begin
  inherited Create;
  FStream := aStream;
  FTokenStackTop := -1;
  FCodepage := 0;
  f8BitBufferCoding := True;
  FSourceLine := 1;
  FSourceCol := 0;
  AutoCodepage := True;  //Set Codepage according XML encoding property
  GetMem(FBuffer, SourceBufferSize);
  Next;
end;

constructor TXmlSource.Create(const aString: RawByteString);
var
  aStream: TStream;
begin
  aStream := TMemoryStream.Create;
  aStream.WriteBuffer(Pointer(aString)^, Length(aString));
  aStream.Position := 0;
  FStreamOwner := True;
  Create(aStream);
end;

procedure TXmlSource.DropToken;
begin
  Dec(FTokenStackTop);
  if FTokenStackTop >= 0 then
    FToken := FTokenStack[FTokenStackTop]
  else
    FToken := nil
end;

destructor TXmlSource.Destroy;
var
  i: Integer;
begin
  for i := 0 to Length(FTokenStack) - 1 do
    FTokenStack[i].Free;
  FreeMem(FBuffer);
  if FStreamOwner
  then
    FStream.Free;
  inherited;
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlToken Implementation'}{$ENDIF}

function UTF8CodepointLength(aChar: UCS4Char): Integer;
begin
  if aChar<$80
  then
    Result := 1
  else
  if aChar<=$7FF
  then
    Result := 2
  else
  if aChar<=$FFFF
  then
    Result := 3
  else
  if aChar<=$1FFFFF
  then
    Result := 4
  else
    Result := 0;
end;

procedure TXmlToken.AppendChar(const aChar: UCS4Char);
var
  p: PByte;
  Size: Integer;
begin
  p := Pointer(FValueBuf);
  inc(p, FLength);
  inc(FLength, WriteUTF8Char(p, aChar));
  Size := Length(FValueBuf);
  if Size - FLength <= 4
  then begin
    SetLength(FValueBuf, Size + 16);
  end;
end;

procedure TXmlToken.AppendText(const aText: PmyXMLChar; const aCount: Integer);
var
  p: PByte;
  Size: Integer;
begin
  Size := System.Length(FValueBuf);
  p := Pointer(FValueBuf);
  inc(p, FLength);
  Inc(FLength, aCount);
  if FLength >= Size
  then begin
    SetLength(FValueBuf, FLength + 32);
  end;
  Move(aText^, p^, aCount);
end;

procedure TXmlToken.Clear;
begin
  FLength := 0;
end;

constructor TXmlToken.Create;
begin
  inherited Create;
  SetLength(FValueBuf, 32);
end;

function TXmlToken.Text: TmyXMLString;
begin
  SetLength(Result, FLength);
  if FLength>0
  then
    Move(Pointer(FValueBuf)^, Pointer(Result)^, FLength);
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlSaver Implementation'}{$ENDIF}

const
  XMLSaverBuffersize = 2048;

constructor TXmlSaver.Create;
begin
  inherited;
  SetCodepage(CP_UTF8);
end;

destructor TXmlSaver.Destroy;
begin
  FlushBuffer;
  FreeMem(fUnicodeBuffer);
  FreeMem(fBuffer);
  inherited;
end;

procedure TXmlSaver.FlushBuffer;
begin
  fAnsiPtr := fBuffer;
  FRemain := FBuffersize;
end;

procedure TXmlSaver.SaveToBuffer(UTF8Data: Pointer; UTF8Size: Cardinal);
// TFileStream.WriteBuffer is very slow for small pices of data. Buffering
// is mutch faster.
var
  UnicodeSize: Integer;
  Count: Cardinal;
begin
  Count := UTF8Size * fMaxCharSize;
  if Count > fRemain
  then
    FlushBuffer;
  if Count > fBufferSize
  then begin
    fBufferSize := Count;
    fRemain := Count;
    ReAllocMem(fBuffer, Count);
    fAnsiPtr := fBuffer;
  end;
  if (UTF8Size<>0)
  then begin
    if Codepage<>CP_UTF8
    then begin
      if UTF8Size>fUnicodeSize
      then begin
        fUnicodeSize := UTF8Size;
        ReAllocMem(fUnicodeBuffer, UTF8Size * SizeOf(WideChar));
      end;
      UnicodeSize := UTF8ToUnicode(fUnicodeBuffer, fUnicodeSize, UTF8Data, UTF8Size);
      if UnicodeSize>0
      then begin
        Count := WideCharToMultiByte(FCodepage, 0,
                                     fUnicodeBuffer, UnicodeSize-1,
                                     fAnsiPtr, FRemain,
                                     nil, nil); //UTF16->Ansi
      end
      else
        Count := 0;
    end
    else begin
      move(UTF8Data^, fAnsiPtr^, Count);
    end;
    inc(fAnsiPtr, Count);
    dec(FRemain, Count);
  end;
end;

procedure TXmlSaver.SetCodepage(const Value: Word);
var
  CPInfo: TCPInfo;
begin
  if Value <> FCodepage
  then begin
    if (Value <> CP_UTF8)
    then begin
      GetMem(fUnicodeBuffer, XMLSaverBuffersize * SizeOf(WideChar));
      fUnicodeSize := XMLSaverBuffersize;
      if GetCPInfo(Value, CPInfo)
      then
        fMaxCharSize := CPInfo.MaxCharSize
      else
        RaiseLastOSError;
    end
    else begin
      FreeMem(fUnicodeBuffer);
      fUnicodeBuffer := nil;
      fUnicodeSize := 0;
      fMaxCharSize := 1;
    end;
    if XMLSaverBuffersize * fMaxCharSize <> fBufferSize
    then begin
      fBufferSize := XMLSaverBuffersize * fMaxCharSize;
      fRemain := fBufferSize;
      ReAllocMem(fBuffer, fBufferSize);
      fAnsiPtr := fBuffer;
    end;
  end;
  FCodepage := Value;
end;

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TXmlStmSaver Implementation'}{$ENDIF}

constructor TXmlStmSaver.Create(aStream: TStream);
begin
  inherited Create;
  FStream := aStream;
end;

procedure TXmlStmSaver.FlushBuffer;
var
  Count: Integer;
begin
  Count := fBuffersize - fRemain;
  if Count>0
  then begin
    FStream.WriteBuffer(fBuffer^, Count);
  end;
  inherited;
end;

procedure TXmlStmSaver.Save(const XmlStr: TmyXmlString);
begin
  SaveToBuffer(Pointer(XmlStr), Length(XmlStr));
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Binary Reader Implementation'}{$ENDIF}

{ TStmXmlReader }

constructor TStreamXmlReader.Create(aStream: TStream; aBufSize: Integer);
begin
  inherited Create;
  FStream := aStream;
  FRemainSize := aStream.Size - aStream.Position;
  FBufSize := aBufSize;
  GetMem(FBufStart, aBufSize);
end;

destructor TStreamXmlReader.Destroy;
begin
  FreeMem(FBufStart);
  inherited;
end;

procedure TStreamXmlReader.Read(var aBuf; aSize: Integer);
var
  aDst: PmyXMLChar;
begin
  if aSize > FRemainSize then
    raise Exception.Create(SSimpleXmlError23);

  if aSize <= FBufRemain
  then begin
    Move(FBufPtr^, aBuf, aSize);
    Inc(FBufPtr, aSize);
    Dec(FRemainSize, aSize);
    Dec(FBufRemain, aSize);
  end
  else begin
    aDst := @aBuf;
    Move(FBufPtr^, aDst^, FBufRemain);
    Inc(aDst, FBufRemain);
    FStream.ReadBuffer(aDst^, aSize - FBufRemain);
    Dec(FRemainSize, aSize);

    if FRemainSize < FBufSize
    then
      FBufRemain := FRemainSize
    else
      FBufRemain := FBufSize;
    FBufPtr := FBufStart;
    if FBufRemain > 0
    then
      FStream.ReadBuffer(FBufStart^, FBufRemain);
  end;
end;

{ TStrXmlReader }

constructor TMemoryXmlReader.Create(const aData; const aCount: Integer);
begin
  inherited Create;
  FData := @aData;
  FRemain := aCount;
  FPtr := FData;
  // Ignore BinXmlSignature
  Inc(FPtr, Length(BinXmlSignature));
  Dec(FRemain, Length(BinXmlSignature));
end;

procedure TMemoryXmlReader.Read(var aBuf; aSize: Integer);
begin
  if aSize > FRemain then
    raise Exception.Create(SSimpleXmlError23);
  Move(FPtr^, aBuf, aSize);
  Inc(FPtr, aSize);
  Dec(FRemain, aSize);
end;

{ TBinXmlReader }

function TBinXmlReader.ReadLongint: Longint;
var
  b: Byte;
begin
  Result := 0;
  Read(Result, 1);
  if Result >= $80 then
    if Result = $FF then
      Read(Result, sizeof(Result))
    else begin
      Read(b, 1);
      Result := (Result and $7F) shl 8 or b;
    end
end;

function TBinXmlReader.ReadBinData: TmyXMLString;
var
  aLength: LongInt;
begin
  aLength := ReadLongint;
  SetLength(Result, aLength);
  if aLength > 0 then
    Read(Pointer(Result)^, aLength);
end;

procedure TBinXmlReader.ReadVariant(var aDataType: TVarType; var aData: TmyXMLString);
begin
  aDataType := ReadLongint;
  aData := ReadBinData;
end;

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Binary Writer Implementation'}{$ENDIF}
{ TStmXmlWriter }

constructor TStreamXmlWriter.Create(aStream: TStream; aBufSize: Integer);
begin
  inherited Create;
  FStream := aStream;
  FBufSize := aBufSize;
  FRemain := aBufSize;
  GetMem(FBuffer, aBufSize);
  FBufPtr := FBuffer;
  Write(Pointer(BinXmlSignature)^, Length(BinXmlSignature));
end;

destructor TStreamXmlWriter.Destroy;
begin
  if FBufPtr<>FBuffer then
    FStream.WriteBuffer(FBuffer^, NativeInt(FBufPtr) - NativeInt(FBuffer));
  FreeMem(FBuffer);
  inherited;
end;

procedure TStreamXmlWriter.Write(const aBuf; aSize: Integer);
begin
  if aSize <= FRemain
  then begin
    Move(aBuf, FBufPtr^, aSize);
    Inc(FBufPtr, aSize);
    Dec(FRemain, aSize);
  end
  else begin
    if FRemain < FBufSize
    then begin
      FStream.WriteBuffer(FBuffer^, FBufSize-FRemain);
      FBufPtr := FBuffer;
      FRemain := FBufSize;
    end;
    FStream.WriteBuffer(aBuf, aSize);
  end
end;

{ TStrXmlWriter }

constructor TMemoryXmlWriter.Create(aBufSize: Integer);
begin
  inherited Create;
  SetLength(FData, aBufSize);
  FRemain := aBufSize;
  FBufPtr := Pointer(FData);
  Write(Pointer(BinXmlSignature)^, Length(BinXmlSignature));
end;

procedure TMemoryXmlWriter.FlushBuf;
begin
  if FRemain>0
  then
    SetLength(FData, Length(FData)-FRemain);
end;

procedure TMemoryXmlWriter.Write(const aBuf; aSize: Integer);
begin
  if aSize <= FRemain
  then begin
    Move(aBuf, FBufPtr^, aSize);
    Inc(FBufPtr, aSize);
    Dec(FRemain, aSize);
  end
  else begin
    SetLength(FData, Length(FData) + FBufSize + aSize);
    Move(aBuf, FBufPtr^, aSize);
    Inc(FBufPtr, aSize);
    FRemain := FBufSize;
  end
end;

{ TBinXmlWriter }

procedure TBinXmlWriter.WriteUTF8String(const aValue: TmyXmlString);
var
  L: Integer;
begin
  L := Length(aValue);
  WriteLongint(L);
  if L > 0 then
    Write(Pointer(aValue)^, L);
end;

procedure TBinXmlWriter.WriteLongint(aValue: Longint);
var
  b: array [0..1] of Byte;
begin
  if aValue < 0 then begin
    b[0] := $FF;
    Write(b[0], 1);
    Write(aValue, SizeOf(aValue));
  end
  else if aValue < $80 then
    Write(aValue, 1)
  else if aValue <= $7FFF then begin
    b[0] := (aValue shr 8) or $80;
    b[1] := aValue and $FF;
    Write(b, 2);
  end
  else begin
    b[0] := $FF;
    Write(b[0], 1);
    Write(aValue, SizeOf(aValue));
  end;
end;

procedure TBinXmlWriter.WriteVariant(aDataType: TVarType; const aData: TMyXMLString);
begin
  WriteLongint(aDataType);
  WriteUTF8String(aData);
end;

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Document Creation Function Implementation'}{$ENDIF}

function CreateXmlElement(const aName: TXmlString; const aNameTable: IXmlNameTable): IXmlElement;
var
  aNameTableImpl: TXmlNameTable;
begin
  if Assigned(aNameTable) then
    aNameTableImpl := aNameTable.GetObject as TXmlNameTable
  else
    aNameTableImpl := TXmlNameTable.Create(DefaultHashSize);
  Result := TXmlElement.Create(aNameTableImpl, aNameTableImpl.GetID(aName));
end;

function CreateXmlDocument(const aRootElementName: String;
                           const aVersion: String;
                           const anEncoding: String;
                           const aNameTable: IXmlNameTable): IXmlDocument;
var
  aNameTableImpl: TXmlNameTable;
begin
  if Assigned(aNameTable)
  then
    aNameTableImpl := aNameTable.GetObject as TXmlNameTable
  else
    aNameTableImpl := nil;
  Result := TXmlDocument.Create(aNameTableImpl);
  if aRootElementName <> '' then
    Result.NewDocument(aVersion, anEncoding, aRootElementName);
end;

function LoadXmlDocumentFromXML(const aXML: RawByteString; const anEncoding: String): IXmlDocument;
begin
  Result := TXmlDocument.Create;
  Result.LoadXML(aXML);
end;

function LoadXmlDocumentFromBinaryXML(const aXML: RawByteString): IXmlDocument;
begin
  Result := TXmlDocument.Create;
  Result.LoadBinaryXML(Pointer(aXML)^, Length(aXML));
end;

function LoadXmlDocument(aStream: TStream): IXmlDocument;
begin
  Result := TXmlDocument.Create;
  Result.Load(aStream);
end;

function LoadXmlDocument(const aFileName: String): IXmlDocument; overload;
begin
  Result := TXmlDocument.Create;
  Result.Load(aFileName);
end;

function LoadXmlDocument(aResType, aResName: PChar): IXmlDocument; overload;
begin
  Result := TXmlDocument.Create;
  Result.LoadResource(aResType, aResName);
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}

end.
