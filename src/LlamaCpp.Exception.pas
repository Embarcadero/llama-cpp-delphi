unit LlamaCpp.Exception;

interface

uses
  System.SysUtils;

type
  ELlama = class(Exception);

  ETensorSplitExceed = class(ELlama);

  ELoraAdapterInitFailure = class(ELlama);

  ELoraAdapterSetFailure = class(ELlama);

  EUnknownValueForKVOverrides = class(ELlama);

  ESaveStateCopy = class(ELlama);

  ESaveStateSet = class(ELlama);

implementation

end.
