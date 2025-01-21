unit LlamaCpp.Api.Llama;

interface

uses
  System.SysUtils,
  LlamaCpp.Api,
  LlamaCpp.CType.Llama,
  LlamaCpp.CType.Ggml,
  LlamaCpp.CType.Ggml.Cpu;

type
  TLlamaApiAccess = class(TLlamaCppLibraryLoader)
  public type
    TLlamaModelDefaultParams = function(): TLlamaModelParams; cdecl;
    TLlamaContextDefaultParams = function(): TLlamaContextParams; cdecl;
    TLlamaSamplerChainDefaultParams = function()
      : TLlamaSamplerChainParams; cdecl;
    TLlamaModelQuantizeDefaultParams = function()
      : TLlamaModelQuantizeParams; cdecl;
    TLlamaBackendInit = procedure(); cdecl;
    TLlamaNumaInit = procedure(const ANuma: TGGMLNumaStrategy); cdecl;
    TLlamaBackendFree = procedure; cdecl;
    TLlamaLoadModelFromFile = function(const APathModel: PAnsiChar;
      const AParams: TLlamaModelParams): PLlamaModel; cdecl;
    TLlamaFreeModel = procedure(const AModel: PLlamaModel); cdecl;
    TLlamaNewContextWithModel = function(const AModel: PLlamaModel;
      const AParams: TLlamaContextParams): PLlamaContext; cdecl;
    TLlamaFree = procedure(const ACtx: PLlamaContext); cdecl;
    TLlamaTimeUs = function: Int64; cdecl;
    TLlamaMaxDevices = function: NativeUInt; cdecl;
    TLlamaSupportsMmap = function: Boolean; cdecl;
    TLlamaSupportsMlock = function: Boolean; cdecl;
    TLlamaSupportsGpuOffload = function: Boolean; cdecl;
    TLlamaSupportsRpc = function: Boolean; cdecl;
    TLlamaNCtx = function(const AContext: PLlamaContext): Cardinal; cdecl;
    TLlamaNBatch = function(const AContext: PLlamaContext): Cardinal; cdecl;
    TLlamaNUbatch = function(const AContext: PLlamaContext): Cardinal; cdecl;
    TLlamaNSeqMax = function(const AContext: PLlamaContext): Cardinal; cdecl;
    TLlamaNVocab = function(const AModel: PLlamaModel): Integer; cdecl;
    TLlamaNCtxTrain = function(const AModel: PLlamaModel): Integer; cdecl;
    TLlamaNEmbd = function(const AModel: PLlamaModel): Integer; cdecl;
    TLlamaNLayer = function(const AModel: PLlamaModel): Integer; cdecl;
    TLlamaNHead = function(const AModel: PLlamaModel): Integer; cdecl;
    TLlamaGetModel = function(const AContext: PLlamaContext)
      : PLlamaModel; cdecl;
    TLlamaPoolingType = function(const AContext: PLlamaContext)
      : LlamaCpp.CType.Llama.TLlamaPoolingType; cdecl;
    TLlamaVocabType = function(const AModel: PLlamaModel)
      : LlamaCpp.CType.Llama.TLlamaVocabType; cdecl;
    TLlamaRopeType = function(const AModel: PLlamaModel)
      : LlamaCpp.CType.Llama.TLlamaRopeType; cdecl;
    TLlamaRopeFreqScaleTrain = function(const AModel: PLlamaModel)
      : Single; cdecl;
    TLlamaModelMetaValStr = function(const AModel: PLlamaModel;
      const AKey: PAnsiChar; ABuf: PAnsiChar; ABufSize: NativeInt)
      : Integer; cdecl;
    TLlamaModelMetaCount = function(const AModel: PLlamaModel): Integer; cdecl;
    TLlamaModelMetaKeyByIndex = function(const AModel: PLlamaModel;
      AIndex: Integer; ABuf: PAnsiChar; ABufSize: NativeInt): Integer; cdecl;
    TLlamaModelMetaValStrByIndex = function(const AModel: PLlamaModel;
      AIndex: Integer; ABuf: PAnsiChar; ABufSize: NativeInt): Integer; cdecl;
    TLlamaModelDesc = function(const AModel: PLlamaModel; ABuf: PAnsiChar;
      ABufSize: NativeInt): Integer; cdecl;
    TLlamaModelSize = function(const AModel: PLlamaModel): UInt64; cdecl;
    TLlamaModelNParams = function(const AModel: PLlamaModel): UInt64; cdecl;
    TLlamaGetModelTensor = function(AModel: PLlamaModel; const AName: PAnsiChar)
      : PGgmlTensor; cdecl;
    TLlamaModelHasEncoder = function(const AModel: PLlamaModel): Boolean; cdecl;
    TLlamaModelHasDecoder = function(const AModel: PLlamaModel): Boolean; cdecl;
    TLlamaModelDecoderStartToken = function(const AModel: PLlamaModel)
      : TLlamaToken; cdecl;
    TLlamaModelIsRecurrent = function(const AModel: PLlamaModel)
      : Boolean; cdecl;
    TLlamaModelQuantize = function(const AFnameInp: PAnsiChar;
      const AFnameOut: PAnsiChar; const AParams: PLlamaModelQuantizeParams)
      : Cardinal; cdecl;
    TLlamaLoraAdapterInit = function(AModel: PLlamaModel;
      const APathLora: PAnsiChar): PLlamaLoraAdapter; cdecl;
    TLlamaLoraAdapterSet = function(AContext: PLlamaContext;
      AAdapter: PLlamaLoraAdapter; AScale: Single): Integer; cdecl;
    TLlamaLoraAdapterRemove = function(AContext: PLlamaContext;
      AAdapter: PLlamaLoraAdapter): Integer; cdecl;
    TLlamaLoraAdapterClear = procedure(AContext: PLlamaContext); cdecl;
    TLlamaLoraAdapterFree = procedure(AAdapter: PLlamaLoraAdapter); cdecl;
    TLlamaControlVectorApply = function(AContext: PLlamaContext; AData: PSingle;
      ALen: NativeInt; ANEmbd, AIlStart, AIlEnd: Integer): Integer; cdecl;
    TLlamaKvCacheViewInit = function(AContext: PLlamaContext; ANSeqMax: Integer)
      : TLlamaKvCacheView; cdecl;
    TLlamaKvCacheViewFree = procedure(AView: PLlamaKvCacheView); cdecl;
    TLlamaKvCacheViewUpdate = procedure(AContext: PLlamaContext;
      AView: PLlamaKvCacheView); cdecl;
    TLlamaGetKvCacheTokenCount = function(AContext: PLlamaContext)
      : Integer; cdecl;
    TLlamaGetKvCacheUsedCells = function(AContext: PLlamaContext)
      : Integer; cdecl;
    TLlamaKvCacheClear = procedure(AContext: PLlamaContext); cdecl;
    TLlamaKvCacheSeqRm = function(AContext: PLlamaContext; ASeqId: TLlamaSeqId;
      AP0, AP1: TLlamaPos): Boolean; cdecl;
    TLlamaKvCacheSeqCp = procedure(AContext: PLlamaContext;
      ASeqIdSrc, ASeqIdDst: TLlamaSeqId; AP0, AP1: TLlamaPos); cdecl;
    TLlamaKvCacheSeqKeep = procedure(AContext: PLlamaContext;
      ASeqId: TLlamaSeqId); cdecl;
    TLlamaKvCacheSeqAdd = procedure(AContext: PLlamaContext;
      ASeqId: TLlamaSeqId; AP0, AP1, ADelta: TLlamaPos); cdecl;
    TLlamaKvCacheSeqDiv = procedure(AContext: PLlamaContext;
      ASeqId: TLlamaSeqId; AP0, AP1: TLlamaPos; AD: Integer); cdecl;
    TLlamaKvCacheSeqPosMax = function(AContext: PLlamaContext;
      ASeqId: TLlamaSeqId): TLlamaPos; cdecl;
    TLlamaKvCacheDefrag = procedure(AContext: PLlamaContext); cdecl;
    TLlamaKvCacheUpdate = procedure(AContext: PLlamaContext); cdecl;
    TLlamaKvCacheCanShift = function(AContext: PLlamaContext): Boolean; cdecl;
    TLlamaStateGetSize = function(AContext: PLlamaContext): NativeInt; cdecl;
    TLlamaStateGetData = function(AContext: PLlamaContext; ADst: PByte;
      ASize: NativeInt): NativeInt; cdecl;
    TLlamaStateSetData = function(AContext: PLlamaContext; ASrc: PByte;
      ASize: NativeInt): NativeInt; cdecl;
    TLlamaGetStateSize = function(AContext: PLlamaContext): NativeInt; cdecl;
    TLlamaCopyStateData = function(AContext: PLlamaContext; ADst: pointer)
      : NativeInt; cdecl;
    TLlamaSetStateData = function(AContext: PLlamaContext; ASrc: pointer)
      : NativeInt; cdecl;
    TLlamaStateLoadFile = function(const AContext: PLlamaContext;
      const APathSession: PAnsiChar; ATokensOut: PLlamaToken;
      ANTokenCapacity: NativeUInt; ANTokenCountOut: PNativeUInt)
      : Boolean; cdecl;
    TLlamaLoadSessionFile = function(const AContext: PLlamaContext;
      const APathSession: PAnsiChar; ATokensOut: PLlamaToken;
      ANTokenCapacity: NativeUInt; ANTokenCountOut: PNativeUInt)
      : Boolean; cdecl;
    TLlamaStateSaveFile = function(const AContext: PLlamaContext;
      const APathSession: PAnsiChar; const ATokens: PLlamaToken;
      ANTokenCount: NativeUInt): Boolean; cdecl;
    TLlamaSaveSessionFile = function(const AContext: PLlamaContext;
      const APathSession: PAnsiChar; const ATokens: PLlamaToken;
      ANTokenCount: NativeUInt): Boolean; cdecl;
    TLlamaStateSeqGetSize = function(const AContext: PLlamaContext;
      ASeqId: TLlamaSeqId): NativeUInt; cdecl;
    TLlamaStateSeqGetData = function(const AContext: PLlamaContext; ADst: Pointer;
      ASize: NativeUInt; ASeqId: TLlamaSeqId): NativeUInt; cdecl;
    TLlamaStateSeqSetData = function(const AContext: PLlamaContext;
      const ASrc: Pointer; ASize: NativeUInt; ADestSeqID: TLlamaSeqId)
      : NativeUInt; cdecl;
    TLlamaStateSeqSaveFile = function(const AContext: PLlamaContext;
      const AFilePath: PAnsiChar; ASeqId: TLlamaSeqId; const ATokens: Pointer;
      ANTokenCount: NativeUInt): NativeUInt; cdecl;
    TLlamaStateSeqLoadFile = function(const AContext: PLlamaContext;
      const AFilePath: PAnsiChar; ADestSeqID: TLlamaSeqId; ATokensOut: Pointer;
      ANTokenCapacity: NativeUInt; ANTokenCountOut: PNativeUInt)
      : NativeUInt; cdecl;
    TLlamaBatchGetOne = function(ATokens: Pointer; ANTokens: Int32)
      : TLlamaBatch; cdecl;
    TLlamaBatchInit = function(ANTokens: Int32; AEmbd: Int32; ANSeqMax: Int32)
      : TLlamaBatch; cdecl;
    TLlamaBatchFree = procedure(ABatch: TLlamaBatch); cdecl;
    TLlamaEncode = function(const AContext: PLlamaContext; ABatch: TLlamaBatch)
      : Int32; cdecl;
    TLlamaDecode = function(const AContext: PLlamaContext; ABatch: TLlamaBatch)
      : Int32; cdecl;
    TLlamaSetNThreads = procedure(const AContext: PLlamaContext; ANThreads: Int32;
      ANThreadsBatch: Int32); cdecl;
    TLlamaNThreads = function(const AContext: PLlamaContext): Int32; cdecl;
    TLlamaNThreadsBatch = function(const AContext: PLlamaContext): Int32; cdecl;
    TLlamaSetEmbeddings = procedure(const AContext: PLlamaContext;
      AEmbeddings: Boolean); cdecl;
    TLlamaSetCausalAttn = procedure(const AContext: PLlamaContext;
      ACausalAttn: Boolean); cdecl;
    TLlamaSetAbortCallback = procedure(const AContext: PLlamaContext;
      AAbortCallback: TGgmlAbortCallback; AAbortCallbackData: pointer); cdecl;
    TLlamaSynchronize = procedure(const AContext: PLlamaContext); cdecl;
    TLlamaGetLogits = function(const AContext: PLlamaContext): PLogitArray; cdecl;
    TLlamaGetLogitsIth = function(const AContext: PLlamaContext; AI: Int32)
      : PLogitArray; cdecl;
    TLlamaGetEmbeddings = function(const AContext: PLlamaContext): PEmbdArray; cdecl;
    TLlamaGetEmbeddingsIth = function(const AContext: PLlamaContext; AI: Int32)
      : PEmbdArray; cdecl;
    TLlamaGetEmbeddingsSeq = function(const AContext: PLlamaContext;
      ASeqId: TLlamaSeqId): PEmbdArray; cdecl;
    TLlamaTokenGetText = function(const AModel: PLlamaModel; AToken: TLlamaToken)
      : PAnsiChar; cdecl;
    TLlamaTokenGetScore = function(const AModel: PLlamaModel; AToken: TLlamaToken)
      : Single; cdecl;
    TLlamaTokenGetAttr = function(const AModel: PLlamaModel; AToken: TLlamaToken)
      : TLLamaTokenAttr; cdecl;
    TLlamaTokenIsEOG = function(const AModel: PLlamaModel; AToken: TLlamaToken)
      : Boolean; cdecl;
    TLlamaTokenIsControl = function(const AModel: PLlamaModel; AToken: TLlamaToken)
      : Boolean; cdecl;
    TLlamaTokenSpecial = function(const AModel: PLlamaModel): TLlamaToken; cdecl;
    TLlamaAddSpecialToken = function(const AModel: PLlamaModel): Boolean; cdecl;
    TLlamaTokenPrefix = function(const AModel: PLlamaModel): TLlamaToken; cdecl;
    TLlamaTokenMiddle = function(const AModel: PLlamaModel): TLlamaToken; cdecl;
    TLlamaTokenSuffix = function(const AModel: PLlamaModel): TLlamaToken; cdecl;
    TLlamaTokenFimPre = function(const AModel: PLlamaModel): TLlamaToken; cdecl;
    TLlamaTokenFimSuf = function(const AModel: PLlamaModel): TLlamaToken; cdecl;
    TLlamaTokenFimMid = function(const AModel: PLlamaModel): TLlamaToken; cdecl;
    TLlamaTokenFimPad = function(const AModel: PLlamaModel): TLlamaToken; cdecl;
    TLlamaTokenFimRep = function(const AModel: PLlamaModel): TLlamaToken; cdecl;
    TLlamaTokenFimSep = function(const AModel: PLlamaModel): TLlamaToken; cdecl;
    TLlamaTokenize = function(const AModel: PLlamaModel; const AText: PAnsiChar;
      ATextLen: Int32; ATokens: PLlamaToken; ANTokensMax: Int32;
      AAddSpecial: Boolean; AParseSpecial: Boolean): Int32; cdecl;
    TLlamaTokenToPiece = function(const AModel: PLlamaModel; AToken: TLlamaToken;
      ABuf: PAnsiChar; ALength: Int32; ALStrip: Int32; ASpecial: Boolean)
      : Int32; cdecl;
    TLlamaDetokenize = function(const AModel: PLlamaModel;
      const ATokens: PLlamaToken; ANTokens: Int32; AText: PAnsiChar;
      ATextLenMax: Int32; ARemoveSpecial: Boolean; AUnparseSpecial: Boolean)
      : Int32; cdecl;
    TLlamaChatApplyTemplate = function(const AModel: PLlamaModel;
      const ATmpl: PAnsiChar; const AChat: PLlamaModel; ANMsg: NativeUInt;
      AAddAss: Boolean; ABuf: PAnsiChar; ALength: Int32): Int32; cdecl;
    TLlamaSamplerName = function(const ASmpl: PLlamaSampler): PAnsiChar; cdecl;
    TLlamaSamplerAccept = procedure(ASmpl: PLlamaSampler;
      AToken: TLlamaToken); cdecl;
    TLlamaSamplerApply = procedure(ASmpl: PLlamaSampler; ACurrProb: Pointer);
      cdecl;
    TLlamaSamplerReset = procedure(ASmpl: PLlamaSampler); cdecl;
    TLlamaSamplerClone = function(const ASmpl: PLlamaSampler)
      : PLlamaSampler; cdecl;
    TLlamaSamplerFree = procedure(ASmpl: PLlamaSampler); cdecl;
    TLlamaSamplerChainInit = function(const AParams: PLlamaSamplerChainParams)
      : PLlamaSampler; cdecl;
    TLlamaSamplerChainAdd = procedure(AChain: PLlamaSampler;
      ASampler: PLlamaSampler); cdecl;
    TLlamaSamplerChainGet = function(const AChain: PLlamaSampler; AIndex: Int32)
      : PLlamaSampler; cdecl;
    TLlamaSamplerChainN = function(const AChain: PLlamaSampler): Integer; cdecl;
    TLlamaSamplerChainRemove = function(AChain: PLlamaSampler; AIndex: Int32)
      : PLlamaSampler; cdecl;
    TLlamaSamplerInitGreedy = function: PLlamaSampler; cdecl;
    TLlamaSamplerInitDist = function(ASeed: UInt32): PLlamaSampler; cdecl;
    TLlamaSamplerInitSoftmax = function: PLlamaSampler; cdecl;
    TLlamaSamplerInitTopK = function(AK: Int32): PLlamaSampler; cdecl;
    TLlamaSamplerInitTopP = function(AP: Single; AMinKeep: NativeUInt)
      : PLlamaSampler; cdecl;
    TLlamaSamplerInitMinP = function(AP: Single; AMinKeep: NativeUInt)
      : PLlamaSampler; cdecl;
    TLlamaSamplerInitTypical = function(AP: Single; AMinKeep: NativeUInt)
      : PLlamaSampler; cdecl;
    TLlamaSamplerInitTemp = function(AT: Single): PLlamaSampler; cdecl;
    TLlamaSamplerInitTempExt = function(AT: Single; ADelta: Single;
      AExponent: Single): PLlamaSampler; cdecl;
    TLlamaSamplerInitXTC = function(AP: Single; AT: Single;
      AMinKeep: NativeUInt; ASeed: UInt32): PLlamaSampler; cdecl;
    TLlamaSamplerInitMirostat = function(ANVocab: Int32; ASeed: UInt32;
      ATau: Single; AEta: Single; AM: Int32): PLlamaSampler; cdecl;
    TLlamaSamplerInitMirostatV2 = function(ASeed: UInt32; ATau: Single;
      AEta: Single): PLlamaSampler; cdecl;
    TLlamaSamplerInitGrammar = function(const AModel: PLlamaModel;
      const AGrammarStr: PAnsiChar; const AGrammarRoot: PAnsiChar)
      : PLlamaSampler; cdecl;
    TLlamaSamplerInitPenalties = function(ANVocab: Int32;
      ASpecialEosID: TLlamaToken; ALinefeedID: TLlamaToken;
      APenaltyLastN: Int32; APenaltyRepeat: Single; APenaltyFreq: Single;
      APenaltyPresent: Single; APenalizeNl: Boolean; AIgnoreEos: Boolean)
      : PLlamaSampler; cdecl;
    TLlamaSamplerInitDry = function(const AModel: PLlamaModel;
      ADryMultiplier: Single; ADryBase: Single; ADryAllowedLength: Int32;
      ADryPenaltyLastN: Int32; ASeqBreakers: PPAnsiChar;
      ANumBreakers: NativeUInt): PLlamaSampler; cdecl;
    TLlamaSamplerInitLogitBias = function(ANVocab: Int32; ANLogitBias: Int32;
      ALogitBias: PLlamaLogitBias): PLlamaSampler; cdecl;
    TLlamaSamplerInitInfill = function(const AModel: PLlamaModel)
      : PLlamaSampler; cdecl;
    TLlamaSamplerGetSeed = function(const ASmpl: PLlamaSampler): UInt32; cdecl;
    TLlamaSamplerSample = function(ASmpl: PLlamaSampler; ACtx: PLlamaContext;
      AIdx: Int32): TLlamaToken; cdecl;
    TLlamaSplitPath = function(ASplitPath: PAnsiChar; AMaxLen: NativeUInt;
      APathPrefix: PAnsiChar; ASplitNo: Int32; ASplitCount: Int32)
      : Int32; cdecl;
    TLlamaSplitPrefix = function(ASplitPrefix: PAnsiChar; AMaxLen: NativeUInt;
      ASplitPath: PAnsiChar; ASplitNo: Int32; ASplitCount: Int32): Int32; cdecl;
    TLlamaPrintSystemInfo = function: PAnsiChar; cdecl;
    TLlamaLogSet = procedure(ALogCallback: TGGMLLogCallback;
      AUserData: Pointer); cdecl;
    TLlamaPerfContext = function(const AContext: PLlamaContext)
      : TLlamaPerfContextData; cdecl;
    TLlamaPerfContextPrint = procedure(const AContext: PLlamaContext); cdecl;
    TLlamaPerfContextReset = procedure(const AContext: PLlamaContext); cdecl;
    TLlamaPerfSampler = function(const AChain: Pointer)
      : TLlamaPerfSamplerData; cdecl;
    TLlamaPerfSamplerPrint = procedure(const AChain: Pointer); cdecl;
    TLlamaPerfSamplerReset = procedure(const AChain: Pointer); cdecl;
  protected
    procedure DoLoadLibrary(const ALibAddr: THandle); override;
  public
    llama_model_default_params: TLlamaModelDefaultParams;
    llama_context_default_params: TLlamaContextDefaultParams;
    llama_sampler_chain_default_params: TLlamaSamplerChainDefaultParams;
    llama_model_quantize_default_params: TLlamaModelQuantizeDefaultParams;
    llama_backend_init: TLlamaBackendInit;
    llama_numa_init: TLlamaNumaInit;
    llama_backend_free: TLlamaBackendFree;
    llama_load_model_from_file: TLlamaLoadModelFromFile;
    llama_free_model: TLlamaFreeModel;
    llama_new_context_with_model: TLlamaNewContextWithModel;
    llama_free: TLlamaFree;
    llama_time_us: TLlamaTimeUs;
    llama_max_devices: TLlamaMaxDevices;
    llama_supports_mmap: TLlamaSupportsMmap;
    llama_supports_mlock: TLlamaSupportsMlock;
    llama_supports_gpu_offload: TLlamaSupportsGpuOffload;
    llama_supports_rpc: TLlamaSupportsRpc;
    llama_n_ctx: TLlamaNCtx;
    llama_n_batch: TLlamaNBatch;
    llama_n_ubatch: TLlamaNUbatch;
    llama_n_seq_max: TLlamaNSeqMax;
    llama_n_vocab: TLlamaNVocab;
    llama_n_ctx_train: TLlamaNCtxTrain;
    llama_n_embd: TLlamaNEmbd;
    llama_n_layer: TLlamaNLayer;
    llama_n_head: TLlamaNHead;
    llama_get_model: TLlamaGetModel;
    llama_pooling_type: TLlamaPoolingType;
    llama_vocab_type: TLlamaVocabType;
    llama_rope_type: TLlamaRopeType;
    llama_rope_freq_scale_train: TLlamaRopeFreqScaleTrain;
    llama_model_meta_val_str: TLlamaModelMetaValStr;
    llama_model_meta_count: TLlamaModelMetaCount;
    llama_model_meta_key_by_index: TLlamaModelMetaKeyByIndex;
    llama_model_meta_val_str_by_index: TLlamaModelMetaValStrByIndex;
    llama_model_desc: TLlamaModelDesc;
    llama_model_size: TLlamaModelSize;
    llama_model_n_params: TLlamaModelNParams;
    llama_get_model_tensor: TLlamaGetModelTensor;
    llama_model_has_encoder: TLlamaModelHasEncoder;
    llama_model_has_decoder: TLlamaModelHasDecoder;
    llama_model_decoder_start_token: TLlamaModelDecoderStartToken;
    llama_model_is_recurrent: TLlamaModelIsRecurrent;
    llama_model_quantize: TLlamaModelQuantize;
    llama_lora_adapter_init: TLlamaLoraAdapterInit;
    llama_lora_adapter_set: TLlamaLoraAdapterSet;
    llama_lora_adapter_remove: TLlamaLoraAdapterRemove;
    llama_lora_adapter_clear: TLlamaLoraAdapterClear;
    llama_lora_adapter_free: TLlamaLoraAdapterFree;
    llama_control_vector_apply: TLlamaControlVectorApply;
    llama_kv_cache_view_init: TLlamaKvCacheViewInit;
    llama_kv_cache_view_free: TLlamaKvCacheViewFree;
    llama_kv_cache_view_update: TLlamaKvCacheViewUpdate;
    llama_get_kv_cache_token_count: TLlamaGetKvCacheTokenCount;
    llama_get_kv_cache_used_cells: TLlamaGetKvCacheUsedCells;
    llama_kv_cache_clear: TLlamaKvCacheClear;
    llama_kv_cache_seq_rm: TLlamaKvCacheSeqRm;
    llama_kv_cache_seq_cp: TLlamaKvCacheSeqCp;
    llama_kv_cache_seq_keep: TLlamaKvCacheSeqKeep;
    llama_kv_cache_seq_add: TLlamaKvCacheSeqAdd;
    llama_kv_cache_seq_div: TLlamaKvCacheSeqDiv;
    llama_kv_cache_seq_pos_max: TLlamaKvCacheSeqPosMax;
    llama_kv_cache_defrag: TLlamaKvCacheDefrag;
    llama_kv_cache_update: TLlamaKvCacheUpdate;
    llama_kv_cache_can_shift: TLlamaKvCacheCanShift;
    llama_state_get_size: TLlamaStateGetSize;
    llama_state_get_data: TLlamaStateGetData;
    llama_state_set_data: TLlamaStateSetData;
    llama_get_state_size: TLlamaGetStateSize;
    llama_copy_state_data: TLlamaCopyStateData;
    llama_set_state_data: TLlamaSetStateData;
    llama_state_load_file: TLlamaStateLoadFile;
    llama_load_session_file: TLlamaLoadSessionFile;
    llama_state_save_file: TLlamaStateSaveFile;
    llama_save_session_file: TLlamaSaveSessionFile;
    llama_state_seq_get_size: TLlamaStateSeqGetSize;
    llama_state_seq_get_data: TLlamaStateSeqGetData;
    llama_state_seq_set_data: TLlamaStateSeqSetData;
    llama_state_seq_save_file: TLlamaStateSeqSaveFile;
    llama_state_seq_load_file: TLlamaStateSeqLoadFile;
    llama_batch_get_one: TLlamaBatchGetOne;
    llama_batch_init: TLlamaBatchInit;
    llama_batch_free: TLlamaBatchFree;
    llama_encode: TLlamaEncode;
    llama_decode: TLlamaDecode;
    llama_set_n_threads: TLlamaSetNThreads;
    llama_n_threads: TLlamaNThreads;
    llama_n_threads_batch: TLlamaNThreadsBatch;
    llama_set_embeddings: TLlamaSetEmbeddings;
    llama_set_causal_attn: TLlamaSetCausalAttn;
    llama_set_abort_callback: TLlamaSetAbortCallback;
    llama_synchronize: TLlamaSynchronize;
    llama_get_logits: TLlamaGetLogits;
    llama_get_logits_ith: TLlamaGetLogitsIth;
    llama_get_embeddings: TLlamaGetEmbeddings;
    llama_get_embeddings_ith: TLlamaGetEmbeddingsIth;
    llama_get_embeddings_seq: TLlamaGetEmbeddingsSeq;
    llama_token_get_text: TLlamaTokenGetText;
    llama_token_get_score: TLlamaTokenGetScore;
    llama_token_get_attr: TLlamaTokenGetAttr;
    llama_token_is_eog: TLlamaTokenIsEOG;
    llama_token_is_control: TLlamaTokenIsControl;
    llama_token_bos: TLlamaTokenSpecial;
    llama_token_eos: TLlamaTokenSpecial;
    llama_token_eot: TLlamaTokenSpecial;
    llama_token_cls: TLlamaTokenSpecial;
    llama_token_sep: TLlamaTokenSpecial;
    llama_token_nl: TLlamaTokenSpecial;
    llama_token_pad: TLlamaTokenSpecial;
    llama_add_bos_token: TLlamaAddSpecialToken;
    llama_add_eos_token: TLlamaAddSpecialToken;
    llama_token_prefix: TLlamaTokenPrefix;
    llama_token_middle: TLlamaTokenMiddle;
    llama_token_suffix: TLlamaTokenSuffix;
    llama_token_fim_pre: TLlamaTokenFimPre;
    llama_token_fim_suf: TLlamaTokenFimSuf;
    llama_token_fim_mid: TLlamaTokenFimMid;
    llama_token_fim_pad: TLlamaTokenFimPad;
    llama_token_fim_rep: TLlamaTokenFimRep;
    llama_token_fim_sep: TLlamaTokenFimSep;
    llama_tokenize: TLlamaTokenize;
    llama_token_to_piece: TLlamaTokenToPiece;
    llama_detokenize: TLlamaDetokenize;
    llama_chat_apply_template: TLlamaChatApplyTemplate;
    llama_sampler_name: TLlamaSamplerName;
    llama_sampler_accept: TLlamaSamplerAccept;
    llama_sampler_apply: TLlamaSamplerApply;
    llama_sampler_reset: TLlamaSamplerReset;
    llama_sampler_clone: TLlamaSamplerClone;
    llama_sampler_free: TLlamaSamplerFree;
    llama_sampler_chain_init: TLlamaSamplerChainInit;
    llama_sampler_chain_add: TLlamaSamplerChainAdd;
    llama_sampler_chain_get: TLlamaSamplerChainGet;
    llama_sampler_chain_n: TLlamaSamplerChainN;
    llama_sampler_chain_remove: TLlamaSamplerChainRemove;
    llama_sampler_init_greedy: TLlamaSamplerInitGreedy;
    llama_sampler_init_dist: TLlamaSamplerInitDist;
    llama_sampler_init_softmax: TLlamaSamplerInitSoftmax;
    llama_sampler_init_top_k: TLlamaSamplerInitTopK;
    llama_sampler_init_top_p: TLlamaSamplerInitTopP;
    llama_sampler_init_min_p: TLlamaSamplerInitMinP;
    llama_sampler_init_typical: TLlamaSamplerInitTypical;
    llama_sampler_init_temp: TLlamaSamplerInitTemp;
    llama_sampler_init_temp_ext: TLlamaSamplerInitTempExt;
    llama_sampler_init_xtc: TLlamaSamplerInitXTC;
    llama_sampler_init_mirostat: TLlamaSamplerInitMirostat;
    llama_sampler_init_mirostat_v2: TLlamaSamplerInitMirostatV2;
    llama_sampler_init_grammar: TLlamaSamplerInitGrammar;
    llama_sampler_init_penalties: TLlamaSamplerInitPenalties;
    llama_sampler_init_dry: TLlamaSamplerInitDry;
    llama_sampler_init_logit_bias: TLlamaSamplerInitLogitBias;
    llama_sampler_init_infill: TLlamaSamplerInitInfill;
    llama_sampler_get_seed: TLlamaSamplerGetSeed;
    llama_sampler_sample: TLlamaSamplerSample;
    llama_split_path: TLlamaSplitPath;
    llama_split_prefix: TLlamaSplitPrefix;
    llama_print_system_info: TLlamaPrintSystemInfo;
    llama_log_set: TLlamaLogSet;
    llama_perf_context: TLlamaPerfContext;
    llama_perf_context_print: TLlamaPerfContextPrint;
    llama_perf_context_reset: TLlamaPerfContextReset;
    llama_perf_sampler: TLlamaPerfSampler;
    llama_perf_sampler_print: TLlamaPerfSamplerPrint;
    llama_perf_sampler_reset: TLlamaPerfSamplerReset;
  end;

  TLlamaApi = class(TLlamaApiAccess)
  private
    class var FInstance: TLlamaApi;
  public
    class constructor Create();
    class destructor Destroy();

    class property Instance: TLlamaApi read FInstance;
  end;

implementation

{ TLlamaApiAccess }

procedure TLlamaApiAccess.DoLoadLibrary(const ALibAddr: THandle);
begin
  @llama_model_default_params := GetProcAddress(ALibAddr,
    'llama_model_default_params');
  @llama_context_default_params := GetProcAddress(ALibAddr,
    'llama_context_default_params');
  @llama_sampler_chain_default_params := GetProcAddress(ALibAddr,
    'llama_sampler_chain_default_params');
  @llama_model_quantize_default_params := GetProcAddress(ALibAddr,
    'llama_model_quantize_default_params');
  @llama_backend_init := GetProcAddress(ALibAddr, 'llama_backend_init');
  @llama_numa_init := GetProcAddress(ALibAddr, 'llama_numa_init');
  @llama_backend_free := GetProcAddress(ALibAddr, 'llama_backend_free');
  @llama_load_model_from_file := GetProcAddress(ALibAddr,
    'llama_load_model_from_file');
  @llama_free_model := GetProcAddress(ALibAddr, 'llama_free_model');
  @llama_new_context_with_model := GetProcAddress(ALibAddr,
    'llama_new_context_with_model');
  @llama_free := GetProcAddress(ALibAddr, 'llama_free');
  @llama_time_us := GetProcAddress(ALibAddr, 'llama_time_us');
  @llama_max_devices := GetProcAddress(ALibAddr, 'llama_max_devices');
  @llama_supports_mmap := GetProcAddress(ALibAddr, 'llama_supports_mmap');
  @llama_supports_mlock := GetProcAddress(ALibAddr, 'llama_supports_mlock');
  @llama_supports_gpu_offload := GetProcAddress(ALibAddr,
    'llama_supports_gpu_offload');
  @llama_supports_rpc := GetProcAddress(ALibAddr, 'llama_supports_rpc');
  @llama_n_ctx := GetProcAddress(ALibAddr, 'llama_n_ctx');
  @llama_n_batch := GetProcAddress(ALibAddr, 'llama_n_batch');
  @llama_n_ubatch := GetProcAddress(ALibAddr, 'llama_n_ubatch');
  @llama_n_seq_max := GetProcAddress(ALibAddr, 'llama_n_seq_max');
  @llama_n_vocab := GetProcAddress(ALibAddr, 'llama_n_vocab');
  @llama_n_ctx_train := GetProcAddress(ALibAddr, 'llama_n_ctx_train');
  @llama_n_embd := GetProcAddress(ALibAddr, 'llama_n_embd');
  @llama_n_layer := GetProcAddress(ALibAddr, 'llama_n_layer');
  @llama_n_head := GetProcAddress(ALibAddr, 'llama_n_head');
  @llama_get_model := GetProcAddress(ALibAddr, 'llama_get_model');
  @llama_pooling_type := GetProcAddress(ALibAddr, 'llama_pooling_type');
  @llama_vocab_type := GetProcAddress(ALibAddr, 'llama_vocab_type');
  @llama_rope_type := GetProcAddress(ALibAddr, 'llama_rope_type');
  @llama_rope_freq_scale_train := GetProcAddress(ALibAddr,
    'llama_rope_freq_scale_train');
  @llama_model_meta_val_str := GetProcAddress(ALibAddr,
    'llama_model_meta_val_str');
  @llama_model_meta_count := GetProcAddress(ALibAddr, 'llama_model_meta_count');
  @llama_model_meta_key_by_index := GetProcAddress(ALibAddr,
    'llama_model_meta_key_by_index');
  @llama_model_meta_val_str_by_index := GetProcAddress(ALibAddr,
    'llama_model_meta_val_str_by_index');
  @llama_model_desc := GetProcAddress(ALibAddr, 'llama_model_desc');
  @llama_model_size := GetProcAddress(ALibAddr, 'llama_model_size');
  @llama_model_n_params := GetProcAddress(ALibAddr, 'llama_model_n_params');
  @llama_get_model_tensor := GetProcAddress(ALibAddr, 'llama_get_model_tensor');
  @llama_model_has_encoder := GetProcAddress(ALibAddr,
    'llama_model_has_encoder');
  @llama_model_has_decoder := GetProcAddress(ALibAddr,
    'llama_model_has_decoder');
  @llama_model_decoder_start_token := GetProcAddress(ALibAddr,
    'llama_model_decoder_start_token');
  @llama_model_is_recurrent := GetProcAddress(ALibAddr,
    'llama_model_is_recurrent');
  @llama_model_quantize := GetProcAddress(ALibAddr, 'llama_model_quantize');
  @llama_lora_adapter_init := GetProcAddress(ALibAddr,
    'llama_lora_adapter_init');
  @llama_lora_adapter_set := GetProcAddress(ALibAddr, 'llama_lora_adapter_set');
  @llama_lora_adapter_remove := GetProcAddress(ALibAddr,
    'llama_lora_adapter_remove');
  @llama_lora_adapter_clear := GetProcAddress(ALibAddr,
    'llama_lora_adapter_clear');
  @llama_lora_adapter_free := GetProcAddress(ALibAddr,
    'llama_lora_adapter_free');
  @llama_control_vector_apply := GetProcAddress(ALibAddr,
    'llama_control_vector_apply');
  @llama_kv_cache_view_init := GetProcAddress(ALibAddr,
    'llama_kv_cache_view_init');
  @llama_kv_cache_view_free := GetProcAddress(ALibAddr,
    'llama_kv_cache_view_free');
  @llama_kv_cache_view_update := GetProcAddress(ALibAddr,
    'llama_kv_cache_view_update');
  @llama_get_kv_cache_token_count := GetProcAddress(ALibAddr,
    'llama_get_kv_cache_token_count');
  @llama_get_kv_cache_used_cells := GetProcAddress(ALibAddr,
    'llama_get_kv_cache_used_cells');
  @llama_kv_cache_clear := GetProcAddress(ALibAddr, 'llama_kv_cache_clear');
  @llama_kv_cache_seq_rm := GetProcAddress(ALibAddr, 'llama_kv_cache_seq_rm');
  @llama_kv_cache_seq_cp := GetProcAddress(ALibAddr, 'llama_kv_cache_seq_cp');
  @llama_kv_cache_seq_keep := GetProcAddress(ALibAddr,
    'llama_kv_cache_seq_keep');
  @llama_kv_cache_seq_add := GetProcAddress(ALibAddr, 'llama_kv_cache_seq_add');
  @llama_kv_cache_seq_div := GetProcAddress(ALibAddr, 'llama_kv_cache_seq_div');
  @llama_kv_cache_seq_pos_max := GetProcAddress(ALibAddr,
    'llama_kv_cache_seq_pos_max');
  @llama_kv_cache_defrag := GetProcAddress(ALibAddr, 'llama_kv_cache_defrag');
  @llama_kv_cache_update := GetProcAddress(ALibAddr, 'llama_kv_cache_update');
  @llama_kv_cache_can_shift := GetProcAddress(ALibAddr,
    'llama_kv_cache_can_shift');
  @llama_state_get_size := GetProcAddress(ALibAddr, 'llama_state_get_size');
  @llama_state_get_data := GetProcAddress(ALibAddr, 'llama_state_get_data');
  @llama_state_set_data := GetProcAddress(ALibAddr, 'llama_state_set_data');
  @llama_get_state_size := GetProcAddress(ALibAddr, 'llama_get_state_size');
  @llama_copy_state_data := GetProcAddress(ALibAddr, 'llama_copy_state_data');
  @llama_set_state_data := GetProcAddress(ALibAddr, 'llama_set_state_data');
  @llama_state_load_file := GetProcAddress(ALibAddr, 'llama_state_load_file');
  @llama_load_session_file := GetProcAddress(ALibAddr,
    'llama_load_session_file');
  @llama_state_save_file := GetProcAddress(ALibAddr, 'llama_state_save_file');
  @llama_save_session_file := GetProcAddress(ALibAddr,
    'llama_save_session_file');
  @llama_state_seq_get_size := GetProcAddress(ALibAddr,
    'llama_state_seq_get_size');
  @llama_state_seq_get_data := GetProcAddress(ALibAddr,
    'llama_state_seq_get_data');
  @llama_state_seq_set_data := GetProcAddress(ALibAddr,
    'llama_state_seq_set_data');
  @llama_state_seq_save_file := GetProcAddress(ALibAddr,
    'llama_state_seq_save_file');
  @llama_state_seq_load_file := GetProcAddress(ALibAddr,
    'llama_state_seq_load_file');
  @llama_batch_get_one := GetProcAddress(ALibAddr, 'llama_batch_get_one');
  @llama_batch_init := GetProcAddress(ALibAddr, 'llama_batch_init');
  @llama_batch_free := GetProcAddress(ALibAddr, 'llama_batch_free');
  @llama_encode := GetProcAddress(ALibAddr, 'llama_encode');
  @llama_decode := GetProcAddress(ALibAddr, 'llama_decode');
  @llama_set_n_threads := GetProcAddress(ALibAddr, 'llama_set_n_threads');
  @llama_n_threads := GetProcAddress(ALibAddr, 'llama_n_threads');
  @llama_n_threads_batch := GetProcAddress(ALibAddr, 'llama_n_threads_batch');
  @llama_set_embeddings := GetProcAddress(ALibAddr, 'llama_set_embeddings');
  @llama_set_causal_attn := GetProcAddress(ALibAddr, 'llama_set_causal_attn');
  @llama_set_abort_callback := GetProcAddress(ALibAddr,
    'llama_set_abort_callback');
  @llama_synchronize := GetProcAddress(ALibAddr, 'llama_synchronize');
  @llama_get_logits := GetProcAddress(ALibAddr, 'llama_get_logits');
  @llama_get_logits_ith := GetProcAddress(ALibAddr, 'llama_get_logits_ith');
  @llama_get_embeddings := GetProcAddress(ALibAddr, 'llama_get_embeddings');
  @llama_get_embeddings_ith := GetProcAddress(ALibAddr,
    'llama_get_embeddings_ith');
  @llama_get_embeddings_seq := GetProcAddress(ALibAddr,
    'llama_get_embeddings_seq');
  @llama_token_get_text := GetProcAddress(ALibAddr, 'llama_token_get_text');
  @llama_token_get_score := GetProcAddress(ALibAddr, 'llama_token_get_score');
  @llama_token_get_attr := GetProcAddress(ALibAddr, 'llama_token_get_attr');
  @llama_token_is_eog := GetProcAddress(ALibAddr, 'llama_token_is_eog');
  @llama_token_is_control := GetProcAddress(ALibAddr, 'llama_token_is_control');
  @llama_token_bos := GetProcAddress(ALibAddr, 'llama_token_bos');
  @llama_token_eos := GetProcAddress(ALibAddr, 'llama_token_eos');
  @llama_token_eot := GetProcAddress(ALibAddr, 'llama_token_eot');
  @llama_token_cls := GetProcAddress(ALibAddr, 'llama_token_cls');
  @llama_token_sep := GetProcAddress(ALibAddr, 'llama_token_sep');
  @llama_token_nl := GetProcAddress(ALibAddr, 'llama_token_nl');
  @llama_token_pad := GetProcAddress(ALibAddr, 'llama_token_pad');
  @llama_add_bos_token := GetProcAddress(ALibAddr, 'llama_add_bos_token');
  @llama_add_eos_token := GetProcAddress(ALibAddr, 'llama_add_eos_token');
  @llama_token_prefix := GetProcAddress(ALibAddr, 'llama_token_prefix');
  @llama_token_middle := GetProcAddress(ALibAddr, 'llama_token_middle');
  @llama_token_suffix := GetProcAddress(ALibAddr, 'llama_token_suffix');
  @llama_token_fim_pre := GetProcAddress(ALibAddr, 'llama_token_fim_pre');
  @llama_token_fim_suf := GetProcAddress(ALibAddr, 'llama_token_fim_suf');
  @llama_token_fim_mid := GetProcAddress(ALibAddr, 'llama_token_fim_mid');
  @llama_token_fim_pad := GetProcAddress(ALibAddr, 'llama_token_fim_pad');
  @llama_token_fim_rep := GetProcAddress(ALibAddr, 'llama_token_fim_rep');
  @llama_token_fim_sep := GetProcAddress(ALibAddr, 'llama_token_fim_sep');
  @llama_tokenize := GetProcAddress(ALibAddr, 'llama_tokenize');
  @llama_token_to_piece := GetProcAddress(ALibAddr, 'llama_token_to_piece');
  @llama_detokenize := GetProcAddress(ALibAddr, 'llama_detokenize');
  @llama_chat_apply_template := GetProcAddress(ALibAddr,
    'llama_chat_apply_template');
  @llama_sampler_name := GetProcAddress(ALibAddr, 'llama_sampler_name');
  @llama_sampler_accept := GetProcAddress(ALibAddr, 'llama_sampler_accept');
  @llama_sampler_apply := GetProcAddress(ALibAddr, 'llama_sampler_apply');
  @llama_sampler_reset := GetProcAddress(ALibAddr, 'llama_sampler_reset');
  @llama_sampler_clone := GetProcAddress(ALibAddr, 'llama_sampler_clone');
  @llama_sampler_free := GetProcAddress(ALibAddr, 'llama_sampler_free');
  @llama_sampler_chain_init := GetProcAddress(ALibAddr,
    'llama_sampler_chain_init');
  @llama_sampler_chain_add := GetProcAddress(ALibAddr,
    'llama_sampler_chain_add');
  @llama_sampler_chain_get := GetProcAddress(ALibAddr,
    'llama_sampler_chain_get');
  @llama_sampler_chain_n := GetProcAddress(ALibAddr, 'llama_sampler_chain_n');
  @llama_sampler_chain_remove := GetProcAddress(ALibAddr,
    'llama_sampler_chain_remove');
  @llama_sampler_init_greedy := GetProcAddress(ALibAddr,
    'llama_sampler_init_greedy');
  @llama_sampler_init_dist := GetProcAddress(ALibAddr,
    'llama_sampler_init_dist');
  @llama_sampler_init_softmax := GetProcAddress(ALibAddr,
    'llama_sampler_init_softmax');
  @llama_sampler_init_top_k := GetProcAddress(ALibAddr,
    'llama_sampler_init_top_k');
  @llama_sampler_init_top_p := GetProcAddress(ALibAddr,
    'llama_sampler_init_top_p');
  @llama_sampler_init_min_p := GetProcAddress(ALibAddr,
    'llama_sampler_init_min_p');
  @llama_sampler_init_typical := GetProcAddress(ALibAddr,
    'llama_sampler_init_typical');
  @llama_sampler_init_temp := GetProcAddress(ALibAddr,
    'llama_sampler_init_temp');
  @llama_sampler_init_temp_ext := GetProcAddress(ALibAddr,
    'llama_sampler_init_temp_ext');
  @llama_sampler_init_xtc := GetProcAddress(ALibAddr, 'llama_sampler_init_xtc');
  @llama_sampler_init_mirostat := GetProcAddress(ALibAddr,
    'llama_sampler_init_mirostat');
  @llama_sampler_init_mirostat_v2 := GetProcAddress(ALibAddr,
    'llama_sampler_init_mirostat_v2');
  @llama_sampler_init_grammar := GetProcAddress(ALibAddr,
    'llama_sampler_init_grammar');
  @llama_sampler_init_penalties := GetProcAddress(ALibAddr,
    'llama_sampler_init_penalties');
  @llama_sampler_init_dry := GetProcAddress(ALibAddr, 'llama_sampler_init_dry');
  @llama_sampler_init_logit_bias := GetProcAddress(ALibAddr,
    'llama_sampler_init_logit_bias');
  @llama_sampler_init_infill := GetProcAddress(ALibAddr,
    'llama_sampler_init_infill');
  @llama_sampler_get_seed := GetProcAddress(ALibAddr, 'llama_sampler_get_seed');
  @llama_sampler_sample := GetProcAddress(ALibAddr, 'llama_sampler_sample');
  @llama_split_path := GetProcAddress(ALibAddr, 'llama_split_path');
  @llama_split_prefix := GetProcAddress(ALibAddr, 'llama_split_prefix');
  @llama_print_system_info := GetProcAddress(ALibAddr,
    'llama_print_system_info');
  @llama_log_set := GetProcAddress(ALibAddr, 'llama_log_set');
  @llama_perf_context := GetProcAddress(ALibAddr, 'llama_perf_context');
  @llama_perf_context_print := GetProcAddress(ALibAddr,
    'llama_perf_context_print');
  @llama_perf_context_reset := GetProcAddress(ALibAddr,
    'llama_perf_context_reset');
  @llama_perf_sampler := GetProcAddress(ALibAddr, 'llama_perf_sampler');
  @llama_perf_sampler_print := GetProcAddress(ALibAddr,
    'llama_perf_sampler_print');
  @llama_perf_sampler_reset := GetProcAddress(ALibAddr,
    'llama_perf_sampler_reset');
end;

{ TLlamaApi }

class constructor TLlamaApi.Create;
begin
  FInstance := TLlamaApi.Create();
end;

class destructor TLlamaApi.Destroy;
begin
  FInstance.Free();
end;

end.
