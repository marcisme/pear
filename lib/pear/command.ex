defmodule Pear.Command do
  @callback accept?(type :: String.t) :: boolean
  @callback execute(message :: Map.t, slack :: Map.t) :: :stop | nil
end

