unit LlamaCpp.Api.Llava;

interface

uses
  System.SysUtils,
  LlamaCpp.Api,
  LlamaCpp.CType.Llava,
  LlamaCpp.CType.Llama;

type
  TLlavaApiAccess = class(TLlamaCppLibraryLoader)
  public type
    TLLavaValidateEmbedSize = function(const ALlamaContext: PLlamaContext;
      const AClipContext: PClipCtx): Boolean; cdecl;
    TLLavaImageEmbedMakeWithClipImg = function(AClipContext: PClipCtx;
      AThreadCount: Integer; const AImage: PClipImageU8;
      var AImageEmbedOut: PSingle; var AImagePosOut: Integer): Boolean; cdecl;
    TLLavaImageEmbedMakeWithBytes = function(AClipContext: PClipCtx;
      AThreadCount: Integer; const AImageBytes: PByte;
      AImageBytesLength: Integer): PLlavaImageEmbed; cdecl;
    TLLavaImageEmbedMakeWithFilename = function(AClipContext: PClipCtx;
      AThreadCount: Integer; const AImagePath: PAnsiChar)
      : PLlavaImageEmbed; cdecl;
    TLLavaImageEmbedFree = procedure(AImageEmbed: PLlavaImageEmbed); cdecl;
    TLLavaEvalImageEmbed = function(ALlamaContext: PLlamaContext;
      const AImageEmbed: PLlavaImageEmbed; ABatchSize: Integer;
      var APastPos: Integer): Boolean; cdecl;
    TClipModelLoad = function(const AFileName: PAnsiChar; AVerbosity: Integer)
      : PClipCtx; cdecl;
    TClipFree = procedure(AClipContext: PClipCtx); cdecl;
  protected
    procedure DoLoadLibrary(const ALibAddr: THandle); override;
  public
    llava_validate_embed_size: TLLavaValidateEmbedSize;
    llava_image_embed_make_with_clip_img: TLLavaImageEmbedMakeWithClipImg;
    llava_image_embed_make_with_bytes: TLLavaImageEmbedMakeWithBytes;
    llava_image_embed_make_with_filename: TLLavaImageEmbedMakeWithFilename;
    llava_image_embed_free: TLLavaImageEmbedFree;
    llava_eval_image_embed: TLLavaEvalImageEmbed;
    clip_model_load: TClipModelLoad;
    clip_free: TClipFree;
  end;

  TLlavaApi = class(TLlavaApiAccess)
  private
    class var FInstance: TLlavaApi;
  public
    class constructor Create();
    class destructor Destroy();

    class property Instance: TLlavaApi read FInstance;
  end;

implementation

{ TLlavaApiAccess }

procedure TLlavaApiAccess.DoLoadLibrary(const ALibAddr: THandle);
begin
  inherited;
  @llava_validate_embed_size := GetProcAddress(ALibAddr,
    'llava_validate_embed_size');
  @llava_image_embed_make_with_clip_img :=
    GetProcAddress(ALibAddr, 'llava_image_embed_make_with_clip_img');
  @llava_image_embed_make_with_bytes := GetProcAddress(ALibAddr,
    'llava_image_embed_make_with_bytes');
  @llava_image_embed_make_with_filename :=
    GetProcAddress(ALibAddr, 'llava_image_embed_make_with_filename');
  @llava_image_embed_free := GetProcAddress(ALibAddr, 'llava_image_embed_free');
  @llava_eval_image_embed := GetProcAddress(ALibAddr, 'llava_eval_image_embed');
  @clip_model_load := GetProcAddress(ALibAddr, 'clip_model_load');
  @clip_free := GetProcAddress(ALibAddr, 'clip_free');
end;

{ TLlavaApi }

class constructor TLlavaApi.Create;
begin
  FInstance := TLlavaAPI.Create();
end;

class destructor TLlavaApi.Destroy;
begin
  FInstance.Free();
end;

end.
