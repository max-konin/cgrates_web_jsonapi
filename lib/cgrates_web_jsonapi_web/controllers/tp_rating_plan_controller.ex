defmodule CgratesWebJsonapiWeb.TpRatingPlanController do
  use CgratesWebJsonapiWeb, :controller
  use JaResource
  use CgratesWebJsonapi.TpSubresource
  use CgratesWebJsonapi.DefaultSorting
  use CgratesWebJsonapi.CsvExport
  use CgratesWebJsonapi.DeleteAll

  alias CgratesWebJsonapi.TariffPlans.TpRatingPlan

  plug JaResource

  def model(), do: TpRatingPlan

  def handle_show(conn, id), do: Repo.get!(TpRatingPlan, id)

  def filter(_conn, query, "tag", tag), do: query |> where([r], like(r.tag, ^"%#{tag}%"))

  def filter(_conn, query, "destrates_tag", tag),
    do: query |> where([r], like(r.destrates_tag, ^"%#{tag}%"))

  def filter(_conn, query, "timing_tag", tag),
    do: query |> where([r], like(r.timing_tag, ^"%#{tag}%"))

  def filter(_conn, query, "weight", weight), do: query |> where(weight: ^weight)

  defp build_query(conn, params) do
    conn
    |> handle_index(params)
    |> JaResource.Index.filter(conn, __MODULE__)
  end
end
