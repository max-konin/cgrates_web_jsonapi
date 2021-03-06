defmodule CgratesWebJsonapi.TariffPlans.TpRatingPlanControllerTest do
  use CgratesWebJsonapi.ConnCase

  import CgratesWebJsonapi.Factory

  alias CgratesWebJsonapi.TariffPlans.TpRatingPlan
  alias CgratesWebJsonapi.Repo
  import CgratesWebJsonapi.Guardian

  setup do
    user = insert(:user)

    {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> put_req_header("authorization", "bearer: " <> token)

    {:ok, conn: conn}
  end

  test "lists all entries related tariff plan on index", %{conn: conn} do
    tariff_plan_1 = insert(:tariff_plan)
    tariff_plan_2 = insert(:tariff_plan)

    insert(:tp_rating_plan, tpid: tariff_plan_1.alias)
    insert(:tp_rating_plan, tpid: tariff_plan_2.alias)

    conn = get(conn, Routes.tp_rating_plan_path(conn, :index, tpid: tariff_plan_1.alias)) |> doc
    assert length(json_response(conn, 200)["data"]) == 1
  end

  test "filtering by tag", %{conn: conn} do
    tariff_plan = insert(:tariff_plan)

    t1 = insert(:tp_rating_plan, tpid: tariff_plan.alias)
    insert(:tp_rating_plan, tpid: tariff_plan.alias)

    conn =
      get(conn, Routes.tp_rating_plan_path(conn, :index, tpid: tariff_plan.alias),
        filter: %{tag: t1.tag}
      )
      |> doc

    assert length(json_response(conn, 200)["data"]) == 1
  end

  test "filtering by destrates_tag", %{conn: conn} do
    tariff_plan = insert(:tariff_plan)

    t1 = insert(:tp_rating_plan, tpid: tariff_plan.alias)
    insert(:tp_rating_plan, tpid: tariff_plan.alias)

    conn =
      get(conn, Routes.tp_rating_plan_path(conn, :index, tpid: tariff_plan.alias),
        filter: %{destrates_tag: t1.destrates_tag}
      )
      |> doc

    assert length(json_response(conn, 200)["data"]) == 1
  end

  test "filtering by timing_tag", %{conn: conn} do
    tariff_plan = insert(:tariff_plan)

    t1 = insert(:tp_rating_plan, tpid: tariff_plan.alias)
    insert(:tp_rating_plan, tpid: tariff_plan.alias)

    conn =
      get(conn, Routes.tp_rating_plan_path(conn, :index, tpid: tariff_plan.alias),
        filter: %{timing_tag: t1.timing_tag}
      )
      |> doc

    assert length(json_response(conn, 200)["data"]) == 1
  end

  test "filtering by weight", %{conn: conn} do
    tariff_plan = insert(:tariff_plan)

    t1 = insert(:tp_rating_plan, tpid: tariff_plan.alias, weight: 1.0)
    insert(:tp_rating_plan, tpid: tariff_plan.alias, weight: 2.1)

    conn =
      get(conn, Routes.tp_rating_plan_path(conn, :index, tpid: tariff_plan.alias),
        filter: %{weight: 1.0}
      )
      |> doc

    assert length(json_response(conn, 200)["data"]) == 1
  end

  test "shows chosen resource", %{conn: conn} do
    tariff_plan = insert(:tariff_plan)
    tp_rating_plan = insert(:tp_rating_plan, tpid: tariff_plan.alias)

    conn = get(conn, Routes.tp_rating_plan_path(conn, :show, tp_rating_plan)) |> doc
    data = json_response(conn, 200)["data"]
    assert data["id"] == "#{tp_rating_plan.id}"
    assert data["type"] == "tp-rating-plan"
    assert data["attributes"]["tpid"] == tp_rating_plan.tpid
    assert data["attributes"]["tag"] == tp_rating_plan.tag
    assert data["attributes"]["destrates-tag"] == tp_rating_plan.destrates_tag
    assert data["attributes"]["timing-tag"] == tp_rating_plan.timing_tag
    assert data["attributes"]["weight"] == "12.10"
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get(conn, Routes.tp_rating_plan_path(conn, :show, -1)) |> doc
    end
  end

  describe "GET export_to_csv" do
    test "returns status 'ok'", %{conn: conn} do
      tariff_plan = insert(:tariff_plan)

      insert(:tp_rating_plan, tpid: tariff_plan.alias, timing_tag: "timing_1", weight: 10)
      insert(:tp_rating_plan, tpid: tariff_plan.alias, timing_tag: "timing_2")

      conn =
        conn
        |> get(Routes.tp_rating_plan_path(conn, :export_to_csv), %{
          tpid: tariff_plan.alias,
          filter: %{timing_tag: "timing_2"}
        })
        |> doc()

      assert conn.status == 200
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    tariff_plan = insert(:tariff_plan)
    params = Map.merge(params_for(:tp_rating_plan), %{tpid: tariff_plan.alias})

    conn =
      post(conn, Routes.tp_rating_plan_path(conn, :create), %{
        "meta" => %{},
        "data" => %{
          "type" => "tp_rating_plan",
          "attributes" => params
        }
      })
      |> doc

    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(TpRatingPlan, params)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn =
      post(conn, Routes.tp_rating_plan_path(conn, :create), %{
        "meta" => %{},
        "data" => %{
          "type" => "tp-timing",
          "attributes" => %{tag: nil}
        }
      })
      |> doc

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    tariff_plan = insert(:tariff_plan)
    tp_rating_plan = insert(:tp_rating_plan, tpid: tariff_plan.alias)
    params = params_for(:tp_rating_plan)

    conn =
      put(conn, Routes.tp_rating_plan_path(conn, :update, tp_rating_plan), %{
        "meta" => %{},
        "data" => %{
          "type" => "tp_rating_plan",
          "id" => tp_rating_plan.id,
          "attributes" => params
        }
      })
      |> doc

    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(TpRatingPlan, params)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    tariff_plan = insert(:tariff_plan)
    tp_rating_plan = insert(:tp_rating_plan, tpid: tariff_plan.alias)

    conn =
      put(conn, Routes.tp_rating_plan_path(conn, :update, tp_rating_plan), %{
        "meta" => %{},
        "data" => %{
          "type" => "tp_rating_plan",
          "id" => tp_rating_plan.id,
          "attributes" => %{tag: nil}
        }
      })
      |> doc

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    tariff_plan = insert(:tariff_plan)
    tp_rating_plan = insert(:tp_rating_plan, tpid: tariff_plan.alias)

    conn = delete(conn, Routes.tp_rating_plan_path(conn, :delete, tp_rating_plan)) |> doc
    assert response(conn, 204)
    refute Repo.get(TpRatingPlan, tp_rating_plan.id)
  end

  test "deletes chosen resource with assosiated resources included", %{conn: conn} do
    tariff_plan = insert(:tariff_plan)
    tp_rating_plan = insert(:tp_rating_plan, tpid: tariff_plan.alias)

    tp_rating_profile =
      insert(:tp_rating_profile, tpid: tariff_plan.alias, rating_plan_tag: tp_rating_plan.tag)

    conn = delete(conn, Routes.tp_rating_plan_path(conn, :delete, tp_rating_plan))
    assert response(conn, 204)
    refute Repo.get(TpRatingPlan, tp_rating_plan.id)
    refute Repo.get(CgratesWebJsonapi.TariffPlans.TpRatingProfile, tp_rating_profile.id)
  end

  describe "DELETE delete_all" do
    test "deletes all records by filter", %{conn: conn} do
      tariff_plan = insert(:tariff_plan)

      tpr1 = insert(:tp_rating_plan, tpid: tariff_plan.alias, timing_tag: "timing_1", weight: 10)
      tpr2 = insert(:tp_rating_plan, tpid: tariff_plan.alias, timing_tag: "timing_2")

      conn =
        conn
        |> post(Routes.tp_rating_plan_path(conn, :delete_all), %{
          tpid: tariff_plan.alias,
          filter: %{timing_tag: "timing_2"}
        })

      assert Repo.get(TpRatingPlan, tpr1.id)
      refute Repo.get(TpRatingPlan, tpr2.id)
    end
  end
end
