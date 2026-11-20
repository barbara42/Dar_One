using DarOne


# restore the 1x1 grid and freely cycling nutrients used by this tutorial
update_grid_size(1, 1)
hold_nutrients_constant(ones(19))

# you should only have to build once, and then be good to go! 
build(base_configuration)

# very basic setup and run to test the executable 
# (if this doesn't work, see "troubleshooting")