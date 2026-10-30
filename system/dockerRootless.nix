{
  # Rootless, so the docker socket isn't root-equivalent and container root
  # maps to the user (files written to bind mounts keep their ownership).
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}
