using NCDatasets

"""
Methods related to creating and assigning the initial conditions 
for a grid of Dar1s. 

For a grid of size (X, Y), the initial conditions for each grid cell are
set in a binary file with X*Y number of floats, in big-endian format, with no headers.
"""

function write_init_bin_file(config_obj, folder_name, file_name, data)
    # write the data to a bin file 
    rundir = joinpath(config_obj.folder, config_obj.ID, "run")
    bin_folder = joinpath(rundir, "my_resources", folder_name)
    if !isdir(bin_folder)
        mkpath(bin_folder)
    end
    output_file = joinpath(bin_folder, file_name)
    open(output_file, "w") do io
        # note: hton -> convert to big-endian
        write(io, hton.(data))
    end
    return output_file
end

"""
    init_tracer_grid(config_obj, tracer_name, init_list, dim, grid_size=(5,3))

Create a bin file of initial values for a tracer. For a grid of size (X, Y), the initial conditions for each grid cell are
set in a binary file with X*Y number of floats, in big-endian format, with no headers.

# Arguments 
- config_obj
- tracer_name: String 
- init_list: list of values to initialize the tracer to 
- dim: "x" or "y" - which dimension to set to the list; values won't change along the other axis 
- grid_size: tuple ints, default 2x2

Returns 
- the matrix of initial values 
"""
function init_tracer_grid(config_obj, tracer_name, init_list, dim, grid_size=(2,2))
    # check that init_list is the same length as the dim of grid size
    if (length(init_list) != grid_size[1]) && (length(init_list) != grid_size[2])
        throw(ArgumentError("init_list must be the same length as one dimension of the grid"))
    end
    # create the matrix
    data = Matrix{Float32}(undef,grid_size...)
    if dim=="x"
        # the x-axis is assigned to the init_list
        # repeated over the y axis 
        data[:,:] = transpose(repeat(init_list,grid_size[2],1))
    elseif dim=="y"
        # the y-axis is assigned to the init_list
        # repeated over the x axis 
        data[:,:] = transpose(repeat(init_list,1,grid_size[1]))
    end
    output_file = write_init_bin_file(config_obj, "my_tracer_inits", tracer_name*"_init.bin", data)
    # update the proper parameter in the namelist files 
    tracer_id = tracer_name_to_id(tracer_name)
    update_ptracers_initialFile(config_obj, tracer_id, output_file)
    return data
end # function 

"""
    init_tracer_grid(config_obj, tracer_name, init_matrix)

Create a bin file of initial values for a tracer. For a grid of size (X, Y), the initial conditions for each grid cell are
set in a binary file with X*Y number of floats, in big-endian format, with no headers.

# Arguments 
- config_obj
- tracer_name: String 
- init_matrix: 2D list of values to write to the bin file 

Returns 
- the matrix of initial values 
"""
function init_tracer_grid(config_obj, tracer_name, init_matrix)
    output_file = write_init_bin_file(config_obj, "my_tracer_inits", tracer_name*"_init.bin", init_matrix)
    # update the proper parameter in the namelist files 
    tracer_id = tracer_name_to_id(tracer_name)
    update_ptracers_initialFile(config_obj, tracer_id, output_file)
    return init_matrix
end # function 

"""
    init_temperature_grid(config_obj, tracer_name, init_list, dim, grid_size=(5,3))

Create a bin file of initial values for temperature. For a grid of size (X, Y), the initial conditions for each grid cell are
set in a binary file with X*Y number of floats, in big-endian format, with no headers.

# Arguments 
- config_obj
- tracer_name: String 
- init_list: list of values to initialize the temperature to 
- dim: "x" or "y" - which dimension to set to the list; values won't change along the other axis 
- grid_size: tuple ints, default 2x2

Returns 
- the matrix of initial values 
"""
function init_temperature_grid(config_obj, init_list, dim, grid_size=(2,2))
    # check that init_list is the same length as the dim of grid size
    if (length(init_list) != grid_size[1]) && (length(init_list) != grid_size[2])
        throw(ArgumentError("init_list must be the same length as one dimension of the grid"))
    end
    # create the matrix
    data = Matrix{Float32}(undef,grid_size...)
    if dim=="x"
        # the x-axis is assigned to the init_list
        # repeated over the y axis 
        data[:,:] = transpose(repeat(init_list,grid_size[2],1))
    elseif dim=="y"
        # the y-axis is assigned to the init_list
        # repeated over the x axis 
        data[:,:] = transpose(repeat(init_list,1,grid_size[1]))
    end
    output_file = write_init_bin_file(config_obj, "temperature", "temperature_init.bin", data)
    # update the proper parameter in the namelist files 
    update_temperature_initialFile(config_obj, output_file)
    return data
end # function 

"""
    init_temperature_grid(config_obj, tracer_name, init_matrix)

Create a bin file of initial values for temperature. For a grid of size (X, Y), the initial conditions for each grid cell are
set in a binary file with X*Y number of floats, in big-endian format, with no headers.

# Arguments 
- config_obj
- init_matrix: 2D list of values to write to the bin file 

Returns 
- the matrix of initial values 
"""
function init_temperature_grid(config_obj, init_matrix)
    output_file = write_init_bin_file(config_obj, "temperature", "temperature_init.bin", init_matrix)
    # update the proper parameter in the namelist files 
    update_temperature_initialFile(config_obj, output_file)
    return init_matrix
end # function 

"""
TODO
note: made specifically for selecting range of latitudes and times at fixed x and z
"""
function init_radtrans_grid(config_obj, ds, x, y_range, z, t_range)
    # for each radtrands band....
    for i in 1:13
        if i < 10
            ed_param_name = "RT_EdFile( $i)"
            es_param_name = "RT_EsFile( $i)"
        else
            ed_param_name = "RT_EdFile($i)"
            es_param_name = "RT_EsFile($i)"
        end
        ed = ed_id_to_name(i)
        es = es_id_to_name(i)
        println(ed, es)
        ed_matrix = ds[ed][x,y_range,z,t_range]
        es_matrix = ds[es][x,y_range,z,t_range]
        ed_output_file = write_init_bin_file(config_obj, "par", "ed$i.bin", transpose(ed_matrix))
        es_output_file = write_init_bin_file(config_obj, "par", "es$i.bin", transpose(es_matrix))
        println(ed_output_file, es_output_file)
        update_radtrans_initialFile(config_obj, ed_param_name, ed_output_file)
        update_radtrans_initialFile(config_obj, es_param_name, es_output_file)
    end # for loop
end # function 