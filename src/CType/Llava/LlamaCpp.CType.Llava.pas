unit LlamaCpp.CType.Llava;

interface

type
  PLlavaImageEmbed = ^TLLavaImageEmbed;
  TLlavaImageEmbed = record
    embed: PSingle;   // Pointer to a float array (Single type in Delphi)
    n_image_pos: Int32;
  end;

  // The struct clip_ctx is an opaque type, so we represent it as a pointer in Delphi.
  PClipCtx = ^TClipCtx;
  TClipCtx = NativeUInt;

  PClipImageU8 = ^TClipImageU8;
  TClipImageU8 = record
    nx: Integer;
    ny: Integer;
    buf: TArray<Byte>;  // This is the equivalent of std::vector<uint8_t>
  end;

implementation

end.
