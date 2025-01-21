unit LlamaCpp.CType.Llama;

interface

uses
  LlamaCpp.CType.Ggml,
  LlamaCpp.CType.Ggml.Backend;

type
  TLlama = class
  private
    class function GetMaxDevices: Integer; static;
  public const
    LLAMA_DEFAULT_SEED = $FFFFFFFF;
    LLAMA_TOKEN_NULL = -1;
    LLAMA_FILE_MAGIC_GGLA = $67676C61;
    LLAMA_FILE_MAGIC_GGSN = $6767736E;
    LLAMA_FILE_MAGIC_GGSQ = $67677371;
    LLAMA_SESSION_MAGIC = $6767736E;
    LLAMA_SESSION_VERSION = 9;
    LLAMA_STATE_SEQ_MAGIC = $67677371;
    LLAMA_STATE_SEQ_VERSION = 2;
  public
    class property LLAMA_MAX_DEVICES: Integer read GetMaxDevices;
  end;

  // struct llama_model;
  PLlamaModel = Pointer;
  // struct llama_context;
  PLlamaContext = Pointer;

  // typedef int32_t llama_pos;
  PLlamaPos = ^TLlamaPos;
  TLlamaPos = Int32;
  // typedef int32_t llama_token;
  PLLamaToken = ^TLlamaToken;
  TLlamaToken = Int32;
  // typedef int32_t llama_seq_id;
  PPLlamaSeqId = ^PLlamaSeqId;
  PLlamaSeqId = ^TLlamaSeqId;
  TLlamaSeqId = Int32;

  PLogitArray = ^TLogitArray;
  TLogitArray = array[0..0] of Single;

  PLlamaTokenArray = ^TLlamaTokenArray;
  TLlamaTokenArray = array[0..0] of TLlamaToken;
  PEmbdArray = ^TEmbdArray;
  TEmbdArray = array[0..0] of Single;
  PPosArray = ^TPosArray;
  TPosArray = array[0..0] of TLlamaPos;
  PNSeqIdArray = ^TNSeqIdArray;
  TNSeqIdArray = array[0..0] of integer;

  PSeqIdArray1D = ^TSeqIdArray1D;
  PSeqIdArray2D = ^TSeqIdArray2D;
  PSeqIdArray = PSeqIdArray2D;
  TSeqIdArray1D = array[0..0] of TLlamaSeqId;
  TSeqIdArray2D = array[0..0] of PSeqIdArray1D;
  PShortLogitArray = ^TShortLogitArray;
  TShortLogitArray = array[0..0] of ShortInt;
  PTensorSplit = ^TTensorSplit;
  TTensorSplit = array[0..0] of Single; { TODO : Check type mapping }

  {$MINENUMSIZE 4}
  TLlamaVocabType = (
    LLAMA_VOCAB_TYPE_NONE = 0, // For models without vocab
    LLAMA_VOCAB_TYPE_SPM  = 1, // LLaMA tokenizer based on byte-level BPE with byte fallback
    LLAMA_VOCAB_TYPE_BPE  = 2, // GPT-2 tokenizer based on byte-level BPE
    LLAMA_VOCAB_TYPE_WPM  = 3, // BERT tokenizer based on WordPiece
    LLAMA_VOCAB_TYPE_UGM  = 4, // T5 tokenizer based on Unigram
    LLAMA_VOCAB_TYPE_RWKV = 5  // RWKV tokenizer based on greedy tokenization
  );

  TLlamaVocabPreType = (
    LLAMA_VOCAB_PRE_TYPE_DEFAULT        = 0,  // Default pre-tokenization type
    LLAMA_VOCAB_PRE_TYPE_LLAMA3         = 1,  // Pre-tokenization for LLaMA3
    LLAMA_VOCAB_PRE_TYPE_DEEPSEEK_LLM   = 2,  // DeepSeek LLM tokenizer
    LLAMA_VOCAB_PRE_TYPE_DEEPSEEK_CODER = 3,  // DeepSeek Coder tokenizer
    LLAMA_VOCAB_PRE_TYPE_FALCON         = 4,  // Falcon tokenizer
    LLAMA_VOCAB_PRE_TYPE_MPT            = 5,  // MPT tokenizer
    LLAMA_VOCAB_PRE_TYPE_STARCODER      = 6,  // StarCoder tokenizer
    LLAMA_VOCAB_PRE_TYPE_GPT2           = 7,  // GPT-2 tokenizer
    LLAMA_VOCAB_PRE_TYPE_REFACT         = 8,  // ReFact tokenizer
    LLAMA_VOCAB_PRE_TYPE_COMMAND_R      = 9,  // Command-R tokenizer
    LLAMA_VOCAB_PRE_TYPE_STABLELM2      = 10, // StableLM v2 tokenizer
    LLAMA_VOCAB_PRE_TYPE_QWEN2          = 11, // QWEN v2 tokenizer
    LLAMA_VOCAB_PRE_TYPE_OLMO           = 12, // Olmo tokenizer
    LLAMA_VOCAB_PRE_TYPE_DBRX           = 13, // DBRX tokenizer
    LLAMA_VOCAB_PRE_TYPE_SMAUG          = 14, // Smaug tokenizer
    LLAMA_VOCAB_PRE_TYPE_PORO           = 15, // Poro tokenizer
    LLAMA_VOCAB_PRE_TYPE_CHATGLM3       = 16, // ChatGLM v3 tokenizer
    LLAMA_VOCAB_PRE_TYPE_CHATGLM4       = 17, // ChatGLM v4 tokenizer
    LLAMA_VOCAB_PRE_TYPE_VIKING         = 18, // Viking tokenizer
    LLAMA_VOCAB_PRE_TYPE_JAIS           = 19, // Jais tokenizer
    LLAMA_VOCAB_PRE_TYPE_TEKKEN         = 20, // Tekken tokenizer
    LLAMA_VOCAB_PRE_TYPE_SMOLLM         = 21, // Smollm tokenizer
    LLAMA_VOCAB_PRE_TYPE_CODESHELL      = 22, // CodeShell tokenizer
    LLAMA_VOCAB_PRE_TYPE_BLOOM          = 23, // Bloom tokenizer
    LLAMA_VOCAB_PRE_TYPE_GPT3_FINNISH   = 24, // GPT-3 Finnish tokenizer
    LLAMA_VOCAB_PRE_TYPE_EXAONE         = 25, // ExaOne tokenizer
    LLAMA_VOCAB_PRE_TYPE_CHAMELEON      = 26  // Chameleon tokenizer
  );

  TLlamaRopeType = (
    LLAMA_ROPE_TYPE_NONE = -1,  // No rope type
    LLAMA_ROPE_TYPE_NORM =  0,  // Normal rope type
    LLAMA_ROPE_TYPE_NEOX = TGgml.GGML_ROPE_TYPE_NEOX // Neox rope type (maps to an external constant or definition)
  );

  TLlamaTokenType = (
    LLAMA_TOKEN_TYPE_UNDEFINED    = 0, // Undefined token type
    LLAMA_TOKEN_TYPE_NORMAL       = 1, // Normal token
    LLAMA_TOKEN_TYPE_UNKNOWN      = 2, // Unknown token
    LLAMA_TOKEN_TYPE_CONTROL      = 3, // Control token
    LLAMA_TOKEN_TYPE_USER_DEFINED = 4, // User-defined token
    LLAMA_TOKEN_TYPE_UNUSED       = 5, // Unused token
    LLAMA_TOKEN_TYPE_BYTE         = 6  // Byte token
  );

  TLlamaTokenAttr = (
    LLAMA_TOKEN_ATTR_UNDEFINED    = 0,      // Undefined attribute
    LLAMA_TOKEN_ATTR_UNKNOWN      = 1 shl 0, // Unknown attribute
    LLAMA_TOKEN_ATTR_UNUSED       = 1 shl 1, // Unused attribute
    LLAMA_TOKEN_ATTR_NORMAL       = 1 shl 2, // Normal attribute
    LLAMA_TOKEN_ATTR_CONTROL      = 1 shl 3, // Control attribute (SPECIAL?)
    LLAMA_TOKEN_ATTR_USER_DEFINED = 1 shl 4, // User-defined attribute
    LLAMA_TOKEN_ATTR_BYTE         = 1 shl 5, // Byte attribute
    LLAMA_TOKEN_ATTR_NORMALIZED   = 1 shl 6, // Normalized attribute
    LLAMA_TOKEN_ATTR_LSTRIP       = 1 shl 7, // Left strip attribute
    LLAMA_TOKEN_ATTR_RSTRIP       = 1 shl 8, // Right strip attribute
    LLAMA_TOKEN_ATTR_SINGLE_WORD  = 1 shl 9  // Single word attribute
  );

  TLlamaFType = (
    LLAMA_FTYPE_ALL_F32              = 0,   // All tensors in F32
    LLAMA_FTYPE_MOSTLY_F16           = 1,   // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q4_0          = 2,   // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q4_1          = 3,   // Except 1D tensors
    // LLAMA_FTYPE_MOSTLY_Q4_1_SOME_F16 = 4, // tok_embeddings.weight and output.weight are F16
    // LLAMA_FTYPE_MOSTLY_Q4_2       = 5,   // Support has been removed
    // LLAMA_FTYPE_MOSTLY_Q4_3       = 6,   // Support has been removed
    LLAMA_FTYPE_MOSTLY_Q8_0          = 7,   // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q5_0          = 8,   // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q5_1          = 9,   // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q2_K          = 10,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q3_K_S        = 11,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q3_K_M        = 12,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q3_K_L        = 13,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q4_K_S        = 14,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q4_K_M        = 15,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q5_K_S        = 16,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q5_K_M        = 17,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q6_K          = 18,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_IQ2_XXS       = 19,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_IQ2_XS        = 20,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q2_K_S        = 21,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_IQ3_XS        = 22,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_IQ3_XXS       = 23,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_IQ1_S         = 24,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_IQ4_NL        = 25,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_IQ3_S         = 26,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_IQ3_M         = 27,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_IQ2_S         = 28,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_IQ2_M         = 29,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_IQ4_XS        = 30,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_IQ1_M         = 31,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_BF16          = 32,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q4_0_4_4      = 33,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q4_0_4_8      = 34,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_Q4_0_8_8      = 35,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_TQ1_0         = 36,  // Except 1D tensors
    LLAMA_FTYPE_MOSTLY_TQ2_0         = 37,  // Except 1D tensors

    LLAMA_FTYPE_GUESSED              = 1024 // Not specified in the model file
  );

  TLlamaRopeScalingType = (
    LLAMA_ROPE_SCALING_TYPE_UNSPECIFIED = -1,
    LLAMA_ROPE_SCALING_TYPE_NONE        = 0,
    LLAMA_ROPE_SCALING_TYPE_LINEAR      = 1,
    LLAMA_ROPE_SCALING_TYPE_YARN        = 2,
    LLAMA_ROPE_SCALING_TYPE_LONGROPE    = 3,
    LLAMA_ROPE_SCALING_TYPE_MAX_VALUE   = Integer(LLAMA_ROPE_SCALING_TYPE_LONGROPE)
  );

  TLlamaPoolingType = (
    LLAMA_POOLING_TYPE_UNSPECIFIED = -1,
    LLAMA_POOLING_TYPE_NONE = 0,
    LLAMA_POOLING_TYPE_MEAN = 1,
    LLAMA_POOLING_TYPE_CLS  = 2,
    LLAMA_POOLING_TYPE_LAST = 3,
    LLAMA_POOLING_TYPE_RANK = Integer(4)  // used by reranking models to attach the classification head to the graph
  );

  TLlamaAttentionType = (
    LLAMA_ATTENTION_TYPE_UNSPECIFIED = -1,
    LLAMA_ATTENTION_TYPE_CAUSAL      = 0,
    LLAMA_ATTENTION_TYPE_NON_CAUSAL  = Integer(1)
  );

  TLlamaSplitMode = (
    LLAMA_SPLIT_MODE_NONE  = 0, // single GPU
    LLAMA_SPLIT_MODE_LAYER = 1, // split layers and KV across GPUs
    LLAMA_SPLIT_MODE_ROW   = 2  // split rows across GPUs
  );
  {$MINENUMSIZE 1}

  PLlamaTokenData = ^TLlamaTokenData;
  TLlamaTokenData = record
    Id: TLlamaToken; // token id
    Logit: Single;   // log-odds of the token
    P: Single;       // probability of the token
  end;

  PLlamaTokenDataArray = ^TLlamaTokenDataArray;
  TLlamaTokenDataArray = record
    // TODO: consider SoA
    // NOTE: this pointer can be modified by the samplers
    data: PLlamaTokenData;  // pointer to array of TLLamaTokenData
    size: NativeInt;        // size of the array
    selected: Int64;        // this is the index in the data array (i.e. not the token id)
    sorted: Boolean;        // indicates if the array is sorted
  end;

  TLlamaProgressCallback = function(const AProgress: single;
      const AUserData: pointer): boolean; cdecl;

  //A llama_batch object can contain input about one or many sequences
  //The provided arrays (i.e. token, embd, pos, etc.) must have size of n_tokens
  //Attributes:
  //  n_tokens: number of tokens
  //  token: the token ids of the input (used when embd is NULL)
  //  embd: token embeddings (i.e. float vector of size n_embd) (used when token is NULL)
  //  pos: the positions of the respective token in the sequence
  //  seq_id: the sequence to which the respective token belongs
  //  logits: if zero, the logits for the respective token will not be output

  PLlamaBatch = ^TLLamaBatch;
  TLlamaBatch = record
  public
    n_tokens: Int32;
    token: PLlamaTokenArray;
    embd: PEmbdArray;
    pos: PPosArray;
    n_seq_id: PNSeqIdArray;
    seq_id: PSeqIdArray;
    logits: PShortLogitArray;  // TODO: rename this to "output"
  end;

  TLlamaModelKvOverrideType = (
    LLAMA_KV_OVERRIDE_TYPE_INT   = 0,    // Integer type
    LLAMA_KV_OVERRIDE_TYPE_FLOAT = 1,  // Float type
    LLAMA_KV_OVERRIDE_TYPE_BOOL  = 2,   // Boolean type
    LLAMA_KV_OVERRIDE_TYPE_STR   = 3    // String type
  );

  TLLamaModelKVOverrideValueString = array[0..127] of AnsiChar;
  TLLamaModelKVOverrideValue = record
    case Integer of
      0: (ValInt64: Int64);                   // Integer value
      1: (ValFloat64: Double);                // Floating-point value
      2: (ValBool: Boolean);                  // Boolean value
      3: (ValStr: TLLamaModelKVOverrideValueString); // String value
  end;

  TLlamaModelKVOverrideKey = array[0..127] of AnsiChar;
  PLlamaModelKVOverride = ^TLlamaModelKVOverride;
  TLlamaModelKVOverride = record
    Tag: TLLamaModelKVOverrideType;
    Key: TLlamaModelKVOverrideKey;
    Value: TLLamaModelKVOverrideValue;
  end;

  PTLlamaModelKVOverrideArray = ^TLlamaModelKVOverrideArray;
  TLlamaModelKVOverrideArray = array[0..0] of TLlamaModelKVOverride;

  TLlamaModelParams = record
    devices: pointer;
    NGpuLayers: Int32;                  // Number of layers to store in VRAM
    SplitMode: TLlamaSplitMode;         // Split mode for multiple GPUs
    MainGpu: Int32;                     // GPU used for the entire model in LLAMA_SPLIT_MODE_NONE
    TensorSplit: PTensorSplit;          // Pointer to proportions of model offloaded to each GPU
    RpcServers: PAnsiChar;              // Comma-separated list of RPC servers
    ProgressCallback: TLlamaProgressCallback; // Callback for progress updates
    ProgressCallbackUserData: Pointer;  // Context pointer for the callback
    KVOverrides: PTLlamaModelKVOverrideArray; // Pointer to key-value metadata overrides
    VocabOnly: Boolean;                 // Load only the vocabulary, no weights
    UseMMap: Boolean;                   // Use memory mapping if possible
    UseMLock: Boolean;                  // Force system to keep the model in RAM
    CheckTensors: Boolean;              // Validate model tensor data
  end;

  TLlamaContextParams = record
    NContext: UInt32;               // Text context, 0 = from model
    NBatch: UInt32;                 // Logical maximum batch size for llama_decode
    NUBatch: UInt32;                // Physical maximum batch size
    NSeqMax: UInt32;                // Max number of sequences for recurrent models
    NThreads: Int32;                // Threads for generation
    NThreadsBatch: Int32;           // Threads for batch processing

    RopeScalingType: TLlamaRopeScalingType; // RoPE scaling type
    PoolingType: TLlamaPoolingType;         // Pooling type for embedding results
    AttentionType: TLlamaAttentionType;     // Attention type for embeddings

    RopeFreqBase: Single;           // RoPE base frequency, 0 = from model
    RopeFreqScale: Single;          // RoPE frequency scaling factor, 0 = from model
    YarnExtFactor: Single;          // YaRN extrapolation mix factor, negative = from model
    YarnAttnFactor: Single;         // YaRN magnitude scaling factor
    YarnBetaFast: Single;           // YaRN low correction dimension
    YarnBetaSlow: Single;           // YaRN high correction dimension
    YarnOrigCtx: UInt32;            // YaRN original context size
    DefragThreshold: Single;        // Defragment KV cache threshold, < 0 disabled

    EvalCallback: TGgmlBackendSchedEvalCallback; // Evaluation callback
    EvalCallbackUserData: Pointer;              // Context for eval callback

    TypeK: TGgmlType;               // Data type for K cache [EXPERIMENTAL]
    TypeV: TGgmlType;               // Data type for V cache [EXPERIMENTAL]

    // Booleans at the end to ensure alignment
    LogitsAll: Boolean;             // Compute all logits, not just the last one (DEPRECATED)
    Embeddings: Boolean;     // Extract embeddings together with logits
    OffloadKQV: Boolean;            // Offload KQV operations to GPU
    FlashAttn: Boolean;     // Use flash attention [EXPERIMENTAL]
    NoPerformance: Boolean;         // Disable performance measurements

    AbortCallback: TGgmlAbortCallback; // Abort callback
    AbortCallbackData: Pointer;       // Context for abort callback
  end;

  TLlamaLogCallback = procedure(const ALevel: TGgmlLogLevel;
    const AText: PAnsiChar; const AUserData: Pointer); cdecl;

  PLlamaModelQuantizeParams = ^TLlamaModelQuantizeParams;
  TLlamaModelQuantizeParams = record
    nthread: Int32;                      // Number of threads to use for quantizing
    ftype: TllamaFtype;                  // Quantize to this llama_ftype
    output_tensor_type: TGgmlType;       // Output tensor type
    token_embedding_type: TGgmlType;     // Token embeddings tensor type
    allow_requantize: Boolean;           // Allow quantizing non-f32/f16 tensors
    quantize_output_tensor: Boolean;     // Quantize output.weight
    only_copy: Boolean;                  // Only copy tensors, ignoring other settings
    pure: Boolean;                       // Quantize all tensors to the default type
    keep_split: Boolean;                 // Quantize to the same number of shards
    imatrix: Pointer;                    // Pointer to importance matrix data
    kv_overrides: Pointer;               // Pointer to vector containing overrides
  end;

  PLlamaLogitBias = ^TLlamaLogitBias;
  TLlamaLogitBias = record
    Token: TLlamaToken; // Type for tokens (define TllamaToken based on your project requirements)
    Bias: Single;       // Floating-point value for the bias
  end;

  PLlamaSamplerChainParams = ^TLlamaSamplerChainParams;
  TLlamaSamplerChainParams = record
    NoPerf: Boolean; // Whether to measure performance timings
  end;

  TLlamaChatMessage = record
    Role: PAnsiChar;
    Content: PAnsiChar;
  end;

  // struct llama_model;
  PLlamaLoraAdapter = ^TLlamaLoraAdapter;
  TLlamaLoraAdapter = NativeUInt;

  PLlamaKvCacheViewCell = ^TLlamaKvCacheViewCell;
  TLlamaKvCacheViewCell = record
    pos: TLlamaPos;
  end;

  PLlamaKvCacheView = ^TLlamaKvCacheView;
  TLlamaKvCacheView = record
    n_cells: Integer;             // int32_t
    n_seq_max: Integer;           // int32_t
    token_count: Integer;         // int32_t
    used_cells: Integer;          // int32_t
    max_contiguous: Integer;      // int32_t
    max_contiguous_idx: Integer;  // int32_t
    cells: PLlamaKvCacheViewCell; // Pointer to array of llama_kv_cache_view_cell
    cells_sequences: ^PLlamaSeqId; // Pointer to array of llama_seq_id
  end;

  TLlamaSamplerContext = Pointer;
  PLlamaSampler = ^TLlamaSampler;    // Pointer to TLlamaSampler

  TLLamaSamplerName = function(const ASmpl: PLlamaSampler): PAnsiChar; cdecl;
  TLLamaSamplerAccept = procedure(ASmpl: PLlamaSampler; AToken: TLLamaToken); cdecl;
  TLLamaSamplerApply = procedure(ASmpl: PLlamaSampler; ACurrProb: PLlamaTokenDataArray); cdecl; // ACurrProb is a pointer to the llama_token_data_array structure
  TLLamaSamplerReset = procedure(ASmpl: PLlamaSampler); cdecl;
  TLLamaSamplerClone = function(const ASmpl: PLlamaSampler): PLlamaSampler; cdecl;
  TLLamaSamplerFree = procedure(ASmpl: PLlamaSampler); cdecl;

  PLlamaSamplerI = ^TLlamaSamplerI;
  TLlamaSamplerI = record
    Name: TLLamaSamplerName;        // Can be NULL
    Accept: TLLamaSamplerAccept;    // Can be NULL
    Apply: TLLamaSamplerApply;      // Required
    Reset: TLLamaSamplerReset;      // Can be NULL
    Clone: TLLamaSamplerClone;      // Can be NULL if context is NULL
    Free: TLLamaSamplerFree;        // Can be NULL if context is NULL
  end;

  TLlamaSampler = record
    Iface: PLlamaSamplerI;           // Pointer to TLlamaSamplerI
    Ctx: TLlamaSamplerContext;      // Defined as Pointer for llama_sampler_context_t
  end;

  TLLamaPerfContextData = record
    t_start_ms: Double;
    t_load_ms: Double;
    t_p_eval_ms: Double;
    t_eval_ms: Double;
    n_p_eval: Int32;
    n_eval: Int32;
  end;

  TLLamaPerfSamplerData = record
    t_sample_ms: Double;
    n_sample: Int32;
  end;

implementation

uses
  LlamaCpp.Api.Llama;

{ TLlama }

class function TLlama.GetMaxDevices: Integer;
begin
  Result := TLlamaApi.Instance.llama_max_devices();
end;

end.

