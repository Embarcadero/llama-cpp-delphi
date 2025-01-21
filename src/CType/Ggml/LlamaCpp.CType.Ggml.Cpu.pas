unit LlamaCpp.CType.Ggml.Cpu;

interface

type
  {$MINENUMSIZE 4}
  TGGMLNumaStrategy = (
    GGML_NUMA_STRATEGY_DISABLED   = 0,
    GGML_NUMA_STRATEGY_DISTRIBUTE = 1,
    GGML_NUMA_STRATEGY_ISOLATE    = 2,
    GGML_NUMA_STRATEGY_NUMACTL    = 3,
    GGML_NUMA_STRATEGY_MIRROR     = 4,
    GGML_NUMA_STRATEGY_COUNT
  );
  {$MINENUMSIZE 1}

implementation

end.
