ExUnit.start()
# ExUnit.configure exclude: [:acceptance]

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

  # https://elixirforum.com/t/how-to-stop-otp-processes-started-in-exunit-setup-callback/3794/5
  # defp assert_down(pid) do
  #   ref = Process.monitor(pid)
  #   assert_receive {:DOWN, ^ref, _, _, _}
  # end
end

defmodule Pear.TestHelpers do
  # Generate a module-specific value
  # Because Pear.Session processes are registered under a channel name,
  # they must be unique channel name to avoid concurrently executing
  # tests from interfering with each other.
  defmacro c(i) do
    quote do
      "#{__MODULE__}##{unquote(i)}"
    end
  end
end
