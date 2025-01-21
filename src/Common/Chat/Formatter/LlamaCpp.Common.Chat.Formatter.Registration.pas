unit LlamaCpp.Common.Chat.Formatter.Registration;

interface

type
  TChatFormatterRegistration = class
  public
    class procedure RegisterAll();
    class procedure UnregisterAll();
  end;

implementation

uses
  LlamaCpp.Common.Chat.Completion.Collection,
  LlamaCpp.Common.Chat.Formatter.Adapter,
  LlamaCpp.Common.Chat.Formatter.Llama2,
  LlamaCpp.Common.Chat.Formatter.Llama3,
  LlamaCpp.Common.Chat.Formatter.Alpaca,
  LlamaCpp.Common.Chat.Formatter.Qwen,
  LlamaCpp.Common.Chat.Formatter.Vicuna,
  LlamaCpp.Common.Chat.Formatter.OasstLlama,
  LlamaCpp.Common.Chat.Formatter.Baichuan,
  LlamaCpp.Common.Chat.Formatter.Baichuan2,
  LlamaCpp.Common.Chat.Formatter.OpenBuddy,
  LlamaCpp.Common.Chat.Formatter.RedpajamaIncite,
  LlamaCpp.Common.Chat.Formatter.Snoozy,
  LlamaCpp.Common.Chat.Formatter.Phind,
  LlamaCpp.Common.Chat.Formatter.Intel,
  LlamaCpp.Common.Chat.Formatter.OpenOrca,
  LlamaCpp.Common.Chat.Formatter.MilstralLite,
  LlamaCpp.Common.Chat.Formatter.Zephyr,
  LlamaCpp.Common.Chat.Formatter.Pygmalion,
  LlamaCpp.Common.Chat.Formatter.Chatml,
  LlamaCpp.Common.Chat.Formatter.MistralInstruct,
  LlamaCpp.Common.Chat.Formatter.ChatGLM3,
  LlamaCpp.Common.Chat.Formatter.OpenChat,
  LlamaCpp.Common.Chat.Formatter.Saiga,
  LlamaCpp.Common.Chat.Formatter.Gemma;

{ TChatFormatterRegistration }

class procedure TChatFormatterRegistration.RegisterAll;
begin
  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'llama-2', TChatFormaterAdapter.ToChatCompletionHandler(
      TLlama2ChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'llama-3', TChatFormaterAdapter.ToChatCompletionHandler(
      TLlama3ChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'alpaca', TChatFormaterAdapter.ToChatCompletionHandler(
      TAlpacaChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'qwen', TChatFormaterAdapter.ToChatCompletionHandler(
      TQwenChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'vicuna', TChatFormaterAdapter.ToChatCompletionHandler(
      TVicunaChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'oasst_llama', TChatFormaterAdapter.ToChatCompletionHandler(
      TOasstLlamaChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'baichuan', TChatFormaterAdapter.ToChatCompletionHandler(
      TBaichuanChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'baichuan-2', TChatFormaterAdapter.ToChatCompletionHandler(
      TBaichuan2ChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'openbuddy', TChatFormaterAdapter.ToChatCompletionHandler(
      TOpenBudyChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'redpajama-incite', TChatFormaterAdapter.ToChatCompletionHandler(
      TRedpajamaInciteChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'snoozy', TChatFormaterAdapter.ToChatCompletionHandler(
      TSnoozyChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'phind', TChatFormaterAdapter.ToChatCompletionHandler(
      TPhindChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'intel', TChatFormaterAdapter.ToChatCompletionHandler(
      TIntelChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'open-orca', TChatFormaterAdapter.ToChatCompletionHandler(
      TOpenOrcaChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'mistrallite', TChatFormaterAdapter.ToChatCompletionHandler(
      TMistralLiteChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'zephyr', TChatFormaterAdapter.ToChatCompletionHandler(
      TZephyrChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'pygmalion', TChatFormaterAdapter.ToChatCompletionHandler(
      TPygmalionChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'chatml', TChatFormaterAdapter.ToChatCompletionHandler(
      TChatmlChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'mistral-instruct', TChatFormaterAdapter.ToChatCompletionHandler(
      TMistralInstructChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'chatglm3', TChatFormaterAdapter.ToChatCompletionHandler(
      TChatGLM3ChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'openchat', TChatFormaterAdapter.ToChatCompletionHandler(
      TOpenChatChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'saiga', TChatFormaterAdapter.ToChatCompletionHandler(
      TSaigaChatFormatter.Create()));

  TLlamaChatCompletionCollection.Instance.RegisterChatCompletionHandler(
    'gemma', TChatFormaterAdapter.ToChatCompletionHandler(
      TGemmaChatFormatter.Create()));
end;

class procedure TChatFormatterRegistration.UnregisterAll;
begin
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('gemma');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('saiga');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('openchat');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('chatglm3');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('mistral-instruct');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('chatml');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('pygmalion');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('zephyr');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('mistrallite');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('open-orca');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('intel');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('phind');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('snoozy');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('redpajama-incite');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('openbuddy');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('baichuan-2');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('baichuan');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('oasst_llama');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('vicuna');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('qwen');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('alpaca');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('llama-3');
  TLlamaChatCompletionCollection.Instance.UnregisterChatHandler('llama-2');
end;

end.
