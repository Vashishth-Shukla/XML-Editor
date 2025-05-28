unit uXmlCommon;

interface

uses
  System.SysUtils; // For Exception and its descendants

type
  // Defines the types of XML nodes
  TXmlNodeType = (
    xntUnknown,                 // Unknown or unhandled node type
    xntElement,                 // An XML element (e.g., <tag>)
    xntAttribute,               // An attribute of an element (e.g., name="value")
    xntText,                    // Text content within an element
    xntCData,                   // CDATA section (e.g., <![CDATA[...]]>)
    xntEntityRef,               // Entity reference (e.g., &amp;)
    xntEntity,                  // Entity declaration (e.g., <!ENTITY ...>)
    xntProcessingInstruction,   // Processing instruction (e.g., <?xml-stylesheet ...?>)
    xntComment,                 // XML comment (e.g., )
    xntDocument,                // The Document node itself
    xntDocumentType,            // Document type declaration (e.g., <!DOCTYPE ...>)
    xntDocumentFragment,        // Document fragment (a lightweight document object)
    xntNotation                 // Notation declaration (e.g., <!NOTATION ...>)
  );

  // Custom exception class for XML adapter errors
  EXmlAdapterException = class(Exception);

implementation

end.
