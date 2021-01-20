defmodule CgratesWebJsonapiWeb.TpRouteView do
  use CgratesWebJsonapiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :pk,
    :tpid,
    :tenant,
    :route_id,
    :tp_route_id,
    :route_weight,
    :sorting,
    :sorting_parameters,
    :weight,
    :filter_ids,
    :activation_interval,
    :route_filter_ids,
    :route_account_ids,
    :route_ratingplan_ids,
    :route_resource_ids,
    :route_stat_ids,
    :route_blocker,
    :route_parameters
  ])
end
