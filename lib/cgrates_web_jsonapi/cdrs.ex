defmodule CgratesWebJsonapi.Cdrs do
  @moduledoc """
  CDRs context.
  """

  alias CgratesWebJsonapi.Repo
  alias CgratesWebJsonapi.Cdrs.Cdr
  alias CgratesWebJsonapi.Cdrs.CdrsStats
  use CgratesWebJsonapi.Cdrs.CdrFilter
  import Ecto.Query

  @type cgr_group :: :daily | :weekly | :monthly
  @type cdr_stat :: %{
          date: DateTime.t(),
          total_usage: Decimal.t(),
          usage_avg: Decimal.t(),
          total_cost: Decimal.t()
        }

  @doc """
  Aggregates some statistics from CDRs.

  ## Examples

      iex> aggregate_stats("daily", %{created_at_lte: datetime})
      [%CdrsStats{date: datetime, total_usage: decimal, usage_avg: decimal, total_cost: decimal, ...}, ...]
  """
  @spec aggregate_stats(cgr_group(), nil | map()) :: list(CdrsStats.t())
  def aggregate_stats(group, nil), do: aggregate_stats(group, %{})

  def aggregate_stats(group, filter) do
    Cdr
    |> group_by_created_at(group)
    |> select([r], %{
      date: fragment("MIN(created_at) as date"),
      total_usage: sum(r.usage),
      usage_avg: avg(r.usage),
      total_cost: fragment("sum(cost) filter (where cost >= 0)"),
      total_count: count(r.id),
      total_errors: fragment("count(id) filter (where cost < 0)")
    })
    |> where(run_id: "*default")
    |> apply_filter(filter)
    |> order_by(fragment("date"))
    |> Repo.all()
    |> Enum.map(&CdrsStats.new/1)
  end

  defp group_by_created_at(q, :daily) do
    q |> group_by([r], fragment("date_trunc('day', ?)", r.created_at))
  end

  defp group_by_created_at(q, :weekly) do
    q |> group_by([r], fragment("date_trunc('week', ?)", r.created_at))
  end

  defp group_by_created_at(q, :monthly) do
    q |> group_by([r], fragment("date_trunc('month', ?)", r.created_at))
  end
end
