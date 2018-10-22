defmodule CgratesWebJsonapi.TpAction do
  use CgratesWebJsonapi.Web, :model
  use EctoConditionals, repo: CgratesWebJsonapi.Repo

  alias CgratesWebJsonapi.TpAction

  schema "tp_actions" do
    field :tpid, :string
    field :tag, :string
    field :action, :string
    field :balance_tag, :string
    field :balance_type, :string
    field :directions, :string
    field :units, :string
    field :expiry_time, :string
    field :timing_tags, :string
    field :destination_tags, :string
    field :rating_subject, :string
    field :categories, :string
    field :shared_groups, :string
    field :balance_weight, :string
    field :balance_blocker, :string
    field :balance_disabled, :string
    field :extra_parameters, :string
    field :filter, :string
    field :weight, :decimal

    field :created_at, :naive_datetime
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:tpid, :tag, :action, :balance_tag, :balance_type, :directions, :units, :expiry_time, :timing_tags,
                     :destination_tags, :rating_subject, :categories, :shared_groups, :balance_weight, :balance_blocker,
                     :balance_disabled, :extra_parameters, :filter, :weight])
    |> validate_required([:tpid, :tag, :action, :balance_tag, :balance_type, :directions, :units, :expiry_time,
                          :timing_tags, :destination_tags, :rating_subject, :categories, :shared_groups,
                          :balance_weight, :balance_blocker, :balance_disabled, :extra_parameters, :filter, :weight])
    |> validate_length(:tpid, max: 64)
    |> validate_length(:tag, max: 64)
    |> validate_length(:action, max: 24)
    |> validate_length(:balance_tag, max: 64)
    |> validate_length(:balance_type, max: 24)
    |> validate_length(:directions, max: 8)
    |> validate_length(:expiry_time, max: 24)
    |> validate_length(:timing_tags, max: 128)
    |> validate_length(:destination_tags, max: 64)
    |> validate_length(:rating_subject, max: 64)
    |> validate_length(:categories, max: 32)
    |> validate_length(:shared_groups, max: 64)
    |> validate_length(:balance_weight, max: 10)
    |> validate_length(:balance_blocker, max: 5)
    |> validate_length(:balance_disabled, max: 24)
    |> unique_constraint(:tag, name: :tp_actions_tpid_tag_action_balance_tag_balance_type_directi_key)
  end

  @doc """
  Parses CSV file and inserts records to tp_actions table.
  """
  def from_csv(path, tpid) do
    path |> File.stream! |> CSV.decode!(headers: true) |> ParallelStream.map(fn (data) ->
      cs = %TpAction{}
      |> changeset(data |> Map.merge(%{"tpid" => tpid}))

      if cs.valid? do
        %TpAction{}
        |> Map.merge(cs |> Map.fetch!(:changes))
        |> upsert_by([:tpid, :tag, :action, :balance_tag, :balance_type, :directions, :units, :expiry_time,
                      :timing_tags, :destination_tags, :rating_subject, :categories, :shared_groups,
                      :balance_weight, :balance_blocker, :balance_disabled, :extra_parameters, :filter, :weight])
      else
        cs
      end
    end)
  end
end
