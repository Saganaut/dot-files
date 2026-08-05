if status is-interactive
# Commands to run in interactive sessions can go here
end

# Point lazydocker (and docker CLI) at the rootless Podman socket
set -gx DOCKER_HOST "unix://$XDG_RUNTIME_DIR/podman/podman.sock"
