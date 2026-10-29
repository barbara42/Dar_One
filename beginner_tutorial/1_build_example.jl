using DarOne

MITgcm_path[1] = get(ENV, "DARONE_MITGCM_PATH", "/dar_one_docker/darwin3")

# you should only have to build once, and then be good to go! 
build(base_configuration)

# very basic setup and run to test the executable 
# (if this doesn't work, see "troubleshooting")