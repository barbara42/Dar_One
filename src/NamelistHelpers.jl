
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

Arguments:
- TODO
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
    tmpfil=joinpath("tracked_parameters",data_file)
    # ClimateModels.git_log_fil(config_obj,tmpfil,"updated $(p_name) parameter file in $(data_file) to $(p_value)")
end # update_param

"""
common time steps in seconds 
"""
@enum SECONDS begin
    one_week=604800 
    two_weeks=604800*2
    month = 2592000
end # enum 

"""
    update_diagnostic_freq(config_obj, diagnostic_num, frequency)   

Speficy a frequency in seconds at which to write to a diagnostic file 

Arguments:
- diagnostic_num: the integer identifier for the diagnostic file you want to modify 
- frequency: new frequency at which to write to that file, in seconds 
- config_obj: the MITgcm_config you are working with 
# TODO: create enums for diagnostic names (and name them better?)
# TODO: what should the initial frequency be? - in file
"""
function update_diagnostic_freq(config_obj, diagnostic_num, frequency)
    update_param(config_obj, "data.diagnostics", "diagnostics_list", "frequency($diagnostic_num)", frequency)
end

"""
    update_temperature(config_obj, new_temp)    

Set the temperature (in celcius). This temperature will be constant throughout the run.
TODO: how do you set a variable temperature? i.e. seasonal?  
# Arguments:
- new_temp: new temperature in celsius 
- config_obj: the MITgcm_config you are working with 
"""
function update_temperature(config_obj, new_temp)
    update_param(config_obj, "data", "PARM01", "tRef", new_temp)
end

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

function update_tracer(config_obj, tracer_num::Int64, new_value::Float32)
    update_param(config_obj, "data.ptracers", "PTRACERS_PARM01", "PTRACERS_ref( :,$tracer_num)", new_value)
end

function update_tracer(config_obj, tracer_num::Int64, new_value::Float64)
    update_param(config_obj, "data.ptracers", "PTRACERS_PARM01", "PTRACERS_ref( :,$tracer_num)", new_value)
end

function update_tracers(config_obj, tracer_ids, ds::NCDataset, x, y, z, t, multiplier=1)
    for tracer_id in tracer_ids
        tracer_name = tracer_id_to_name(tracer_id)
        update_tracer(config_obj, tracer_id, ds[tracer_name][x,y,z,t]*multiplier)
    end
end

function dar_one_run(config_obj)
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
- `config_obj``: the MITgcm_config you are working with 
- `new_val`: amount of FeT for the model's initial condition
"""
function update_FeT(config_obj, new_val)
    update_tracer(config_obj, Int(FeT), new_val)
end

"""
    update_pro(config_obj, new_val)    

# Arguments:
- `config_obj``: the MITgcm_config you are working with 
- `new_val`: amount of Prochlorococcus for the model's initial condition
"""
function update_pro(config_obj, new_val)
    update_tracer(config_obj, Int(Pro), new_val)
end

"""
    update_syn(config_obj, new_val)    

# Arguments:
- `config_obj``: the MITgcm_config you are working with 
- `new_val`: amount of Synechococcus for the model's initial condition
"""
function update_syn(config_obj, new_val)
    update_tracer(config_obj, Int(Syn), new_val)
end