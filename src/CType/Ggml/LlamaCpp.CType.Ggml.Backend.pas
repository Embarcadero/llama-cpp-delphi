unit LlamaCpp.CType.Ggml.Backend;

interface

type
  // Evaluation callback for each node in the graph (set with ggml_backend_sched_set_eval_callback)
  // when ask == true, the scheduler wants to know if the user wants to observe this node
  // this allows the scheduler to batch nodes together in order to evaluate them in a single call
  //
  // when ask == false, the scheduler is passing the node tensor to the user for observation
  // if the user returns false, the scheduler will cancel the graph compute
  //
  // typedef bool (*ggml_backend_sched_eval_callback)(struct ggml_tensor * t, bool ask, void * user_data);
  TGgmlBackendSchedEvalCallback = function(const AGgmlTensor: pointer;
    const AAsk: boolean; const AUserData: pointer): boolean; cdecl;

implementation

end.
