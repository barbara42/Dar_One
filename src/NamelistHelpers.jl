
using NCDatasets

# export update_param
# export update_tracer
# export update_tracers
# export dar_one_run
# export tracer_id_to_name
# export tracer_name_to_id
# export update_diagnostic_freq
# export update_temperature
"""
    update_param(config_obj, file_name, group_name, param_name, new_param_value)  

Speficy a parameter to update  
"""
function update_param(config_obj, file_name, group_name, param_name, new_param_value)
    rundir = joinpath(config_obj.folder, config_obj.ID, "run")
    # read the contents of the data file into a namelist 
    data_file = file_name
    fil = joinpath(rundir, data_file)
    nml = read(fil, MITgcm_namelist())

    # which param group do you want to modify?
    nmlgroup = group_name
    group_idx =findall(nml.groups.==Symbol(nmlgroup))[1]
    parms = nml.params[group_idx]

    # what parameter do you want to modify?
    p_name = param_name
    p_value = new_param_value

    # write changed parameter
    # tmptype= haskey(nml.params[group_idx], Symbol(p_name)) ? typeof(nml.params[group_idx][Symbol(p_name)]) : typeof(p_value)
    #nml.params[group_idx][Symbol(p_name)]=parse(tmptype,p_value)
    nml.params[group_idx][Symbol(p_name)] = p_value
    tmpfil=joinpath(rundir,data_file)
    rm(tmpfil)
    write(tmpfil,nml)
    #tmpfil=joinpath("tracked_parameters",data_file)
    # ClimateModels.git_log_fil(config_obj,tmpfil,"updated $(p_name) parameter file in $(data_file) to $(p_value)")
end # update_param

"""
    update_params(config_obj, file_name, group_names, param_names, new_param_values)  

Update multiple parameters in the same file.
"""
function update_params(config_obj, file_name, group_names, param_names, new_param_values)
    rundir = joinpath(config_obj.folder, config_obj.ID, "run")
    # read the contents of the data file into a namelist 
    data_file = file_name
    fil = joinpath(rundir, data_file)
    nml = read(fil, MITgcm_namelist())

    for i in eachindex(group_names)
        group_name = group_names[i]
        param_name = param_names[i]
        new_param_value = new_param_values[i]

        nmlgroup = group_name
        group_idx =findall(nml.groups.==Symbol(nmlgroup))[1]
        parms = nml.params[group_idx]
    
        # what parameter do you want to modify?
        p_name = param_name
        p_value = new_param_value

        # update param
        nml.params[group_idx][Symbol(p_name)] = p_value
    end
    
    # remove old file and write updated params to new file 
    tmpfil=joinpath(rundir,data_file)
    rm(tmpfil)
    write(tmpfil,nml)
    tmpfil=joinpath("tracked_parameters",data_file)
    # ClimateModels.git_log_fil(config_obj,tmpfil,"updated $(p_name) parameter file in $(data_file) to $(p_value)")
end # update_params

"""
common time steps in seconds 
"""
@enum SECONDS begin
    one_week=604800 
    two_weeks=604800*2
    month = 2592000
    year = 31104000
end # enum 

"""
    update_diagnostic_freq(config_obj, diagnostic_num, frequency)   

Speficy a frequency in seconds at which to write to a diagnostic file 

Arguments:
- diagnostic_num: the integer identifier for the diagnostic file you want to modify 
- frequency: new frequency at which to write to that file, in seconds 
- config_obj: the MITgcm_config you are working with 
"""
function update_diagnostic_freq(config_obj, diagnostic_num, frequency)
    update_param(config_obj, "data.diagnostics", "diagnostics_list", "frequency($diagnostic_num)", frequency)
end
# TODO: create enums for diagnostic names (and name them better?)
# TODO: what should the initial frequency be? - in file

"""
    update_all_diagnostic_freqs(config_obj, frequency)   

Speficy a frequency in seconds at which to write all diagnostic files 

Arguments:
- config_obj: the MITgcm_config you are working with 
- frequency: new frequency at which to write to the files, in seconds 
"""
function update_all_diagnostic_freqs(config_obj, frequency, diagnostic_nums=[1,2,4,5,6,7,8,10,11])
    file_name = "data.diagnostics"
    group_names = repeat(["diagnostics_list"], length(diagnostic_nums))
    param_names = ["frequency($diagnostic_num)" for diagnostic_num in diagnostic_nums]
    new_param_values = repeat([frequency], length(diagnostic_nums))
    update_params(config_obj, file_name, group_names, param_names, new_param_values)
end

"""
    update_temperature(config_obj, new_temp)    

Set the temperature (in celcius). This temperature will be constant throughout the run.
# Arguments:
- new_temp: new temperature in celsius 
- config_obj: the MITgcm_config you are working with 
"""
function update_temperature(config_obj, new_temp)
    update_param(config_obj, "data", "PARM01", "tRef", new_temp)
end
#TODO: how do you set a variable temperature? i.e. seasonal?  


"""
    tracer_id_to_name(id)

Return the string "TRAC"+id      
"""
function tracer_id_to_name(id)
    tracer_id = length(string(id)) < 2 ? "0"*string(id) : string(id)
    tracer_name = "TRAC"*tracer_id 
    return tracer_name
end

"""
    tracer_name_to_id(name)
    
Return the int in the tracer name. i.e. `tracer_name_to_id("TRAC21")` will return 21      
"""
function tracer_name_to_id(name)
    return parse(Int64, name[5:6])
end

"""
    update_tracer(config_obj, tracer_num::Int64, new_value::Float32)

# Arguments 
- `config_id` 
- `tracer_num`
- `new_value`
"""
function update_tracer(config_obj, tracer_num::Int64, new_value::Float32)
    update_param(config_obj, "data.ptracers", "PTRACERS_PARM01", "PTRACERS_ref( :,$tracer_num)", new_value)
end

function update_tracer(config_obj, tracer_num::Int64, new_value::Float64)
    update_param(config_obj, "data.ptracers", "PTRACERS_PARM01", "PTRACERS_ref( :,$tracer_num)", new_value)
end

# TODO: rewrite using update_params 
"""
    update_tracers(config_obj, tracer_ids, ds::NCDataset, x, y, z, t, multiplier=1)

# Arguments 
- `config_obj`
- `tracer_ids`
- `ds`
- x
- y 
- z 
- t
- multiplier
"""
function update_tracers(config_obj, tracer_ids, ds::NCDataset, x, y, z, t, multiplier=1)
    for tracer_id in tracer_ids
        tracer_name = tracer_id_to_name(tracer_id)
        update_tracer(config_obj, tracer_id, ds[tracer_name][x,y,z,t]*multiplier)
    end
end

"""
    update_tracers(config_obj, tracer_ids, values)

takes a list of tracers and list of values
"""
function update_tracers(config_obj, tracer_ids, values)
    file_name = "data.ptracers"
    group_names = repeat(["PTRACERS_PARM01"], length(tracer_ids))
    param_names = ["PTRACERS_ref( :,$tracer_num)" for tracer_num in tracer_ids]
    update_params(config_obj, file_name, group_names, param_names, values)
    # for i in 1:length(tracer_ids)
    #     tracer_name = tracer_id_to_name(tracer_id[i])
    #     update_tracer(config_obj, tracer_id, values[i])
    # end
end

function dar_one_run(config_obj)
    rundir = joinpath(config_obj.folder, config_obj.ID, "run")
    @info "$(Threads.threadid()) launching..."
    t = @elapsed begin
        MITgcm_launch(config_obj)
    end
    @info "$(Threads.threadid()) run completed"
    @info "$(Threads.threadid()) time elapsed: $(t) seconds"
    @info "$(Threads.threadid()) Output in directory $(rundir), most recent ecco folder "
    # TODO: print out the subfolder (i.e. "ecco_gud_DATE_0001")
end

# nutrients (name -> tracer id)
@enum TRACER_IDS begin
    # DIC = "TRAC01"
    # NO3 = "TRAC02"
    # NO3 = "TRAC03"
    # NH4 = "TRAC04"
    # PO4 = "TRAC05"
    # FeT = "TRAC06"
    # SiO2 = "TRAC07"
    # DOC = "TRAC08"
    # DON = "TRAC09"
    # DOP = "TRAC10"
    # DOFe = "TRAC11"
    # POC = "TRAC12"
    # PON = "TRAC13" 
    # POP = "TRAC14"
    # POFe  = "TRAC15"
    # POSi = "TRAC16"
    # PIC = "TRAC17"
    # ALK = "TRAC18"
    # O2 = "TRAC19"
    # CDOM = "TRAC20"
    DIC = 1
    NO3 = 2
    NO2 = 3
    NH4 = 4
    PO4 = 5
    FeT = 6
    SiO2 = 7
    DOC = 8
    DON = 9
    DOP = 10
    DOFe = 11
    POC = 12
    PON = 13 
    POP = 14
    POFe  = 15
    POSi = 16
    PIC = 17
    ALK = 18
    O2 = 19
    CDOM = 20
    Pro=21
    Syn = 22
end 

"""
    create_MITgcm_config(config_id)

Arguments:
- config_id: unique name for your dar_one run  

Returns
- config_obj::MITgcm_config
- rundir::AbstractString - folder where output will be 
"""
function create_MITgcm_config(config_id::AbstractString)
    config_name = base_configuration
    println("mitgcm path ", MITgcm_path[1])
    println("base configuration = ", base_configuration)
    folder = joinpath(MITgcm_path[1], "verification/$(config_name)/run")
    config_obj = MITgcm_config(configuration=config_name, ID=config_id, folder=folder)
    rundir = joinpath(folder, config_id, "run")
    return config_obj, rundir 
end

"""
    update_end_time(end_time, config_obj)    

Set how long the simulation will run, in iterations. Each iteration is 3 hours, or 10800 seconds.
One year is 2880 iterations, which is the default. 

# Arguments:
- end_time: how many iterations to run the model for
- config_obj: the MITgcm_config you are working with 
"""
function update_end_time(config_obj, end_time)
    update_param(config_obj, "data", "PARM03", "nenditer", end_time)
end

"""
    update_NO3(config_obj, new_val)    

# Arguments:
- `config_obj``: the MITgcm_config you are working with 
- `new_val`: amount of NO3 for the model's initial condition
"""
function update_NO3(config_obj, new_val)
    update_tracer(config_obj,Int(NO3), new_val)
end

"""
    update_NO2(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of NO2 for the model's initial condition
"""
function update_NO2(config_obj, new_val)
    update_tracer(config_obj, Int(NO2), new_val)
end

"""
    update_NH4(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of NH4 for the model's initial condition
"""
function update_NH4(config_obj, new_val)
    update_tracer(config_obj, Int(NH4), new_val)
end

"""
    update_PO4(config_obj, new_val)    

# Arguments:
- `config_obj``: the MITgcm_config you are working with 
- `new_val`: amount of PO4 for the model's initial condition
"""
function update_PO4(config_obj, new_val)
    update_tracer(config_obj, Int(PO4), new_val)
end

"""
    update_FeT(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of FeT for the model's initial condition
"""
function update_FeT(config_obj, new_val)
    update_tracer(config_obj, Int(FeT), new_val)
end

"""
    update_SiO2(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of SiO2 for the model's initial condition
"""
function update_SiO2(config_obj, new_val)
    update_tracer(config_obj, Int(SiO2), new_val)
end

"""
    update_DOC(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of DOC for the model's initial condition
"""
function update_DOC(config_obj, new_val)
    update_tracer(config_obj, Int(DOC), new_val)
end

"""
    update_DON(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of DON for the model's initial condition
"""
function update_DON(config_obj, new_val)
    update_tracer(config_obj, Int(DON), new_val)
end

"""
    update_DOP(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of DOP for the model's initial condition
"""
function update_DOP(config_obj, new_val)
    update_tracer(config_obj, Int(DOP), new_val)
end

"""
    update_DOFe(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of DOFe for the model's initial condition
"""
function update_DOFe(config_obj, new_val)
    update_tracer(config_obj, Int(DOFe), new_val)
end

"""
    update_POC(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of POC for the model's initial condition
"""
function update_POC(config_obj, new_val)
    update_tracer(config_obj, Int(POC), new_val)
end

"""
    update_PON(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of PON for the model's initial condition
"""
function update_PON(config_obj, new_val)
    update_tracer(config_obj, Int(PON), new_val)
end

"""
    update_POP(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of POP for the model's initial condition
"""
function update_POP(config_obj, new_val)
    update_tracer(config_obj, Int(POP), new_val)
end

"""
    update_POFe(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of POFe for the model's initial condition
"""
function update_POFe(config_obj, new_val)
    update_tracer(config_obj, Int(POFe), new_val)
end

"""
    update_POSi(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of POSi for the model's initial condition
"""
function update_POSi(config_obj, new_val)
    update_tracer(config_obj, Int(POSi), new_val)
end

"""
    update_PIC(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of PIC for the model's initial condition
"""
function update_PIC(config_obj, new_val)
    update_tracer(config_obj, Int(PIC), new_val)
end

"""
    update_ALK(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of ALK for the model's initial condition (note: it will equalize through air-sea exchange)
"""
function update_ALK(config_obj, new_val)
    update_tracer(config_obj, Int(ALK), new_val)
end

"""
    update_O2(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of O2 for the model's initial condition (note: it will equalize through air-sea exchange)
"""
function update_O2(config_obj, new_val)
    update_tracer(config_obj, Int(O2), new_val)
end

"""
    update_CDOM(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of CDOM for the model's initial condition 
"""
function update_CDOM(config_obj, new_val)
    update_tracer(config_obj, Int(CDOM), new_val)
end

"""
    update_pro(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of Prochlorococcus for the model's initial condition
"""
function update_pro(config_obj, new_val)
    update_tracer(config_obj, Int(Pro), new_val)
end

"""
    update_syn(config_obj, new_val)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of Synechococcus for the model's initial condition
"""
function update_syn(config_obj, new_val)
    update_tracer(config_obj, Int(Syn), new_val)
end

"""
    update_radtrans(config_obj, ds::NCDataset, x, y, z, t)    

# Arguments:
- `config_obj`: the MITgcm_config you are working with 
- `new_val`: amount of Synechococcus for the model's initial condition
"""
function update_radtrans(config_obj, ds::NCDataset, x, y, z, t)
    file_name = "data.radtrans"
    group_names = repeat(["RADTRANS_FORCING_PARAMS"], 26)
    param_names = []
    new_param_values = []
    for i in 1:13
        if i < 10
            ed_param_name = "RT_Ed_const( $i)"
            es_param_name = "RT_Es_const( $i)"
        else
            ed_param_name = "RT_Ed_const($i)"
            es_param_name = "RT_Es_const($i)"
        end
        ed = ed_id_to_name(i)
        es = es_id_to_name(i)
        ed_val = ds[ed][x,y,z,t]
        es_val = ds[es][x,y,z,t]
        append!(param_names, [ed_param_name, es_param_name])
        append!(new_param_values, [ed_val, es_val])
    end
    update_params(config_obj, file_name, group_names, param_names, new_param_values)
end


"""
    es_id_to_name(id)

Return the string "Es"+id      
"""
function es_id_to_name(id)
    radtrans_id = length(string(id)) < 2 ? "00"*string(id) : "0"*string(id)
    radtrans_name = "Es"*radtrans_id 
    return radtrans_name
end

"""
    ed_id_to_name(id)

Return the string "Ed"+id      
"""
function ed_id_to_name(id)
    radtrans_id = length(string(id)) < 2 ? "00"*string(id) : "0"*string(id)
    radtrans_name = "Ed"*radtrans_id 
    return radtrans_name
end

"""
    update_ptracers_initialFile(config_obj, tracer_id, new_val)
"""
function update_ptracers_initialFile(config_obj, tracer_id, new_val)
    file_name = "data.ptracers"
    group_name = "PTRACERS_PARM01"
    param_name = tracer_id>9 ? "PTRACERS_initialFile( $tracer_id)" : "PTRACERS_initialFile(  $tracer_id)"
    update_param(config_obj, file_name, group_name, param_name, new_val)
end

"""
    update_temperature_initialFile(config_obj, new_val)
"""
function update_temperature_initialFile(config_obj, new_val)
    file_name = "data"
    group_name = "PARM05"
    param_name = "hydrogThetaFile"
    update_param(config_obj, file_name, group_name, param_name, new_val)
end

"""
    update_radtrans_initialFile(config_obj, param_name, new_val)
"""
function update_radtrans_initialFile(config_obj, param_name, new_val)
    file_name = "data.radtrans"
    group_name = "RADTRANS_FORCING_PARAMS"
    update_param(config_obj, file_name, group_name, param_name, new_val)
end

"""
    update_delX_delY_for_grid(config_obj, x_size, y_size)
"""
function update_delX_delY_for_grid(config_obj, x_size, y_size)
    file_name = "data"
    group_names = repeat(["PARM04"], 2)
    param_names = ["delX", "delY"]
    new_param_values = ["$x_size*1.E0", "$y_size*1.E0"]
    update_params(config_obj, file_name, group_names, param_names, new_param_values)
end

"""
Update the palatability matrix for grazer preference where PALAT(X,Y) := rate at which predator Y eats prey X

"""
function write_palat_matrix(config_obj, matrix)
    # note: PALAT(X,Y) := rate at which predator Y eats prey X
    # load up file like above 
    file_name = "data.traits"
    group_name = "DARWIN_TRAITS"
    rundir = joinpath(config_obj.folder, config_obj.ID, "run")
    # read the contents of the data file into a namelist 
    data_file = file_name
    fil = joinpath(rundir, data_file)
    nml = read(fil, MITgcm_namelist())
    # which param group do you want to modify?
    nmlgroup = group_name
    group_idx =findall(nml.groups.==Symbol(nmlgroup))[1]
    parms = nml.params[group_idx]

    # remove all lines with form PALAT()
    for key in keys(parms)
        if occursin("PALAT(", String(key)) 
            # remove entry 
            delete!(parms, key)
        end
    end

    # TODO: faster way to do this? element-wise?
    # add new palat key-element pairs to dictionary
    for x in 1:length(matrix[:, 1])
        for y in 1:length(matrix[1, :]) 
            if matrix[x,y] != 0 #(don't write if 0)
                key = "PALAT($x, $y)"
                parms[Symbol(key)] = matrix[x, y]
            end
        end
    end

    # write to file 
    nml.params[group_idx] = parms
    temp_file =fil
    write(temp_file, nml)
end
