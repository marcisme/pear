defmodule Pear.Command do
  @callback accept?(event :: Map.t) :: boolean
  @callback execute(event :: Map.t, slack :: Map.t) :: :stop | :continue | { Atom.t, Atom.t, any }
end

