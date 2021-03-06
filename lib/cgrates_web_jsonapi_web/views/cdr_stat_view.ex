defmodule CgratesWebJsonapiWeb.CdrStatView do
  use CgratesWebJsonapiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :date,
    :total_usage,
    :usage_avg,
    :total_cost,
    :total_count,
    :total_errors,
    :total_unspecified_disconnects,
    :total_normal_clearing_disconnects,
    :total_rejected_disconnects
  ])
end
