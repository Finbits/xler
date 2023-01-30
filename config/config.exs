import Config

if Mix.env() in [:dev, :test] do
  config :xler, force_build: true
end
