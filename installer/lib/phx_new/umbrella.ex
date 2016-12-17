defmodule Phx.New.Umbrella do
  @moduledoc false
  use Phx.New.Generator
  alias Mix.Tasks.Phx.New.{App, Web}
  alias Phx.New.{Project}

  template :new, [
    {:eex,  "phx_umbrella/config/config.exs", :project, "config/config.exs"},
    {:eex,  "phx_umbrella/mix.exs",           :project, "mix.exs"},
    {:eex,  "phx_umbrella/README.md",         :project, "README.md"},
  ]

  def prepare_project(%Project{app: app} = project) when not is_nil(app) do
    project
    |> put_app()
    |> put_web()
    |> put_root_app()
  end
  defp put_app(project) do
    project_path = Path.expand(project.base_path <> "_umbrella")
    app_path = Path.join(project_path, "apps/#{project.app}")

    %Project{project |
             in_umbrella?: true,
             app_path: app_path,
             project_path: project_path}
  end
  def put_web(%Project{} = project) do
    web_app = :"#{project.app}_web"

    %Project{project |
             web_app: web_app,
             web_namespace: Module.concat(project.app_mod, "Web"),
             web_path: Path.join(project.project_path, "apps/#{web_app}/")}
  end

  defp put_root_app(%Project{app: app} = project) do
    %Project{project |
             root_app: :"#{app}_umbrella",
             root_mod: Module.concat(project.app_mod, "Umbrella")}
  end

  def generate(%Project{} = project) do
    if in_umbrella?(project.project_path) do
      Mix.raise "unable to nest umbrella project within apps"
    end
    copy_from project, __MODULE__, template_files(:new)

    project
    |> Web.generate()
    |> App.generate()
  end
end
