ExUnit.CaptureIO.capture_io(fn ->
  Mix.Task.run "ecto.drop", ["quiet", "-r", "Authql.Repo"]
  Mix.Task.run "ecto.create", ["quiet", "-r", "Authql.Repo"]
  Mix.Task.run "ecto.migrate", ["-r", "Authql.Repo"]
end)

Authql.Repo.start_link

ExUnit.start()
