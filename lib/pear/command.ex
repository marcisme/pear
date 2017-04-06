defmodule Pear.Command do
  @callback accept?(type :: String.t) :: boolean
  @callback execute(message :: Map.t, slack :: Map.t) :: :stop | :continue | { Atom.t, Atom.t, any }
end

