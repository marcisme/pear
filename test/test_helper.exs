ExUnit.start()
ExUnit.configure exclude: [:acceptance]

defmodule Pear.Assertions do
  defmacro eventually(timeout \\ 2_000, delay \\ 100, do: assertion) do
    quote do
      start = :os.system_time(:millisecond)
      Enum.reduce_while(1..100, 0, fn _, acc ->
        try do
          unquote(assertion)
          {:halt, acc}
        rescue
          e ->
            now = :os.system_time(:millisecond)
            cond do
              now - start < unquote(timeout) ->
                Process.sleep(unquote(delay))
                {:cont, acc}
              true ->
                raise e
            end
        end
      end)
    end
  end
end
